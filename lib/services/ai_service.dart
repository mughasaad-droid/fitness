import 'dart:math';
import '../models/workout_data.dart';
import '../models/sleep_data.dart';

enum CoachMode { disciplined, gentle, roast, expert }

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  CoachMode _mode = CoachMode.disciplined;
  CoachMode get mode => _mode;
  set mode(CoachMode m) => _mode = m;

  // ============== AI RUNNING FORM ANALYZER ==============
  String analyzeRunningForm(List<FormSnapshot> snapshots) {
    if (snapshots.isEmpty) return 'No data yet. Start moving to see your analysis!';

    final avgBounce = snapshots.map((s) => s.bounceScore).reduce((a, b) => a + b) / snapshots.length;
    final avgBalance = snapshots.map((s) => s.balanceScore).reduce((a, b) => a + b) / snapshots.length;
    final avgCadence = snapshots.map((s) => s.cadence).reduce((a, b) => a + b) / snapshots.length;

    final buffer = StringBuffer();
    buffer.writeln('📊 AI FORM REPORT\n');
    buffer.writeln('Bounce Score: ${avgBounce.toStringAsFixed(1)}/100');
    buffer.writeln('Balance Score: ${avgBalance.toStringAsFixed(1)}/100');
    buffer.writeln('Avg Cadence: ${avgCadence.toStringAsFixed(0)} SPM\n');

    if (avgBounce > 80 && avgBalance > 80 && avgCadence > 160 && avgCadence < 185) {
      buffer.writeln('🌟 AI Analysis: Your running form is excellent!');
      buffer.writeln('   You are maintaining form like a professional runner.');
    } else {
      buffer.writeln('🔍 AI Analysis:');
      if (avgBounce < 70) {
        buffer.writeln('   • High vertical bounce — you are wasting energy on vertical movement.');
        buffer.writeln('     Tip: Keep closer to the ground and "glide" while running.');
      }
      if (avgBalance < 70) {
        buffer.writeln('   • Uneven body balance — you might be leaning too much on one side.');
        buffer.writeln('     Tip: Focus on core exercises and maintaining a straight line.');
      }
      if (avgCadence > 0 && avgCadence < 155) {
        buffer.writeln('   • Slow cadence — long strides increase injury risk.');
        buffer.writeln('     Tip: Aim for shorter, faster steps (170-180 SPM).');
      }
      if (avgCadence > 190) {
        buffer.writeln('   • Very high cadence — likely overstriding; watch out for early fatigue.');
      }
    }

    return buffer.toString();
  }

  // ============== AI COACH CHAT ==============
  String generateCoachResponse(String userMessage, List<DailyStats> last7Days, DailyStats today) {
    final msg = userMessage.toLowerCase();
    final avgSteps = last7Days.isNotEmpty 
      ? last7Days.map((d) => d.steps).reduce((a, b) => a + b) / last7Days.length 
      : 0.0;
    final isConsistent = last7Days.length >= 5 && last7Days.every((d) => d.steps > 3000);
    final isLazy = today.steps < 2000;
    final isCrushing = today.steps > 10000;

    switch (_mode) {
      case CoachMode.disciplined:
        return _disciplinedTrainerResponse(msg, today, avgSteps, isConsistent, isLazy, isCrushing);
      case CoachMode.gentle:
        return _gentleResponse(msg, today, avgSteps, isConsistent, isLazy, isCrushing);
      case CoachMode.roast:
        return _roastResponse(msg, today, avgSteps, isConsistent, isLazy, isCrushing);
      case CoachMode.expert:
        return _expertResponse(msg, today, avgSteps, isConsistent, isLazy, isCrushing);
    }
  }

  String _disciplinedTrainerResponse(String msg, DailyStats today, double avgSteps, bool consistent, bool lazy, bool crushing) {
    if (msg.contains('hello') || msg.contains('hi') || msg.contains('salam')) {
      return 'Hello! What is the plan for today? Need a workout or step goals? Let\'s get to work! 💪';
    }
    if (msg.contains('motivat') || msg.contains('demotivat') || msg.contains('don\'t feel like')) {
      if (lazy) return 'Listen, discipline beats motivation every time! Get up and start with a 10-minute walk. I\'m right here with you!';
      if (crushing) return 'Great energy today! Keep this momentum going, you are on your way to becoming a champion! 🏆';
      return 'Don\'t listen to your feelings, listen to your goals! You have ${today.steps} steps so far. Push a bit more for that 10k target!';
    }
    if (msg.contains('diet') || msg.contains('food') || msg.contains('eat')) {
      return 'Nutrition protocol: High protein (eggs, chicken), complex carbs (oats, brown rice), and plenty of greens. Cut down on sugar and processed snacks. Consistency in the kitchen is key! 😤';
    }
    if (msg.contains('pain') || msg.contains('hurt') || msg.contains('injury')) {
      return 'Safety first. If you are in pain, stop. Use ice, rest, and see a professional if it doesn\'t improve in 3 days. We train smart! 🚑';
    }
    if (msg.contains('steps') || msg.contains('walk')) {
      if (lazy) return 'Only ${today.steps} steps? You can do better than this! Put your phone in your pocket and hit the pavement! 👟';
      if (crushing) return '${today.steps} steps! Exceptional work. You are in beast mode today! 🔥';
      return 'You are at ${today.steps} steps. Your average is ${avgSteps.toStringAsFixed(0)}. ${today.steps > avgSteps ? "You are above average, good job!" : "Keep moving to beat your daily average!"}';
    }
    if (msg.contains('workout') || msg.contains('exercise')) {
      return 'Workout routine: Start with 5 mins of dynamic stretches. Then: 20 squats, 15 pushups, 30-second plank. Repeat for 3 rounds. Don\'t forget the cool down! 💯';
    }
    if (msg.contains('sleep') || msg.contains('rest') || msg.contains('tired')) {
      return 'Recovery is essential. Aim for 7-8 hours. Put your phone away 1 hour before bed and keep your room cool. Better sleep means a better workout tomorrow! 😴';
    }

    if (consistent && crushing) {
      return 'Consistency plus performance equals progress! Your dedication is inspiring. Keep crushing it! 🚀';
    } else if (consistent) {
      return 'Great consistency. Now, let\'s push the boundaries. Growth happens outside the comfort zone! 💪';
    } else if (lazy) {
      return 'Today seems slow. Remember: "The best time to plant a tree was 20 years ago. The second best time is now." Get moving! 👟';
    }

    return 'I see you have ${today.steps} steps today. Focus on hitting your daily goal and let\'s keep progressing! 🎯';
  }

  String _roastResponse(String msg, DailyStats today, double avgSteps, bool consistent, bool lazy, bool crushing) {
    if (lazy) {
      final roasts = [
        '${today.steps} steps? I\'ve seen more movement on a loading screen! 😂',
        'Are you tracking steps or just the distance to your fridge? 🍕',
        'Your phone\'s battery has more charge than your activity level today! 🔋',
        'I know snails that are more active than this. Get up! 🐌',
      ];
      return roasts[Random().nextInt(roasts.length)];
    }
    if (crushing) {
      return 'Whoa, ${today.steps} steps? Did you lose your car keys or something? 😄 Just kidding, stellar job!';
    }
    if (msg.contains('diet') || msg.contains('food')) {
      return 'Your diet seems to be 100% "cheat meal" and 0% "meal". 🍕😂';
    }
    return 'Decent performance, but "decent" doesn\'t get you to the top. Level up! 💪';
  }

  String _gentleResponse(String msg, DailyStats today, double avgSteps, bool consistent, bool lazy, bool crushing) {
    if (lazy) return 'It\'s okay to have a slow day. Everyone needs a break sometimes. Let\'s try for a fresh start tomorrow, I\'m with you. 🤗';
    if (crushing) return 'You did amazing today! I\'m so proud of your hard work. It\'s definitely paying off! 🌟';
    return 'You are doing great. Just a little more effort and you\'ll reach your goal. Believe in yourself! ✨';
  }

  String _expertResponse(String msg, DailyStats today, double avgSteps, bool consistent, bool lazy, bool crushing) {
    if (msg.contains('form') || msg.contains('running')) {
      return 'For optimal running form: 1) Focus on midfoot strike, 2) Target 170-180 SPM cadence, 3) Slight forward lean from ankles, 4) Arms at a 90-degree angle. Efficiency peaks at 4:30-5:00 min/km with these parameters.';
    }
    if (msg.contains('diet') || msg.contains('nutrition')) {
      return 'Nutrition protocol: Protein 1.6-2.2g/kg BW, Carbs 3-5g/kg based on output, Fats 0.8-1g/kg. Timing: Pre-workout carbs 30-60 min prior, post-workout protein within 120 min.';
    }
    if (msg.contains('sleep') || msg.contains('recovery')) {
      return 'Sleep hygiene: 7-9 hours for adults, consistent bedtime ±30 min, room temp 18-20°C, no blue light 1h before bed. Deep sleep peaks in first 3-4 hours.';
    }
    return 'Current data analysis: Avg ${avgSteps.toStringAsFixed(0)} steps/day. ${consistent ? "Strong consistency." : "Inconsistency detected — recommend habit stacking."} Today: ${today.steps} steps.';
  }

  // ============== AI WORKOUT GENERATOR ==============
  WorkoutPlan generateWorkout(String mood, int energyLevel, int availableMinutes, String? focusArea) {
    String title;
    String description;
    String aiNote;
    List<WorkoutExercise> exercises = [];
    String difficulty;

    if (energyLevel >= 8) {
      difficulty = 'High';
    } else if (energyLevel >= 5) {
      difficulty = 'Medium';
    } else {
      difficulty = 'Low';
    }

    switch (mood.toLowerCase()) {
      case 'stressed':
        title = 'Stress Relief Yoga Flow';
        description = 'Say goodbye to stress! This workout is designed to calm your mind and body.';
        aiNote = 'AI Note: Stress increases cortisol. Light cardio and stretching release endorphins. Focus on deep breathing.';
        exercises = [
          WorkoutExercise(name: 'Deep Breathing', duration: '3 min', trainerTip: 'Find a quiet space and focus entirely on your breath.', sets: 1),
          WorkoutExercise(name: 'Child\'s Pose', duration: '2 min', trainerTip: 'Relax completely and let go of all thoughts.', sets: 1),
          WorkoutExercise(name: 'Cat-Cow Stretch', duration: '3 min', trainerTip: 'Move fluidly with your breath to loosen the spine.', sets: 2),
          WorkoutExercise(name: 'Slow Walk', duration: '10 min', trainerTip: 'A gentle walk to clear your head.', sets: 1),
          WorkoutExercise(name: 'Savasana', duration: '5 min', trainerTip: 'Lie perfectly still and focus on total relaxation.', sets: 1),
        ];
        break;

      case 'angry':
        title = 'Release the Rage Boxing';
        description = 'Convert anger into positive energy! High-intensity movements to help you decompress.';
        aiNote = 'AI Note: High intensity helps process adrenaline from anger. Punching is a great therapeutic release!';
        exercises = [
          WorkoutExercise(name: 'Shadow Boxing', duration: '3 min', trainerTip: 'Imagine your obstacles in front of you and strike with precision.', sets: 3),
          WorkoutExercise(name: 'Burpees', duration: '1 min', trainerTip: 'Explosive movements to burn off that extra adrenaline.', sets: 3),
          WorkoutExercise(name: 'High Knees', duration: '1 min', trainerTip: 'Drive your knees up with power and intensity.', sets: 3),
          WorkoutExercise(name: 'Plank', duration: '1 min', trainerTip: 'Focus your energy on maintaining a solid, stable core.', sets: 2),
        ];
        break;

      case 'lazy':
        title = 'The Wake-Up Call';
        description = 'Very light movements to get your blood flowing and boost your energy levels.';
        aiNote = 'AI Note: Beat laziness with micro-habits. Just start for 5 minutes and you\'ll want to keep going!';
        exercises = [
          WorkoutExercise(name: 'Get Out of Bed', duration: '1 min', trainerTip: 'The hardest part is the first step — just stand up!', sets: 1),
          WorkoutExercise(name: 'Arm Circles', duration: '2 min', trainerTip: 'Large, controlled movements to wake up your shoulders.', sets: 1),
          WorkoutExercise(name: 'Walking on Spot', duration: '3 min', trainerTip: 'No equipment needed, just keep a steady rhythm.', sets: 1),
          WorkoutExercise(name: 'Neck Rolls', duration: '2 min', trainerTip: 'Release tension from sitting or lying down too long.', sets: 1),
        ];
        break;

      case 'happy':
        title = 'Joyful Cardio Blast';
        description = 'High energy workout to match your great mood. Let\'s have some fun!';
        aiNote = 'AI Note: A happy mood is a peak performance window. Great time to try for a personal best!';
        exercises = [
          WorkoutExercise(name: 'Freestyle Dance', duration: '5 min', trainerTip: 'Move however you feel! Just keep the heart rate up.', sets: 2),
          WorkoutExercise(name: 'Jumping Jacks', duration: '2 min', trainerTip: 'Stay light on your toes and maintain a steady pace.', sets: 3),
          WorkoutExercise(name: 'Mountain Climbers', duration: '1 min', trainerTip: 'Keep your core tight and drive those legs!', sets: 3),
          WorkoutExercise(name: 'Sprint on Spot', duration: '30 sec', trainerTip: 'Maximum effort! Give it everything you\'ve got.', sets: 4),
        ];
        break;

      default:
        title = 'Total Body Conditioning';
        description = 'A balanced workout covering all major muscle groups for overall fitness.';
        aiNote = 'AI Note: Focus on compound movements and maintaining proper form throughout.';
        exercises = [
          WorkoutExercise(name: 'Squats', duration: '1 min', trainerTip: 'Keep your chest up and weight on your heels.', sets: 3, reps: 15),
          WorkoutExercise(name: 'Pushups', duration: '1 min', trainerTip: 'Maintain a straight line from head to heels.', sets: 3, reps: 10),
          WorkoutExercise(name: 'Lunges', duration: '1 min', trainerTip: 'Step forward and drop your back knee toward the floor.', sets: 3, reps: 12),
          WorkoutExercise(name: 'Plank', duration: '45 sec', trainerTip: 'Keep your body rigid and breathe steadily.', sets: 2),
          WorkoutExercise(name: 'Jump Rope', duration: '2 min', trainerTip: 'Mimic the motion even if you don\'t have a rope.', sets: 2),
        ];
    }

    if (availableMinutes < 15) {
      exercises = exercises.take(3).toList();
      aiNote += '\n(Shortened version for $availableMinutes mins)';
    }

    return WorkoutPlan(
      title: title,
      description: description,
      exercises: exercises,
      totalMinutes: availableMinutes,
      difficulty: difficulty,
      aiNote: aiNote,
    );
  }

  // ============== AI DAILY INSIGHT ==============
  String generateDailyInsight(DailyStats today, List<DailyStats> last7Days) {
    final buffer = StringBuffer();

    if (last7Days.length < 3) {
      buffer.writeln('👋 Welcome to your fitness journey!');
      buffer.writeln('   Collect data for 7 days to unlock personalized AI insights.');
      return buffer.toString();
    }

    final avgSteps = last7Days.map((d) => d.steps).reduce((a, b) => a + b) / last7Days.length;
    final bestDay = last7Days.reduce((a, b) => a.steps > b.steps ? a : b);
    final trend = today.steps > avgSteps ? 'up' : 'down';
    final consistency = last7Days.where((d) => d.steps > 5000).length;

    buffer.writeln('🧠 AI DAILY INSIGHT\n');

    if (today.steps >= 10000) {
      buffer.writeln('🔥 You\'ve joined the 10K club! You are among the top 5% of active users!');
    } else if (today.steps >= 7000) {
      buffer.writeln('✅ Highly active day. Let\'s hit the 10K target tomorrow!');
    } else if (today.steps >= 4000) {
      buffer.writeln('⚠️ Average activity level. A 20-min evening walk could give you a boost.');
    } else {
      buffer.writeln('📉 Low activity today. That\'s okay, let\'s aim for more tomorrow!');
    }

    buffer.writeln('');
    buffer.writeln('📊 7-Day Analysis:');
    buffer.writeln('   • Average: ${avgSteps.toStringAsFixed(0)} steps/day');
    buffer.writeln('   • Best Day: ${bestDay.date} (${bestDay.steps} steps)');
    buffer.writeln('   • Consistency Score: $consistency/7 days');
    buffer.writeln('   • Today vs Avg: ${trend == 'up' ? '↑ Above average' : '↓ Below average'}');

    if (consistency >= 5) {
      buffer.writeln('');
      buffer.writeln('🏆 Pattern Detected: Consistency Leader!');
      buffer.writeln('   You are building a strong habit. Keep it up for 21 days for lasting change.');
    } else if (consistency <= 2) {
      buffer.writeln('');
      buffer.writeln('💡 Pattern Detected: Irregular Activity');
      buffer.writeln('   Try walking at the same time daily — 8 AM or 6 PM works best for many.');
    }

    final totalCals = last7Days.map((d) => d.calories).reduce((a, b) => a + b);
    buffer.writeln('');
    buffer.writeln('🔥 7-Day Burn: $totalCals calories');
    buffer.writeln('   = Approximately ${(totalCals / 350).toStringAsFixed(1)} healthy meals burned!');

    return buffer.toString();
  }

  // ============== AI SLEEP INSIGHT ==============
  String generateSleepInsight(SleepStats stats, List<SleepSession> sessions) {
    final buffer = StringBuffer();

    buffer.writeln('🌙 AI SLEEP INSIGHT\n');
    buffer.writeln('Avg Sleep: ${stats.avgSleepHours.toStringAsFixed(1)} hrs/night');
    buffer.writeln('Avg Quality: ${stats.avgQuality}/10');
    buffer.writeln('Sleep Debt: ${(stats.sleepDebtMinutes / 60).toStringAsFixed(1)} hrs this week\n');

    if (stats.avgSleepHours < 6) {
      buffer.writeln('⚠️ CRITICAL: Sleep duration is too low!');
      buffer.writeln('   7-8 hours is essential. Lack of sleep leads to:');
      buffer.writeln('   • Impaired memory');
      buffer.writeln('   • Metabolic changes');
      buffer.writeln('   • Weakened immune system');
    } else if (stats.avgSleepHours < 7) {
      buffer.writeln('⚠️ Slight sleep deficit. Target 7-8 hours for optimal recovery.');
    } else if (stats.avgSleepHours > 9) {
      buffer.writeln('💤 Excessive sleep detected. 7-8 hours is the recommended range.');
    } else {
      buffer.writeln('✅ Excellent sleep duration! Maintain this rhythm.');
    }

    if (stats.avgQuality < 5) {
      buffer.writeln('\n😴 Low sleep quality. Tips:');
      buffer.writeln('   • No screens 1 hour before bed');
      buffer.writeln('   • Keep your room cool and dark');
      buffer.writeln('   • Avoid caffeine in the afternoon/evening');
    }

    if (stats.sleepDebtMinutes > 180) {
      buffer.writeln('\n📉 High sleep debt! Use the weekend for restorative catch-up sleep.');
    }

    return buffer.toString();
  }
}
