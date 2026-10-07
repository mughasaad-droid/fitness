class BodyPart {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<Symptom> symptoms;
  final List<Deficiency> deficiencies;
  final ColorTheme theme;

  BodyPart({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.symptoms,
    required this.deficiencies,
    required this.theme,
  });
}

class Symptom {
  final String name;
  final String severity; // mild, moderate, severe
  final String description;

  Symptom({
    required this.name,
    required this.severity,
    required this.description,
  });
}

class Deficiency {
  final String nutrient; // Vitamin D, Iron, etc.
  final String nutrientType; // Vitamin, Mineral, Amino Acid, etc.
  final String causes;
  final String effectsOnBody;
  final List<Supplement> recommendedSupplements;
  final List<String> naturalSources;
  final String dailyRequirement;
  final String proTip;

  Deficiency({
    required this.nutrient,
    required this.nutrientType,
    required this.causes,
    required this.effectsOnBody,
    required this.recommendedSupplements,
    required this.naturalSources,
    required this.dailyRequirement,
    required this.proTip,
  });
}

class Supplement {
  final String name;
  final String dosage;
  final String timing;
  final String benefits;
  final String sideEffects;
  final String naturalAlternative;
  final double priceRange; // in PKR

  Supplement({
    required this.name,
    required this.dosage,
    required this.timing,
    required this.benefits,
    required this.sideEffects,
    required this.naturalAlternative,
    required this.priceRange,
  });
}

class ColorTheme {
  final int primary;
  final int secondary;
  final int accent;

  ColorTheme({required this.primary, required this.secondary, required this.accent});
}

// ==================== DATA ====================
class SupplementData {
  static List<BodyPart> getAllBodyParts() {
    return [
      _legsData(),
      _heartData(),
      _bonesData(),
      _brainData(),
      _musclesData(),
      _eyesData(),
      _skinData(),
      _hairData(),
      _jointsData(),
      _digestionData(),
      _immunityData(),
      _energyData(),
    ];
  }

  static BodyPart _legsData() {
    return BodyPart(
      id: 'legs',
      name: 'Legs & Feet',
      icon: '🦵',
      description: 'Leg pain, cramps, and weakness are common issues often caused by deficiencies.',
      theme: ColorTheme(primary: 0xFF4CAF50, secondary: 0xFF81C784, accent: 0xFFA5D6A7),
      symptoms: [
        Symptom(name: 'Leg Pain', severity: 'moderate', description: 'Pain in legs while walking or after sitting'),
        Symptom(name: 'Night Cramps', severity: 'severe', description: 'Sudden leg cramps while sleeping'),
        Symptom(name: 'Weakness', severity: 'moderate', description: 'Lack of strength in legs, difficulty walking'),
        Symptom(name: 'Numbness', severity: 'mild', description: 'Tingling or numbness in the legs'),
        Symptom(name: 'Swelling', severity: 'moderate', description: 'Swelling in the ankles or feet'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Vitamin D',
          nutrientType: 'Vitamin',
          causes: 'Low sun exposure, staying indoors, dark skin tone',
          effectsOnBody: 'Weakens bones, causes leg pain, and increases risk of falls',
          dailyRequirement: '600-800 IU (15-20 mcg)',
          proTip: 'Sit in the sun for 15-20 mins between 8-10 AM — a FREE supplement! ☀️',
          naturalSources: ['Egg yolks', 'Milk', 'Fish', 'Sunlight'],
          recommendedSupplements: [
            Supplement(
              name: 'Vitamin D3 (Cholecalciferol)',
              dosage: '1000-2000 IU daily',
              timing: 'After breakfast with milk',
              benefits: 'Stronger bones, relieves leg pain, boosts immunity',
              sideEffects: 'Excessive intake may increase kidney stone risk',
              naturalAlternative: 'Sunlight + Clarified butter (Ghee)',
              priceRange: 800,
            ),
            Supplement(
              name: 'Calcium + Vitamin D Combo',
              dosage: '500mg Calcium + 400 IU D3',
              timing: 'After dinner',
              benefits: 'Bone and joint health, controls cramps',
              sideEffects: 'May cause constipation',
              naturalAlternative: 'Jaggery and roasted chickpeas in winter',
              priceRange: 1200,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Magnesium',
          nutrientType: 'Mineral',
          causes: 'High intake of processed food, stress, alcohol',
          effectsOnBody: 'Muscle cramps, anxiety, sleep issues, heart palpitations',
          dailyRequirement: '310-420 mg',
          proTip: 'Eat 2-3 almonds at night — a natural magnesium source! 🥜',
          naturalSources: ['Almonds', 'Spinach', 'Liver', 'Dark chocolate', 'Pumpkin seeds'],
          recommendedSupplements: [
            Supplement(
              name: 'Magnesium Glycinate',
              dosage: '200-400 mg daily',
              timing: 'Before bedtime',
              benefits: 'Relieves cramps, better sleep, reduced stress',
              sideEffects: 'May cause loose motions initially',
              naturalAlternative: 'Warm milk + turmeric at night',
              priceRange: 1500,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Vitamin B12',
          nutrientType: 'Vitamin',
          causes: 'Vegetarian diet, absorption issues, aging',
          effectsOnBody: 'Nerve damage, numbness in legs, weakness, memory loss',
          dailyRequirement: '2.4 mcg',
          proTip: 'Vegetarians should use nutritional yeast! 🍄',
          naturalSources: ['Liver', 'Eggs', 'Milk', 'Fish', 'Nutritional yeast'],
          recommendedSupplements: [
            Supplement(
              name: 'Methylcobalamin B12',
              dosage: '1000 mcg sublingual',
              timing: 'Morning on empty stomach or with breakfast',
              benefits: 'Nerve health, energy boost, relieves leg numbness',
              sideEffects: 'Very rare — potential allergic reaction',
              naturalAlternative: 'Eat liver once a week',
              priceRange: 600,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Iron',
          nutrientType: 'Mineral',
          causes: 'Low red meat intake, heavy periods, poor absorption',
          effectsOnBody: 'Anemia, fatigue, dizziness, leg pain',
          dailyRequirement: '8-18 mg (higher for women)',
          proTip: 'Beetroot juice + lemon = double iron absorption! 🥤',
          naturalSources: ['Liver', 'Spinach', 'Beetroot', 'Chickpeas', 'Sesame seeds'],
          recommendedSupplements: [
            Supplement(
              name: 'Iron Bisglycinate',
              dosage: '25-50 mg daily',
              timing: 'Empty stomach with Vitamin C',
              benefits: 'Increases hemoglobin, ends fatigue, leg strength',
              sideEffects: 'Constipation, black stool, stomach pain',
              naturalAlternative: 'Jaggery + roasted chickpeas daily',
              priceRange: 700,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _heartData() {
    return BodyPart(
      id: 'heart',
      name: 'Heart Health',
      icon: '❤️',
      description: 'Specific nutrients are needed for heart health to control cholesterol, BP, and circulation.',
      theme: ColorTheme(primary: 0xFFE53935, secondary: 0xFFEF5350, accent: 0xFFFFCDD2),
      symptoms: [
        Symptom(name: 'Dizziness', severity: 'moderate', description: 'Sudden dizziness or restlessness'),
        Symptom(name: 'Chest Pain', severity: 'severe', description: 'Chest discomfort or pain'),
        Symptom(name: 'Shortness of Breath', severity: 'moderate', description: 'Breathlessness while walking'),
        Symptom(name: 'High BP', severity: 'severe', description: 'Blood pressure above 140/90'),
        Symptom(name: 'Fatigue', severity: 'mild', description: 'Feeling tired without any obvious reason'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Omega-3 Fatty Acids',
          nutrientType: 'Fatty Acid',
          causes: 'Low fish intake, high processed food intake',
          effectsOnBody: 'Increases triglycerides, inflammation, heart disease risk',
          dailyRequirement: '250-500 mg EPA+DHA',
          proTip: 'Eat fish twice a week — keep your heartbeat in check! 🐟',
          naturalSources: ['Salmon', 'Flaxseeds', 'Walnuts', 'Chia seeds'],
          recommendedSupplements: [
            Supplement(
              name: 'Fish Oil (Omega-3)',
              dosage: '1000-2000 mg daily',
              timing: 'After meals',
              benefits: 'Lower cholesterol, BP control, normal heart rhythm',
              sideEffects: 'Fishy burps, blood thinning',
              naturalAlternative: '1 tablespoon of flaxseed powder daily',
              priceRange: 2000,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'CoQ10 (Coenzyme Q10)',
          nutrientType: 'Enzyme',
          causes: 'Aging, statin medications, heart disease',
          effectsOnBody: 'Weakens heart muscles, lower energy production',
          dailyRequirement: '100-200 mg',
          proTip: 'A MUST-have supplement for people over 40! 💊',
          naturalSources: ['Liver', 'Chicken', 'Sardines', 'Peanuts'],
          recommendedSupplements: [
            Supplement(
              name: 'Ubiquinol CoQ10',
              dosage: '100-200 mg daily',
              timing: 'With breakfast (fatty food)',
              benefits: 'Energy to heart cells, BP control, anti-aging',
              sideEffects: 'Very rare — may cause insomnia if taken at night',
              naturalAlternative: '50g peanuts daily',
              priceRange: 3500,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Potassium',
          nutrientType: 'Mineral',
          causes: 'High salt intake, dehydration, kidney issues',
          effectsOnBody: 'High BP, irregular heartbeat, muscle weakness',
          dailyRequirement: '2600-3400 mg',
          proTip: 'Eat a banana daily — a natural way to control BP! 🍌',
          naturalSources: ['Banana', 'Potatoes', 'Kidney beans', 'Yogurt', 'Coconut water'],
          recommendedSupplements: [
            Supplement(
              name: 'Potassium Citrate',
              dosage: '99 mg (consult a doctor)',
              timing: 'After meals',
              benefits: 'BP control, normal heart rhythm, reduced cramps',
              sideEffects: 'Can be dangerous in case of kidney issues',
              naturalAlternative: '2 bananas daily',
              priceRange: 500,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _bonesData() {
    return BodyPart(
      id: 'bones',
      name: 'Bones & Joints',
      icon: '🦴',
      description: 'Calcium, Vitamin D, and Collagen are essential for bone strength.',
      theme: ColorTheme(primary: 0xFF795548, secondary: 0xFFA1887F, accent: 0xFFD7CCC8),
      symptoms: [
        Symptom(name: 'Bone Pain', severity: 'moderate', description: 'Pain in back or joints'),
        Symptom(name: 'Frequent Fractures', severity: 'severe', description: 'Bones breaking from minor injuries'),
        Symptom(name: 'Loss of Height', severity: 'mild', description: 'Shrinking in height due to age'),
        Symptom(name: 'Weak Teeth', severity: 'moderate', description: 'Cavities or breaking of teeth'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Calcium',
          nutrientType: 'Mineral',
          causes: 'Low milk intake, aging, hormonal changes',
          effectsOnBody: 'Osteoporosis, bone fractures, weak teeth',
          dailyRequirement: '1000-1200 mg',
          proTip: 'Drink milk with clarified butter (ghee) — strong bones! 🥛',
          naturalSources: ['Milk', 'Yogurt', 'Cheese', 'Leafy greens', 'Sardines'],
          recommendedSupplements: [
            Supplement(
              name: 'Calcium Citrate + Vitamin D3',
              dosage: '500mg Calcium + 400 IU D3',
              timing: 'After dinner',
              benefits: 'Increases bone density, reduces fracture risk',
              sideEffects: 'Constipation, kidney stones (with excessive intake)',
              naturalAlternative: '2 glasses of milk with turmeric daily',
              priceRange: 1000,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Collagen',
          nutrientType: 'Protein',
          causes: 'Aging, smoking, sun exposure, poor diet',
          effectsOnBody: 'Stiff joints, loose skin, weak bones',
          dailyRequirement: '10-15 g',
          proTip: 'Drink bone broth — a natural collagen source! 🍲',
          naturalSources: ['Bone broth', 'Chicken skin', 'Fish', 'Eggs'],
          recommendedSupplements: [
            Supplement(
              name: 'Hydrolyzed Collagen Peptides',
              dosage: '10-15 g daily',
              timing: 'Mixed in morning coffee or smoothie',
              benefits: 'Smooth joints, tight skin, strong bones',
              sideEffects: 'Very rare — taste might be unpleasant',
              naturalAlternative: 'Bone broth 2-3 times a week',
              priceRange: 4000,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _brainData() {
    return BodyPart(
      id: 'brain',
      name: 'Brain & Memory',
      icon: '🧠',
      description: 'Specific nutrients are required for brain sharpness, focus, and memory.',
      theme: ColorTheme(primary: 0xFF9C27B0, secondary: 0xFFBA68C8, accent: 0xFFE1BEE7),
      symptoms: [
        Symptom(name: 'Forgetfulness', severity: 'moderate', description: 'Quickly forgetting things'),
        Symptom(name: 'Poor Concentration', severity: 'moderate', description: 'Unable to focus on work'),
        Symptom(name: 'Headache', severity: 'mild', description: 'Frequent headaches'),
        Symptom(name: 'Mood Swings', severity: 'moderate', description: 'Getting angry or sad quickly'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Omega-3 (DHA)',
          nutrientType: 'Fatty Acid',
          causes: 'Low fish intake, vegetarian diet',
          effectsOnBody: 'Weak memory, depression, focus issues',
          dailyRequirement: '250-500 mg DHA',
          proTip: 'Eat walnuts daily — sharp brain! 🧠',
          naturalSources: ['Fatty fish', 'Walnuts', 'Flaxseeds', 'Chia seeds'],
          recommendedSupplements: [
            Supplement(
              name: 'DHA Omega-3',
              dosage: '500 mg daily',
              timing: 'After breakfast',
              benefits: 'Memory boost, better focus, stable mood',
              sideEffects: 'Fishy burps',
              naturalAlternative: '4-5 walnuts daily',
              priceRange: 2500,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Vitamin B Complex',
          nutrientType: 'Vitamin',
          causes: 'Stress, processed food, alcohol',
          effectsOnBody: 'Brain fog, anxiety, fatigue, nerve issues',
          dailyRequirement: 'Varies by B vitamin',
          proTip: 'A traditional breakfast — egg + whole wheat bread = B vitamins! 🍳',
          naturalSources: ['Whole grains', 'Eggs', 'Leafy greens', 'Meat'],
          recommendedSupplements: [
            Supplement(
              name: 'B-Complex with B12',
              dosage: '1 tablet daily',
              timing: 'After breakfast',
              benefits: 'Energy, brain function, nerve health',
              sideEffects: 'Urine may turn yellow (this is normal)',
              naturalAlternative: 'Sprouts and leafy greens daily',
              priceRange: 800,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _musclesData() {
    return BodyPart(
      id: 'muscles',
      name: 'Muscles & Strength',
      icon: '💪',
      description: 'Protein, Creatine, and BCAAs are essential for muscle building and recovery.',
      theme: ColorTheme(primary: 0xFFFF9800, secondary: 0xFFFFB74D, accent: 0xFFFFE0B2),
      symptoms: [
        Symptom(name: 'Muscle Loss', severity: 'moderate', description: 'Muscles shrinking or becoming weak'),
        Symptom(name: 'Slow Recovery', severity: 'moderate', description: 'Pain for 3-4 days after workout'),
        Symptom(name: 'Reduced Strength', severity: 'mild', description: 'Lifting less weight than before'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Protein',
          nutrientType: 'Macronutrient',
          causes: 'Vegetarian diet, low intake, poor absorption',
          effectsOnBody: 'Muscle loss, slow recovery, weakness',
          dailyRequirement: '1.6-2.2 g per kg body weight',
          proTip: 'Every meal should have a protein source — eggs, lentils, or chicken! 🍗',
          naturalSources: ['Chicken', 'Eggs', 'Lentils', 'Yogurt', 'Cottage cheese', 'Soy'],
          recommendedSupplements: [
            Supplement(
              name: 'Whey Protein',
              dosage: '25-30 g daily (1 scoop)',
              timing: '30 min after workout',
              benefits: 'Muscle build, fast recovery, strength gain',
              sideEffects: 'Bloating in case of lactose intolerance',
              naturalAlternative: 'Roasted chickpea flour (Sattu) + milk',
              priceRange: 6000,
            ),
            Supplement(
              name: 'Creatine Monohydrate',
              dosage: '5 g daily',
              timing: 'Any time — consistency is key',
              benefits: 'Strength boost (10-15%), muscle volume, brain energy',
              sideEffects: 'Weight gain (water retention) in the first few days',
              naturalAlternative: 'Eat red meat (natural source of creatine)',
              priceRange: 2000,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _eyesData() {
    return BodyPart(
      id: 'eyes',
      name: 'Eye Health',
      icon: '👁️',
      description: 'Specific antioxidants are essential for eye health and vision.',
      theme: ColorTheme(primary: 0xFF00BCD4, secondary: 0xFF4DD0E1, accent: 0xFFB2EBF2),
      symptoms: [
        Symptom(name: 'Eye Pain', severity: 'mild', description: 'Pain in eyes after screen time'),
        Symptom(name: 'Reduced Vision', severity: 'moderate', description: 'Difficulty seeing at night'),
        Symptom(name: 'Dry Eyes', severity: 'mild', description: 'Dryness and burning in eyes'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Vitamin A',
          nutrientType: 'Vitamin',
          causes: 'Low carrot intake, poor fat absorption',
          effectsOnBody: 'Night blindness, dry eyes, weak immunity',
          dailyRequirement: '700-900 mcg',
          proTip: 'Eat carrots — sharp eyes! 🥕',
          naturalSources: ['Carrots', 'Papaya', 'Spinach', 'Eggs', 'Butter'],
          recommendedSupplements: [
            Supplement(
              name: 'Vitamin A (Retinol)',
              dosage: '2500-5000 IU daily',
              timing: 'After breakfast with fatty food',
              benefits: 'Night vision, eye moisture, skin health',
              sideEffects: 'Excessive intake can cause liver damage',
              naturalAlternative: 'Carrot juice daily',
              priceRange: 500,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Lutein & Zeaxanthin',
          nutrientType: 'Antioxidant',
          causes: 'High screen time, aging, poor diet',
          effectsOnBody: 'Blue light damage, macular degeneration, eye strain',
          dailyRequirement: '10 mg Lutein + 2 mg Zeaxanthin',
          proTip: 'Leafy greens daily — medicine for your eyes! 🥬',
          naturalSources: ['Kale', 'Spinach', 'Broccoli', 'Corn', 'Eggs'],
          recommendedSupplements: [
            Supplement(
              name: 'Lutein + Zeaxanthin Complex',
              dosage: '10-20 mg daily',
              timing: 'After breakfast',
              benefits: 'Blue light protection, reduced eye strain, sharp vision',
              sideEffects: 'Very rare',
              naturalAlternative: 'Spinach and fenugreek daily',
              priceRange: 1800,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _skinData() {
    return BodyPart(
      id: 'skin',
      name: 'Skin Health',
      icon: '✨',
      description: 'Vitamins A, C, E, and Zinc are necessary for skin glow and acne control.',
      theme: ColorTheme(primary: 0xFFFF69B4, secondary: 0xFFF48FB1, accent: 0xFFF8BBD0),
      symptoms: [
        Symptom(name: 'Acne', severity: 'moderate', description: 'Pimples and breakouts on face'),
        Symptom(name: 'Dry Skin', severity: 'mild', description: 'Skin remains rough and dry'),
        Symptom(name: 'Dark Spots', severity: 'mild', description: 'Black spots on face'),
        Symptom(name: 'Premature Aging', severity: 'mild', description: 'Early onset of wrinkles'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Vitamin C',
          nutrientType: 'Vitamin',
          causes: 'Low fruit intake, smoking, stress',
          effectsOnBody: 'Low collagen, dull skin, slow healing, weak immunity',
          dailyRequirement: '75-90 mg',
          proTip: 'Eat gooseberry (Amla) daily — a treasure of Vitamin C! 🍊',
          naturalSources: ['Amla', 'Lemon', 'Orange', 'Strawberry', 'Bell peppers'],
          recommendedSupplements: [
            Supplement(
              name: 'Vitamin C (Ascorbic Acid)',
              dosage: '500-1000 mg daily',
              timing: 'After breakfast',
              benefits: 'Skin glow, collagen boost, strong immunity',
              sideEffects: 'Excessive intake may cause diarrhea',
              naturalAlternative: '1 Amla or lemon water daily',
              priceRange: 600,
            ),
          ],
        ),
        Deficiency(
          nutrient: 'Zinc',
          nutrientType: 'Mineral',
          causes: 'Vegetarian diet, poor absorption, alcohol',
          effectsOnBody: 'Acne, slow healing, hair loss, weak immunity',
          dailyRequirement: '8-11 mg',
          proTip: 'Eat pumpkin seeds — a natural source of zinc! 🎃',
          naturalSources: ['Meat', 'Shellfish', 'Pumpkin seeds', 'Chickpeas', 'Nuts'],
          recommendedSupplements: [
            Supplement(
              name: 'Zinc Picolinate',
              dosage: '15-30 mg daily',
              timing: 'After meals',
              benefits: 'Acne control, wound healing, immunity boost',
              sideEffects: 'Taking on an empty stomach may cause nausea',
              naturalAlternative: 'Eat oysters or meat 2-3 times a week',
              priceRange: 900,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _hairData() {
    return BodyPart(
      id: 'hair',
      name: 'Hair Health',
      icon: '💇',
      description: 'Biotin, Iron, and Protein are essential for hair health.',
      theme: ColorTheme(primary: 0xFF8D6E63, secondary: 0xFFBCAAA4, accent: 0xFFD7CCC8),
      symptoms: [
        Symptom(name: 'Hair Fall', severity: 'moderate', description: 'Excessive hair loss'),
        Symptom(name: 'Dandruff', severity: 'mild', description: 'Dryness in the scalp'),
        Symptom(name: 'Thin Hair', severity: 'moderate', description: 'Thin and weak hair'),
        Symptom(name: 'Premature Grey', severity: 'mild', description: 'Early greying of hair'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Biotin (Vitamin B7)',
          nutrientType: 'Vitamin',
          causes: 'Eating raw eggs (avidin), poor diet, antibiotics',
          effectsOnBody: 'Hair fall, brittle nails, skin rashes',
          dailyRequirement: '30-100 mcg',
          proTip: 'Eat cooked eggs — raw eggs block biotin! 🥚',
          naturalSources: ['Eggs (cooked)', 'Nuts', 'Seeds', 'Sweet potato', 'Salmon'],
          recommendedSupplements: [
            Supplement(
              name: 'Biotin 10,000 mcg',
              dosage: '1 capsule daily',
              timing: 'After breakfast',
              benefits: 'Hair growth, strong nails, skin health',
              sideEffects: 'May interfere with lab tests',
              naturalAlternative: 'Almonds and walnuts daily',
              priceRange: 1200,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _jointsData() {
    return BodyPart(
      id: 'joints',
      name: 'Joints & Mobility',
      icon: '🦿',
      description: 'Glucosamine, Chondroitin, and Turmeric are best for joint pain and stiffness.',
      theme: ColorTheme(primary: 0xFF607D8B, secondary: 0xFF90A4AE, accent: 0xFFCFD8DC),
      symptoms: [
        Symptom(name: 'Joint Pain', severity: 'moderate', description: 'Pain in knees or elbows'),
        Symptom(name: 'Stiffness', severity: 'mild', description: 'Stiff joints when waking up in the morning'),
        Symptom(name: 'Swelling', severity: 'moderate', description: 'Swelling in joints'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Glucosamine + Chondroitin',
          nutrientType: 'Compound',
          causes: 'Aging, joint wear, injury',
          effectsOnBody: 'Cartilage breakdown, bone-on-bone friction, pain',
          dailyRequirement: '1500 mg Glucosamine + 1200 mg Chondroitin',
          proTip: 'Drink turmeric milk — a natural anti-inflammatory! 🥛',
          naturalSources: ['Bone broth', 'Shellfish', 'Turmeric', 'Ginger'],
          recommendedSupplements: [
            Supplement(
              name: 'Glucosamine Chondroitin MSM',
              dosage: '2 tablets daily',
              timing: 'After meals',
              benefits: 'Joint pain relief, cartilage repair, better mobility',
              sideEffects: 'Avoid if you have a shellfish allergy',
              naturalAlternative: 'Turmeric milk + ginger daily',
              priceRange: 3000,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _digestionData() {
    return BodyPart(
      id: 'digestion',
      name: 'Digestion & Gut',
      icon: '🍽️',
      description: 'Probiotics, Fiber, and Digestive Enzymes are essential for gut health.',
      theme: ColorTheme(primary: 0xFF4CAF50, secondary: 0xFF81C784, accent: 0xFFA5D6A7),
      symptoms: [
        Symptom(name: 'Gas', severity: 'mild', description: 'Gas and bloating in stomach'),
        Symptom(name: 'Constipation', severity: 'moderate', description: 'No bowel movement for 2-3 days'),
        Symptom(name: 'Acidity', severity: 'moderate', description: 'Heartburn and acidity'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Probiotics',
          nutrientType: 'Bacteria',
          causes: 'Antibiotics, processed food, stress',
          effectsOnBody: 'Gut imbalance, bloating, weak immunity',
          dailyRequirement: '10-50 billion CFU',
          proTip: 'Eat yogurt daily — a natural probiotic! 🥣',
          naturalSources: ['Yogurt', 'Lassi', 'Kimchi', 'Kombucha', 'Kefir'],
          recommendedSupplements: [
            Supplement(
              name: 'Multi-Strain Probiotic',
              dosage: '1 capsule daily',
              timing: 'Empty stomach in the morning',
              benefits: 'Gut health, digestion, immunity boost',
              sideEffects: 'May cause gas in the first few days',
              naturalAlternative: '1 bowl of fresh yogurt daily',
              priceRange: 2500,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _immunityData() {
    return BodyPart(
      id: 'immunity',
      name: 'Immunity System',
      icon: '🛡️',
      description: 'Vitamin C, D, Zinc, and Elderberry are best for keeping immunity strong.',
      theme: ColorTheme(primary: 0xFFFFC107, secondary: 0xFFFFD54F, accent: 0xFFFFECB3),
      symptoms: [
        Symptom(name: 'Frequent Illness', severity: 'moderate', description: 'Getting flu every 2-3 months'),
        Symptom(name: 'Slow Recovery', severity: 'mild', description: 'Taking time to recover after getting sick'),
        Symptom(name: 'Infections', severity: 'moderate', description: 'Getting infections repeatedly'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Vitamin C + Zinc + D3',
          nutrientType: 'Combo',
          causes: 'Poor diet, stress, lack of sun',
          effectsOnBody: 'Weak immune cells, high infection risk',
          dailyRequirement: '500mg C + 15mg Zinc + 1000 IU D3',
          proTip: 'Ginger tea + lemon = immunity bomb! 🍵',
          naturalSources: ['Amla', 'Lemon', 'Ginger', 'Garlic', 'Turmeric'],
          recommendedSupplements: [
            Supplement(
              name: 'Immunity Booster Complex',
              dosage: '1 tablet daily',
              timing: 'After breakfast',
              benefits: 'Strong immunity, cold/flu protection, fast recovery',
              sideEffects: 'Very rare',
              naturalAlternative: 'Herbal tea (tulsi + ginger + turmeric + black pepper)',
              priceRange: 1500,
            ),
          ],
        ),
      ],
    );
  }

  static BodyPart _energyData() {
    return BodyPart(
      id: 'energy',
      name: 'Energy & Stamina',
      icon: '⚡',
      description: 'Iron, B12, CoQ10, and Ashwagandha are best for boosting energy levels.',
      theme: ColorTheme(primary: 0xFFFF5722, secondary: 0xFFFF8A65, accent: 0xFFFFCCBC),
      symptoms: [
        Symptom(name: 'Fatigue', severity: 'moderate', description: 'Feeling tired all day'),
        Symptom(name: 'Low Stamina', severity: 'moderate', description: 'Getting out of breath and tired quickly'),
        Symptom(name: 'Brain Fog', severity: 'mild', description: 'Confusion or lack of mental clarity'),
      ],
      deficiencies: [
        Deficiency(
          nutrient: 'Ashwagandha (Withania Somnifera)',
          nutrientType: 'Herb',
          causes: 'Chronic stress, poor sleep, overwork',
          effectsOnBody: 'High cortisol, fatigue, anxiety, low testosterone',
          dailyRequirement: '300-600 mg KSM-66 extract',
          proTip: 'Drink Ashwagandha powder mixed in milk — natural power! 💪',
          naturalSources: ['Ashwagandha root', 'Tulsi', 'Brahmi'],
          recommendedSupplements: [
            Supplement(
              name: 'Ashwagandha KSM-66',
              dosage: '300-600 mg daily',
              timing: 'At night with milk',
              benefits: 'Reduced stress, energy boost, better sleep, testosterone support',
              sideEffects: 'Consult a doctor if you have thyroid issues',
              naturalAlternative: 'Ashwagandha powder + jaggery + milk',
              priceRange: 2000,
            ),
          ],
        ),
      ],
    );
  }
}
