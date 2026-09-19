import 'package:flutter/material.dart';

import 'package:chain_pay/core/theme/app_colors.dart';
import 'package:chain_pay/core/theme/app_typography.dart';
import 'package:chain_pay/core/constants/strings.dart';

/// Slide-to-pay button for confirming transactions.
class SlideToPayButton extends StatefulWidget {
  const SlideToPayButton({
    super.key,
    required this.onConfirmed,
    this.isLoading = false,
  });

  final VoidCallback onConfirmed;
  final bool isLoading;

  @override
  State<SlideToPayButton> createState() => _SlideToPayButtonState();
}

class _SlideToPayButtonState extends State<SlideToPayButton> {
  double _dragValue = 0.0;
  bool _isConfirmed = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isConfirmed || widget.isLoading) return;
    
    setState(() {
      _dragValue += details.primaryDelta! / maxWidth;
      _dragValue = _dragValue.clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isConfirmed || widget.isLoading) return;
    
    if (_dragValue > 0.8) {
      setState(() {
        _dragValue = 1.0;
        _isConfirmed = true;
      });
      widget.onConfirmed();
    } else {
      setState(() {
        _dragValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final thumbSize = 56.0;
        final dragDistance = maxWidth - thumbSize;
        
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Text
              Center(
                child: Text(
                  widget.isLoading ? Strings.broadcasting : Strings.slideToPay,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              
              // Animated progress background
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: thumbSize + (_dragValue * dragDistance),
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.brandSaffron.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              
              // Draggable Thumb
              AnimatedPositioned(
                duration: _dragValue == 0.0 ? const Duration(milliseconds: 300) : Duration.zero,
                curve: Curves.easeOutBack,
                left: _dragValue * dragDistance,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, dragDistance),
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.brandSaffron,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.bgDeep,
                              ),
                            )
                          : const Icon(
                              Icons.double_arrow_rounded,
                              color: AppColors.textPrimary,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
