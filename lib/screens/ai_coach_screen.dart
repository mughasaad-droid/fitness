import 'package:flutter/material.dart';
import '../models/workout_data.dart';
import '../services/ai_service.dart';
import '../services/pedometer_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final _aiService = AIService();
  final _pedometerService = PedometerService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  DailyStats _todayStats = DailyStats(date: DateTime.now().toIso8601String().split('T')[0]);
  List<DailyStats> _last7Days = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Welcome message
    _messages.add(ChatMessage(
      text: 'Hello! I am your AI Fitness Coach.\n\nHow can I help you today? Motivation, diet tips, workout plans, or step analysis? Just ask! 💪',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  Future<void> _loadData() async {
    final stats = await _pedometerService.getTodayStats();
    final List<DailyStats> weekData = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      weekData.add(DailyStats(date: dateStr));
    }
    setState(() {
      _todayStats = stats;
      _last7Days = weekData;
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        time: DateTime.now(),
      ));
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Simulate AI thinking
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _aiService.generateCoachResponse(text, _last7Days, _todayStats);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          time: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _changeMode(CoachMode mode) {
    setState(() => _aiService.mode = mode);
    String modeName = '';
    switch (mode) {
      case CoachMode.disciplined: modeName = 'Disciplined Trainer'; break;
      case CoachMode.gentle: modeName = 'Gentle Friend'; break;
      case CoachMode.roast: modeName = 'Roast Master'; break;
      case CoachMode.expert: modeName = 'Expert Coach'; break;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: 'Mode changed to: **$modeName** 🔄\nI will now respond in this style!',
        isUser: false,
        time: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Fitness Coach', style: TextStyle(color: Colors.black87, fontSize: 16)),
                Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          PopupMenuButton<CoachMode>(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onSelected: _changeMode,
            itemBuilder: (context) => [
              const PopupMenuItem(value: CoachMode.disciplined, child: Text('⚡ Disciplined')),
              const PopupMenuItem(value: CoachMode.gentle, child: Text('🤗 Gentle')),
              const PopupMenuItem(value: CoachMode.roast, child: Text('🔥 Roast')),
              const PopupMenuItem(value: CoachMode.expert, child: Text('🎓 Expert')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tune, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Mode: ${_aiService.mode.name.toUpperCase()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0),
                        _buildDot(1),
                        _buildDot(2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Quick suggestions
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSuggestionChip('Give me motivation'),
                _buildSuggestionChip('Steps are low today'),
                _buildSuggestionChip('Diet tips'),
                _buildSuggestionChip('I am in pain'),
                _buildSuggestionChip('Suggest a workout'),
              ],
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isUser
            ? const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])
            : null,
          color: isUser ? null : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          _textController.text = text;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ),
      ),
    );
  }
}
