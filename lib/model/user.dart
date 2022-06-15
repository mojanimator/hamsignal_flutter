class User {
  final String id;
  String name;
  String family;
  String username;
  String email;
  bool email_verified;
  String phone;
  bool phone_verified;
  String score;
  String role;
  bool active;
  String sheba;
  String cart;
  String ref_code;
  String created_at;
  String updated_at;
  String expires_at;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        family = json['family'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        email_verified = json['email_verified'] ?? false,
        phone = json['phone'] ?? '',
        phone_verified = json['phone_verified'] ?? false,
        score = json['score'] != null ? "${json['score']}" : '0',
        active = json['active'],
        role = json['role'],
        sheba = json['sheba'] ?? '',
        cart = json['cart'] ?? '',
        ref_code = json['ref_code'] ?? '',
        created_at = json['created_at'] ?? '',
        updated_at = json['updated_at'] ?? '',
        expires_at = json['expires_at'] ?? '';

  User.nullUser()
      : id = '',
        name = '',
        family = '',
        username = '',
        email = '',
        email_verified = false,
        phone = '',
        phone_verified = false,
        score = '0',
        active = false,
        role = '',
        sheba = '',
        cart = '',
        ref_code = '',
        created_at = '',
        updated_at = '',
        expires_at = '';

//  Map<String, dynamic> toJson() => {
//        'id': id,
//        'group_id': group_id,
//        'path': path,
//        'size': size,
//        'created_at': created_at,
//        'link': link,
//      };
}
