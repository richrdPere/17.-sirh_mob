import 'package:flutter/material.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final double elevation;
  final Color? backgroundColor;
  final Color? iconColor;
  final double height;

  const TAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.elevation = 0,
    this.backgroundColor,
    this.iconColor,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? IconButton(
              onPressed: leadingOnPressed, // Volver atras
              icon: Icon(
                Icons.arrow_back,
                color: iconColor ?? Theme.of(context).iconTheme.color,
              ),
            )
          : leadingIcon != null
          ? IconButton(
              onPressed: leadingOnPressed,
              icon: Icon(
                leadingIcon,
                color: iconColor ?? Theme.of(context).iconTheme.color,
              ),
            )
          : null,
      title: title,
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}
