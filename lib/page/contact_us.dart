import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/model/Ticket.dart';
import 'package:hamsignal/page/chat_ticket.dart';

import '../controller/AnimationController.dart';
import '../controller/TicketController.dart';
import '../controller/UserController.dart';
import '../helper/helpers.dart';
import '../helper/styles.dart';
import '../widget/blinkanimation.dart';
import '../widget/my_text_field.dart';

class ContactUsPage extends StatelessWidget {
  late Style styleController;
  late SettingController settingController;
  late TicketController ticketController;

  TextEditingController textNameCtrl = TextEditingController();
  TextEditingController textPhoneCtrl = TextEditingController();
  TextEditingController textTitleCtrl = TextEditingController();
  TextEditingController textTextCtrl = TextEditingController();
  MyAnimationController animationController = Get.find<MyAnimationController>();
  UserController userController = Get.find<UserController>();
  Helper helper = Get.find<Helper>();
  RxBool loading = RxBool(false);

  ContactUsPage() {
    styleController = Get.find<Style>();
    settingController = Get.find<SettingController>();
    ticketController = Get.find<TicketController>();

    textNameCtrl.text = userController.user?.fullName ?? '';
    textPhoneCtrl.text =
        userController.user?.phone ?? userController.user?.phone ?? '';

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await ticketController.getTickets();
      // Get.to(
      //     ChatPage(ticket: ticketController.tickets.firstWhere((e) => true)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(styleController.cardMargin),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(styleController.cardBorderRadius)),
          child: Padding(
            padding: EdgeInsets.all(styleController.cardMargin),
            child: Obx(() {
              loading.value = loading.value;
              return ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.all(styleController.cardMargin / 2),
                    child: Text(
                      'read_before_send'.tr,
                      style: styleController.textMediumStyle,
                    ),
                  ),
                  ...settingController.appInfo.questions
                      .map<Widget>((e) => Padding(
                            padding:
                                EdgeInsets.all(styleController.cardMargin / 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.circle,
                                    color: styleController.primaryMaterial[500],
                                  ),
                                  label: Text(
                                    e['q'],
                                    style: styleController.textMediumLightStyle
                                        .copyWith(
                                            color: styleController
                                                .primaryMaterial[500]),
                                  ),
                                  onPressed: () {
                                    e['visible'].value = !e['visible'].value;
                                  },
                                  style: styleController.buttonStyle(
                                      backgroundColor:
                                          styleController.primaryMaterial[50],
                                      radius: BorderRadius.vertical(
                                          bottom: Radius.circular(
                                              styleController.cardMargin / 2),
                                          top: Radius.circular(
                                              styleController.cardMargin)),
                                      splashColor:
                                          styleController.primaryMaterial[600]),
                                ),
                                Visibility(
                                  visible: e['visible'].value,
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        styleController.cardMargin),
                                    decoration: BoxDecoration(
                                        color: styleController.secondaryColor,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                styleController.cardMargin / 2),
                                            bottom: Radius.circular(
                                                styleController.cardMargin))),
                                    child: Text(
                                      e['a'],
                                      style: styleController.textMediumStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  // contact form
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: styleController.cardMargin,
                      vertical: styleController.cardMargin * 3,
                    ),
                    child: TextButton.icon(
                      style: styleController.buttonStyle(
                          padding: EdgeInsets.symmetric(
                              vertical: styleController.cardMargin * 2),
                          backgroundColor: Colors.teal,
                          radius: BorderRadius.circular(
                              styleController.cardMargin / 2)),
                      onPressed: () async {
                        Get.dialog(
                            Center(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  margin: EdgeInsets.all(
                                      styleController.cardMargin / 4),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: styleController.cardMargin,
                                    vertical: styleController.cardMargin * 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: styleController.primaryMaterial[50],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            styleController.cardMargin)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (false)
                                        //name field
                                        MyTextField(
                                            margin: EdgeInsets.symmetric(
                                                vertical:
                                                    styleController.cardMargin /
                                                        4),
                                            controller: textNameCtrl,
                                            hintText: 'name'.tr,
                                            icon: Icons.person,
                                            keyboardType: TextInputType.number),
                                      if (false)
                                        //phone field
                                        MyTextField(
                                            margin: EdgeInsets.symmetric(
                                                vertical:
                                                    styleController.cardMargin /
                                                        4),
                                            controller: textPhoneCtrl,
                                            hintText: 'phone'.tr,
                                            icon: Icons.phone,
                                            keyboardType: TextInputType.number),
                                      //title field
                                      MyTextField(
                                          margin: EdgeInsets.symmetric(
                                              vertical:
                                                  styleController.cardMargin /
                                                      4),
                                          controller: textTitleCtrl,
                                          hintText: 'title'.tr,
                                          icon: Icons.textsms,
                                          keyboardType: TextInputType.text),
                                      //message field
                                      MyTextField(
                                          margin: EdgeInsets.symmetric(
                                              vertical:
                                                  styleController.cardMargin /
                                                      4),
                                          controller: textTextCtrl,
                                          minLines: 3,
                                          hintText: 'message'.tr,
                                          icon: Icons.message,
                                          keyboardType:
                                              TextInputType.multiline),
                                      if (!loading.value)
                                        TextButton.icon(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            textDirection: TextDirection.ltr,
                                            color:
                                                styleController.secondaryColor,
                                          ),
                                          label: Center(
                                            child: Text(
                                              'send'.tr,
                                              style: styleController
                                                  .textBigStyle
                                                  .copyWith(
                                                      color: styleController
                                                          .secondaryColor),
                                            ),
                                          ),
                                          onPressed: () async {
                                            loading.value = true;
                                            var res = await ticketController
                                                .sendMessage(
                                              cmnd: 'user_create_ticket',
                                              subject: textTitleCtrl.text,
                                              message: textTextCtrl.text,
                                            );
                                            loading.value = false;
                                            if (res['status'] != null &&
                                                res['status'] == 'success') {
                                              textNameCtrl.clear();
                                              textPhoneCtrl.clear();
                                              textTitleCtrl.clear();
                                              textTextCtrl.clear();
                                              Get.back();
                                              ticketController.getTickets();
                                              helper.showToast(
                                                  msg: res['message'],
                                                  status: 'success');
                                              // Future.delayed(Duration(seconds: 3));
                                            }
                                          },
                                          style: styleController.buttonStyle(
                                              radius: BorderRadius.vertical(
                                                  bottom: Radius.circular(
                                                      styleController
                                                          .cardMargin),
                                                  top: Radius.circular(
                                                      styleController
                                                              .cardMargin /
                                                          2)),
                                              splashColor: styleController
                                                  .secondaryColor),
                                        ),
                                      if (loading.value)
                                        CupertinoActivityIndicator(
                                          color: styleController.secondaryColor,
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            barrierDismissible: true);
                      },
                      icon: Icon(Icons.add_box, color: Colors.white),
                      label: Text(
                        'new_ticket'.tr,
                        style: styleController.textMediumStyle.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
//tickets list
                  ticketController.obx((tickets) {
                    if (tickets == null) return Center();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ticket_list'.tr,
                          style: styleController.textMediumStyle,
                        ),
                        Divider(),
                        ...[
                          for (Ticket ticket in tickets)
                            Obx(
                              () => Card(
                                color: Colors.white,
                                elevation: 2,
                                margin:
                                    EdgeInsets.all(styleController.cardMargin),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        styleController.cardBorderRadius / 2)),
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              styleController.secondaryColor
                                                  .withOpacity(.2)),
                                      overlayColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) {
                                          return states.contains(
                                                  MaterialState.pressed)
                                              ? styleController.secondaryColor
                                              : null;
                                        },
                                      ),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                styleController.cardMargin)),
                                      ))),
                                  onPressed: () {
                                    ticket.status.value =
                                        settingController.ticketStatuses[1];
                                    Get.dialog(ChatPage(ticket: ticket));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        styleController.cardMargin),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  styleController.cardMargin),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      "${"id".tr} ${ticket.id}",
                                                      style: styleController
                                                          .textMediumStyle,
                                                    ),
                                                    Text(ticket.updatedAt,
                                                        style: styleController
                                                            .textMediumStyle
                                                            .copyWith(
                                                                color: styleController
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        .5)))
                                                  ]),
                                            ),
                                            Divider(
                                              height: 1,
                                              thickness: 3,
                                              indent:
                                                  styleController.cardMargin,
                                              endIndent:
                                                  styleController.cardMargin,
                                              color: styleController
                                                  .primaryMaterial[100],
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    styleController.cardMargin *
                                                        2,
                                                vertical:
                                                    styleController.cardMargin,
                                              ),
                                              child: Text(
                                                ticket.subject,
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                style: styleController
                                                    .textMediumStyle
                                                    .copyWith(
                                                        color: styleController
                                                                .primaryMaterial[
                                                            900]),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    styleController.cardMargin *
                                                        2,
                                              ),
                                              child: Text(
                                                ticket.status.value,
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: styleController
                                                    .textSmallStyle
                                                    .copyWith(
                                                        color: styleController
                                                            .primaryColor
                                                            .withOpacity(.7)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (ticket.status.value ==
                                            settingController.ticketStatuses[2])
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            bottom: 0,
                                            child: BlinkAnimation(
                                              repeat: true,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                                padding: EdgeInsets.all(
                                                    styleController.cardMargin),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ]
                      ],
                    );
                  },
                      onLoading: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                      onError: (e) => Center(),
                      onEmpty: Center()),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: styleController.cardMargin * 3,
                        left: styleController.cardMargin / 4,
                        right: styleController.cardMargin / 4,
                      ),
                      child: Wrap(
                        spacing: styleController.cardMargin / 2,
                        runSpacing: styleController.cardMargin / 2,
                        children: [
                          Container(
                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.orange,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('eitaa');
                              },
                              icon: Image.asset('assets/images/eitaa.png'),
                              label: Text(
                                'eitaa'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.teal,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('whatsapp');
                              },
                              icon: Icon(Icons.perm_phone_msg_rounded,
                                  color: Colors.white),
                              label: Text(
                                'whatsapp'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.pink,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('instagram');
                              },
                              icon: Icon(Icons.photo_camera_outlined,
                                  color: Colors.white),
                              label: Text(
                                'instagram'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.blue,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('telegram');
                              },
                              icon: Icon(Icons.telegram_outlined,
                                  color: Colors.white),
                              label: Text(
                                'telegram'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            child: TextButton.icon(
                              style: styleController.buttonStyle(
                                  backgroundColor: Colors.red,
                                  radius: BorderRadius.circular(
                                      styleController.cardMargin / 2)),
                              onPressed: () async {
                                settingController.goTo('email');
                              },
                              icon: Icon(Icons.email_outlined,
                                  color: Colors.white),
                              label: Text(
                                'email'.tr,
                                style: styleController.textMediumStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
