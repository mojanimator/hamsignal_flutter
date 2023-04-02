class Category {
  int id;
  String title;
  int? parentId;
  int hasChild = 0;

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        parentId = json['parent_id'],
        hasChild = json['has_child'] ?? 0;
}

class CategoryRelate {
  static const Books = 1;
  static const Contents = 2;
  static const Conventions = 3;
  static const Votes = 4;
  static const Lawyer = 5; //Users
  static const Opinions = 6;
  static const Legal_Needs = 7;
  static const Locations = 8;
  static const Contracts = 9;
  static const links = 10;

  static List types = [
    {
      'id': Books,
      'title': 'مقالات',
    },
    {
      'id': Contents,
      'title': 'اخبار',
    },
    {
      'id': Conventions,
      'title': 'کنوانسیون ها',
    },
    {
      'id': Votes,
      'title': 'آرای وحدت رویه',
    },
    {
      'id': Lawyer,
      'title': 'وکلا',
    },
    {
      'id': Opinions,
      'title': 'نظریات مشورتی',
    },
    {
      'id': Legal_Needs,
      'title': 'دادخواست/لایحه',
    },
    {
      'id': Locations,
      'title': 'مکان ها',
    },
    {
      'id': Contracts,
      'title': 'قراردادها',
    },
    {
      'id': links,
      'title': 'لینک ها',
    }
  ];
}
