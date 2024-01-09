import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/cards/card42button.dart';
import 'package:provider/provider.dart';
import 'strings.dart';
import 'theme.dart';

class Chat2Screen extends StatefulWidget {
  @override
  _Chat2ScreenState createState() => _Chat2ScreenState();
}

class _Chat2ScreenState extends State<Chat2Screen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final TextEditingController _messageEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _init();
    super.initState();
  }

  _init() async {
    var ret = await initChatCompanion((){setState(() {});});
    if (ret != null)
      messageError(context, ret);
  }

  @override
  void dispose() {
    _messageEditingController.dispose();
    _scrollController.dispose();
    if (chatListenCompanion != null)
      chatListenCompanion!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            Container(
                // color: (darkMode) ? blackColorTitleBkg : mainColorGray,
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+90, bottom: 70),
                child: _chatMessages()

            ),

            ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
                    width: windowWidth,
                    child: card42button(
                        userForChat.name,
                        "",
                        _mainModel,
                        windowWidth,(){},
                        userForChat.logoServerPath,
                      height: 100
                    )
                )),

            appbar1(Colors.transparent, Colors.white,
                "", context, () {
              goBack();
            }),

            _editFieldForMessage(),

          ],
        ))

    );
  }

  _editFieldForMessage(){
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(bottom: 10),
      width: windowWidth,
      child: Container(
        padding: EdgeInsets.all(10),
        color: (theme.darkMode) ? theme.blackColorTitleBkg : Color(0x54FFFFFF),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Edit26(
                    hint: strings.get(139), /// "Write your message ...",
                    color: Colors.grey.withAlpha(30),
                    decor: decor,
                    style: theme.style14W400,
                    controller: _messageEditingController,
                    type: TextInputType.emailAddress
                )
                ),
                SizedBox(width: 16,),
                GestureDetector(
                    onTap: () async {
                      if (_messageEditingController.text.isNotEmpty){
                        var ret = await sendChat2Message(_messageEditingController.text, strings.get(183)); /// "Chat message"
                        if (ret == null)
                          setState(() {
                            _messageEditingController.text = "";
                          });
                        else
                          messageError(context, ret);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Image.asset("assets/send.png", fit: BoxFit.contain)
                    )
                ),
              ],
            ),
          ],
        )
      ),
    );
  }

  _chatMessages() {
    List<Widget> list = [];
    DateTime? _lastTime;
    User? user = FirebaseAuth.instance.currentUser;
    for (var item in getMessagesChat2()) {
      var _time = item.time.toLocal();
      if (_lastTime != null)
        if (_time.year != _lastTime.year || _time.month != _lastTime.month ||
            _time.day != _lastTime.day)
          list.add(Center(child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Color(0xffa1f4f0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(DateFormat(appSettings.
            dateFormat).format(_time)),)));
      _lastTime = _time;
      list.add(MessageTile(
        message: item.text,
        sendByMe: user!.uid == item.sendBy,
        time: DateFormat(appSettings.getTimeFormat()).format(_time),
      ));
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent,);
    });
    return ListView(
      controller: _scrollController,
      children: list,);
  }
}


class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String time;

  MessageTile({required this.message, required this.sendByMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [

            if (sendByMe)
              Container(width: 20,),
            if (sendByMe)
              Container(child: Text(time, style: theme.style12W600Grey,),),

            Flexible(child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: sendByMe ? BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10)
                ) :
                BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: sendByMe ? Color(0xffa1f4f0) : Color(0xffe1f0ff),
              ),
              child: Text(message,
                  textAlign: TextAlign.start,
                  maxLines: 20,
                  style: theme.style14W600Grey
              ),
            )),

            if (!sendByMe)
              Container(child: Text(time, style: theme.style12W600Grey,),),
            if (!sendByMe)
              Container(width: 20,),
          ],
        )
    );
  }
}


