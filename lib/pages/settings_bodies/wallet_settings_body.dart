import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/topup_checkout_service.dart';
import '../../widgets/settings_sidebar.dart';

class WalletSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const WalletSettingsBody({super.key, required this.entry});

  @override
  State<WalletSettingsBody> createState() => _WalletSettingsBodyState();
}

class _WalletSettingsBodyState extends State<WalletSettingsBody> {
  final TopupCheckoutService _checkoutService = TopupCheckoutService();

  String? _syncedUserId;
  bool _isSyncing = false;
  bool _isSubmittingWithdrawal = false;
  TopupWalletSnapshot? _walletFallback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1520),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(34, 30, 34, 34),
          decoration: BoxDecoration(
            color: const Color(0x30000000),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildWalletContent(context),
        ),
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          _syncedUserId = null;
          _walletFallback = null;
          return _SignedOutWalletHint(
            onSignInTap: () => context.go('/login'),
            onTopupTap: () => context.go('/wallet/topup'),
          );
        }

        _syncWalletBalanceOnce(user);

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('wallets')
              .doc(user.uid)
              .snapshots(includeMetadataChanges: true),
          builder: (context, walletSnapshot) {
            final liveWallet = _WalletSummary.fromMap(
              walletSnapshot.data?.data(),
            );
            final hasLiveWalletData = walletSnapshot.data?.data() != null;
            final useFallback =
                _walletFallback != null &&
                (walletSnapshot.hasError ||
                    !hasLiveWalletData ||
                    (walletSnapshot.data?.metadata.isFromCache ?? false));
            final wallet = useFallback
                ? _WalletSummary.fromTopupWalletSnapshot(_walletFallback!)
                : liveWallet;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('wallet_transactions')
                  .where('user_id', isEqualTo: user.uid)
                  .limit(120)
                  .snapshots(),
              builder: (context, transactionSnapshot) {
                final rows = _buildDealRows(transactionSnapshot.data);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WalletPolicyNotice(wallet: wallet),
                    const SizedBox(height: 20),
                    _WalletStatsSection(
                      wallet: wallet,
                      withdrawInProgress: _isSubmittingWithdrawal,
                      onWithdrawTap: () =>
                          unawaited(_requestWithdrawal(wallet: wallet)),
                    ),
                    const SizedBox(height: 28),
                    _DealsDetailsCard(
                      rows: rows,
                      walletStreamIssue: walletSnapshot.hasError,
                      hasError: transactionSnapshot.hasError,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _syncWalletBalanceOnce(User user) {
    if (_isSyncing || _syncedUserId == user.uid) {
      return;
    }

    _syncedUserId = user.uid;
    _isSyncing = true;
    unawaited(() async {
      try {
        final syncedWallet = await _checkoutService.syncMyWallet();
        if (mounted) {
          setState(() => _walletFallback = syncedWallet);
        }
      } catch (_) {
        // Keep wallet UI usable even when sync endpoint is temporarily unavailable.
      } finally {
        _isSyncing = false;
      }
    }());
  }

  List<_DealRowData> _buildDealRows(
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  ) {
    if (snapshot == null) {
      return const <_DealRowData>[];
    }

    final rows =
        snapshot.docs
            .map((doc) => _DealRowData.fromMap(doc.id, doc.data()))
            .toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return rows.length > 50 ? rows.sublist(0, 50) : rows;
  }

  Future<void> _requestWithdrawal({required _WalletSummary wallet}) async {
    if (_isSubmittingWithdrawal) {
      return;
    }
    if (wallet.incomeBalanceUsd <= 0) {
      _showSnackbar('No withdrawable wallet balance available right now.');
      return;
    }

    final amountUsd = await showDialog<double>(
      context: context,
      builder: (context) =>
          _WithdrawRequestDialog(maxAmountUsd: wallet.incomeBalanceUsd),
    );
    if (amountUsd == null) {
      return;
    }

    setState(() => _isSubmittingWithdrawal = true);

    try {
      final result = await _checkoutService.requestWalletWithdrawal(
        amountUsd: amountUsd,
      );
      if (!mounted) {
        return;
      }

      setState(() => _walletFallback = result.wallet);
      _showSnackbar(
        'Withdrawal submitted. Net payout: \$${result.payoutUsd.toStringAsFixed(2)} (15% fee applied).',
        isError: false,
      );

      try {
        final syncedWallet = await _checkoutService.syncMyWallet();
        if (mounted) {
          setState(() => _walletFallback = syncedWallet);
        }
      } catch (_) {
        // Keep UI usable even when sync endpoint is temporarily unavailable.
      }
    } on TopupCheckoutException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackbar(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackbar('Could not submit withdrawal right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmittingWithdrawal = false);
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

class _SignedOutWalletHint extends StatelessWidget {
  final VoidCallback onSignInTap;
  final VoidCallback onTopupTap;

  const _SignedOutWalletHint({
    required this.onSignInTap,
    required this.onTopupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Wallet is available after sign in',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Buds top-up, wallet income and transactions are account-based and synced live from backend.',
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
              _WalletActionButton(label: 'Sign in', onTap: onSignInTap),
              _WalletActionButton(
                label: 'Open Top-up',
                dark: true,
                onTap: onTopupTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletPolicyNotice extends StatelessWidget {
  final _WalletSummary wallet;

  const _WalletPolicyNotice({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _tag('1 USD = 1 Bud'),
          _tag('Buds are non-withdrawable'),
          _tag('Wallet Balance is withdrawable USD'),
          _tag('Gems: 200 = 1 Bud'),
          _tag('Gem Dust: 200 = 1 Gem'),
          _tag('Withdrawal fee: 15%'),
          if (wallet.gemDustBalance > 0)
            _tag(
              'Gem Dust progress: ${wallet.gemDustBalance.toStringAsFixed(0)} / 200',
            ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.86),
          fontWeight: FontWeight.w500,
          fontSize: 11,
          height: 1,
        ),
      ),
    );
  }
}

class _WalletStatsSection extends StatelessWidget {
  final _WalletSummary wallet;
  final bool withdrawInProgress;
  final VoidCallback onWithdrawTap;

  const _WalletStatsSection({
    required this.wallet,
    required this.withdrawInProgress,
    required this.onWithdrawTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 1180) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WalletStatCard(
                      title: 'Buds Balance',
                      value: wallet.budsBalance.toStringAsFixed(2),
                      actionLabel: 'Recharge',
                      onActionTap: () => context.go('/wallet/topup'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _WalletStatCard(
                      title: 'Wallet Balance',
                      value: wallet.incomeBalanceUsd.toStringAsFixed(2),
                      actionLabel: withdrawInProgress
                          ? 'Submitting...'
                          : 'Withdraw',
                      onActionTap: withdrawInProgress ? null : onWithdrawTap,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _WalletStatCard(
                      title: 'On Hold (USD)',
                      value: wallet.onHoldUsd.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _WalletStatCard(
                      title: 'Gems',
                      value:
                          '${wallet.gemsBalance.toStringAsFixed(0)}~\$${wallet.gemsValueUsd.toStringAsFixed(2)}',
                      actionLabel: 'Get more',
                      actionDark: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(child: SizedBox()),
                  const SizedBox(width: 14),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          );
        }

        final cards = <Widget>[
          _WalletStatCard(
            title: 'Buds Balance',
            value: wallet.budsBalance.toStringAsFixed(2),
            actionLabel: 'Recharge',
            onActionTap: () => context.go('/wallet/topup'),
          ),
          _WalletStatCard(
            title: 'Wallet Balance',
            value: wallet.incomeBalanceUsd.toStringAsFixed(2),
            actionLabel: withdrawInProgress ? 'Submitting...' : 'Withdraw',
            onActionTap: withdrawInProgress ? null : onWithdrawTap,
          ),
          _WalletStatCard(
            title: 'On Hold (USD)',
            value: wallet.onHoldUsd.toStringAsFixed(2),
          ),
          _WalletStatCard(
            title: 'Gems',
            value:
                '${wallet.gemsBalance.toStringAsFixed(0)}~\$${wallet.gemsValueUsd.toStringAsFixed(2)}',
            actionLabel: 'Get more',
            actionDark: true,
          ),
        ];

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards
              .map(
                (card) => SizedBox(
                  width: width >= 760 ? (width - 14) / 2 : width,
                  child: card,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _WalletStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? actionLabel;
  final bool actionDark;
  final VoidCallback? onActionTap;

  const _WalletStatCard({
    required this.title,
    required this.value,
    this.actionLabel,
    this.actionDark = false,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 24,
              letterSpacing: -0.35,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const _CoinGlyph(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF1E2029),
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    letterSpacing: -0.7,
                    height: 1.0,
                  ),
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(width: 10),
                _WalletActionButton(
                  label: actionLabel!,
                  dark: actionDark,
                  onTap: onActionTap,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinGlyph extends StatelessWidget {
  const _CoinGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8FBFFA), Color(0xFF2859C5)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        r'$',
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final String label;
  final bool dark;
  final VoidCallback? onTap;

  const _WalletActionButton({
    required this.label,
    this.dark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 35,
          constraints: const BoxConstraints(minWidth: 113),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0C2444) : const Color(0xFF2F88FF),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: dark ? 16 : 20,
              letterSpacing: -0.25,
              height: dark ? 1.0 : 1.15,
            ),
          ),
        ),
      ),
    );
  }
}

class _WithdrawRequestDialog extends StatefulWidget {
  final double maxAmountUsd;

  const _WithdrawRequestDialog({required this.maxAmountUsd});

  @override
  State<_WithdrawRequestDialog> createState() => _WithdrawRequestDialogState();
}

class _WithdrawRequestDialogState extends State<_WithdrawRequestDialog> {
  static const double _feeRate = 0.15;

  late final TextEditingController _amountController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountUsd = _parsedAmountUsd;
    final feeUsd = _round2(amountUsd * _feeRate);
    final payoutUsd = _round2(amountUsd - feeUsd);

    return Dialog(
      backgroundColor: const Color(0xFF171C29),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Withdrawal',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available: \$${widget.maxAmountUsd.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.poppins(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  } else {
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Amount (USD)',
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF51D76E)),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  errorText: _errorText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Fee (15%): \$${feeUsd.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Net payout: \$${payoutUsd.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF51D76E),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F88FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Submit'),
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

  double get _parsedAmountUsd {
    final raw = _amountController.text.trim().replaceAll(',', '');
    return double.tryParse(raw) ?? 0;
  }

  void _submit() {
    final amountUsd = _round2(_parsedAmountUsd);

    if (amountUsd <= 0) {
      setState(() => _errorText = 'Enter an amount greater than 0.');
      return;
    }
    if (amountUsd > widget.maxAmountUsd) {
      setState(
        () => _errorText = 'Amount cannot exceed available wallet balance.',
      );
      return;
    }

    final payoutUsd = _round2(amountUsd * (1 - _feeRate));
    if (payoutUsd <= 0) {
      setState(() => _errorText = 'Amount is too small after fee deduction.');
      return;
    }

    Navigator.of(context).pop(amountUsd);
  }

  double _round2(double value) => (value * 100).round() / 100;
}

class _DealsDetailsCard extends StatelessWidget {
  final List<_DealRowData> rows;
  final bool walletStreamIssue;
  final bool hasError;

  const _DealsDetailsCard({
    required this.rows,
    required this.walletStreamIssue,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 54,
            offset: Offset(6, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Deals Details',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 39,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: const [
                      _FilterChip(
                        label: 'Live backend data',
                        withChevron: false,
                        active: true,
                      ),
                      _FilterChip(
                        label: 'Latest 50',
                        withChevron: false,
                        active: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'Could not load transactions right now.',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF8A8A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (walletStreamIssue)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'Live wallet stream is temporarily unavailable. Showing server-synced wallet balance.',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFD180),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (rows.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No transactions yet. Top-up and wallet activity will appear here.',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(constraints.maxWidth, 1080),
                    child: Column(
                      children: [
                        const _DealsTableHeader(),
                        ...List<Widget>.generate(rows.length, (index) {
                          final row = rows[index];
                          return Column(
                            children: [
                              _DealsTableRow(data: row),
                              Divider(
                                height: 1,
                                color: index == rows.length - 1
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : Colors.white.withValues(alpha: 0.2),
                                thickness: index == rows.length - 1 ? 1 : 0.8,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DealsTableHeader extends StatelessWidget {
  const _DealsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF202224),
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 1.2,
        ),
        child: const Row(
          children: [
            _TableCell(width: 230, child: Text('Service')),
            _TableCell(width: 190, child: Text('Order')),
            _TableCell(width: 210, child: Text('Date - Time')),
            _TableCell(width: 150, child: Text('User')),
            _TableCell(width: 140, child: Text('Amount')),
            _TableCell(width: 130, child: Text('Status')),
          ],
        ),
      ),
    );
  }
}

class _DealsTableRow extends StatelessWidget {
  final _DealRowData data;

  const _DealsTableRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.nunitoSans(
      color: Colors.white.withValues(alpha: 0.85),
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.2,
    );

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          _TableCell(width: 230, child: Text(data.service, style: valueStyle)),
          _TableCell(
            width: 190,
            child: Text(
              data.order,
              style: valueStyle.copyWith(color: const Color(0xFF51D76E)),
            ),
          ),
          _TableCell(width: 210, child: Text(data.dateTime, style: valueStyle)),
          _TableCell(
            width: 150,
            child: Text(
              data.user,
              style: valueStyle.copyWith(color: const Color(0xFF51D76E)),
            ),
          ),
          _TableCell(
            width: 140,
            child: Text(
              data.amount,
              style: valueStyle.copyWith(
                color: data.amountPositive
                    ? const Color(0xFF51D76E)
                    : Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ),
          _TableCell(
            width: 130,
            child: Text(
              data.status,
              style: valueStyle.copyWith(
                color: data.statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final double width;
  final Widget child;

  const _TableCell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool withChevron;
  final bool active;

  const _FilterChip({
    required this.label,
    required this.withChevron,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? const Color(0xFF51D76E) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1,
            ),
          ),
          if (withChevron) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ],
      ),
    );
  }
}

@immutable
class _WalletSummary {
  final double budsBalance;
  final double incomeBalanceUsd;
  final double onHoldUsd;
  final double gemsBalance;
  final double gemDustBalance;

  const _WalletSummary({
    required this.budsBalance,
    required this.incomeBalanceUsd,
    required this.onHoldUsd,
    required this.gemsBalance,
    required this.gemDustBalance,
  });

  double get gemsValueUsd => gemsBalance / 200;

  factory _WalletSummary.fromMap(Map<String, dynamic>? data) {
    double toDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return _WalletSummary(
      budsBalance: toDouble(data?['buds_balance'] ?? data?['balance_buds']),
      incomeBalanceUsd: toDouble(
        data?['income_balance_usd'] ?? data?['wallet_income_usd'],
      ),
      onHoldUsd: toDouble(data?['on_hold_usd'] ?? data?['buds_on_hold']),
      gemsBalance: toDouble(data?['gems_balance'] ?? data?['gems']),
      gemDustBalance: toDouble(data?['gem_dust_balance'] ?? data?['gem_dust']),
    );
  }

  factory _WalletSummary.fromTopupWalletSnapshot(TopupWalletSnapshot wallet) {
    return _WalletSummary(
      budsBalance: wallet.budsBalance,
      incomeBalanceUsd: wallet.incomeBalanceUsd,
      onHoldUsd: wallet.onHoldUsd,
      gemsBalance: wallet.gemsBalance,
      gemDustBalance: wallet.gemDustBalance,
    );
  }
}

@immutable
class _DealRowData {
  final String service;
  final String order;
  final String dateTime;
  final DateTime createdAt;
  final String user;
  final String amount;
  final bool amountPositive;
  final String status;
  final Color statusColor;

  const _DealRowData({
    required this.service,
    required this.order,
    required this.dateTime,
    required this.createdAt,
    required this.user,
    required this.amount,
    required this.amountPositive,
    required this.status,
    required this.statusColor,
  });

  factory _DealRowData.fromMap(String docId, Map<String, dynamic> data) {
    final createdAt = _parseDateTime(data['created_at']) ?? DateTime(1970);
    final flow = (data['flow']?.toString() ?? '').trim().toLowerCase();
    final status = (data['status']?.toString() ?? 'completed').trim();
    final type = (data['type']?.toString() ?? 'credit').trim().toLowerCase();
    final service = _serviceLabel(flow);
    final order = _orderLabel(data, docId);

    final amountBuds = _toDouble(data['amount_buds']);
    final amountUsd = _toDouble(data['amount_usd']);

    final amountPositive = type != 'debit' && type != 'charge';
    final sign = amountPositive ? '+' : '-';

    String amount;
    if (amountBuds > 0) {
      amount = '$sign${_formatAmount(amountBuds)} Buds';
    } else {
      amount = '$sign\$${_formatAmount(amountUsd)}';
    }

    return _DealRowData(
      service: service,
      order: order,
      dateTime: _formatDateTime(createdAt),
      createdAt: createdAt,
      user: data['counterparty']?.toString() ?? 'You',
      amount: amount,
      amountPositive: amountPositive,
      status: _statusLabel(status),
      statusColor: _statusColor(status),
    );
  }

  static String _serviceLabel(String flow) {
    switch (flow) {
      case 'topup':
        return 'Buds top-up';
      case 'subscription':
        return 'Subscription income';
      case 'gift':
        return 'Gift income';
      case 'wishlist':
        return 'Wishlist income';
      case 'refund':
        return 'Refund';
      default:
        if (flow.isEmpty) {
          return 'Wallet activity';
        }
        return flow
            .split('_')
            .map((part) {
              if (part.isEmpty) {
                return part;
              }
              return '${part[0].toUpperCase()}${part.substring(1)}';
            })
            .join(' ');
    }
  }

  static String _orderLabel(Map<String, dynamic> data, String docId) {
    final orderId = data['order_id']?.toString();
    if (orderId != null && orderId.isNotEmpty) {
      return orderId;
    }
    final sessionId = data['stripe_checkout_session_id']?.toString();
    if (sessionId != null && sessionId.isNotEmpty) {
      return sessionId.length > 18 ? sessionId.substring(0, 18) : sessionId;
    }
    return docId;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }
    if (value is DateTime) {
      return value.toLocal();
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  static String _formatDateTime(DateTime value) {
    String two(int x) => x.toString().padLeft(2, '0');
    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${two(value.day)}.${two(value.month)}.${value.year} - ${two(hour12)}.${two(value.minute)} $period';
  }

  static String _statusLabel(String status) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'completed':
      case 'fulfilled':
        return 'Completed';
      case 'pending':
      case 'processing':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'refunded':
        return 'Refunded';
      default:
        if (status.isEmpty) {
          return 'Completed';
        }
        return '${status[0].toUpperCase()}${status.substring(1)}';
    }
  }

  static Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'failed':
      case 'cancelled':
      case 'refunded':
      case 'expired':
        return const Color(0xFFFF2B2B);
      case 'pending':
      case 'processing':
        return const Color(0xFFFFD180);
      default:
        return Colors.white;
    }
  }
}
