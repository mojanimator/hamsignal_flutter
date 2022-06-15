import 'package:dabel_sport/helper/helpers.dart';

class Event {
  final int id;
  final String sport_id;
  final String title;
  final String team1;
  final String team2;
  final String score1;
  final String score2;
  final String status;
  final String source;
  final String link;
  final String details;
  final String time;
  final int? timestamp;

  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sport_id = json['sport_id'] ?? '',
        title = json['title'] ?? '',
        team1 = json['team1'] ?? '',
        team2 = json['team2'] ?? '',
        score1 = json['score1'] ?? '',
        score2 = json['score2'] ?? '',
        status = json['status'] ?? '',
        source = json['source'] ?? '',
        link = json['link'] ?? '',
        time = Helper.toShamsi(
          json['time'],
        ),
        timestamp = json['time'] ?? '',
        details = json['details'] ?? '';
}
