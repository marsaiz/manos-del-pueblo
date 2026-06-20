import 'package:flutter/material.dart';

/// AppBar que se adapta automáticamente a la orientación del dispositivo.
/// En landscape reduce su altura para ganar espacio vertical.
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      toolbarHeight: isLandscape ? 40.0 : kToolbarHeight,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: isLandscape ? 14.0 : 18.0,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      ),
      iconTheme: IconThemeData(
        size: isLandscape ? 20.0 : 24.0,
        color: Colors.white,
      ),
    );
  }

  /// PreferredSizeWidget requiere este getter para que Scaffold
  /// calcule correctamente el espacio del AppBar
  @override
  Size get preferredSize {
    // Usamos WidgetsBinding para obtener la orientación actual
    final window = WidgetsBinding.instance.platformDispatcher.views.first;
    final isLandscape = window.physicalSize.width > window.physicalSize.height;
    return Size.fromHeight(isLandscape ? 40.0 : kToolbarHeight);
  }
}
