import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/store/frame_catalog.dart';

class UserAvatarWithFrame extends StatelessWidget {
  final String? userId;
  final double size;
  final double frameScale;
  final String fallbackAsset;
  final String? fallbackAvatarUrl;
  final bool showFrame;
  final Color? borderColor;
  final double borderWidth;
  final Color fallbackBackground;
  final IconData fallbackIcon;
  final Color fallbackIconColor;

  const UserAvatarWithFrame({
    super.key,
    this.userId,
    required this.size,
    this.frameScale = 1.32,
    this.fallbackAsset = 'assets/pp6.png',
    this.fallbackAvatarUrl,
    this.showFrame = true,
    this.borderColor,
    this.borderWidth = 0,
    this.fallbackBackground = const Color(0xFF213258),
    this.fallbackIcon = Icons.person_rounded,
    this.fallbackIconColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return _AvatarFrameLayer(
        size: size,
        frameAssetPath: null,
        avatarUrl: fallbackAvatarUrl,
        fallbackAsset: fallbackAsset,
        showFrame: showFrame,
        frameScale: frameScale,
        borderColor: borderColor,
        borderWidth: borderWidth,
        fallbackBackground: fallbackBackground,
        fallbackIcon: fallbackIcon,
        fallbackIconColor: fallbackIconColor,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(resolvedUserId)
          .snapshots(includeMetadataChanges: true),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final avatarUrl = _resolveAvatarUrl(data) ?? fallbackAvatarUrl;
        final frameAssetPath = _resolveFrameAssetPath(data);

        return _AvatarFrameLayer(
          size: size,
          frameAssetPath: frameAssetPath,
          avatarUrl: avatarUrl,
          fallbackAsset: fallbackAsset,
          showFrame: showFrame,
          frameScale: frameScale,
          borderColor: borderColor,
          borderWidth: borderWidth,
          fallbackBackground: fallbackBackground,
          fallbackIcon: fallbackIcon,
          fallbackIconColor: fallbackIconColor,
        );
      },
    );
  }

  String? _resolveUserId(String? rawUserId) {
    final explicit = rawUserId?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final current = FirebaseAuth.instance.currentUser?.uid.trim();
    if (current == null || current.isEmpty) {
      return null;
    }
    return current;
  }

  String? _resolveAvatarUrl(Map<String, dynamic>? data) {
    final candidates = <dynamic>[
      data?['avatar_url'],
      data?['metadata']?['avatar_url'],
      data?['metadata']?['picture'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String? _resolveFrameAssetPath(Map<String, dynamic>? data) {
    final candidates = <dynamic>[
      data?['profile_frame_asset'],
      data?['active_frame_asset'],
      data?['metadata']?['profile_frame_asset'],
      data?['metadata']?['active_frame_asset'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    final frameIdCandidates = <dynamic>[
      data?['active_frame_id'],
      data?['profile_frame_id'],
      data?['metadata']?['active_frame_id'],
      data?['metadata']?['profile_frame_id'],
    ];
    for (final candidate in frameIdCandidates) {
      final frameId = candidate?.toString().trim();
      if (frameId != null && frameId.isNotEmpty) {
        final mapped = frameAssetPathById(frameId);
        if (mapped != null && mapped.isNotEmpty) {
          return mapped;
        }
      }
    }
    return null;
  }
}

class _AvatarFrameLayer extends StatelessWidget {
  final double size;
  final String? frameAssetPath;
  final String? avatarUrl;
  final String fallbackAsset;
  final bool showFrame;
  final double frameScale;
  final Color? borderColor;
  final double borderWidth;
  final Color fallbackBackground;
  final IconData fallbackIcon;
  final Color fallbackIconColor;

  const _AvatarFrameLayer({
    required this.size,
    required this.frameAssetPath,
    required this.avatarUrl,
    required this.fallbackAsset,
    required this.showFrame,
    required this.frameScale,
    required this.borderColor,
    required this.borderWidth,
    required this.fallbackBackground,
    required this.fallbackIcon,
    required this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final frameSize = size * frameScale;
    final ringWidth = borderWidth < 0 ? 0.0 : borderWidth;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ringWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.18),
                width: ringWidth,
              )
            : null,
      ),
      child: ClipOval(child: _avatarImage()),
    );

    return SizedBox(
      width: math.max(size, frameSize).toDouble(),
      height: math.max(size, frameSize).toDouble(),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (showFrame && frameAssetPath != null && frameAssetPath!.isNotEmpty)
            IgnorePointer(
              child: Image.asset(
                frameAssetPath!,
                width: frameSize,
                height: frameSize,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarImage() {
    final trimmedUrl = avatarUrl?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
      return Image.network(
        trimmedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackAvatar(),
      );
    }

    return Image.asset(
      fallbackAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackAvatar(),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: fallbackBackground,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: fallbackIconColor, size: size * 0.48),
    );
  }
}
