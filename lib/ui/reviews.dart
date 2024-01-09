// import 'dart:math';
// import 'package:flutter/material.dart';
// import '../strings.dart';
// import 'theme.dart';
// import 'package:ondemandservice/widgets/appbars/appbar1.dart';
// import 'package:ondemandservice/widgets/cards/card46.dart';
// import 'package:ondemandservice/widgets/cards/card47.dart';
// import 'package:ondemandservice/widgets/clippath/clippath23.dart';
//
// class ReviewsScreen extends StatefulWidget {
//   @override
//   _ReviewsScreenState createState() => _ReviewsScreenState();
// }
//
// class _ReviewsScreenState extends State<ReviewsScreen>  with TickerProviderStateMixin{
//
//   double windowWidth = 0;
//   double windowHeight = 0;
//   double windowSize = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     windowWidth = MediaQuery.of(context).size.width;
//     windowHeight = MediaQuery.of(context).size.height;
//     windowSize = min(windowWidth, windowHeight);
//     return Scaffold(
//         backgroundColor: (darkMode) ? blackColorTitleBkg : mainColorGray,
//         body: Directionality(
//         textDirection: strings.direction,
//         child: Stack(
//           children: <Widget>[
//
//             Container(
//               margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+130, left: 10, right: 10),
//               child: ListView(
//                 children: [
//
//                   card47("assets/user1.jpg",
//                       "Carter Anne", theme.style16W800,
//                       "20 Dec 2021", theme.style12W600Grey,
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ",
//                       theme.style14W400,
//                       false, (darkMode) ? Colors.black : Colors.white,
//                       ["assets/barber/1.jpg", "assets/barber/2.jpg", "assets/barber/3.jpg", "assets/barber/4.jpg",
//                         "assets/barber/5.jpg", "assets/barber/6.jpg", ],
//                       3, Colors.orange
//                   ),
//
//                   SizedBox(height: 20,),
//
//                   card47("assets/user2.jpg",
//                       "Carter Anne", theme.style16W800,
//                       "20 Dec 2021", theme.style12W600Grey,
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ",
//                       theme.style14W400,
//                       false, (darkMode) ? Colors.black : Colors.white,
//                       [],
//                       5, Colors.orange
//                   ),
//
//                   SizedBox(height: 20,),
//
//                   card47("assets/user3.jpg",
//                       "Carter Anne", theme.style16W800,
//                       "20 Dec 2021", theme.style12W600Grey,
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ",
//                       theme.style14W400,
//                       false, (darkMode) ? Colors.black : Colors.white,
//                       ["assets/barber/1.jpg", "assets/barber/2.jpg", "assets/barber/3.jpg", "assets/barber/4.jpg",
//                         "assets/barber/5.jpg", "assets/barber/6.jpg", ],
//                       3, Colors.orange
//                   ),
//
//                   SizedBox(height: 20,),
//
//                   card47("assets/user4.jpg",
//                       "Carter Anne", theme.style16W800,
//                       "20 Dec 2021", theme.style12W600Grey,
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ",
//                       theme.style14W400,
//                       false, (darkMode) ? Colors.black : Colors.white,
//                       ["assets/barber/3.jpg", "assets/barber/4.jpg",
//                         "assets/barber/5.jpg", "assets/barber/6.jpg", ],
//                       3, Colors.orange
//                   ),
//
//                   SizedBox(height: 120,),
//                 ],
//               ),
//             ),
//
//             ClipPath(
//                 clipper: ClipPathClass23(20),
//                 child: Container(
//                     margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//                     width: windowWidth,
//                     child: card46(
//                         "4.6", theme.style25W800,
//                         strings.get(42), // "Average Ratings",
//                         theme.style16W600Grey,
//                         Image.asset("assets/ondemands/ondemand13.png", fit: BoxFit.cover),
//                         windowWidth, (darkMode) ? Colors.black : Colors.white, _makePhoto
//                     )
//                 )),
//
//             appbar1(Colors.transparent, (darkMode) ? Colors.white : Colors.black, "", context, () {
//               Navigator.pop(context);
//             }),
//
//
//           ],
//         ))
//
//     );
//   }
//
//   _makePhoto(){
//
//   }
// }
//
//
