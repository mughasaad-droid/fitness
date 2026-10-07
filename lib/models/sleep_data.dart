import 'dart:convert';

class SleepSession {
  final String id;
  final DateTime bedTime;
  DateTime? wakeTime;
  int? sleepQuality; // 1-10
  String? notes;
  List<SleepPhase> phases;

  SleepSession({
    required this.id,
    required this.bedTime,
    this.wakeTime,
    this.sleepQuality,
    this.notes,
    this.phases = const [],
  });

  Duration? get duration => wakeTime != null 
    ? wakeTime!.difference(bedTime) 
    : null;

  double? get hoursSlept => duration != null 
    ? duration!.inMinutes / 60 
    : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'bedTime': bedTime.toIso8601String(),
    'wakeTime': wakeTime?.toIso8601String(),
    'sleepQuality': sleepQuality,
    'notes': notes,
    'phases': phases.map((p) => p.toJson()).toList(),
  };

  factory SleepSession.fromJson(Map<String, dynamic> json) => SleepSession(
    id: json['id'],
    bedTime: DateTime.parse(json['bedTime']),
    wakeTime: json['wakeTime'] != null ? DateTime.parse(json['wakeTime']) : null,
    sleepQuality: json['sleepQuality'],
    notes: json['notes'],
    phases: (json['phases'] as List?)?.map((p) => SleepPhase.fromJson(p)).toList() ?? [],
  );
}

class SleepPhase {
  final String type; // deep, light, rem, awake
  final int durationMinutes;
  final DateTime startTime;

  SleepPhase({
    required this.type,
    required this.durationMinutes,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'durationMinutes': durationMinutes,
    'startTime': startTime.toIso8601String(),
  };

  factory SleepPhase.fromJson(Map<String, dynamic> json) => SleepPhase(
    type: json['type'],
    durationMinutes: json['durationMinutes'],
    startTime: DateTime.parse(json['startTime']),
  );
}

class SleepStats {
  final String date;
  final double avgSleepHours;
  final int avgQuality;
  final DateTime? avgBedTime;
  final DateTime? avgWakeTime;
  final int sleepDebtMinutes;
  final String aiInsight;

  SleepStats({
    required this.date,
    required this.avgSleepHours,
    required this.avgQuality,
    this.avgBedTime,
    this.avgWakeTime,
    required this.sleepDebtMinutes,
    required this.aiInsight,
  });
}
