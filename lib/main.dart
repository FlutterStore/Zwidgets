import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zwidget/zwidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const AnimatedExample(),
    );
  }
}

class AnimatedExample extends StatefulWidget {
  const AnimatedExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedExampleState();
  }
}

class _AnimatedExampleState extends State<AnimatedExample> {
  final _contentKey = GlobalKey(); // declare a global key
  Size? _size;
  double? _statusBarHeight;
  double _rotationX = 0;
  double _rotationY = 0;
  Offset? _mousePosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _size = MediaQuery.of(context).size;
      _statusBarHeight = MediaQuery.of(context).viewPadding.top;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Animated ZWidget',style: TextStyle(fontSize: 15),),
      ),
      body: Stack(children: [
        Center(
          child: Listener(
            onPointerMove: (PointerMoveEvent event) {
              if (event.down && _size != null) {
                RenderBox box =
                    _contentKey.currentContext!.findRenderObject() as RenderBox;
                Offset targetPosition =
                    box.localToGlobal(box.paintBounds.center);

                final distance = event.position - targetPosition;

                setState(() {
                  _mousePosition = event.position -
                      Offset(0, kToolbarHeight + (_statusBarHeight ?? 0));
                  _rotationY = distance.dx / (_size!.width / 2.0) * 2 * pi;
                  _rotationX = distance.dy / (_size!.height / 2.0) * 2 * pi;
                });
              }
            },
            child: ZWidget.backwards(
              key: _contentKey,
              midChild: ClipRect(
                  child: CustomPaint(
                painter: ExampleCustomPainter(),
                size: const Size(200, 200),
              )),
              rotationX: _rotationX,
              rotationY: _rotationY,
              layers: 11,
              depth: 12,
            ),
          ),
        ),
        if (_mousePosition != null)
          Positioned(
            left: _mousePosition!.dx - 15,
            top: _mousePosition!.dy - 15,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white54,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, spreadRadius: 2)
                  ]),
            ),
          ),
      ]),
    );
  }
}

class ExampleCustomPainter extends CustomPainter {
  @override 
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width / 2.0, size.height / 2.0),
            width: size.width / 4.0,
            height: size.height / 4.0),
        Paint()..color = Colors.black);

    canvas.drawCircle(
        Offset(size.shortestSide / 2.0, size.shortestSide / 2.0),
        size.shortestSide / 3.0,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    canvas.drawLine(Offset.zero, size.bottomRight(Offset.zero),
        Paint()..color = Colors.green);

    canvas.drawLine(
        size.bottomLeft(Offset.zero),
        size.topRight(Offset.zero),
        Paint()
          ..color = Colors.green
          ..strokeWidth = 4);

    canvas.drawCircle(Offset(size.shortestSide / 8.0, size.shortestSide / 2.0),
        size.shortestSide / 10.0, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}