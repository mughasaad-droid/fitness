import 'package:flutter/material.dart';
import '../models/supplement_data.dart';

class SupplementAdvisorScreen extends StatefulWidget {
  const SupplementAdvisorScreen({super.key});

  @override
  State<SupplementAdvisorScreen> createState() => _SupplementAdvisorScreenState();
}

class _SupplementAdvisorScreenState extends State<SupplementAdvisorScreen> {
  final List<BodyPart> _allParts = SupplementData.getAllBodyParts();
  List<BodyPart> _filteredParts = [];
  final TextEditingController _searchController = TextEditingController();
  BodyPart? _selectedPart;
  int _selectedDeficiencyIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredParts = _allParts;
  }

  void _filterParts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredParts = _allParts;
      } else {
        _filteredParts = _allParts.where((part) {
          final matchesName = part.name.toLowerCase().contains(query.toLowerCase());
          final matchesSymptom = part.symptoms.any((s) => s.name.toLowerCase().contains(query.toLowerCase()));
          final matchesDeficiency = part.deficiencies.any((d) => d.nutrient.toLowerCase().contains(query.toLowerCase()));
          return matchesName || matchesSymptom || matchesDeficiency;
        }).toList();
      }
    });
  }

  void _showBodyPartDetail(BodyPart part) {
    setState(() {
      _selectedPart = part;
      _selectedDeficiencyIndex = 0;
    });
  }

  void _goBack() {
    setState(() => _selectedPart = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _selectedPart == null ? 'Supplement Advisor' : _selectedPart!.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: _selectedPart != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: _goBack,
            )
          : null,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: _selectedPart == null ? _buildBodyPartsGrid() : _buildDetailView(),
    );
  }

  // ==================== BODY PARTS GRID ====================
  Widget _buildBodyPartsGrid() {
    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search body part, symptom, or vitamin...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          _filterParts('');
                        },
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: _filterParts,
              ),
            ),
          ),

          // Info banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF667EEA).withValues(alpha: 0.08), const Color(0xFF764BA2).withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF667EEA), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Select a body part to identify potential vitamin/mineral deficiencies and find the best recommended supplements.',
                      style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid
          Expanded(
            child: _filteredParts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, color: Colors.grey, size: 48),
                      SizedBox(height: 12),
                      Text('No results found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filteredParts.length,
                  itemBuilder: (context, index) {
                    final part = _filteredParts[index];
                    return _buildBodyPartCard(part);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPartCard(BodyPart part) {
    return GestureDetector(
      onTap: () => _showBodyPartDetail(part),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(part.theme.primary).withValues(alpha: 0.1), Color(part.theme.secondary).withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(part.theme.primary).withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(part.icon, style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              part.name,
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${part.symptoms.length} symptoms',
              style: TextStyle(color: Colors.black54, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              '${part.deficiencies.length} deficiencies',
              style: TextStyle(color: Color(part.theme.primary).withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DETAIL VIEW ====================
  Widget _buildDetailView() {
    final part = _selectedPart!;
    final deficiency = part.deficiencies[_selectedDeficiencyIndex];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(part.theme.primary).withValues(alpha: 0.1), Color(part.theme.secondary).withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(part.theme.primary).withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(part.icon, style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 12),
                  Text(part.name, style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(part.description, style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5), textAlign: TextAlign.center),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Symptoms Section
            Text('Common Symptoms', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...part.symptoms.map((symptom) => _buildSymptomCard(symptom)),

            const SizedBox(height: 24),

            // Deficiency Selector
            if (part.deficiencies.length > 1) ...[
              Text('Select Deficiency', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: part.deficiencies.length,
                  itemBuilder: (context, index) {
                    final def = part.deficiencies[index];
                    final isSelected = index == _selectedDeficiencyIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDeficiencyIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(part.theme.primary).withValues(alpha: 0.15) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Color(part.theme.primary) : Colors.grey.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          def.nutrient,
                          style: TextStyle(
                            color: isSelected ? Color(part.theme.primary) : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Deficiency Detail Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(part.theme.primary).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(part.theme.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          deficiency.nutrientType,
                          style: TextStyle(color: Color(part.theme.primary), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        deficiency.nutrient,
                        style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow('⚠️ Causes', deficiency.causes, Colors.orange),
                  const SizedBox(height: 12),
                  _buildInfoRow('🔬 Effects on Body', deficiency.effectsOnBody, Colors.redAccent),
                  const SizedBox(height: 12),
                  _buildInfoRow('📊 Daily Requirement', deficiency.dailyRequirement, Colors.blue),
                  const SizedBox(height: 12),
                  _buildInfoRow('💡 Pro Tip', deficiency.proTip, Colors.green),
                  const SizedBox(height: 16),

                  // Natural Sources
                  Text('Natural Sources:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: deficiency.naturalSources.map((source) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(part.theme.secondary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(source, style: TextStyle(color: Color(part.theme.secondary), fontSize: 12, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommended Supplements
            Text('Recommended Supplements', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...deficiency.recommendedSupplements.map((supp) => _buildSupplementCard(supp, part.theme)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCard(Symptom symptom) {
    Color severityColor;
    switch (symptom.severity) {
      case 'mild': severityColor = Colors.amber; break;
      case 'moderate': severityColor = Colors.orange; break;
      case 'severe': severityColor = Colors.red; break;
      default: severityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symptom.name, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(symptom.description, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              symptom.severity.toUpperCase(),
              style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildSupplementCard(Supplement supp, ColorTheme theme) {
    final isMagnesium = supp.name.toLowerCase().contains('magnesium');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(theme.primary).withValues(alpha: isMagnesium ? 0.1 : 0.05),
            isMagnesium ? Color(theme.secondary).withValues(alpha: 0.05) : Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(theme.primary).withValues(alpha: isMagnesium ? 0.3 : 0.15),
          width: isMagnesium ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isMagnesium ? 0.06 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMagnesium) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/suppliments/mag.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 70,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  supp.name,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isMagnesium ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Rs. ${supp.priceRange.toInt()}',
                  style: TextStyle(color: Colors.green[700], fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSuppDetailRow(Icons.medication, 'Dosage', supp.dosage, Colors.blue),
          const SizedBox(height: 10),
          _buildSuppDetailRow(Icons.access_time, 'Timing', supp.timing, Colors.orange),
          const SizedBox(height: 10),
          _buildSuppDetailRow(Icons.check_circle, 'Benefits', supp.benefits, Colors.green),
          const SizedBox(height: 10),
          _buildSuppDetailRow(Icons.warning_amber, 'Side Effects', supp.sideEffects, Colors.redAccent),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.home, color: Colors.orange[800], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Natural Alternative: ${supp.naturalAlternative}',
                    style: TextStyle(color: Colors.orange[900], fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.black87, fontSize: 12)),
        ),
      ],
    );
  }
}
