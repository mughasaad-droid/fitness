import 'dart:convert';

class DailyStats {
  final String date;
  int steps;
  double distanceKm;
  int calories;
  int activeMinutes;
  double? avgPace;
  String? aiInsight;

  DailyStats({
    required this.date,
    this.steps = 0,
    this.distanceKm = 0.0,
    this.calories = 0,
    this.activeMinutes = 0,
    this.avgPace,
    this.aiInsight,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'steps': steps,
    'distanceKm': distanceKm,
    'calories': calories,
    'activeMinutes': activeMinutes,
    'avgPace': avgPace,
    'aiInsight': aiInsight,
  };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    date: json['date'],
    steps: json['steps'] ?? 0,
    distanceKm: (json['distanceKm'] ?? 0).toDouble(),
    calories: json['calories'] ?? 0,
    activeMinutes: json['activeMinutes'] ?? 0,
    avgPace: json['avgPace'] != null ? (json['avgPace']).toDouble() : null,
    aiInsight: json['aiInsight'],
  );
}

class RunningSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  int steps;
  double distanceKm;
  int calories;
  List<FormSnapshot> formSnapshots;
  double avgCadence;

  RunningSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.steps = 0,
    this.distanceKm = 0.0,
    this.calories = 0,
    this.formSnapshots = const [],
    this.avgCadence = 0.0,
  });

  int get durationSeconds => endTime != null 
    ? endTime!.difference(startTime).inSeconds 
    : DateTime.now().difference(startTime).inSeconds;

  double? get paceMinPerKm => distanceKm > 0 
    ? (durationSeconds / 60) / distanceKm 
    : null;
}

class FormSnapshot {
  final double timestamp;
  final double bounceScore;
  final double balanceScore;
  final double cadence;
  final String feedback;

  FormSnapshot({
    required this.timestamp,
    required this.bounceScore,
    required this.balanceScore,
    required this.cadence,
    required this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'bounceScore': bounceScore,
    'balanceScore': balanceScore,
    'cadence': cadence,
    'feedback': feedback,
  };
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? mood;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.mood,
  });
}

class WorkoutPlan {
  final String title;
  final String description;
  final List<WorkoutExercise> exercises;
  final int totalMinutes;
  final String difficulty;
  final String aiNote;

  WorkoutPlan({
    required this.title,
    required this.description,
    required this.exercises,
    required this.totalMinutes,
    required this.difficulty,
    required this.aiNote,
  });
}

class WorkoutExercise {
  final String name;
  final String duration;
  final String trainerTip;
  final int sets;
  final int reps;

  WorkoutExercise({
    required this.name,
    required this.duration,
    required this.trainerTip,
    this.sets = 1,
    this.reps = 0,
  });
}
