import 'dart:math';

import 'package:flutter/material.dart';

class ShrinkSlideRotateSideMenuState extends SideMenuState {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final statusBarHeight = mq.padding.top;

    return Material(
      color: widget.background != null
          ? widget.background
          : const Color(0xFF112473),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: statusBarHeight + (widget.closeIcon.size ?? 25.0) * 2,
            // top: statusBarHeight + (widget.closeIcon.size ?? 25.0) * 2,
            bottom: statusBarHeight + (widget.closeIcon.size ?? 25.0) * 2,
            // bottom: 0.0,
            width: size.width * 0.60,
            right: widget._inverse == 1 ? null : 0,
            child: ClipRRect(
                borderRadius: _getBorderRadius()
                    .copyWith(bottomRight: Radius.zero, topRight: Radius.zero),
                child: widget.menu),
          ),
          _getCloseButton(statusBarHeight),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastLinearToSlowEaseIn,
            transform: _getMatrix4(size),
            decoration: BoxDecoration(
                borderRadius: _getBorderRadius(),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 18.0),
                      color: Colors.black12,
                      blurRadius: 32.0)
                ]),
            child: _getChild(),
          ),
        ],
      ),
    );
  }

  Widget _getChild() => _opened
      ? SafeArea(
          child: ClipRRect(
            borderRadius: _getBorderRadius(),
            clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        )
      : widget.child;

  BorderRadius _getBorderRadius() => _opened
      ? (widget.radius != null ? widget.radius : BorderRadius.circular(34.0))
      : BorderRadius.zero;

  Matrix4 _getMatrix4(Size size) {
    if (_opened) {
      return Matrix4.identity()
        ..rotateZ(widget.degToRad(2.0 * widget._inverse))
        ..invertRotation()
        ..translate(min(size.width / 3, widget.maxMenuWidth) * widget._inverse,
            size.height * .1)
        ..scale(.8, .8);
    }
    return Matrix4.identity();
  }
}

/// Shrink Side Menu Types
enum SideMenuType {
  /// child will shrink slide and rotate when sidemenu opens
  shrikNRotate,

  /// child will shrink and slide when sidemenu opens
  shrinkNSlide,

  /// child will slide and rotate when sidemenu opens
  slideNRotate,

  /// child will slide when sidemenu opens
  slide,
}

/// Liquid Shrink Side Menu is compatible with [Liquid ui](https://pub.dev/packages/liquid_ui)
///
/// Create a SideMenu / Drawer
///
class SideMenu extends StatefulWidget {
  final int _inverse;

  /// Widget that should be enclosed in sidemenu
  ///
  /// generally a [Scaffold] and should not be `null`
  final Widget child;

  /// Background color of the side menu
  ///
  /// default: Color(0xFF112473)
  final Color background;

  /// Radius for the child when side menu opens
  final BorderRadius radius;

  /// Close Icon
  final Icon closeIcon;

  /// Menu that should be in side menu
  ///
  /// generally a [SingleChildScrollView] with a [Column]
  final Widget menu;

  /// Maximum constrints for menu width
  ///
  /// default: `275.0`
  final double maxMenuWidth;

  /// Type of Side menu
  ///
  /// 1. shrikNRotate
  /// 2. shrinkNSlide
  /// 3. slideNRotate
  /// 4. slide
  final SideMenuType type;
  final closeDrawer;

  /// Liquid Shrink Side Menu is compatible with [Liquid ui](https://pub.dev/packages/liquid_ui)
  ///
  /// Create a SideMenu / Drawer
  ///
  ///
  ///```dart
  ///
  ///final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  ///
  ///SideMenu(
  ///    key: _sideMenuKey, // to toggle this sidemenu
  ///    menu: buildMenu(),
  ///    type: SideMenuType.slideNRotate, // check above images
  ///    child: Scaffold(
  ///        appBar: AppBar(
  ///            leading: IconButton(
  ///              icon: Icon(Icons.menu),
  ///              onPressed: () {
  ///                final _state = _sideMenuKey.currentState;
  ///                if (_state.isOpened)
  ///                  _state.closeDrawer(); // close side menu
  ///                else
  ///                  _state.openDrawer();// open side menu
  ///              },
  ///            ),
  ///        ...
  ///    ),
  ///);
  ///```
  ///
  ///Set `inverse` equals `true` to create end sidemenu
  ///
  const SideMenu({
    Key? key,
    required this.child,
    required this.background,
    required this.radius,
    this.closeIcon = const Icon(
      Icons.close,
      color: Colors.black,
    ),
    required this.menu,
    this.type = SideMenuType.shrikNRotate,
    this.maxMenuWidth = 275.0,
    bool inverse = false,
    required this.closeDrawer,
  })  : assert(maxMenuWidth > 0),
        _inverse = inverse ? -1 : 1,
        super(key: key);

  static SideMenuState? of(BuildContext context) {
    return context.findAncestorStateOfType<SideMenuState>();
  }

  double degToRad(double deg) => (pi / 180) * deg;

  bool get inverse => _inverse == -1;

  @override
  SideMenuState createState() {
    // if (type == SideMenuType.shrikNRotate)
    return ShrinkSlideRotateSideMenuState();
    // if (type == SideMenuType.shrinkNSlide) return ShrinkSlideSideMenuState();
    // if (type == SideMenuType.slide) return SlideSideMenuState();
    // if (type == SideMenuType.slideNRotate) return SlideRotateSideMenuState();
    // return null;
  }
}

abstract class SideMenuState extends State<SideMenu> {
  bool _opened = false;

  /// open SideMenu
  void openSideMenu() => setState(() => _opened = true);

  /// close SideMenu
  void closeSideMenu() => setState(() {
        _opened = false;
      });

  /// get current status of sidemenu
  bool get isOpened => _opened;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    _opened = false;
    super.initState();
  }

  Widget _getCloseButton(double statusBarHeight) {
    return widget.closeIcon != null
        ? Positioned(
            top: statusBarHeight,
            left: widget.inverse ? null : 0,
            right: widget.inverse ? 0 : null,
            child: IconButton(
              icon: widget.closeIcon,
              onPressed: () {
                closeSideMenu();
                widget.closeDrawer();
              },
            ),
          )
        : Container();
  }
}
