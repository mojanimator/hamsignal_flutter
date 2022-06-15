import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/model/Table.dart';

class Tournament {
  final int id;
  final String sport_id;
  final String name;
  final String started_at;
  final String updated_at;
  final bool active;
  final List<Table> tables;

  Tournament.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sport_id = json['sport_id'] ?? '',
        name = json['name'] ?? '',
        started_at = Helper.toShamsi(json['started_at']),
        updated_at = Helper.toShamsi(json['updated_at']),
        active = json['active'],
        tables = json['tables'] != null
            ? json['tables'].map<Table>((data) => Table.fromJson(data)).toList()
            : [];
}
