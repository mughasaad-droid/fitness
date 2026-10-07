# AI Fitness Pro (Desi Fitness AI) 🏋️‍♂️⚡

**AI Fitness Pro** is a modern, feature-rich Flutter application powered by AI algorithms to deliver an all-in-one fitness, workout, sleep, running, and nutrition/supplement coaching experience.

---

## 🌟 Key Features & Highlights

### 🤖 1. AI Fitness Coach ("Desi Coach")
- **Interactive Conversational AI**: Instant answers to questions regarding fitness, exercise, nutrition, diet plans, and recovery.
- **4 Distinct Coach Modes**:
  - **Disciplined Trainer**: Strict, goal-focused, zero-excuses approach.
  - **Gentle Coach**: Empathetic, encouraging, and supportive tone.
  - **Roast Mode**: Witty, humorous, and entertaining banter to keep you motivated.
  - **Expert Coach**: Metric-driven, bio-scientific insights for advanced athletes.

---

### 🏃 2. Live Run Tracker & AI Form Analyzer
- **Real-time Movement Tracking**: Continuous tracking of steps, pace, distance, and active time.
- **AI Running Form Analyzer**: Uses accelerometer data to calculate:
  - **Vertical Bounce Score**: Minimizes wasted energy during stride landing.
  - **Balance Score**: Evaluates bilateral symmetry and stride stability.
  - **Cadence Monitor**: Target cadence recommendations (170–180 SPM) to avoid injury.

---

### 🏋️ 3. Smart Workout Generator
- Custom workout program generation dynamically calculated based on:
  - **Mood**: Stressed, Angry, Lazy, Happy, Energetic.
  - **Energy Level**: 1–10 intensity slider.
  - **Time Available**: Custom duration (e.g. 10, 20, 30+ minutes).
- Complete with exercise instructions, targeted reps/sets, and AI trainer tips.

---

### 🌙 4. Sleep Tracker & Sleep Debt Calculator
- Track night-by-night sleep duration and quality.
- Automatic **Sleep Debt Analysis** to detect cumulative sleep deficits over 7 days.
- AI-driven suggestions for circadian rhythm optimization and sleep hygiene.

---

### 💊 5. Supplement Advisor
- Personalized recommendations tailored to goals:
  - Muscle Growth & Hypertrophy
  - Fat Loss & Metabolism
  - General Health & Vitality
  - Athletic Endurance & Recovery
  - Deep Sleep & Joint Health
- Provides exact dosages, optimal timing, key benefits, and safety guidance.

---

### 📊 6. Analytics & Performance Dashboard
- Visual graphs and historical trends powered by `fl_chart`:
  - Weekly & Monthly Step Trends
  - Calorie Burn Tracking
  - Daily Hydration Logs
  - Weight Progression History

---

## 📂 Project Architecture

```
lib/
├── main.dart                           # App entry point, theme & status bar setup
├── models/
│   ├── sleep_data.dart                 # Sleep session logs & sleep debt models
│   ├── supplement_data.dart            # Comprehensive supplement data structures
│   └── workout_data.dart               # Workout routines and exercise definitions
├── screens/
│   ├── splash_screen.dart              # Onboarding splash screen
│   ├── home_screen.dart                # Main dashboard (steps, calories, water, quick links)
│   ├── ai_coach_screen.dart            # Chat interface with AI Coach personality switcher
│   ├── run_screen.dart                 # Live run tracker with motion sensor form analysis
│   ├── workout_generator_screen.dart    # Mood & energy-based workout generator
│   ├── sleep_tracker_screen.dart       # Nightly sleep tracker & sleep debt UI
│   ├── supplement_advisor_screen.dart  # Custom supplement recommendation screen
│   └── analytics_screen.dart           # Detailed fl_chart analytical graphs
└── services/
    ├── ai_service.dart                 # Core AI logic (Chat, Form Analyzer, Workout Engine)
    ├── pedometer_service.dart          # Pedometer & accelerometer hardware listener
    └── sleep_service.dart              # SharedPreferences persistence for sleep records
```

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `>=3.0.0 <4.0.0`)
- **UI Design**: Material Design 3, Custom Dynamic Gradients, Responsive UI Layouts
- **Sensors & Hardware**: `pedometer`, `sensors_plus`
- **Charts & Graphs**: `fl_chart`
- **Persistence**: `shared_preferences`
- **Date & Permissions**: `intl`, `permission_handler`

---

## 🚀 Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mughasaad-droid/fitness.git
   cd fitness
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 👤 Author & Maintainer

- **Developer**: Mughal Saad
- **GitHub**: [@mughasaad-droid](https://github.com/mughasaad-droid)
- **Repository**: [https://github.com/mughasaad-droid/fitness.git](https://github.com/mughasaad-droid/fitness.git)
