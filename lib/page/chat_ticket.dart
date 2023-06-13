import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hamsignal/controller/AnimationController.dart';
import 'package:hamsignal/controller/TicketController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/main.dart';
import 'package:hamsignal/widget/shakeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/Ticket.dart';

class ChatPage extends StatelessWidget {
  late TicketController ticketController;
  late SettingController settingController;
  late Style styleController;
  MyAnimationController animationController = Get.find<MyAnimationController>();
  UserController userController = Get.find<UserController>();
  TextEditingController textController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Ticket ticket;
  String? chatId;

  ChatPage({Key? key, required this.ticket}) : super(key: key) {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    ticketController = TicketController();
    chatId = this.ticket?.id ?? '';
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ticketController.filterController.filters['chat_id'] = chatId;
      ticketController
          .getChat(param: {'ticket_id': ticket.id, 'page': 'clear'});

      edit();

      scrollController.addListener(() {
        if (scrollController.position.pixels + 50 >
                scrollController.position.maxScrollExtent &&
            !ticketController.loading) {
          ticketController.getChat(param: {'ticket_id': ticket.id});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: styleController.mainGradientBackground,
            image: DecorationImage(
                image: AssetImage("assets/images/texture.jpg"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.scaleDown,
                filterQuality: FilterQuality.medium,
                colorFilter: ColorFilter.mode(
                    styleController.secondaryColor.withOpacity(.2),
                    BlendMode.colorBurn),
                opacity: .05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: styleController.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        bottom:
                            Radius.circular(styleController.cardBorderRadius))),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.all(styleController.cardMargin * 2),
                  title: Text(
                    "${'ticket_id'.tr}: ${chatId}",
                    style: styleController.textMediumLightStyle,
                  ),
                  subtitle: Text(
                    ticket.subject,
                    style: styleController.textMediumLightStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ticketController.obx(
                  (c) => Visibility(
                      visible: ticketController.loading,
                      child: CupertinoActivityIndicator()),
                  onLoading: CupertinoActivityIndicator(),
                  onError: (e) => Center()),
              Expanded(
                  child: RefreshIndicator(
                onRefresh: () => ticketController
                    .getChat(param: {'page': 'clear', 'ticket_id': ticket.id}),
                child: ticketController.obx((contacts) {
                  if (contacts != null)
                    return ListView(
                        controller: scrollController,
                        reverse: true,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: false,
                        children: [
                          ...contacts
                              .map<Widget>((c) => ChatCell(
                                  chat: c,
                                  fromUser: userController.user != null &&
                                      userController.user?.id == c.fromId))
                              .toList()
                        ]);
                  return Center();
                },
                    onError: (e) => Center(),
                    onEmpty: Center(),
                    onLoading: Center()),
              )),
              Container(
                color: Colors.white,
                child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton.icon(
                            style: ButtonStyle(
                                overlayColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    return states
                                            .contains(MaterialState.pressed)
                                        ? styleController.secondaryColor
                                        : null;
                                  },
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    styleController.primaryColor),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          styleController.cardMargin)),
                                ))),
                            onPressed: () async {
                              bool res = await ticketController.sendMessage(
                                  ticketId: ticket.id,
                                  message: textController.text,
                                  cmnd: 'user_send_chat');
                              if (res) {
                                ticketController.getChat(param: {
                                  'ticket_id': ticket.id,
                                  'page': 'clear'
                                });
                                textController.clear();
                                animationController.toggleCloseSearchIcon(0);
                              }
                            },
                            icon: Icon(Icons.send,
                                color: Colors.white,
                                textDirection: TextDirection.ltr),
                            label: Text('')),
                        VerticalDivider(
                          indent: styleController.cardMargin / 2,
                          endIndent: styleController.cardMargin / 2,
                        ),
                      ],
                    ),
                    title: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: textController,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                          hintText: 'write_text'.tr, border: InputBorder.none),
                      onSubmitted: (str) {
                        textController.text = textController.text + "\n";
                      },
                      // onEditingComplete: () {
                      //   controller.getData(param: {'page': 'clear'});
                      // },
                      onChanged: (str) {
                        animationController.toggleCloseSearchIcon(str.length);
                      },
                    ),
                    trailing: FadeTransition(
                      opacity: animationController.fadeShowController,
                      child: IconButton(
                        splashColor: styleController.secondaryColor,
                        icon: Icon(Icons.close),
                        onPressed: () {
                          textController.clear();
                          animationController.toggleCloseSearchIcon(0);

                          // animationController
                          //     .toggleCloseSearchIcon(0);
                          // controller.getData(params: {'page': '1'});
                          // onSearchTextChanged('');
                        },
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ChatCell({required TicketChat chat, required bool fromUser}) {
    return ShakeWidget(
      child: Directionality(
        textDirection: fromUser ? TextDirection.rtl : TextDirection.ltr,
        child: IntrinsicHeight(
          child: ListTile(
            splashColor: styleController.primaryMaterial[100],
            leading: CircleAvatar(
                child: Icon(fromUser ? Icons.person : Icons.headset_mic)),
            contentPadding: EdgeInsets.all(styleController.cardMargin),
            title: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      styleController.cardBorderRadius / 2)),
              color: Colors.white,
              child: TextButton(
                onPressed: () {
                  settingController.copyToClipboard(chat.message);
                },
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(styleController.cardMargin),
                            child: Text(
                              chat.createdAt,
                              style: styleController.textTinyLightStyle
                                  .copyWith(
                                      color:
                                          styleController.primaryMaterial[200]),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.all(styleController.cardMargin),
                          child: Linkify(
                            onOpen: (link) async {
                              await launchUrlString(link.url,
                                  mode: LaunchMode.externalApplication);
                            },
                            text: chat.message,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: styleController.textMediumStyle.copyWith(
                                color: styleController.primaryMaterial[900]),
                            linkStyle: TextStyle(color: Colors.red),
                          )),
                      Padding(
                        padding: EdgeInsets.all(styleController.cardMargin),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (chat.userSeen)
                              Icon(Icons.check,
                                  color: styleController.primaryColor,
                                  size: styleController.cardMargin * 2),
                            if (chat.adminSeen)
                              Icon(
                                Icons.check,
                                color: styleController.primaryColor,
                                size: styleController.cardMargin * 2,
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void edit() async {
    var res = await ticketController
        .edit(param: {'ticket_id': chatId, 'cmnd': 'ticket_user_seen'});
    if (res['user_notification'] != null) {
      userController.user?.ticketNotification = res['user_notification'];
      MyHomePage.ticketNotification.value = res['user_notification'];
    }
  }
}
