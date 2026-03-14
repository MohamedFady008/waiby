import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livekit_client/livekit_client.dart';

import '../core/store/live_gift_catalog.dart';
import '../data/models/live_room_models.dart';
import '../services/live_room_service.dart';

class LiveRoomPage extends StatefulWidget {
  final bool isHost;
  final String? roomId;
  final String? roomName;
  final String? tagline;
  final String? language;
  final String? tags;
  final String? atmosphereImageUrl;
  final String? overviewImageUrl;
  final String? pinnedMessage;
  final String visibility;
  final bool giftGoalEnabled;
  final double? giftGoalBuds;

  const LiveRoomPage({
    super.key,
    this.isHost = false,
    this.roomId,
    this.roomName,
    this.tagline,
    this.language,
    this.tags,
    this.atmosphereImageUrl,
    this.overviewImageUrl,
    this.pinnedMessage,
    this.visibility = 'public',
    this.giftGoalEnabled = false,
    this.giftGoalBuds,
  });

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final LiveRoomService _liveRoomService = LiveRoomService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  Room? _room;
  EventsListener<RoomEvent>? _roomListener;
  LiveRoomJoinSession? _session;

  bool _joining = true;
  bool _leaving = false;
  bool _sendingMessage = false;
  bool _sendingGift = false;
  bool _micEnabled = false;
  bool _cameraEnabled = false;
  bool _screenShareEnabled = false;
  bool _audioPlaybackRequired = false;
  bool _handledEndedRoom = false;
  bool _showViewerList = false;
  String? _errorText;
  double? _giftBalanceOverride;

  String _slugify(String raw) {
    final normalized = raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (normalized.isEmpty) return 'waiby-live';
    return normalized.substring(0, math.min(normalized.length, 64));
  }

  String get _resolvedRoomId =>
      _slugify(widget.roomId ?? widget.roomName ?? 'waiby-live');

  List<String> get _requestedTags {
    final raw = widget.tags?.trim();
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw
        .split(RegExp(r'[\s,]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _describeDisconnectReason(DisconnectReason? reason) {
    if (reason == null || reason == DisconnectReason.unknown) {
      return 'You were disconnected from the live room.';
    }
    final humanized = reason.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)!.toLowerCase()}',
        )
        .trim();
    return 'Disconnected from the live room ($humanized).';
  }

  @override
  void initState() {
    super.initState();
    unawaited(_joinLiveRoom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    unawaited(_leaveRoom(markEnded: false, navigateAway: false));
    super.dispose();
  }

  Future<void> _joinLiveRoom() async {
    setState(() {
      _joining = true;
      _errorText = null;
    });
    try {
      final session = await _liveRoomService.joinRoom(
        roomId: _resolvedRoomId,
        roomName: widget.roomName?.trim().isNotEmpty == true
            ? widget.roomName
            : null,
        role: widget.isHost ? 'host' : 'joiner',
        tagline: widget.tagline?.trim().isNotEmpty == true
            ? widget.tagline
            : null,
        language: widget.language?.trim().isNotEmpty == true
            ? widget.language
            : null,
        tags: _requestedTags.isEmpty ? null : _requestedTags,
        atmosphereImageUrl: widget.atmosphereImageUrl?.trim().isNotEmpty == true
            ? widget.atmosphereImageUrl
            : null,
        overviewImageUrl: widget.overviewImageUrl?.trim().isNotEmpty == true
            ? widget.overviewImageUrl
            : null,
        visibility: widget.visibility == 'private' ? 'private' : 'public',
        pinnedMessage: widget.pinnedMessage?.trim().isNotEmpty == true
            ? widget.pinnedMessage
            : null,
        giftGoalEnabled: widget.giftGoalEnabled,
        giftGoalBuds: widget.giftGoalBuds,
      );

      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );
      final listener = room.createListener();

      room.addListener(_onRoomUpdated);
      listener
        ..on<RoomDisconnectedEvent>((event) {
          if (!mounted || _leaving || _joining) return;
          setState(() {
            _errorText = _describeDisconnectReason(event.reason);
          });
        })
        ..on<AudioPlaybackStatusChanged>((_) {
          if (!mounted) return;
          setState(() => _audioPlaybackRequired = !room.canPlaybackAudio);
        })
        ..on<LocalTrackPublishedEvent>((_) => unawaited(_syncPresence()))
        ..on<LocalTrackUnpublishedEvent>((_) => unawaited(_syncPresence()))
        ..on<ParticipantConnectedEvent>((_) => setState(() {}))
        ..on<ParticipantDisconnectedEvent>((_) => setState(() {}))
        ..on<TrackPublishedEvent>((_) => setState(() {}))
        ..on<TrackUnpublishedEvent>((_) => setState(() {}));

      try {
        await room.prepareConnection(session.livekitUrl, session.token);
        await room.connect(session.livekitUrl, session.token);
      } catch (error) {
        room.removeListener(_onRoomUpdated);
        await listener.dispose();
        await room.dispose();
        throw LiveRoomException('LiveKit connection failed: $error');
      }

      _room = room;
      _roomListener = listener;
      _session = session;

      if (session.isHost) {
        try {
          await room.localParticipant?.setMicrophoneEnabled(true);
          _micEnabled = true;
        } catch (_) {
          _micEnabled = false;
        }
      }

      await _liveRoomService.joinParticipantPresence(
        roomId: session.roomId,
        isHost: session.isHost,
        micEnabled: _micEnabled,
        cameraEnabled: _cameraEnabled,
        screenShareEnabled: _screenShareEnabled,
      );

      if (!mounted) return;
      setState(() => _joining = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _joining = false;
        _errorText = error.toString();
      });
    }
  }

  void _onRoomUpdated() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _syncPresence() async {
    final room = _room;
    final session = _session;
    final localParticipant = room?.localParticipant;
    if (session == null || localParticipant == null) return;

    final nextMicEnabled = localParticipant.isMicrophoneEnabled();
    final nextCameraEnabled = localParticipant.isCameraEnabled();
    final nextScreenShareEnabled = localParticipant.isScreenShareEnabled();

    setState(() {
      _micEnabled = nextMicEnabled;
      _cameraEnabled = nextCameraEnabled;
      _screenShareEnabled = nextScreenShareEnabled;
    });

    try {
      await _liveRoomService.updateParticipantPresence(
        roomId: session.roomId,
        micEnabled: nextMicEnabled,
        cameraEnabled: nextCameraEnabled,
        screenShareEnabled: nextScreenShareEnabled,
      );
    } catch (_) {}
  }

  Future<void> _toggleMicrophone() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) return;
    try {
      await localParticipant.setMicrophoneEnabled(!_micEnabled);
      await _syncPresence();
    } catch (error) {
      _showSnack('Could not update microphone: $error');
    }
  }

  Future<void> _toggleCamera() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) return;
    try {
      await localParticipant.setCameraEnabled(!_cameraEnabled);
      await _syncPresence();
    } catch (error) {
      _showSnack('Could not update camera: $error');
    }
  }

  Future<void> _toggleScreenShare() async {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) return;
    try {
      await localParticipant.setScreenShareEnabled(!_screenShareEnabled);
      await _syncPresence();
    } catch (error) {
      _showSnack('Could not update screen share: $error');
    }
  }

  Future<void> _startAudioPlayback() async {
    final room = _room;
    if (room == null) return;
    try {
      await room.startAudio();
      if (!mounted) return;
      setState(() => _audioPlaybackRequired = false);
    } catch (error) {
      _showSnack('Could not start room audio: $error');
    }
  }

  Future<void> _sendMessage() async {
    final session = _session;
    final text = _messageController.text.trim();
    if (session == null || text.isEmpty || _sendingMessage) return;
    setState(() => _sendingMessage = true);
    try {
      await _liveRoomService.sendTextMessage(
        roomId: session.roomId,
        text: text,
      );
      _messageController.clear();
      _scrollMessagesToBottom();
    } catch (error) {
      _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _sendingMessage = false);
    }
  }

  Future<void> _copyInviteLink() async {
    final session = _session;
    if (session == null) return;
    final inviteUrl = _liveRoomService.resolveInviteUrl(
      session.roomId,
      roomName: session.roomName,
    );
    await Clipboard.setData(ClipboardData(text: inviteUrl));
    _showSnack('Invite link copied.');
  }

  Future<void> _leaveWithConfirmation() async {
    final session = _session;
    if (session == null) {
      if (mounted) context.go('/playground');
      return;
    }
    final shouldLeave = await _showLeaveLiveDialog(
      context,
      isHost: session.isHost,
    );
    if (shouldLeave != true) return;
    await _leaveRoom(markEnded: session.isHost, navigateAway: true);
  }

  Future<void> _leaveRoom({
    required bool markEnded,
    required bool navigateAway,
  }) async {
    if (_leaving) return;
    _leaving = true;
    final session = _session;
    final room = _room;
    final listener = _roomListener;
    try {
      if (session != null) {
        try {
          if (markEnded && session.isHost) {
            await _liveRoomService.endRoom(session.roomId);
          }
        } catch (_) {}
        try {
          await _liveRoomService.leaveParticipantPresence(session.roomId);
        } catch (_) {}
      }
      try {
        await room?.disconnect();
      } catch (_) {}
      room?.removeListener(_onRoomUpdated);
      await listener?.dispose();
      await room?.dispose();
    } finally {
      _room = null;
      _roomListener = null;
      _session = null;
      _leaving = false;
    }
    if (navigateAway && mounted) context.go('/playground');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollMessagesToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  VideoTrack? _trackForSource(Participant participant, TrackSource source) {
    final publication = participant.getTrackPublicationBySource(source);
    final track = publication?.track;
    return track is VideoTrack ? track : null;
  }

  _ParticipantMetadata _participantMetadata(Participant participant) {
    final raw = participant.metadata?.trim();
    if (raw == null || raw.isEmpty) return const _ParticipantMetadata();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const _ParticipantMetadata();
      return _ParticipantMetadata(
        isHost: decoded['isHost'] == true,
        avatarUrl: decoded['avatarUrl']?.toString().trim() ?? '',
      );
    } catch (_) {
      return const _ParticipantMetadata();
    }
  }

  List<_ParticipantTileData> _participantTiles(Room room) {
    final tiles = <_ParticipantTileData>[];

    void collect(Participant participant) {
      final metadata = _participantMetadata(participant);
      final cameraTrack = _trackForSource(participant, TrackSource.camera);
      final screenTrack = _trackForSource(
        participant,
        TrackSource.screenShareVideo,
      );
      if (screenTrack != null) {
        tiles.add(
          _ParticipantTileData(
            participant: participant,
            videoTrack: screenTrack,
            isScreenShare: true,
            isHost: metadata.isHost,
            avatarUrl: metadata.avatarUrl,
          ),
        );
      }
      tiles.add(
        _ParticipantTileData(
          participant: participant,
          videoTrack: cameraTrack,
          isScreenShare: false,
          isHost: metadata.isHost,
          avatarUrl: metadata.avatarUrl,
        ),
      );
    }

    final local = room.localParticipant;
    if (local != null) collect(local);
    for (final participant in room.remoteParticipants.values) {
      collect(participant);
    }

    tiles.sort((a, b) {
      if (a.isScreenShare != b.isScreenShare) return a.isScreenShare ? -1 : 1;
      if (a.isHost != b.isHost) return a.isHost ? -1 : 1;
      if (a.participant.isSpeaking != b.participant.isSpeaking) {
        return a.participant.isSpeaking ? -1 : 1;
      }
      return a.participant.joinedAt.compareTo(b.participant.joinedAt);
    });
    return tiles;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double _giftGoalProgressBuds(List<LiveRoomMessageRecord> messages) {
    return messages.fold<double>(
      0,
      (total, message) => total + (message.giftTotalBuds ?? 0),
    );
  }

  List<_GiftLeaderboardEntry> _topGifters(
    List<LiveRoomMessageRecord> messages,
  ) {
    final totals = <String, _GiftLeaderboardEntry>{};
    for (final message in messages) {
      if (!message.isGift) continue;
      final totalBuds = message.giftTotalBuds ?? 0;
      if (totalBuds <= 0) continue;
      final key = message.senderId.isNotEmpty
          ? message.senderId
          : message.senderName;
      final previous = totals[key];
      totals[key] = _GiftLeaderboardEntry(
        userId: key,
        displayName: message.senderName,
        avatarUrl: message.senderAvatarUrl,
        totalBuds: (previous?.totalBuds ?? 0) + totalBuds,
      );
    }
    final ranked = totals.values.toList(growable: false)
      ..sort((a, b) => b.totalBuds.compareTo(a.totalBuds));
    return ranked.take(4).toList(growable: false);
  }

  Future<void> _showGiftSheet(double balanceBuds) async {
    final session = _session;
    if (session == null || _sendingGift) return;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (session.hostId.isEmpty || session.hostId == currentUserId) {
      _showSnack('Only viewers can gift the host.');
      return;
    }

    final selection = await showModalBottomSheet<_GiftSelection>(
      context: context,
      backgroundColor: const Color(0xFF0A1024),
      isScrollControlled: true,
      builder: (context) => _GiftPickerSheet(balanceBuds: balanceBuds),
    );
    if (selection == null) return;

    setState(() => _sendingGift = true);
    try {
      final result = await _liveRoomService.sendGift(
        roomId: session.roomId,
        giftId: selection.gift.id,
        multiplier: selection.multiplier,
      );
      if (!mounted) return;
      setState(() => _giftBalanceOverride = result.senderBudsBalance);
      _showSnack('Gift sent to ${session.hostName}.');
    } catch (error) {
      _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _sendingGift = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_leaveWithConfirmation());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050816),
        body: _joining
            ? const Center(child: CircularProgressIndicator())
            : _errorText != null
            ? _ErrorState(message: _errorText!, onRetry: _joinLiveRoom)
            : _buildRoomScaffold(),
      ),
    );
  }

  Widget _buildRoomScaffold() {
    final session = _session!;
    final room = _room!;
    final participantTiles = _participantTiles(room);

    return StreamBuilder<LiveRoomRecord?>(
      stream: _liveRoomService.watchRoom(session.roomId),
      builder: (context, roomSnapshot) {
        final roomRecord = roomSnapshot.data;

        if (roomRecord?.status == 'ended' &&
            !_handledEndedRoom &&
            !session.isHost) {
          _handledEndedRoom = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _showSnack('The host ended the live room.');
            await _leaveRoom(markEnded: false, navigateAway: true);
          });
        }

        return StreamBuilder<List<LiveRoomParticipantRecord>>(
          stream: _liveRoomService.watchParticipants(session.roomId),
          builder: (context, participantsSnapshot) {
            final participants =
                participantsSnapshot.data ??
                const <LiveRoomParticipantRecord>[];

            return StreamBuilder<List<LiveRoomMessageRecord>>(
              stream: _liveRoomService.watchMessages(session.roomId),
              builder: (context, messagesSnapshot) {
                final messages =
                    messagesSnapshot.data ?? const <LiveRoomMessageRecord>[];
                _scrollMessagesToBottom();
                final giftLeaderboard = _topGifters(messages);
                final giftGoalProgressBuds = _giftGoalProgressBuds(messages);

                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: currentUserId == null
                      ? const Stream<
                          DocumentSnapshot<Map<String, dynamic>>
                        >.empty()
                      : FirebaseFirestore.instance
                            .collection('wallets')
                            .doc(currentUserId)
                            .snapshots(),
                  builder: (context, walletSnapshot) {
                    final walletData = walletSnapshot.data?.data();
                    final liveBalance = _toDouble(
                      walletData?['buds_balance'] ??
                          walletData?['balance_buds'],
                    );
                    final giftBalance = _giftBalanceOverride ?? liveBalance;

                    final resolvedHostName =
                        roomRecord?.hostName.isNotEmpty == true
                        ? roomRecord!.hostName
                        : session.hostName;
                    final resolvedHostAvatar =
                        roomRecord?.hostAvatarUrl.isNotEmpty == true
                        ? roomRecord!.hostAvatarUrl
                        : session.hostAvatarUrl;
                    final resolvedTitle =
                        roomRecord?.roomName ?? session.roomName;
                    final resolvedPinnedMessage =
                        roomRecord?.pinnedMessage.isNotEmpty == true
                        ? roomRecord!.pinnedMessage
                        : session.pinnedMessage;
                    final resolvedAtmosphereImageUrl =
                        roomRecord?.atmosphereImageUrl.isNotEmpty == true
                        ? roomRecord!.atmosphereImageUrl
                        : session.atmosphereImageUrl;
                    final goalTargetBuds =
                        roomRecord?.giftGoalBuds ?? session.giftGoalBuds;

                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0B0E24), Color(0xFF060818)],
                        ),
                      ),
                      child: Column(
                        children: [
                          // ── Thin top bar: room name + participant count + actions ──
                          _LiveRoomTopBar(
                            title: resolvedTitle,
                            hostName: resolvedHostName,
                            hostAvatarUrl: resolvedHostAvatar,
                            participantCount: participants.length,
                            isHost: session.isHost,
                            onInvite: _copyInviteLink,
                            onLeave: _leaveWithConfirmation,
                          ),
                          if (_audioPlaybackRequired)
                            _InfoBanner(
                              icon: Icons.volume_up_rounded,
                              color: const Color(0xFF2F88FF),
                              text: 'Tap to start room audio playback.',
                              actionLabel: 'Start audio',
                              onAction: _startAudioPlayback,
                            ),
                          // ── Main content area ──
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                18,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final showLeftRail =
                                      constraints.maxWidth >= 1180;
                                  final showDockedChat =
                                      constraints.maxWidth >= 920;

                                  final utilityColumn = _LiveRoomUtilityColumn(
                                    hostName: resolvedHostName,
                                    hostAvatarUrl: resolvedHostAvatar,
                                    giftLeaderboard: giftLeaderboard,
                                    showGiftButton: !session.isHost,
                                    sendingGift: _sendingGift,
                                    onGift: !session.isHost
                                        ? () => _showGiftSheet(giftBalance)
                                        : null,
                                  );

                                  final chatPanel = _LiveRoomChatPanel(
                                    showViewerList: _showViewerList,
                                    onShowChat: () =>
                                        setState(() => _showViewerList = false),
                                    onShowViewers: () =>
                                        setState(() => _showViewerList = true),
                                    hostName: resolvedHostName,
                                    pinnedMessage: resolvedPinnedMessage,
                                    goalTargetBuds: goalTargetBuds,
                                    goalProgressBuds: giftGoalProgressBuds,
                                    participants: participants,
                                    messages: messages,
                                    messageController: _messageController,
                                    messageScrollController:
                                        _messageScrollController,
                                    sendingMessage: _sendingMessage,
                                    onSendMessage: _sendMessage,
                                  );

                                  if (showDockedChat) {
                                    return Column(
                                      children: [
                                        Expanded(
                                          child: _LiveRoomSurface(
                                            atmosphereImageUrl:
                                                resolvedAtmosphereImageUrl,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                if (showLeftRail) ...[
                                                  SizedBox(
                                                    width: 248,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16,
                                                          ),
                                                      child: utilityColumn,
                                                    ),
                                                  ),
                                                  const _SurfaceDivider(),
                                                ],
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          18,
                                                        ),
                                                    child: _buildStage(
                                                      session: session,
                                                      participantTiles:
                                                          participantTiles,
                                                      giftBalance: giftBalance,
                                                    ),
                                                  ),
                                                ),
                                                const _SurfaceDivider(),
                                                SizedBox(
                                                  width: 328,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    child: chatPanel,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!showLeftRail) ...[
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            height: 238,
                                            child: _PanelSurface(
                                              child: utilityColumn,
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  }

                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 560,
                                          child: _LiveRoomSurface(
                                            atmosphereImageUrl:
                                                resolvedAtmosphereImageUrl,
                                            child: Padding(
                                              padding: const EdgeInsets.all(18),
                                              child: _buildStage(
                                                session: session,
                                                participantTiles:
                                                    participantTiles,
                                                giftBalance: giftBalance,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 420,
                                          child: _PanelSurface(
                                            child: chatPanel,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 238,
                                          child: _PanelSurface(
                                            child: utilityColumn,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStage({
    required LiveRoomJoinSession session,
    required List<_ParticipantTileData> participantTiles,
    required double giftBalance,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: participantTiles.isEmpty
              ? _EmptyStageCard(hostName: session.hostName)
              : _ParticipantStageGrid(
                  participantTiles: participantTiles,
                  hostName: session.hostName,
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: _ControlBar(
            micEnabled: _micEnabled,
            cameraEnabled: _cameraEnabled,
            screenShareEnabled: _screenShareEnabled,
            sendingGift: _sendingGift,
            showGiftButton: !session.isHost,
            onToggleMic: _toggleMicrophone,
            onToggleCamera: _toggleCamera,
            onToggleScreenShare: _toggleScreenShare,
            onGift: () => _showGiftSheet(giftBalance),
            onLeave: _leaveWithConfirmation,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar (thin, compact)
// ─────────────────────────────────────────────────────────────────────────────

class _LiveRoomTopBar extends StatelessWidget {
  final String title;
  final String hostName;
  final String hostAvatarUrl;
  final int participantCount;
  final bool isHost;
  final VoidCallback onInvite;
  final VoidCallback onLeave;

  const _LiveRoomTopBar({
    required this.title,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.participantCount,
    required this.isHost,
    required this.onInvite,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1028),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF472B6), Color(0xFF9333EA)],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: hostAvatarUrl.trim().isNotEmpty
                  ? Image.network(
                      hostAvatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          const SizedBox(width: 10),
          // Room name + host meta
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$hostName · $participantCount views',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _liveCapsule(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          _HeaderActionButton(
            onTap: onInvite,
            background: const Color(0xFF1B234B),
            icon: Icons.link_rounded,
            tooltip: 'Copy invite link',
          ),
          const SizedBox(width: 6),
          _HeaderActionButton(
            onTap: onLeave,
            background: const Color(0x332C1111),
            borderColor: const Color(0x55942424),
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFB44747),
            tooltip: isHost ? 'End live' : 'Leave live',
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFF171D37),
    alignment: Alignment.center,
    child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _liveCapsule() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFFF1D1D),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Live',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}

class _HeaderActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color background;
  final Color? borderColor;
  final IconData icon;
  final Color? iconColor;
  final String tooltip;

  const _HeaderActionButton({
    required this.onTap,
    required this.background,
    this.borderColor,
    required this.icon,
    this.iconColor,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info banner (audio unlock)
// ─────────────────────────────────────────────────────────────────────────────

class _LiveRoomSurface extends StatelessWidget {
  final String atmosphereImageUrl;
  final Widget child;

  const _LiveRoomSurface({
    required this.atmosphereImageUrl,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFCB62FF).withValues(alpha: 0.42),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33D946EF), blurRadius: 32, spreadRadius: -8),
          BoxShadow(
            color: Color(0x2206A3FF),
            blurRadius: 28,
            spreadRadius: -14,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D122B), Color(0xFF070914)],
                ),
              ),
            ),
            if (atmosphereImageUrl.trim().isNotEmpty)
              Image.network(
                atmosphereImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF060818).withValues(alpha: 0.18),
                      const Color(0xFF060818).withValues(alpha: 0.4),
                      const Color(0xFF060818).withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _PanelSurface extends StatelessWidget {
  final Widget child;

  const _PanelSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC0C1026),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }
}

class _SurfaceDivider extends StatelessWidget {
  const _SurfaceDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: Colors.white.withValues(alpha: 0.08));
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left utility column: Top Gifters + Suggested Gifts
// ─────────────────────────────────────────────────────────────────────────────

class _LiveRoomUtilityColumn extends StatelessWidget {
  final String hostName;
  final String hostAvatarUrl;
  final List<_GiftLeaderboardEntry> giftLeaderboard;
  final bool showGiftButton;
  final bool sendingGift;
  final VoidCallback? onGift;

  const _LiveRoomUtilityColumn({
    required this.hostName,
    required this.hostAvatarUrl,
    required this.giftLeaderboard,
    required this.showGiftButton,
    required this.sendingGift,
    required this.onGift,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Column(
        children: [
          // ── Top Gifters ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x9D1A1535),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7B4FCC)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33D946EF),
                  blurRadius: 24,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Top Gifters',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFEFA315),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (giftLeaderboard.isEmpty)
                  Text(
                    'No gifts sent yet.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  )
                else
                  for (final entry in giftLeaderboard) ...[
                    _LeaderboardEntryTile(entry: entry),
                    if (entry != giftLeaderboard.last)
                      const SizedBox(height: 6),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ── Suggested Gifts ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0x9D1A1535),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB744FF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33D946EF),
                  blurRadius: 24,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Gifts',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: math.min(6, liveGiftCatalog.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) =>
                      _SuggestedGiftTile(gift: liveGiftCatalog[index]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: showGiftButton && !sendingGift ? onGift : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7B4FCC),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      showGiftButton
                          ? (sendingGift ? 'Sending...' : 'Send gift')
                          : '$hostName is hosting',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedGiftTile extends StatelessWidget {
  final LiveGiftCatalogItem gift;

  const _SuggestedGiftTile({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Image.asset(gift.assetPath, fit: BoxFit.contain)),
        const SizedBox(height: 4),
        Text(
          gift.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        Text(
          gift.priceBuds.toStringAsFixed(0),
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardEntryTile extends StatelessWidget {
  final _GiftLeaderboardEntry entry;

  const _LeaderboardEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final name = entry.displayName.trim().isEmpty
        ? 'Anonymous'
        : entry.displayName.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF1B234B),
            backgroundImage: entry.avatarUrl.trim().isNotEmpty
                ? NetworkImage(entry.avatarUrl)
                : null,
            child: entry.avatarUrl.trim().isEmpty
                ? Text(
                    name.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${entry.totalBuds.toStringAsFixed(0)} Buds',
            style: GoogleFonts.inter(
              color: const Color(0xFFEFA315),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage area (featured card + seat rows)
// ─────────────────────────────────────────────────────────────────────────────

class _LiveRoomChatPanel extends StatelessWidget {
  final bool showViewerList;
  final VoidCallback onShowChat;
  final VoidCallback onShowViewers;
  final String hostName;
  final String pinnedMessage;
  final double? goalTargetBuds;
  final double goalProgressBuds;
  final List<LiveRoomParticipantRecord> participants;
  final List<LiveRoomMessageRecord> messages;
  final TextEditingController messageController;
  final ScrollController messageScrollController;
  final bool sendingMessage;
  final VoidCallback onSendMessage;

  const _LiveRoomChatPanel({
    required this.showViewerList,
    required this.onShowChat,
    required this.onShowViewers,
    required this.hostName,
    required this.pinnedMessage,
    required this.goalTargetBuds,
    required this.goalProgressBuds,
    required this.participants,
    required this.messages,
    required this.messageController,
    required this.messageScrollController,
    required this.sendingMessage,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final goalTarget = goalTargetBuds;
    final progress = goalTarget != null && goalTarget > 0
        ? (goalProgressBuds / goalTarget).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ChatModeButton(
                selected: !showViewerList,
                label: 'Chat',
                onTap: onShowChat,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ChatModeButton(
                selected: showViewerList,
                label: 'Viewers',
                onTap: onShowViewers,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (goalTarget != null && goalTarget > 0) ...[
          _GiftGoalCard(
            targetBuds: goalTarget,
            progressBuds: goalProgressBuds,
            progress: progress,
          ),
          const SizedBox(height: 12),
        ],
        if (pinnedMessage.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.push_pin_rounded,
                    color: Color(0xFF2F88FF),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pinnedMessage,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: showViewerList
                ? _ViewerList(hostName: hostName, participants: participants)
                : _MessageList(
                    messages: messages,
                    controller: messageScrollController,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _ChatComposer(
          controller: messageController,
          enabled: !showViewerList,
          sendingMessage: sendingMessage,
          onSendMessage: onSendMessage,
        ),
      ],
    );
  }
}

class _ChatModeButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _ChatModeButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1B234B)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF7B4FCC)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<LiveRoomMessageRecord> messages;
  final ScrollController controller;

  const _MessageList({required this.messages, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'The chat is quiet. Send the first message.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.58),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _ChatMessageTile(message: messages[index]),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  final LiveRoomMessageRecord message;

  const _ChatMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final senderName = message.senderName.trim().isEmpty
        ? 'Guest'
        : message.senderName.trim();
    final initials = senderName.substring(0, 1).toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF1B234B),
          backgroundImage: message.senderAvatarUrl.trim().isNotEmpty
              ? NetworkImage(message.senderAvatarUrl)
              : null,
          child: message.senderAvatarUrl.trim().isEmpty
              ? Text(
                  initials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: message.isGift
                  ? const Color(0x331DDF7A)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: message.isGift
                    ? const Color(0xFF51D76E).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isGift &&
                        message.giftAssetPath?.trim().isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.asset(
                          message.giftAssetPath!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        message.text,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewerList extends StatelessWidget {
  final String hostName;
  final List<LiveRoomParticipantRecord> participants;

  const _ViewerList({required this.hostName, required this.participants});

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No viewers connected yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.58),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: participants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _ViewerPresenceTile(
        participant: participants[index],
        hostName: hostName,
      ),
    );
  }
}

class _ViewerPresenceTile extends StatelessWidget {
  final LiveRoomParticipantRecord participant;
  final String hostName;

  const _ViewerPresenceTile({
    required this.participant,
    required this.hostName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = participant.displayName.trim().isEmpty
        ? hostName
        : participant.displayName.trim();
    final initials = displayName.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1B234B),
            backgroundImage: participant.avatarUrl.trim().isNotEmpty
                ? NetworkImage(participant.avatarUrl)
                : null,
            child: participant.avatarUrl.trim().isEmpty
                ? Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (participant.isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Host',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFF8C35B),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    participant.micEnabled ? 'mic on' : 'mic muted',
                    participant.cameraEnabled ? 'camera on' : 'camera off',
                    if (participant.screenShareEnabled) 'sharing screen',
                  ].join(' • '),
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool sendingMessage;
  final VoidCallback onSendMessage;

  const _ChatComposer({
    required this.controller,
    required this.enabled,
    required this.sendingMessage,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled && !sendingMessage,
              onSubmitted: (_) => onSendMessage(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: enabled
                    ? 'Say hi'
                    : 'Switch to chat to send a message',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: enabled && !sendingMessage ? onSendMessage : null,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFF2F88FF)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: sendingMessage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: enabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStageCard extends StatelessWidget {
  final String hostName;

  const _EmptyStageCard({required this.hostName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FeaturedStagePlaceholder(hostName: hostName),
            const SizedBox(height: 32),
            const _StageSeatRow(
              tiles: <_ParticipantTileData?>[null, null, null],
            ),
            const SizedBox(height: 18),
            const _StageSeatRow(
              tiles: <_ParticipantTileData?>[null, null, null],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantStageGrid extends StatelessWidget {
  final List<_ParticipantTileData> participantTiles;
  final String hostName;

  const _ParticipantStageGrid({
    required this.participantTiles,
    required this.hostName,
  });

  @override
  Widget build(BuildContext context) {
    final featured = participantTiles.firstWhere(
      (tile) => tile.isScreenShare,
      orElse: () => participantTiles.firstWhere(
        (tile) => tile.isHost,
        orElse: () => participantTiles.first,
      ),
    );
    final queue = participantTiles
        .where((tile) => !identical(tile, featured))
        .take(6)
        .toList(growable: false);

    // Split queue into two rows of 3
    final firstRow = <_ParticipantTileData?>[];
    final secondRow = <_ParticipantTileData?>[];
    for (var i = 0; i < 3; i++) {
      firstRow.add(i < queue.length ? queue[i] : null);
    }
    for (var i = 3; i < 6; i++) {
      secondRow.add(i < queue.length ? queue[i] : null);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          _FeaturedStageCard(tile: featured, fallbackHostName: hostName),
          const SizedBox(height: 28),
          _StageSeatRow(tiles: firstRow),
          const SizedBox(height: 16),
          _StageSeatRow(tiles: secondRow),
        ],
      ),
    );
  }
}

// ── Featured host card with floral/gradient frame ──
class _FeaturedStagePlaceholder extends StatelessWidget {
  final String hostName;

  const _FeaturedStagePlaceholder({required this.hostName});

  @override
  Widget build(BuildContext context) {
    return _HostFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFF1D2341),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hostName,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _MeetButton(onTap: null),
        ],
      ),
    );
  }
}

class _FeaturedStageCard extends StatelessWidget {
  final _ParticipantTileData tile;
  final String fallbackHostName;

  const _FeaturedStageCard({
    required this.tile,
    required this.fallbackHostName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _participantDisplayName(tile.participant);

    return _HostFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar or video
          if (tile.isScreenShare && tile.videoTrack != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 160,
                height: 100,
                child: VideoTrackRenderer(
                  tile.videoTrack!,
                  renderMode: VideoRenderMode.auto,
                ),
              ),
            )
          else
            _ParticipantMediaAvatar(tile: tile, size: 110),
          const SizedBox(height: 14),
          Text(
            displayName.isEmpty ? fallbackHostName : displayName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          // "Meet" button (host invite / spotlight action)
          _MeetButton(onTap: () {}),
        ],
      ),
    );
  }
}

/// Purple gradient rounded frame that wraps the featured host card.
class _HostFrame extends StatelessWidget {
  final Widget child;

  const _HostFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE080FF), Color(0xFFF49E2C)],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(color: Color(0x77D946EF), blurRadius: 28, spreadRadius: -4),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0F24),
          borderRadius: BorderRadius.circular(33),
        ),
        child: child,
      ),
    );
  }
}

class _MeetButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MeetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C3DFF), Color(0xFF3D6BFF)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Meet',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Participant seat rows (pill shaped) ──
class _StageSeatRow extends StatelessWidget {
  final List<_ParticipantTileData?> tiles;

  const _StageSeatRow({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xBB07091A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF7B4FCC).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x44D946EF), blurRadius: 12, spreadRadius: -4),
          BoxShadow(
            color: Color(0x33FF9F1A),
            blurRadius: 16,
            spreadRadius: -6,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            Expanded(
              child: Center(
                child: tiles[i] == null
                    ? _StageSeatPlaceholder()
                    : _StageSeatBubble(tile: tiles[i]!),
              ),
            ),
            if (i < tiles.length - 1)
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _StageSeatPlaceholder extends StatelessWidget {
  const _StageSeatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1835),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.mic_rounded,
        color: Colors.white.withValues(alpha: 0.35),
        size: 22,
      ),
    );
  }
}

class _StageSeatBubble extends StatelessWidget {
  final _ParticipantTileData tile;

  const _StageSeatBubble({required this.tile});

  @override
  Widget build(BuildContext context) {
    final displayName = _participantDisplayName(tile.participant);
    final micEnabled = tile.participant.isMicrophoneEnabled();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _ParticipantMediaAvatar(tile: tile, size: 48),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1A20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                  color: micEnabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  size: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gift Goal Card
// ─────────────────────────────────────────────────────────────────────────────

class _GiftGoalCard extends StatelessWidget {
  final double targetBuds;
  final double progressBuds;
  final double progress;

  const _GiftGoalCard({
    required this.targetBuds,
    required this.progressBuds,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF180D2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF51D76E)),
        boxShadow: const [
          BoxShadow(color: Color(0x2206FF48), blurRadius: 20, spreadRadius: -6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFF51D76E),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Gift Goal',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${progressBuds.toStringAsFixed(0)}/${targetBuds.toStringAsFixed(0)} Buds',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.black,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF51D76E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Control Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  final bool micEnabled;
  final bool cameraEnabled;
  final bool screenShareEnabled;
  final bool sendingGift;
  final bool showGiftButton;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onGift;
  final VoidCallback onLeave;

  const _ControlBar({
    required this.micEnabled,
    required this.cameraEnabled,
    required this.screenShareEnabled,
    required this.sendingGift,
    required this.showGiftButton,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleScreenShare,
    required this.onGift,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary row: gift (optional) + mic + hangup
          _ControlDock(
            children: [
              if (showGiftButton)
                _RoundControlButton(
                  icon: Icons.redeem_rounded,
                  background: const Color(0xFFFF7A1A),
                  iconColor: Colors.white,
                  onTap: sendingGift ? null : onGift,
                  busy: sendingGift,
                ),
              _RoundControlButton(
                icon: micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                background: const Color(0xFF202020),
                iconColor: micEnabled ? const Color(0xFF2F88FF) : Colors.white,
                ringColor: micEnabled ? const Color(0xFFB744FF) : null,
                onTap: onToggleMic,
              ),
              _RoundControlButton(
                icon: Icons.call_end_rounded,
                background: const Color(0xFF691D1D),
                iconColor: Colors.white,
                onTap: onLeave,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Secondary row: camera + screen share
          _ControlDock(
            children: [
              _RoundControlButton(
                icon: cameraEnabled
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                background: const Color(0xFF2B2B2B),
                iconColor: Colors.white,
                onTap: onToggleCamera,
              ),
              _RoundControlButton(
                icon: screenShareEnabled
                    ? Icons.stop_screen_share_rounded
                    : Icons.screen_share_rounded,
                background: const Color(0xFF2B2B2B),
                iconColor: screenShareEnabled
                    ? const Color(0xFF51D76E)
                    : Colors.white,
                onTap: onToggleScreenShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlDock extends StatelessWidget {
  final List<Widget> children;

  const _ControlDock({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final Color? ringColor;
  final VoidCallback? onTap;
  final bool busy;

  const _RoundControlButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.ringColor,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          )
        : Icon(icon, color: iconColor, size: 20);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: ringColor == null
                  ? null
                  : Border.all(color: ringColor!, width: 1.4),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Participant media avatar
// ─────────────────────────────────────────────────────────────────────────────

class _ParticipantMediaAvatar extends StatelessWidget {
  final _ParticipantTileData tile;
  final double size;

  const _ParticipantMediaAvatar({required this.tile, required this.size});

  @override
  Widget build(BuildContext context) {
    final displayName = _participantDisplayName(tile.participant);
    final initials = _nameInitial(displayName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1D2341),
        border: Border.all(
          color: tile.isHost
              ? const Color(0xFFF59E0B)
              : Colors.white.withValues(alpha: 0.08),
          width: tile.isHost ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: tile.videoTrack != null
          ? VideoTrackRenderer(
              tile.videoTrack!,
              renderMode: VideoRenderMode.auto,
            )
          : tile.avatarUrl.trim().isNotEmpty
          ? Image.network(
              tile.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _avatarFallback(initials),
            )
          : _avatarFallback(initials),
    );
  }

  Widget _avatarFallback(String initials) {
    return Container(
      color: const Color(0xFF171D37),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.28,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gift picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _GiftPickerSheet extends StatefulWidget {
  final double balanceBuds;

  const _GiftPickerSheet({required this.balanceBuds});

  @override
  State<_GiftPickerSheet> createState() => _GiftPickerSheetState();
}

class _GiftPickerSheetState extends State<_GiftPickerSheet> {
  LiveGiftCatalogItem _selectedGift = liveGiftCatalog.first;
  int _multiplier = 1;

  @override
  Widget build(BuildContext context) {
    final totalCost = _selectedGift.priceBuds * _multiplier;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send gift to host',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Balance: ${widget.balanceBuds.toStringAsFixed(2)} Buds',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: GridView.builder(
              itemCount: liveGiftCatalog.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final gift = liveGiftCatalog[index];
                final selected = gift.id == _selectedGift.id;
                return InkWell(
                  onTap: () => setState(() => _selectedGift = gift),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2F88FF).withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2F88FF)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            gift.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gift.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${gift.priceBuds.toStringAsFixed(0)} Buds',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Quantity',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _multiplier > 1
                    ? () => setState(() => _multiplier -= 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text(
                '$_multiplier',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _multiplier += 1),
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: widget.balanceBuds + 0.0001 < totalCost
                ? null
                : () {
                    Navigator.of(context).pop(
                      _GiftSelection(
                        gift: _selectedGift,
                        multiplier: _multiplier,
                      ),
                    );
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text('Send ${totalCost.toStringAsFixed(0)} Buds'),
          ),
        ],
      ),
    );
  }
}

class _GiftSelection {
  final LiveGiftCatalogItem gift;
  final int multiplier;

  const _GiftSelection({required this.gift, required this.multiplier});
}

// ─────────────────────────────────────────────────────────────────────────────
// Leave dialog
// ─────────────────────────────────────────────────────────────────────────────

Future<bool?> _showLeaveLiveDialog(
  BuildContext context, {
  required bool isHost,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: Text(
          isHost ? 'End live room?' : 'Leave live room?',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          isHost
              ? 'Ending the live room disconnects everyone.'
              : 'You can rejoin later using the same invite link.',
          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.72)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isHost ? 'End live' : 'Leave'),
          ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models (private)
// ─────────────────────────────────────────────────────────────────────────────

class _GiftLeaderboardEntry {
  final String userId;
  final String displayName;
  final String avatarUrl;
  final double totalBuds;

  const _GiftLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.totalBuds,
  });
}

class _ParticipantTileData {
  final Participant participant;
  final VideoTrack? videoTrack;
  final bool isScreenShare;
  final bool isHost;
  final String avatarUrl;

  const _ParticipantTileData({
    required this.participant,
    required this.videoTrack,
    required this.isScreenShare,
    required this.isHost,
    required this.avatarUrl,
  });
}

class _ParticipantMetadata {
  final bool isHost;
  final String avatarUrl;

  const _ParticipantMetadata({this.isHost = false, this.avatarUrl = ''});
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared utility functions
// ─────────────────────────────────────────────────────────────────────────────

String _participantDisplayName(Participant participant) {
  final name = participant.name.trim();
  if (name.isNotEmpty) return name;
  return participant.identity.trim().isNotEmpty
      ? participant.identity
      : 'Guest';
}

String _nameInitial(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
}
