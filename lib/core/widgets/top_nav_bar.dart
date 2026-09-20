import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/core/widgets/glass_container.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({super.key, required this.isHome});

  final bool isHome;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Left: Wallet / History Toggle
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GlassContainer(
                borderRadius: 30,
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isHome) context.go('/home');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isHome
                              ? (context.isDarkMode ? Colors.white : Colors.black)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: isHome
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Wallet',
                          style: context.typography.labelMedium?.copyWith(
                            color: isHome
                                ? (context.isDarkMode ? Colors.black : Colors.white)
                                : context.colors.onSurface.withValues(alpha: 0.6),
                            fontWeight: isHome ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isHome) context.go('/history');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: !isHome
                              ? (context.isDarkMode ? Colors.white : Colors.black)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: !isHome
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'History',
                          style: context.typography.labelMedium?.copyWith(
                            color: !isHome
                                ? (context.isDarkMode ? Colors.black : Colors.white)
                                : context.colors.onSurface.withValues(alpha: 0.6),
                            fontWeight: !isHome ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top Right: Settings
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.settings_rounded,
                    size: 24,
                    color: context.colors.onSurface,
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
