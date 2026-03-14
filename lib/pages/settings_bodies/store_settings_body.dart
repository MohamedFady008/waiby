import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/frame_store_service.dart';
import '../../widgets/settings_sidebar.dart';

class StoreSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const StoreSettingsBody({super.key, required this.entry});

  @override
  State<StoreSettingsBody> createState() => _StoreSettingsBodyState();
}

class _StoreSettingsBodyState extends State<StoreSettingsBody> {
  final FrameStoreService _frameStoreService = FrameStoreService();

  FrameStoreState? _storeState;
  String? _loadingUserId;
  String? _pendingFrameId;
  bool _isLoading = false;
  String? _loadError;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          _loadingUserId = null;
          _storeState = null;
          _pendingFrameId = null;
          _isLoading = false;
          _loadError = null;
          return _StoreSignedOutHint(
            onSignInTap: () => context.go('/login'),
            onTopupTap: () => context.go('/wallet/topup'),
          );
        }

        if (_loadingUserId != user.uid && !_isLoading) {
          _scheduleLoadStoreState(user.uid);
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
        }

        return _buildStoreContent(context, user.uid);
      },
    );
  }

  void _scheduleLoadStoreState(String uid) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadingUserId == uid || _isLoading) {
        return;
      }
      unawaited(_loadStoreState(uid));
    });
  }

  Widget _buildStoreContent(BuildContext context, String uid) {
    final state = _storeState;
    if (state == null && _isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
    }

    if (state == null) {
      return _StoreLoadErrorCard(
        message: _loadError ?? 'Could not load store right now.',
        onRetry: () => _loadStoreState(uid),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StoreHeroBanner(),
            const SizedBox(height: 26),
            _StoreHeader(
              budsBalance: state.wallet.budsBalance,
              onTopupTap: () => context.go('/wallet/topup'),
            ),
            if (_loadError != null) ...[
              const SizedBox(height: 14),
              Text(
                _loadError!,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _StoreFramesGrid(
              frames: state.frames,
              pendingFrameId: _pendingFrameId,
              onFrameTap: (frame) => unawaited(_handleFrameTap(frame)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadStoreState(String uid) async {
    final switchingUser = _loadingUserId != uid;
    setState(() {
      _isLoading = true;
      _loadError = null;
      _loadingUserId = uid;
      if (switchingUser) {
        _storeState = null;
        _pendingFrameId = null;
      }
    });

    try {
      final state = await _frameStoreService.getMyFrameStoreState();
      if (!mounted) {
        return;
      }
      setState(() {
        _storeState = state;
      });
    } on FrameStoreException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = 'Could not load store right now.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFrameTap(FrameStoreItem frame) async {
    if (_pendingFrameId != null || _storeState == null) {
      return;
    }

    if (frame.active) {
      return;
    }

    if (!frame.owned && frame.priceBuds > _storeState!.wallet.budsBalance) {
      _showSnackbar('Not enough Buds. Please recharge your wallet first.');
      return;
    }

    if (!frame.owned) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _FramePurchaseDialog(frame: frame),
      );
      if (confirmed != true) {
        return;
      }
    }

    setState(() => _pendingFrameId = frame.id);

    try {
      final nextState = frame.owned
          ? await _frameStoreService.setActiveFrame(frame.id)
          : await _frameStoreService.purchaseFrame(frame.id);
      if (!mounted) {
        return;
      }
      setState(() => _storeState = nextState);
      _showSnackbar(
        frame.owned
            ? 'Frame equipped successfully.'
            : 'Frame purchased and equipped successfully.',
        isError: false,
      );
    } on FrameStoreException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackbar(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackbar('Could not complete this action right now.');
    } finally {
      if (mounted) {
        setState(() => _pendingFrameId = null);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB43A3A)
            : const Color(0xFF2E7D32),
      ),
    );
  }
}

class _StoreHeroBanner extends StatelessWidget {
  const _StoreHeroBanner();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 901 / 141,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF69C87E), Color(0xFFA3C5AA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Store: Profile Frames',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0A204A),
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final double budsBalance;
  final VoidCallback onTopupTap;

  const _StoreHeader({required this.budsBalance, required this.onTopupTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final compact = constraints.maxWidth < 620;
        final titleSize = compact ? 30.0 : 40.0;
        final balanceSize = compact ? 23.0 : 31.0;

        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frames',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFFDFD),
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
                height: 1.03,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 12,
                  color: Color(0xFF51D76E),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bought frames can be equipped from Store or Edit Profile.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        final right = Column(
          crossAxisAlignment: wide
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Buds Balance:',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: balanceSize,
                    height: 1.05,
                  ),
                ),
                const SizedBox(width: 8),
                const _CoinGlyph(size: 15),
                const SizedBox(width: 6),
                Text(
                  budsBalance.toStringAsFixed(2),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: balanceSize,
                    height: 1.05,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: onTopupTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Recharge',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF51D76E),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Color(0xFF51D76E),
                  ),
                ],
              ),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              right,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 16), right],
        );
      },
    );
  }
}

class _StoreFramesGrid extends StatelessWidget {
  final List<FrameStoreItem> frames;
  final String? pendingFrameId;
  final ValueChanged<FrameStoreItem> onFrameTap;

  const _StoreFramesGrid({
    required this.frames,
    required this.pendingFrameId,
    required this.onFrameTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const gap = 18.0;

        int columns;
        if (width >= 1500) {
          columns = 5;
        } else if (width >= 1200) {
          columns = 4;
        } else if (width >= 860) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = ((width - (gap * (columns - 1))) / columns).clamp(
          200.0,
          244.0,
        );

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: frames
              .map(
                (frame) => SizedBox(
                  width: cardWidth,
                  child: _StoreFrameCard(
                    data: frame,
                    pending: pendingFrameId == frame.id,
                    onTap: () => onFrameTap(frame),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _StoreFrameCard extends StatelessWidget {
  final FrameStoreItem data;
  final bool pending;
  final VoidCallback onTap;

  const _StoreFrameCard({
    required this.data,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actionLabel = pending
        ? 'Processing...'
        : data.active
        ? 'Using'
        : data.owned
        ? 'Use'
        : 'Buy for';
    final canTap = !pending && !data.active;

    return Stack(
      children: [
        Container(
          height: 232,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141D35),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: data.active
                  ? const Color(0xFF51D76E)
                  : Colors.white.withValues(alpha: 0.14),
              width: data.active ? 1.1 : 0.7,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(2, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 74,
                            height: 74,
                            color: const Color(0xFF263351),
                            child: Image.asset(
                              'assets/bunny1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.pets_rounded,
                                color: Color(0xFF8ADE57),
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        Image.asset(
                          data.assetPath,
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 13),
              _FrameActionButtons(
                actionLabel: actionLabel,
                priceLabel: data.priceBuds.toStringAsFixed(2),
                showPrice: !data.owned && !data.active,
                showGiftButton: !data.owned && data.giftable,
                enabled: canTap,
                onTap: onTap,
              ),
            ],
          ),
        ),
        if (data.active)
          const Positioned(
            left: 7,
            top: 4,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 12,
              color: Color(0xFF51D76E),
            ),
          ),
      ],
    );
  }
}

class _FrameActionButtons extends StatelessWidget {
  final String actionLabel;
  final String priceLabel;
  final bool showPrice;
  final bool showGiftButton;
  final bool enabled;
  final VoidCallback onTap;

  const _FrameActionButtons({
    required this.actionLabel,
    required this.priceLabel,
    required this.showPrice,
    required this.showGiftButton,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buyButton = Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 29,
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF2F88FF)
                : const Color(0xFF42516B).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                actionLabel,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1,
                ),
              ),
              if (showPrice) ...[
                const SizedBox(width: 5),
                const _CoinGlyph(size: 12),
                const SizedBox(width: 5),
                Text(
                  priceLabel,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!showGiftButton) {
      return Row(children: [buyButton]);
    }

    return Row(
      children: [
        buyButton,
        const SizedBox(width: 6),
        Container(
          width: 24,
          height: 29,
          decoration: BoxDecoration(
            color: const Color(0xFF2F88FF).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Icon(
            Icons.card_giftcard_rounded,
            size: 13,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CoinGlyph extends StatelessWidget {
  final double size;

  const _CoinGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8FBFFA), Color(0xFF2859C5)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.circle_outlined,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}

class _StoreSignedOutHint extends StatelessWidget {
  final VoidCallback onSignInTap;
  final VoidCallback onTopupTap;

  const _StoreSignedOutHint({
    required this.onSignInTap,
    required this.onTopupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in to use the Store',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Buy profile frames with Buds, equip your active frame, and show it across your profile.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: onSignInTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F88FF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign in'),
                  ),
                  ElevatedButton(
                    onPressed: onTopupTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2444),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Open Top-up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreLoadErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StoreLoadErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF8A8A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F88FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FramePurchaseDialog extends StatelessWidget {
  final FrameStoreItem frame;

  const _FramePurchaseDialog({required this.frame});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF171C29),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Purchase',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Buy "${frame.name}" for ${frame.priceBuds.toStringAsFixed(2)} Buds?',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Purchased frame will be equipped immediately and can be changed later in Edit Profile.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F88FF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Buy'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
