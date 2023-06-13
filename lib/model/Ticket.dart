import 'package:get/get.dart';

class Ticket {
  //   'status', 'user_id'
  String id;
  String subject;
  RxString status;
  String createdAt;
  String updatedAt;

  Ticket.fromJson(Map<String, dynamic> json)
      : id = "${json['id'] ?? ''}",
        subject = "${json['subject'] ?? ''}",
        status = "${json['status'] ?? ''}".obs,
        updatedAt = "${json['updated_at'] ?? ''}",
        createdAt = "${json['created_at'] ?? ''}";
}

class TicketChat {
  //
  String id;
  String fromId;
  String ticketId;
  String message;
  String createdAt;
  bool userSeen;
  bool adminSeen;

  TicketChat.fromJson(Map<String, dynamic> json)
      : id = "${json['id'] ?? ''}",
        fromId = "${json['from_id'] ?? ''}",
        ticketId = "${json['ticket_id'] ?? ''}",
        message = "${json['message'] ?? ''}",
        userSeen = json["user_seen"] ?? false,
        adminSeen = json['admin_seen'] ?? false,
        createdAt = "${json['created_at'] ?? ''}";
}
