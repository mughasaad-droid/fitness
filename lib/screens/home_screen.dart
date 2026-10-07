import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/workout_data.dart';
import '../services/pedometer_service.dart';
import '../services/ai_service.dart';
import '../services/sleep_service.dart';
import 'run_screen.dart';
import 'ai_coach_screen.dart';
import 'workout_generator_screen.dart';
import 'analytics_screen.dart';
import 'sleep_tracker_screen.dart';
import 'supplement_advisor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _pedometerService = PedometerService();
  final _aiService = AIService();
  final _sleepService = SleepService();
  int _steps = 0;
  double _distance = 0.0;
  int _calories = 0;
  String _aiInsight = 'AI analysis loading...';
  DailyStats _todayStats = DailyStats(date: DateTime.now().toIso8601String().split('T')[0]);
  List<DailyStats> _last7Days = [];
  double _lastNightSleep = 0.0;
  int _sleepQuality = 0;
  late AnimationController _animationController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
    _loadData();
  }

  Future<void> _loadData() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      await _pedometerService.init();

      _pedometerService.stepsStream.listen((steps) {
        setState(() {
          _steps = steps;
          _distance = steps * 0.000762;
          _calories = (steps * 0.04).round();
          _todayStats.steps = steps;
          _todayStats.distanceKm = _distance;
          _todayStats.calories = _calories;
        });
        _updateAIInsight();
      });
    } else {
      setState(() {
        _aiInsight = 'Permission denied. Please enable activity recognition in settings.';
      });
    }

    final stats = await _pedometerService.getTodayStats();
    final List<DailyStats> weekData = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      weekData.add(DailyStats(date: dateStr));
    }

    final sleepSessions = await _sleepService.getLast7DaysSessions();
    final lastNight = sleepSessions.isNotEmpty ? sleepSessions.first : null;

    setState(() {
      _todayStats = stats;
      _last7Days = weekData;
      _lastNightSleep = lastNight?.hoursSlept ?? 0.0;
      _sleepQuality = lastNight?.sleepQuality ?? 0;
    });
    _updateAIInsight();
  }

  void _updateAIInsight() {
    final insight = _aiService.generateDailyInsight(_todayStats, _last7Days);
    setState(() => _aiInsight = insight);
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Clear Record?', style: TextStyle(color: Colors.black87)),
        content: const Text('Do you want to reset today\'s steps to zero?', style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _pedometerService.resetSteps();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Steps reset!')),
              );
            },
            child: const Text('Yes, Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goalSteps = 10000;
    final progress = (_steps / goalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 90,
                          width: 240, // Wider to accommodate "Pure Fitness" logo text properly
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/home.PNG',
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.fitness_center, color: Colors.blueAccent, size: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black54),
                          tooltip: 'Clear Record',
                          onPressed: _showResetDialog,
                        ),
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF667EEA),
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Stats Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Stats on the left (Stacked vertically)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatItem(Icons.local_fire_department, '$_calories', 'Calories'),
                          const SizedBox(height: 24),
                          _buildStatItem(Icons.location_on, _distance.toStringAsFixed(2), 'Km'),
                          const SizedBox(height: 24),
                          _buildStatItem(Icons.timer, (_steps * 0.008).toStringAsFixed(0), 'Min'),
                        ],
                      ),
                      const Spacer(),
                      // Larger Step Tracker on the right
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 14,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.directions_walk, color: Colors.white70, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_steps',
                                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                                  ),
                                  const Text('/ 10000', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Sleep Widget
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackerScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bedtime, color: Colors.amber, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Last Night's Sleep",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _lastNightSleep > 0 
                                  ? '${_lastNightSleep.toStringAsFixed(1)} hours'
                                  : 'No data yet',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              if (_sleepQuality > 0)
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Quality: $_sleepQuality/10',
                                      style: TextStyle(color: Colors.amber, fontSize: 12),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions - Stacked Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Quick Actions', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 380,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _actions.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
                              } else if (index != 0) {
                                value = 0.75; // Initial state for side cards
                              }

                              return Opacity(
                                opacity: value.clamp(0.4, 1.0),
                                child: Transform.scale(
                                  scale: Curves.easeInOut.transform(value),
                                  child: child,
                                ),
                              );
                            },
                            child: _StackedActionCard(
                              action: _actions[index],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _actions[index].screen)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // AI Insight Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1 + (_animationController.value * 0.05)),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.psychology, color: Colors.green),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text('AI Daily Insight', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _aiInsight,
                        style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  final List<_ActionData> _actions = [
    _ActionData(title: 'Running Tracker', subtitle: 'Track your form & pace', icon: Icons.run_circle, color: Colors.orange, screen: const RunScreen()),
    _ActionData(title: 'AI Personal Coach', subtitle: 'Disciplined fitness advice', icon: Icons.psychology, color: Colors.green, screen: const AICoachScreen()),
    _ActionData(title: 'Workout Generator', subtitle: 'Custom plans for your mood', icon: Icons.fitness_center, color: Colors.purple, screen: const WorkoutGeneratorScreen()),
    _ActionData(title: 'Health Analytics', subtitle: 'Deep dive into your progress', icon: Icons.bar_chart, color: Colors.blue, screen: const AnalyticsScreen()),
    _ActionData(title: 'Sleep Monitor', subtitle: 'Quality & cycle analysis', icon: Icons.bedtime, color: Colors.indigo, screen: const SleepTrackerScreen()),
    _ActionData(title: 'Supplement Guide', subtitle: 'Nutrient & vitamin advisor', icon: Icons.medication, color: Colors.teal, screen: const SupplementAdvisorScreen()),
  ];

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;
  _ActionData({required this.title, required this.subtitle, required this.icon, required this.color, required this.screen});
}

class _StackedActionCard extends StatelessWidget {
  final _ActionData action;
  final VoidCallback onTap;

  const _StackedActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: action.color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Glossy Shine Effect Layer
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Top Decoration Circle (More subtle)
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Badge (Glossy look)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: action.color.withValues(alpha: 0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(action.icon, color: action.color, size: 36),
                    ),
                    const Spacer(),
                    // Labels
                    Text(
                      action.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Button Label
                    Row(
                      children: [
                        Text(
                          'OPEN',
                          style: TextStyle(
                            color: action.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: action.color, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
