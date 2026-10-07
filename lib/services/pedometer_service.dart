import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_data.dart';

class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  Stream<StepCount>? _stepStream;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  int _todaySteps = 0;
  int _baselineSteps = 0;
  int _lastRawSteps = 0;
  bool _isTrackingRun = false;
  RunningSession? _currentSession;

  final _stepsController = StreamController<int>.broadcast();
  final _formController = StreamController<FormSnapshot>.broadcast();
  final _sessionController = StreamController<RunningSession>.broadcast();

  Stream<int> get stepsStream => _stepsController.stream;
  Stream<FormSnapshot> get formStream => _formController.stream;
  Stream<RunningSession> get sessionStream => _sessionController.stream;

  int get todaySteps => _todaySteps;
  bool get isTrackingRun => _isTrackingRun;
  RunningSession? get currentSession => _currentSession;

  // Accelerometer analysis vars
  final List<AccelerometerEvent> _accelBuffer = [];
  DateTime? _lastStepTime;
  int _stepCount = 0;
  final List<double> _cadenceHistory = [];

  Future<void> init() async {
    await _loadBaseline();
    _startListening();
  }

  Future<void> _loadBaseline() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('baseline_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (saved == today) {
      _baselineSteps = prefs.getInt('baseline_steps') ?? 0;
    } else {
      _baselineSteps = 0;
      await prefs.setString('baseline_date', today);
      await prefs.setInt('baseline_steps', 0);
    }
  }

  void _startListening() {
    _stepStream = Pedometer.stepCountStream;
    _stepSubscription = _stepStream?.listen((event) {
      _lastRawSteps = event.steps;

      if (_baselineSteps == 0) {
        _baselineSteps = event.steps;
        _saveBaseline(_baselineSteps);
      }

      _todaySteps = event.steps - _baselineSteps;
      if (_todaySteps < 0) {
        _baselineSteps = event.steps;
        _saveBaseline(_baselineSteps);
        _todaySteps = 0;
      }
      
      _stepsController.add(_todaySteps);

      if (_isTrackingRun && _currentSession != null) {
        _currentSession!.steps = _todaySteps - (_currentSession!.steps > 0 ? _currentSession!.steps : 0);
        _currentSession!.distanceKm = _todaySteps * 0.000762;
        _currentSession!.calories = (_todaySteps * 0.04).round();
        _sessionController.add(_currentSession!);
      }
    });
  }

  void startRun() {
    if (_isTrackingRun) return;
    _isTrackingRun = true;
    _currentSession = RunningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    _stepCount = 0;
    _cadenceHistory.clear();
    _startFormAnalysis();
    _sessionController.add(_currentSession!);
  }

  void stopRun() {
    if (!_isTrackingRun) return;
    _isTrackingRun = false;
    _currentSession?.endTime = DateTime.now();
    _accelSubscription?.cancel();
    _accelBuffer.clear();
    _saveSession();
    _sessionController.add(_currentSession!);
  }

  void _startFormAnalysis() {
    _accelSubscription = accelerometerEventStream().listen((event) {
      _accelBuffer.add(event);
      if (_accelBuffer.length > 50) _accelBuffer.removeAt(0);

      if (_accelBuffer.length >= 20) {
        _analyzeForm();
      }
    });
  }

  void _analyzeForm() {
    if (_accelBuffer.length < 20) return;

    final recent = _accelBuffer.sublist(_accelBuffer.length - 20);

    // Bounce analysis (Z-axis variance)
    final zValues = recent.map((e) => e.z).toList();
    final zMean = zValues.reduce((a, b) => a + b) / zValues.length;
    final zVariance = zValues.map((z) => pow(z - zMean, 2)).reduce((a, b) => a + b) / zValues.length;
    final bounceScore = 100 - (zVariance * 15).clamp(0, 100).toDouble();

    // Balance analysis (X-axis symmetry)
    final xValues = recent.map((e) => e.x).toList();
    final xMean = xValues.reduce((a, b) => a + b) / xValues.length;
    final balanceScore = 100 - (xMean.abs() * 30).clamp(0, 100).toDouble();

    // Cadence estimation
    final now = DateTime.now();
    if (_lastStepTime != null && zMean > 11.5) {
      final diff = now.difference(_lastStepTime!).inMilliseconds;
      if (diff > 200 && diff < 2000) {
        final spm = 60000 / diff;
        _cadenceHistory.add(spm);
        if (_cadenceHistory.length > 10) _cadenceHistory.removeAt(0);
        _stepCount++;
      }
    }
    if (zMean > 11.5) _lastStepTime = now;

    final avgCadence = _cadenceHistory.isNotEmpty 
      ? _cadenceHistory.reduce((a, b) => a + b) / _cadenceHistory.length 
      : 0.0;

    // Generate feedback
    String feedback = _generateFormFeedback(bounceScore, balanceScore, avgCadence);

    final snapshot = FormSnapshot(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000,
      bounceScore: bounceScore,
      balanceScore: balanceScore,
      cadence: avgCadence,
      feedback: feedback,
    );

    if (_currentSession != null) {
      _currentSession!.formSnapshots = [..._currentSession!.formSnapshots, snapshot];
      _currentSession!.avgCadence = avgCadence;
    }

    _formController.add(snapshot);
  }

  String _generateFormFeedback(double bounce, double balance, double cadence) {
    final List<String> issues = [];

    if (bounce < 60) issues.add('High bounce — keep your stride lower');
    if (balance < 60) issues.add('Balance issues — distribute weight evenly');
    if (cadence > 0 && cadence < 150) issues.add('Low cadence — aim for shorter, faster steps');
    if (cadence > 190) issues.add('Very high cadence — avoid overstriding');

    if (issues.isEmpty) {
      if (bounce > 85 && balance > 85) return '🔥 Professional form! Keep it up!';
      return '✅ Good form, just maintain your rhythm';
    }

    return issues.join(' | ');
  }

  Future<void> _saveSession() async {
    if (_currentSession == null) return;
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('running_sessions') ?? [];
    sessions.add(jsonEncode({
      'id': _currentSession!.id,
      'startTime': _currentSession!.startTime.toIso8601String(),
      'endTime': _currentSession!.endTime?.toIso8601String(),
      'steps': _currentSession!.steps,
      'distanceKm': _currentSession!.distanceKm,
      'calories': _currentSession!.calories,
      'avgCadence': _currentSession!.avgCadence,
      'formSnapshots': _currentSession!.formSnapshots.map((s) => s.toJson()).toList(),
    }));
    await prefs.setStringList('running_sessions', sessions);
  }

  Future<List<RunningSession>> getPastSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('running_sessions') ?? [];
    return sessions.map((s) {
      final json = jsonDecode(s);
      return RunningSession(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        steps: json['steps'],
        distanceKm: json['distanceKm'].toDouble(),
        calories: json['calories'],
        avgCadence: json['avgCadence'].toDouble(),
      );
    }).toList();
  }

  Future<DailyStats> getTodayStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final saved = prefs.getString('daily_stats_$today');

    if (saved != null) {
      return DailyStats.fromJson(jsonDecode(saved));
    }

    return DailyStats(date: today);
  }

  Future<void> saveTodayStats(DailyStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('daily_stats_$today', jsonEncode(stats.toJson()));
  }

  Future<void> resetSteps() async {
    _baselineSteps = _lastRawSteps;
    await _saveBaseline(_baselineSteps);
    _todaySteps = 0;
    _stepsController.add(0);
  }

  Future<void> _saveBaseline(int baseline) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('baseline_date', today);
    await prefs.setInt('baseline_steps', baseline);
  }

  void dispose() {
    _stepSubscription?.cancel();
    _accelSubscription?.cancel();
    _stepsController.close();
    _formController.close();
    _sessionController.close();
  }
}
