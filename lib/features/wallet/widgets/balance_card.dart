import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settl/core/utils/formatters.dart';
import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/core/widgets/glass_container.dart';
import 'package:settl/features/identity/providers/identity_provider.dart';

/// Glassmorphism balance card showing USDC and SOL balances.
class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({
    super.key,
    required this.usdcBalance,
    required this.solBalance,
    required this.walletAddress,
    this.isLoading = false,
  });

  final double usdcBalance;
  final double solBalance;
  final String walletAddress;
  final bool isLoading;

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  final GlobalKey _cardKey = GlobalKey();
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isDragging = false;

  void _updateTilt(Offset globalPosition) {
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dx = ((localPosition.dx - centerX) / centerX).clamp(-1.0, 1.0);
    final dy = ((localPosition.dy - centerY) / centerY).clamp(-1.0, 1.0);

    setState(() {
      _tiltY = -dx * 0.15;
      _tiltX = dy * 0.15;
      _isDragging = true;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _tiltX == 0.0 && _tiltY == 0.0) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final innerCardColor = isDark ? Colors.white : Colors.black;
    final innerTextColor = isDark ? Colors.black : Colors.white;
    final innerMutedColor = isDark ? Colors.black54 : Colors.white54;

    return GestureDetector(
      onPanDown: (details) => _updateTilt(details.globalPosition),
      onPanUpdate: (details) => _updateTilt(details.globalPosition),
      onPanEnd: (_) => _resetTilt(),
      onPanCancel: () => _resetTilt(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fixed background glow (Always visible, peeping from top part of card)
          Positioned(
            top: 40,
            left: 60,
            right: 60,
            height: 100,
            child: AnimatedOpacity(
              opacity: _isDragging ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF14F195),
                      Color(0xFF9945FF),
                      Color(0xFF14F195),
                      Color(0xFF9945FF),
                      Color(0xFF14F195),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ),
          
          // Tiltable Card
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            tween: Tween(begin: 0, end: _tiltX),
            builder: (context, tiltX, child) {
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                tween: Tween(begin: 0, end: _tiltY),
                builder: (context, tiltY, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateX(tiltX)
                      ..rotateY(tiltY),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: child,
              );
            },
            child: AnimatedContainer(
              key: _cardKey,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isDragging ? 0.0 : 0.3),
                    blurRadius: _isDragging ? 0 : 30,
                    offset: Offset(0, _isDragging ? 0 : 15),
                  ),
                ],
              ),
              child: GlassContainer(
                disableBlur: _isDragging,
                borderRadius: 32,
                padding: const EdgeInsets.all(8),
                borderOpacity: 0.2,
                opacity: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top layer (Glassy with address)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ref.watch(identityServiceProvider).resolvePubKeyToSettlId(widget.walletAddress) ?? 'anon@settl',
                            style: context.typography.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            Formatters.truncateAddress(widget.walletAddress),
                            style: context.typography.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Inner card
                    Container(
                      decoration: BoxDecoration(
                        color: innerCardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Solana badge
                          Positioned(
                            right: 24,
                            top: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9945FF), Color(0xFF14F195)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9945FF).withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(-2, 2),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF14F195).withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Solana',
                                style: context.typography.labelMedium?.copyWith(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Credit',
                                  style: context.typography.bodyMedium?.copyWith(
                                    color: innerMutedColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                widget.isLoading
                                    ? _buildShimmer(innerCardColor)
                                    : Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            Formatters.usdcAmount(widget.usdcBalance),
                                            style: context.typography.displayLarge?.copyWith(
                                              color: innerTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'USDC',
                                              style: context.typography.titleMedium?.copyWith(
                                                color: innerMutedColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: innerTextColor.withValues(alpha: isDark ? 0.05 : 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/sol.svg',
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(innerMutedColor, BlendMode.srcIn),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SOL Balance: ${widget.solBalance.toStringAsFixed(4)}',
                                        style: context.typography.labelMedium?.copyWith(
                                          color: innerMutedColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildShimmer(Color innerCardColor) {
    return Container(
      width: 180,
      height: 48,
      decoration: BoxDecoration(
        color: innerCardColor == Colors.black ? Colors.white24 : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
