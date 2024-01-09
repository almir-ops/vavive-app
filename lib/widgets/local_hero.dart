import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LocalHero extends StatefulWidget {
  final Widget? child;
  final Function() getStart;
  final Function() setStart;
  final Function() setEnd;
  final Function() getKeySource;
  final Function() getKeyDest;

  const LocalHero({Key? key, this.child, required this.getStart, required this.getKeySource,
    required this.getKeyDest, required this.setStart, required this.setEnd}) : super(key: key);
  @override
  _LocalHeroState createState() => _LocalHeroState();
}

class _LocalHeroState extends State<LocalHero> with SingleTickerProviderStateMixin {

  double windowWidth = 0;
  double windowHeight = 0;

  late AnimationController _controller2;
  Animation? _animation2;
  final GlobalKey _keyCanvas = GlobalKey();

  Offset _start = Offset(0, 0);
  Offset _end = Offset(0, 0);
  Size _startSize = Size(0, 0);
  Size _endSize = Size(0, 0);
  Size _canvasSize = Size(0, 0);

  @override
  void initState() {
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    if (widget.getStart()){
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _animate();
      });
    }

    return Stack(
        children: <Widget>[

          if (widget.child != null)
            widget.child!,

          Container(
              key :_keyCanvas,
              width: windowWidth,
              height: windowHeight,
              child: _heroChild()
          )

        ]
    );
  }

  Uint8List? _pngBytes;

  _animate() async {
    if (_keyCanvas.currentContext == null) {
      print("_keyCanvas.currentContext == null");
      return;
    }

    var source = widget.getKeySource().currentContext;
    var dest = widget.getKeyDest().currentContext;
    print("source=$source dest=$dest");
    if (source != null && _pngBytes == null){
      _end = Offset(0, 0);
      var keySource = widget.getKeySource();
      _startSize = keySource.currentContext!.size!;
      RenderBox box = keySource.currentContext!.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero); //this is global position
      // print("source $position");
      RenderBox boxCanvas = _keyCanvas.currentContext!.findRenderObject() as RenderBox;
      _start = boxCanvas.globalToLocal(position);
      // print("local $_start");
      RenderRepaintBoundary _render = keySource.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var _image = await _render.toImage();
      var byteData = await _image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        print("byteData == null");
        return;
      }
      _pngBytes = byteData.buffer.asUint8List();
      widget.setStart();
      print("_animation2 = Tween");
      _animation2 = Tween(begin: 0.0, end: 100).animate(_controller2)
        ..addListener(() {
          setState(() {});
        })..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller2.reset();
            _animation2 = null;
            _pngBytes = null;
            print("-------------------");
          }
          // _controller2.dispose();
          // _controller2.reverse();
          // else
          // if (status == AnimationStatus.dismissed)
          //   _controller2.forward();
        });

      _controller2.forward();
    }
    if (dest != null && _pngBytes != null){
      widget.setEnd();
      var keyDest = widget.getKeyDest();

      RenderBox boxCanvas = _keyCanvas.currentContext!.findRenderObject() as RenderBox;
      _canvasSize = _keyCanvas.currentContext!.size!;

      // print("${_keyDest.currentContext!.size}");
      _endSize = keyDest.currentContext!.size!;
      RenderBox box2 = keyDest.currentContext!.findRenderObject() as RenderBox;
      Offset position2 = box2.localToGlobal(Offset.zero); //this is global position
      // print("dest $position2");
      _end = boxCanvas.globalToLocal(position2);
      // print("local $_end");
    }
  }

  _heroChild(){
    if (_animation2 == null || _pngBytes == null)
      return Container();

    double dx = _start.dx;
    double dy = _start.dy;
    double w = _startSize.width;
    double h = _startSize.height;
    print("dx=$dx dy=$dy");
    //if (_end.dx != 0 && _end.dy != 0) {
    if (!_controller2.isCompleted){
      double dx1 = (_end.dx - _start.dx).abs();
      double dx2 = dx1 / 100 * _animation2!.value;
      dx = dx2 + _start.dx;
      if (_end.dx < _start.dx) {
        dx2 = dx1 / 100 * (100 - _animation2!.value);
        dx = _end.dx + dx2;
      }

      double dy1 = (_end.dy - _start.dy).abs();
      double dy2 = dy1 / 100 * _animation2!.value;
      dy = dy2 + _start.dy;
      if (_end.dy < _start.dy) {
        dy2 = dy1 / 100 * (100 - _animation2!.value);
        dy = _end.dy + dy2;
      }

      //print("${_animation2!.value} $_start $_end dx1=$dx1 dx2=$dx2 dx=$dx dy1=$dy1 dy2=$dy2 dy=$dy");

      //
      double w1 = (_endSize.width - _startSize.width).abs();
      double w2 = w1 / 100 * _animation2!.value;
      w = _startSize.width + w2;
      if (_endSize.width < _startSize.width)
        w = _startSize.width - w2;
      //
      double h1 = (_endSize.height - _startSize.height).abs();
      double h2 = h1 / 100 * _animation2!.value;
      h = _startSize.height + h2;
      if (_endSize.height < _startSize.height)
        h = _startSize.height - h2;

   // print("${_animation2!.value} _startSize=$_startSize _endSize=$_endSize w1=$w1 w2=$w2 w=$w h1=$h1 h2=$h2 h=$h");

      if (dx < 0) return Container();
      if (dy < 0) return Container();
      if (dy > _canvasSize.height) return Container();
      if (dy + h > _canvasSize.height)
        h = _canvasSize.height - dy;
    }
    // widget.keySource.currentContext!.owner.
    return Container(
        alignment: Alignment.topLeft,
        child: UnconstrainedBox(
            child: Container(
                width: w,
                height: h,
                margin: EdgeInsets.only(left: dx, top: dy),
                // color: Colors.blue
              child: Image.memory(_pngBytes!, width: w, height: h, fit: BoxFit.contain,),
              // child: widget.keySource.currentContext!.widget,
            )));
  }
}