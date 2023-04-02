class Lawyer {
  int id;
  bool isLawyer;
  String fullName;
  List<String> categories;
  List<String> lawyerCategories;
  String lawyerNumber;
  String avatar;
  bool mark;
  String cityId;
  String mobile;
  String email;
  String tel;
  String address;
  String lawyerMelicard;
  bool lawyerExpired;
  String expiredMessage;
  String cv;
  String location;

  String expiredAt;
  String lawyerExpiredAt;
  String appVersion;
  bool? lawyerSex;

  Lawyer.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        fullName = json['fullname'] ?? '',
        categories = json['categories'] != null && json['categories'] != ""
            ? json['categories'].split(',')
            : [],
        lawyerCategories = json['lawyer_categories'] != null && json['lawyer_categories'] != ""
            ? json['lawyer_categories'].split(',')
            : [],
        lawyerNumber = "${json['lawyer_number']}",
        avatar = json['avatar'] ?? '',
        cityId = "${json['city_id']}" ?? '',
        mark = json['mark'] ?? false,
        mobile = json['mobile'] ?? '',
        email = json['email'] ?? '',
        tel = json['tel'] ?? '',
        address = json['address'] ?? '',
        lawyerMelicard = json['lawyer_melicard'] ?? '',
        lawyerExpired = json['lawyer_expired'] ?? false,
        expiredMessage = json['expired_message'] ?? '',
        cv = json['cv'] ?? '',
        location = json['location'] ?? '',
        isLawyer = json['is_lawyer'] != null ? (json['is_lawyer'] == 1) : false,
        expiredAt = json['expired_at'] ?? '',
        lawyerExpiredAt = json['lawyer_expired_at'] ?? '',
        appVersion = json['app_version'] ?? '',
        lawyerSex =
            json['lawyer_sex'] != null ? (json['is_lawyer'] == 1) : null;
}
