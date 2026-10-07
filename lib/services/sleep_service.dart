import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_data.dart';

class SleepService {
  static final SleepService _instance = SleepService._internal();
  factory SleepService() => _instance;
  SleepService._internal();

  SleepSession? _currentSession;
  SleepSession? get currentSession => _currentSession;

  Future<void> startSleepTracking() async {
    _currentSession = SleepSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bedTime: DateTime.now(),
    );
    await _saveCurrentSession();
  }

  Future<void> stopSleepTracking({int? quality, String? notes}) async {
    if (_currentSession == null) return;

    _currentSession!.wakeTime = DateTime.now();
    _currentSession!.sleepQuality = quality;
    _currentSession!.notes = notes;

    // Generate simulated sleep phases based on duration
    _currentSession!.phases = _generateSleepPhases(_currentSession!.bedTime, _currentSession!.wakeTime!);

    await _saveSession(_currentSession!);
    _currentSession = null;
    await _clearCurrentSession();
  }

  List<SleepPhase> _generateSleepPhases(DateTime bedTime, DateTime wakeTime) {
    final phases = <SleepPhase>[];
    final totalMinutes = wakeTime.difference(bedTime).inMinutes;
    if (totalMinutes <= 0) return phases;

    var currentTime = bedTime;
    final random = Random();

    // Typical sleep cycle: 90 minutes
    // Light → Deep → REM → Light → Awake (brief)
    int remaining = totalMinutes;

    while (remaining > 0) {
      // Light sleep (first 20-30 min of cycle)
      final lightDuration = 20 + random.nextInt(15);
      phases.add(SleepPhase(
        type: 'light',
        durationMinutes: min(lightDuration, remaining),
        startTime: currentTime,
      ));
      currentTime = currentTime.add(Duration(minutes: lightDuration));
      remaining -= lightDuration;
      if (remaining <= 0) break;

      // Deep sleep (next 20-40 min)
      final deepDuration = 20 + random.nextInt(20);
      phases.add(SleepPhase(
        type: 'deep',
        durationMinutes: min(deepDuration, remaining),
        startTime: currentTime,
      ));
      currentTime = currentTime.add(Duration(minutes: deepDuration));
      remaining -= deepDuration;
      if (remaining <= 0) break;

      // REM sleep (next 10-20 min)
      final remDuration = 10 + random.nextInt(15);
      phases.add(SleepPhase(
        type: 'rem',
        durationMinutes: min(remDuration, remaining),
        startTime: currentTime,
      ));
      currentTime = currentTime.add(Duration(minutes: remDuration));
      remaining -= remDuration;
      if (remaining <= 0) break;

      // Brief awake (0-5 min) - not always
      if (random.nextDouble() < 0.3 && remaining > 5) {
        final awakeDuration = 1 + random.nextInt(4);
        phases.add(SleepPhase(
          type: 'awake',
          durationMinutes: min(awakeDuration, remaining),
          startTime: currentTime,
        ));
        currentTime = currentTime.add(Duration(minutes: awakeDuration));
        remaining -= awakeDuration;
      }
    }

    return phases;
  }

  Future<void> _saveSession(SleepSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('sleep_sessions') ?? [];
    sessions.add(jsonEncode(session.toJson()));
    await prefs.setStringList('sleep_sessions', sessions);
  }

  Future<void> _saveCurrentSession() async {
    if (_currentSession == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_sleep_session', jsonEncode(_currentSession!.toJson()));
  }

  Future<void> _clearCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_sleep_session');
  }

  Future<void> loadCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('current_sleep_session');
    if (saved != null) {
      _currentSession = SleepSession.fromJson(jsonDecode(saved));
    }
  }

  Future<List<SleepSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('sleep_sessions') ?? [];
    return sessions.map((s) => SleepSession.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.bedTime.compareTo(a.bedTime));
  }

  Future<List<SleepSession>> getLast7DaysSessions() async {
    final all = await getAllSessions();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return all.where((s) => s.bedTime.isAfter(weekAgo)).toList();
  }

  Future<SleepStats> getWeeklyStats() async {
    final sessions = await getLast7DaysSessions();
    final completed = sessions.where((s) => s.wakeTime != null).toList();

    if (completed.isEmpty) {
      return SleepStats(
        date: DateTime.now().toIso8601String().split('T')[0],
        avgSleepHours: 0,
        avgQuality: 0,
        sleepDebtMinutes: 0,
        aiInsight: 'No sleep data available yet. Start tracking tonight!',
      );
    }

    final avgHours = completed.map((s) => s.hoursSlept!).reduce((a, b) => a + b) / completed.length;
    final avgQuality = completed.where((s) => s.sleepQuality != null).isNotEmpty
      ? completed.where((s) => s.sleepQuality != null).map((s) => s.sleepQuality!).reduce((a, b) => a + b) ~/ completed.where((s) => s.sleepQuality != null).length
      : 0;

    // Calculate sleep debt (ideal 8 hours = 480 min)
    int totalDebt = 0;
    for (final s in completed) {
      final sleptMinutes = s.duration!.inMinutes;
      final debt = 480 - sleptMinutes;
      if (debt > 0) totalDebt += debt;
    }

    // Average bed time
    int totalBedMinutes = 0;
    for (final s in completed) {
      totalBedMinutes += s.bedTime.hour * 60 + s.bedTime.minute;
    }
    final avgBedMinutes = totalBedMinutes ~/ completed.length;
    final avgBedTime = DateTime.now().subtract(const Duration(days: 1));
    final avgBedDateTime = DateTime(
      avgBedTime.year, avgBedTime.month, avgBedTime.day,
      avgBedMinutes ~/ 60, avgBedMinutes % 60,
    );

    // Average wake time
    int totalWakeMinutes = 0;
    for (final s in completed) {
      totalWakeMinutes += s.wakeTime!.hour * 60 + s.wakeTime!.minute;
    }
    final avgWakeMinutes = totalWakeMinutes ~/ completed.length;
    final avgWakeDateTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day,
      avgWakeMinutes ~/ 60, avgWakeMinutes % 60,
    );

    return SleepStats(
      date: DateTime.now().toIso8601String().split('T')[0],
      avgSleepHours: avgHours,
      avgQuality: avgQuality,
      avgBedTime: avgBedDateTime,
      avgWakeTime: avgWakeDateTime,
      sleepDebtMinutes: totalDebt,
      aiInsight: _generateSleepInsight(avgHours, avgQuality, totalDebt, completed.length),
    );
  }

  String _generateSleepInsight(double avgHours, int avgQuality, int debt, int days) {
    final buffer = StringBuffer();

    buffer.writeln('🌙 SLEEP ANALYSIS\n');
    buffer.writeln('Avg Sleep: ${avgHours.toStringAsFixed(1)} hrs/night');
    buffer.writeln('Avg Quality: $avgQuality/10');
    buffer.writeln('Sleep Debt: ${(debt / 60).toStringAsFixed(1)} hrs this week\n');

    if (avgHours < 6) {
      buffer.writeln('⚠️ CRITICAL: Sleep duration is very low!');
      buffer.writeln('   7-8 hours is essential for health. Lack of sleep causes:');
      buffer.writeln('   • Weakened memory');
      buffer.writeln('   • Weight gain');
      buffer.writeln('   • Weakened immune system');
    } else if (avgHours < 7) {
      buffer.writeln('⚠️ You need more sleep. 7-8 hours is the ideal range.');
    } else if (avgHours > 9) {
      buffer.writeln('💤 Excessive sleep detected. 7-8 hours is best for most adults.');
    } else {
      buffer.writeln('✅ Perfect sleep duration! Keep up this rhythm.');
    }

    if (avgQuality < 5) {
      buffer.writeln('\n😴 Sleep quality is low. Tips:');
      buffer.writeln('   • Put away screens 1 hour before bed');
      buffer.writeln('   • Keep your room cool and dark');
      buffer.writeln('   • Avoid caffeine in the evening');
    }

    if (debt > 180) {
      buffer.writeln('\n📉 High sleep debt! Use the weekend for catch-up sleep.');
    }

    return buffer.toString();
  }

  Map<String, double> getPhaseDistribution(SleepSession session) {
    if (session.phases.isEmpty) return {};

    final total = session.phases.map((p) => p.durationMinutes).reduce((a, b) => a + b);
    final dist = <String, double>{};

    for (final phase in ['deep', 'light', 'rem', 'awake']) {
      final minutes = session.phases
        .where((p) => p.type == phase)
        .map((p) => p.durationMinutes)
        .fold(0, (a, b) => a + b);
      dist[phase] = total > 0 ? (minutes / total) * 100 : 0;
    }
    return dist;
  }
}
