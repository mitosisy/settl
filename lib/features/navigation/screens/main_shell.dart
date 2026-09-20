import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chain_pay/core/widgets/glass_container.dart';
import 'package:chain_pay/core/theme/theme_extension.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The current location to determine which tab is active
    final String location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (location.startsWith('/home')) currentIndex = 0;
    if (location.startsWith('/receive')) currentIndex = 1;
    if (location.startsWith('/scan')) currentIndex = 2;
    if (location.startsWith('/history')) currentIndex = 3;
    if (location.startsWith('/settings')) currentIndex = 4;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by GradientScaffold in pages
      body: Stack(
        children: [
          // The current page
          child,
          
          // Floating Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 32, // Floating above the bottom edge
            child: _FloatingNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/receive');
                    break;
                  case 2:
                    context.go('/scan');
                    break;
                  case 3:
                    context.go('/history');
                    break;
                  case 4:
                    context.go('/settings');
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GlassContainer(
        height: 70,
        borderRadius: 35,
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Expanded(
            child: _NavBarItem(
              icon: Icons.home_rounded,
              label: "Home",
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              icon: Icons.document_scanner_rounded,
              label: "Scan",
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              icon: Icons.qr_code_2_rounded,
              label: "Receive",
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    
    // Glassy highlight instead of solid black/white
    Color selectedBgColor = isDark 
        ? Colors.white.withValues(alpha: 0.15) 
        : Colors.black.withValues(alpha: 0.08);
    Color iconColor = colors.onSurface;
    Color unselectedIconColor = colors.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        margin: EdgeInsets.zero, // removed horizontal and vertical margin to fill height
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(100), // pill shaped
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? iconColor : unselectedIconColor, 
              size: 24
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.typography.labelSmall?.copyWith(
                color: isSelected ? iconColor : unselectedIconColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
