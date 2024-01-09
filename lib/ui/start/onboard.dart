import 'package:abg_utils/abg_utils.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/widgets/buttons/button182.dart';
import '../strings.dart';
import '../theme.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {

  //////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Data for pages
  //
  List<Page> pages = [
    Page(
        image : AssetImage('assets/x1.png'),
        title: strings.get(130), /// "Get favorite service"
        bodyText: strings.get(131)), /// Select your location to see the wide range providers and booking your desired service.
    Page(
        image : AssetImage('assets/x2.png'),
        title: strings.get(132), /// "Easy payment",
        bodyText: strings.get(133)), /// Booking service with COD payment or pay by safer and faster payment gateways.
    Page(
        image : AssetImage('assets/x3.png'),
        title: strings.get(134), /// Fast work
        bodyText: strings.get(135)), /// Hundreds of service man are waiting for you booking.
  ];

  //
  // User press "Skip" button
  //
  _pressSkipButton(){
    Navigator.pushNamedAndRemoveUntil(context, "/main", (_) => false);
  }

  //
  // User press "Down" button
  //
  _pressDownButton(){
    Navigator.pushNamedAndRemoveUntil(context, "/main", (_) => false);
  }

  //
  // Page select listener.
  //
  _pageSelect(int index){
    print("Current page: $index");
  }

  Animation<double>? _animation;
  AnimationController? _controller;
  double _fraction = 100.0;
  var _curIndex = 0;
  var _curIndex2 = 0;
  final _duration = 1000;
  var _move = false;

  @override
  void initState() {
    _pageSelect(0);
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: _duration), vsync: this);
    _animation = Tween(begin: 100.0, end: 0.0).animate(_controller!)
      ..addListener(() {
        setState(() {
          _fraction = _animation!.value;
        });
      })..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _move = false;
        if (_moveBack) {
          _moveBack = false;
          if (_curIndex > 0) {
            _curIndex--;
            _pageSelect(_curIndex);
          }
        }else
          if (_curIndex < pages.length-1) {
            _curIndex++;
            _pageSelect(_curIndex);
          }
        _controller!.reset();
      }
        //}else if(status == AnimationStatus.dismissed)
        // _controller.forward();
      });
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void go() {
    if (_move)
      return;
    if (_curIndex < pages.length-1) {
      _move = true;
      _curIndex2 = _curIndex2+1;
      _controller!.forward();
    }
  }

  bool _moveBack = false;

  void goBack() {
    if (_move)
      return;
    if (_curIndex > 0) {
      _move = true;
      _curIndex2 = _curIndex-1;
      _moveBack = true;
      _controller!.forward();
    }
  }

  double windowWidth = 0.0;
  double windowHeight = 0.0;
  var _fraction2 = 100.0;
  DragStartDetails? _dragStartPosition;

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;

    var _if = pages[_curIndex].image;
    var _ifTitle = pages[_curIndex].title;
    var _ifbodyText = pages[_curIndex].bodyText;

    var _ib = pages[_curIndex].image;
    var _ibTitle = pages[_curIndex].title;
    var _ibbodyText = pages[_curIndex].bodyText;

    if (_curIndex+1 < pages.length) {
        _ib = pages[_curIndex + 1].image;
        _ibTitle = pages[_curIndex + 1].title;
        _ibbodyText = pages[_curIndex + 1].bodyText;
    }
    if (_moveBack) {
      if (_curIndex > 0) {
        _ib = pages[_curIndex - 1].image;
        _ibTitle = pages[_curIndex - 1].title;
        _ibbodyText = pages[_curIndex - 1].bodyText;
      }
    }

    if (_move)
      _fraction2 = _fraction;

    var _color = theme.darkMode ? Colors.black : mainColorGray;

    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (DragStartDetails details) {
            _dragStartPosition = details;
        },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (_dragStartPosition!.globalPosition.dx > details.globalPosition.dx)
              go();
            else
              goBack();
          },
          child: Stack(
          children: <Widget>[

            // Background
            Container(
                color: _color,
                width: windowWidth,
                height: windowHeight,
                child: _buildInfo(_ib, _ibTitle, _ibbodyText, _fraction2)
            ),

            // Foreground
            ClipPath(clipper: BezierClipper(
                clock: _fraction,
              ),
              child: Container(
                  color: _color,
                  width: windowWidth,
                  height: windowHeight,
                  child: _buildInfo(_if, _ifTitle, _ifbodyText, 0)
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_curIndex != 2)
                        button134(strings.get(136), _pressSkipButton, style: theme.style14W800), ///  "Skip"
                      if (_curIndex == 2)
                        Container(
                          width: windowWidth/2,
                          child: button182(strings.get(137), theme.style14W800W, /// "GET STARTED"
                              theme.mainColor, 10, _pressDownButton, true),
                        ),
                      SizedBox(height: 30,),
                      pagination1(3, _curIndex, theme.mainColor)
                    ],
                  ),
                  )
            )
            ],
        ),

        ));
  }

  _buildInfo(var _ib, String _ibTitle, String _ibbodyText, var _fraction2){

    return Center(
      child: Container(

          margin: EdgeInsets.only(left: 30, right: 30,top: _fraction2/2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Image(image: _ib),
              SizedBox(height: 15,),
              Container(
                  margin: EdgeInsets.only(top: _fraction2/5),
                  child: Text(_ibTitle,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: theme.style14W800MainColor
                  )),
              SizedBox(height: 15,),
              Text(_ibbodyText,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: theme.style12W400
              ),

            ],
          )
      ),
    );
  }
}


class BezierClipper extends CustomClipper<Path>{
  double clock = 100;
  BezierClipper({required this.clock});

  @override
  Path getClip(Size size){
    var start = size.height*clock/100;

    Path path = Path();
    path.lineTo(0, start);
    if (clock != 100)
      path.quadraticBezierTo(size.width/2, start-size.height*0.4, size.width, start);
    else
      path.lineTo(size.width, start);

    path.lineTo(size.width, 0);

    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}


class Page{
  final AssetImage image;
  final String title;
  final String bodyText;

  Page({required this.image, required this.title, required this.bodyText});
}



class RevealProgressButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RevealProgressButtonState();
}

class _RevealProgressButtonState extends State<RevealProgressButton>
    with TickerProviderStateMixin {
  Animation<double>? _animation;
  AnimationController? _controller;
  double _fraction = 0.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
      RevealProgressButtonPainter(_fraction, MediaQuery.of(context).size),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 3000), (){
      reveal();
    });
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void reveal() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller!)
      ..addListener(() {
        setState(() {
          _fraction = _animation!.value;
        });
      });

    _controller!.forward();
  }

}

class RevealProgressButtonPainter extends CustomPainter {
  double fraction = 0.0;
  final Size _screenSize;

  RevealProgressButtonPainter(this.fraction, this._screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    var finalRadius = sqrt(pow(_screenSize.width, 2) + pow(_screenSize.height, 2));
    var radius = 24.0 + finalRadius * fraction;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(RevealProgressButtonPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}