import 'package:flutter/material.dart';
import '../models/workout_data.dart';
import '../services/ai_service.dart';

class WorkoutGeneratorScreen extends StatefulWidget {
  const WorkoutGeneratorScreen({super.key});

  @override
  State<WorkoutGeneratorScreen> createState() => _WorkoutGeneratorScreenState();
}

class _WorkoutGeneratorScreenState extends State<WorkoutGeneratorScreen> {
  final _aiService = AIService();
  WorkoutPlan? _currentPlan;
  String _selectedMood = 'Normal';
  double _energyLevel = 5;
  double _availableMinutes = 20;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Stressed', 'icon': Icons.cloud, 'color': Colors.blue},
    {'label': 'Angry', 'icon': Icons.local_fire_department, 'color': Colors.red},
    {'label': 'Lazy', 'icon': Icons.bed, 'color': Colors.orange},
    {'label': 'Happy', 'icon': Icons.emoji_emotions, 'color': Colors.yellow},
    {'label': 'Normal', 'icon': Icons.sentiment_satisfied, 'color': Colors.green},
  ];

  void _generateWorkout() {
    final plan = _aiService.generateWorkout(
      _selectedMood,
      _energyLevel.round(),
      _availableMinutes.round(),
      null,
    );
    setState(() => _currentPlan = plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('AI Workout Generator', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Selection
              const Text(
                'How are you feeling today?',
                style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? (mood['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? mood['color'] as Color : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(mood['icon'] as IconData, color: mood['color'] as Color, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            mood['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Energy Level
              Text(
                'Energy Level: ${_energyLevel.toInt()}/10',
                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _energyLevel < 4 ? Colors.red : _energyLevel < 7 ? Colors.orange : Colors.green,
                  thumbColor: Colors.purple,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _energyLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => setState(() => _energyLevel = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Exhausted 💀', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text('Ready to Go! 🔥', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),

              const SizedBox(height: 24),

              // Available Time
              Text(
                'Available time: ${_availableMinutes.toInt()} min',
                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.purple,
                  thumbColor: Colors.purple,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _availableMinutes,
                  min: 5,
                  max: 60,
                  divisions: 11,
                  onChanged: (v) => setState(() => _availableMinutes = v),
                ),
              ),

              const SizedBox(height: 24),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateWorkout,
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text(
                    'Generate AI Workout',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Workout Plan Display
              if (_currentPlan != null) _buildWorkoutCard(_currentPlan!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plan.totalMinutes} min • ${plan.difficulty} Intensity',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.description,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 16),

          // AI Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.aiNote,
                    style: TextStyle(color: Colors.green[900], fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),

          // Exercises
          Text(
            'Exercises',
            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...plan.exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final ex = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${ex.duration}${ex.reps > 0 ? ' • ${ex.sets}x${ex.reps}' : ''}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '💡 ${ex.trainerTip}',
                          style: TextStyle(color: Colors.orange[900], fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
