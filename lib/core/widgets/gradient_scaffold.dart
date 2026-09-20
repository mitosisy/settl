import 'package:flutter/material.dart';
import 'package:chain_pay/core/theme/theme_extension.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.isHome = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    // In dark mode: fully black background
    // In light mode: fully white background
    final Color bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: true, // Make top section seamless
      backgroundColor: Colors.transparent,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: body,
      ),
    );
  }
}
