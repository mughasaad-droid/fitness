import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sleep_data.dart';
import '../services/sleep_service.dart';
import '../services/ai_service.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final _sleepService = SleepService();
  // ignore: unused_local_variable
  final _aiService = AIService();
  bool _isTracking = false;
  Timer? _timer;
  int _elapsedMinutes = 0;
  SleepSession? _currentSession;
  List<SleepSession> _pastSessions = [];
  SleepStats? _weeklyStats;
  int _selectedQuality = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _sleepService.loadCurrentSession();
    final sessions = await _sleepService.getLast7DaysSessions();
    final stats = await _sleepService.getWeeklyStats();

    setState(() {
      _pastSessions = sessions;
      _weeklyStats = stats;
      _currentSession = _sleepService.currentSession;
      _isTracking = _currentSession != null;
      if (_isTracking) {
        _elapsedMinutes = DateTime.now().difference(_currentSession!.bedTime).inMinutes;
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() => _elapsedMinutes++);
    });
  }

  void _toggleTracking() {
    if (_isTracking) {
      _showWakeDialog();
    } else {
      _startSleep();
    }
  }

  void _startSleep() async {
    await _sleepService.startSleepTracking();
    setState(() {
      _isTracking = true;
      _elapsedMinutes = 0;
      _currentSession = _sleepService.currentSession;
    });
    _startTimer();
  }

  void _showWakeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Good Morning! 🌅', style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Rate your sleep quality:', style: TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (index) {
                    final rating = index + 1;
                    return GestureDetector(
                      onTap: () => setModalState(() => _selectedQuality = rating),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: rating <= _selectedQuality 
                            ? Colors.amber.withValues(alpha: 0.3) 
                            : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$rating',
                          style: TextStyle(
                            color: rating <= _selectedQuality ? Colors.amber : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _selectedQuality <= 3 ? 'Very poor 😫' :
                    _selectedQuality <= 5 ? 'Fair 😐' :
                    _selectedQuality <= 7 ? 'Good 😊' :
                    _selectedQuality <= 9 ? 'Very good 😴' : 'Perfect! 🌟',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _sleepService.stopSleepTracking(quality: _selectedQuality);
                      _timer?.cancel();
                      setState(() {
                        _isTracking = false;
                        _elapsedMinutes = 0;
                        _currentSession = null;
                      });
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Wake Up!', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hrs}h ${mins}m';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String status = _isTracking ? "I am Awake!" : "Go to Sleep";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sleep Tracker', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleep Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isTracking 
                      ? [Color(0xFF1a237e), Color(0xFF0d47a1)]
                      : [Color(0xFF311b92), Color(0xFF4527a0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isTracking ? Icons.nights_stay : Icons.bedtime,
                      color: Colors.amber,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isTracking ? 'Sleeping... 😴' : 'Ready for Bed',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_isTracking)
                      Text(
                        _formatDuration(_elapsedMinutes),
                        style: TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    const SizedBox(height: 16),
                    if (_isTracking && _currentSession != null)
                      Text(
                        'Bed time: ${_formatTime(_currentSession!.bedTime)}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _toggleTracking,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: _isTracking ? Colors.amber : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _isTracking ? Colors.black : Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Weekly Stats
              if (_weeklyStats != null) ...[
                const Text('This Week', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSleepStatCard('Avg Sleep', '${_weeklyStats!.avgSleepHours.toStringAsFixed(1)}h', Icons.timer, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSleepStatCard('Quality', '${_weeklyStats!.avgQuality}/10', Icons.star, Colors.amber)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSleepStatCard('Sleep Debt', '${(_weeklyStats!.sleepDebtMinutes / 60).toStringAsFixed(1)}h', Icons.warning, Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSleepStatCard('Nights', '${_pastSessions.where((s) => s.wakeTime != null).length}', Icons.calendar_today, Colors.purple)),
                  ],
                ),

                const SizedBox(height: 24),

                // AI Sleep Insight
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.indigo, size: 20),
                          SizedBox(width: 8),
                          Text('AI Sleep Coach', style: TextStyle(color: Colors.indigo, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _weeklyStats!.aiInsight,
                        style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Past Sessions
              if (_pastSessions.isNotEmpty) ...[
                const Text('Recent Sleep Sessions', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._pastSessions.take(7).map((session) {
                  final isComplete = session.wakeTime != null;
                  final dist = isComplete ? _sleepService.getPhaseDistribution(session) : <String, double>{};

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isComplete ? Colors.indigo.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isComplete ? Icons.bedtime : Icons.hourglass_top,
                                color: isComplete ? Colors.indigo : Colors.orange,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${session.bedTime.day}/${session.bedTime.month}/${session.bedTime.year}',
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                  if (isComplete)
                                    Text(
                                      '${_formatTime(session.bedTime)} → ${_formatTime(session.wakeTime!)} • ${session.hoursSlept!.toStringAsFixed(1)}h',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            if (session.sleepQuality != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${session.sleepQuality}/10',
                                  style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        if (isComplete && dist.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          // Phase distribution bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Row(
                              children: [
                                if ((dist['deep'] ?? 0) > 0)
                                  Expanded(
                                    flex: (dist['deep']!).round(),
                                    child: Container(height: 8, color: Color(0xFF1a237e)),
                                  ),
                                if ((dist['light'] ?? 0) > 0)
                                  Expanded(
                                    flex: (dist['light']!).round(),
                                    child: Container(height: 8, color: Color(0xFF5c6bc0)),
                                  ),
                                if ((dist['rem'] ?? 0) > 0)
                                  Expanded(
                                    flex: (dist['rem']!).round(),
                                    child: Container(height: 8, color: Color(0xFF9fa8da)),
                                  ),
                                if ((dist['awake'] ?? 0) > 0)
                                  Expanded(
                                    flex: (dist['awake']!).round(),
                                    child: Container(height: 8, color: Color(0xFFffcdd2)),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildPhaseLegend('Deep', Color(0xFF1a237e), '${(dist['deep'] ?? 0).toStringAsFixed(0)}%'),
                              const SizedBox(width: 12),
                              _buildPhaseLegend('Light', Color(0xFF5c6bc0), '${(dist['light'] ?? 0).toStringAsFixed(0)}%'),
                              const SizedBox(width: 12),
                              _buildPhaseLegend('REM', Color(0xFF9fa8da), '${(dist['rem'] ?? 0).toStringAsFixed(0)}%'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPhaseLegend(String label, Color color, String percent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text('$label $percent', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
