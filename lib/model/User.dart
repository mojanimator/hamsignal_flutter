import 'package:hamsignal/helper/variables.dart';

class User {
  String id;
  String avatar;
  String phone;
  String username;
  String fullName;
  String telegramUsername;
  String telegramId;
  String email;
  bool isVip;
  bool phoneVerified;
  bool emailVerified;
  bool isActive;
  String score;
  String wallet;
  String expiresAt;
  String refId;
  bool ticketNotification;

  User({
    required this.id,
    required this.avatar,
    required this.phone,
    required this.fullName,
    required this.username,
    required this.email,
    required this.expiresAt,
    required this.telegramUsername,
    required this.telegramId,
    required this.isVip,
    required this.isActive,
    required this.score,
    required this.phoneVerified,
    required this.emailVerified,
    required this.refId,
    required this.ticketNotification,
    required this.wallet,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"] ?? '',
        username = json["username"] ?? '',
        fullName = json["fullname"] ?? '',
        telegramUsername = json["telegram_username"] ?? '',
        telegramId = json["telegram_id"] ?? '',
        email = json["email"] ?? '',
        score = "${json["score"] ?? 0}",
        wallet = "${json["wallet"] ?? 0}",
        phone = json["phone"] ?? '',
        isActive = json["is_active"] != null ? json["is_active"] == 1 : false,
        isVip = json["vip"] != null ? json["vip"] == 1 : false,
        avatar = "${Variables.LINK_USERS_STORAGE}/${json['id']}.jpg",
        phoneVerified = json["phone_verified"] ?? false,
        emailVerified = json["email_verified"] ?? false,
        ticketNotification = json["ticket_notification"] ?? false,
        refId = json["ref_id"] ?? '',
        expiresAt = json["expires_at"] ?? '';

  User.nullUser()
      : id = '',
        username = '',
        avatar = "",
        fullName = '',
        phone = '',
        telegramUsername = '',
        telegramId = '',
        email = '',
        score = '0',
        wallet = '0',
        isVip = false,
        refId = '',
        ticketNotification = false,
        phoneVerified = false,
        emailVerified = false,
        isActive = false,
        expiresAt = '';
}
