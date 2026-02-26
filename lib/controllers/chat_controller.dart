import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/models/chat_models.dart';
import '../data/repositories/chat_repository.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  ChatController({
    AuthController? authController,
    ChatRepository? chatRepository,
  }) : _authController = authController ?? Get.find<AuthController>(),
       _chatRepository = chatRepository ?? ChatRepository();

  final AuthController _authController;
  final ChatRepository _chatRepository;

  final RxList<WaibyChatThread> threads = <WaibyChatThread>[].obs;
  final RxnString activeThreadId = RxnString();
  final RxBool isStartingConversation = false.obs;

  StreamSubscription<List<ChatConversation>>? _conversationsSubscription;
  final Map<String, StreamSubscription<List<ChatMessageRecord>>>
  _messagesSubscriptions =
      <String, StreamSubscription<List<ChatMessageRecord>>>{};
  final Map<String, ChatConversation> _conversationsById =
      <String, ChatConversation>{};
  final Map<String, List<ChatMessageRecord>> _messagesByConversationId =
      <String, List<ChatMessageRecord>>{};

  Worker? _authWorker;
  String? _lastPath;

  String? get currentUserId => _authController.currentUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    _syncForAuthUser(_authController.currentUser.value);
    _authWorker = ever<User?>(_authController.currentUser, _syncForAuthUser);
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    _cancelStreamSubscriptions();
    super.onClose();
  }

  void handleRouteChanged(String path) {
    if (_lastPath != null && _lastPath != path) {
      closePanel();
    }
    _lastPath = path;
  }

  Future<void> startDirectConversation({
    required String otherUserId,
    String? otherUserName,
    String? otherUserAvatarUrl,
  }) async {
    final selfUser = _authController.currentUser.value;
    if (selfUser == null) {
      throw StateError('You must be signed in to start a chat.');
    }

    final selfId = selfUser.uid.trim();
    final targetId = otherUserId.trim();
    if (targetId.isEmpty) {
      throw ArgumentError('Target user id is missing.');
    }
    if (targetId.contains('/')) {
      throw ArgumentError('Invalid profile id.');
    }
    if (targetId == selfId) {
      throw ArgumentError('Cannot chat with yourself.');
    }

    isStartingConversation.value = true;
    try {
      final conversationId = await _chatRepository.ensureDirectConversation(
        currentUserId: selfId,
        otherUserId: targetId,
        currentUserName: _authController.userName,
        currentUserAvatarUrl: _authController.userPhotoUrl,
        otherUserName: otherUserName,
        otherUserAvatarUrl: otherUserAvatarUrl,
      );
      activeThreadId.value = conversationId;
      unawaited(
        _chatRepository.markConversationRead(
          conversationId: conversationId,
          userId: selfId,
        ),
      );
    } finally {
      isStartingConversation.value = false;
    }
  }

  void selectThread(String threadId) {
    final normalizedThreadId = threadId.trim();
    if (normalizedThreadId.isEmpty) return;
    activeThreadId.value = normalizedThreadId;
    final selfId = currentUserId;
    if (selfId == null || selfId.isEmpty) return;
    unawaited(
      _chatRepository.markConversationRead(
        conversationId: normalizedThreadId,
        userId: selfId,
      ),
    );
  }

  void closePanel() {
    activeThreadId.value = null;
  }

  Future<void> sendMessage({
    required String threadId,
    required String text,
  }) async {
    final selfId = currentUserId;
    if (selfId == null || selfId.isEmpty) {
      throw StateError('You must be signed in to send a message.');
    }
    await _chatRepository.sendMessage(
      conversationId: threadId,
      senderId: selfId,
      text: text,
    );
  }

  void _syncForAuthUser(User? user) {
    if (user == null || user.uid.trim().isEmpty) {
      _cancelStreamSubscriptions();
      threads.clear();
      activeThreadId.value = null;
      return;
    }

    final userId = user.uid.trim();
    _cancelStreamSubscriptions();
    _conversationsSubscription = _chatRepository
        .watchConversationsForUser(userId)
        .listen(_onConversationsUpdated);
  }

  void _onConversationsUpdated(List<ChatConversation> conversations) {
    final selfId = currentUserId;
    if (selfId == null || selfId.isEmpty) return;

    final nextIds = conversations
        .map((conversation) => conversation.id)
        .toSet();
    final removedIds = _messagesSubscriptions.keys
        .where((id) => !nextIds.contains(id))
        .toList(growable: false);
    for (final removedId in removedIds) {
      _messagesSubscriptions.remove(removedId)?.cancel();
      _messagesByConversationId.remove(removedId);
      _conversationsById.remove(removedId);
    }

    for (final conversation in conversations) {
      _conversationsById[conversation.id] = conversation;
      _messagesSubscriptions[conversation.id] ??= _chatRepository
          .watchMessages(conversation.id)
          .listen((messages) {
            _messagesByConversationId[conversation.id] = messages;
            _rebuildThreads();

            final activeId = activeThreadId.value;
            if (activeId == conversation.id) {
              unawaited(
                _chatRepository.markConversationRead(
                  conversationId: conversation.id,
                  userId: selfId,
                ),
              );
            }
          });
    }

    _rebuildThreads();
  }

  void _rebuildThreads() {
    final selfId = currentUserId;
    if (selfId == null || selfId.isEmpty) {
      threads.clear();
      return;
    }

    final nextThreads = <WaibyChatThread>[];
    for (final conversation in _conversationsById.values) {
      final otherUserId = conversation.otherParticipantId(selfId);
      final mappedMessages = <WaibyChatMessage>[];
      for (final message
          in _messagesByConversationId[conversation.id] ??
              const <ChatMessageRecord>[]) {
        mappedMessages.add(
          WaibyChatMessage(
            text: message.text,
            fromCurrentUser: message.senderId == selfId,
            sentAt: message.sentAt,
          ),
        );
      }

      final lastMessageText = conversation.lastMessageText?.trim();
      final previewText =
          (lastMessageText != null && lastMessageText.isNotEmpty)
          ? lastMessageText
          : (mappedMessages.isNotEmpty
                ? mappedMessages.last.text
                : 'Start chatting');
      final lastActivityAt =
          conversation.lastMessageAt ??
          conversation.updatedAt ??
          conversation.createdAt;
      final lastActivityLabel = _formatRelativeTime(lastActivityAt);

      nextThreads.add(
        WaibyChatThread(
          id: conversation.id,
          displayName: conversation.displayNameFor(
            otherUserId,
            fallback: 'Unknown user',
          ),
          avatarAsset: _fallbackAvatarAsset(otherUserId),
          avatarUrl: conversation.avatarUrlFor(otherUserId),
          frameAsset: null,
          previewText: previewText,
          previewItalic: false,
          lastActivityLabel: lastActivityLabel,
          unreadCount: conversation.unreadCountFor(selfId),
          showUnreadIndicator: conversation.unreadCountFor(selfId) > 0,
          isOnline: conversation.isOnlineFor(otherUserId),
          messages: mappedMessages,
        ),
      );
    }

    nextThreads.sort((a, b) {
      DateTime? lastMessageTime(WaibyChatThread thread) {
        if (thread.messages.isEmpty) return null;
        return thread.messages.last.sentAt;
      }

      final aTime = lastMessageTime(a);
      final bTime = lastMessageTime(b);
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    threads.assignAll(nextThreads);

    final selectedId = activeThreadId.value;
    if (selectedId != null &&
        nextThreads.every((thread) => thread.id != selectedId)) {
      activeThreadId.value = null;
    }
  }

  void _cancelStreamSubscriptions() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = null;

    for (final entry in _messagesSubscriptions.values) {
      entry.cancel();
    }
    _messagesSubscriptions.clear();
    _conversationsById.clear();
    _messagesByConversationId.clear();
  }
}

String _formatRelativeTime(DateTime? value) {
  if (value == null) return 'now';
  final now = DateTime.now();
  final diff = now.difference(value);
  if (diff.inSeconds < 45) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${math.max(1, diff.inDays)}d';
}

String _fallbackAvatarAsset(String seed) {
  const avatars = <String>[
    'assets/pp1.png',
    'assets/pp2.png',
    'assets/pp3.png',
    'assets/pp4.png',
    'assets/pp5.png',
    'assets/pp6.png',
    'assets/pp7.png',
  ];
  final normalized = seed.trim();
  final hash = normalized.isEmpty ? 0 : normalized.hashCode;
  final index = hash.abs() % avatars.length;
  return avatars[index];
}
