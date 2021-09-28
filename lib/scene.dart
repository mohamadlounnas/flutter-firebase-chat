import 'package:flutter/material.dart';

class Scene extends StatelessWidget {
  final Widget child;
  final Widget? placeholder;
  final bool loading;
  final bool scroll;
  final bool center;
  final bool active;

  const Scene(
      {Key? key,
      required this.child,
      this.placeholder,
      this.loading = false,
      this.scroll = false,
      this.center = true,
      this.active = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var _child = child;
    if (scroll) {
      _child = SingleChildScrollView(child: _child);
    }
    if (center) {
      _child = Center(child: _child);
    }
    return Scaffold(
      body: Stack(
        children: [
          _child,
          if (loading) ...[
            const Positioned.fill(child: ColoredBox(color: Colors.white54)),
            const Center(child: CircularProgressIndicator()),
          ],
          if (!active && placeholder != null && !loading) ...[
            const Positioned.fill(child: ColoredBox(color: Colors.white54)),
            Center(child: placeholder),
          ],
        ],
      ),
    );
  }
}
