import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_data.dart';
import '../services/pedometer_service.dart';
import '../services/ai_service.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> with SingleTickerProviderStateMixin {
  final _pedometerService = PedometerService();
  final _aiService = AIService();
  bool _isRunning = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  FormSnapshot? _latestForm;
  RunningSession? _session;
  final List<FormSnapshot> _formHistory = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pedometerService.formStream.listen((snapshot) {
      setState(() {
        _latestForm = snapshot;
        _formHistory.add(snapshot);
      });
    });

    _pedometerService.sessionStream.listen((session) {
      setState(() => _session = session);
    });
  }

  void _toggleRun() {
    if (_isRunning) {
      _stopRun();
    } else {
      _startRun();
    }
  }

  void _startRun() {
    setState(() {
      _isRunning = true;
      _elapsedSeconds = 0;
      _formHistory.clear();
      _latestForm = null;
    });
    _pedometerService.startRun();
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopRun() {
    _timer?.cancel();
    _pulseController.stop();
    _pedometerService.stopRun();

    setState(() => _isRunning = false);

    // Show AI Form Report
    Future.delayed(const Duration(milliseconds: 500), () {
      _showFormReport();
    });
  }

  void _showFormReport() {
    if (_formHistory.isEmpty) return;

    final report = _aiService.analyzeRunningForm(_formHistory);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.green, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'AI Form Analysis',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Awesome!', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = _session?.distanceKm ?? 0.0;
    final pace = distance > 0 ? (_elapsedSeconds / 60) / distance : 0.0;
    final calories = _session?.calories ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Running Tracker', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Timer Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isRunning ? Colors.orange.withValues(alpha: 0.5) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? 'RUNNING...' : 'READY TO RUN',
                      style: TextStyle(
                        color: _isRunning ? Colors.orange : Colors.grey[600],
                        fontSize: 14,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildRunStat('Distance', '${distance.toStringAsFixed(2)} km', Icons.location_on)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRunStat('Pace', pace > 0 ? '${pace.toStringAsFixed(1)} min/km' : '--', Icons.speed)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildRunStat('Calories', '$calories', Icons.local_fire_department)),
                ],
              ),

              const SizedBox(height: 20),

              // AI Real-time Form Feedback
              if (_isRunning && _latestForm != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1 + (_pulseController.value * 0.2)),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.mic, color: Colors.green, size: 16),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Coach Live',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _latestForm!.feedback,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFormMetric('Bounce', _latestForm!.bounceScore, Colors.blue),
                          const SizedBox(width: 12),
                          _buildFormMetric('Balance', _latestForm!.balanceScore, Colors.purple),
                          const SizedBox(width: 12),
                          _buildFormMetric('Cadence', _latestForm!.cadence, Colors.orange, isCadence: true),
                        ],
                      ),
                    ],
                  ),
                ),

              if (!_isRunning && _formHistory.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Last Run Complete!',
                        style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap below to see AI Form Report',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Start/Stop Button
              GestureDetector(
                onTap: _toggleRun,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isRunning 
                        ? const [Colors.red, Colors.redAccent]
                        : const [Colors.green, Colors.greenAccent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning ? Colors.red : Colors.green).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                _isRunning ? 'TAP TO STOP' : 'TAP TO START',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormMetric(String label, double value, Color color, {bool isCadence = false}) {
    final displayValue = isCadence ? value.toStringAsFixed(0) : value.toStringAsFixed(0);
    final unit = isCadence ? ' SPM' : '';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$displayValue$unit',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
