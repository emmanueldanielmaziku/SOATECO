import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const CustomContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.cardColor,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: border,
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: gradient,
        ),
        child: child,
      ),
    );
  }

  // Factory constructors for common container styles
  factory CustomContainer.card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return CustomContainer(
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      width: width,
      height: height,
      backgroundColor: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
    );
  }

  factory CustomContainer.gradient({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Gradient? gradient,
    VoidCallback? onTap,
  }) {
    return CustomContainer(
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      width: width,
      height: height,
      gradient: gradient ?? AppTheme.primaryGradient,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
    );
  }

  factory CustomContainer.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color borderColor = AppTheme.primaryColor,
    VoidCallback? onTap,
  }) {
    return CustomContainer(
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      width: width,
      height: height,
      backgroundColor: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: 1.5),
      onTap: onTap,
    );
  }
}
