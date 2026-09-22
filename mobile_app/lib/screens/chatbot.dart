import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const PerciApp());
}

class PerciApp extends StatelessWidget {
  const PerciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PERCI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          primary: const Color(0xFF00897B),
          surface: const Color(0xFFF4F7F6),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _isLoading = false;

  static const String _apiKey = 'AQ.Ab8RN6JG1IidybpaTrBJmbL697XRakBm_LOYmroc83VPUS81aA';

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system('''
        You are PERCI (Personal Parent Coach Intelligent), an empathetic, supportive, and non-judgmental AI coach designed to assist parents of autistic children.

Guidelines:
1. Tone: Warm, patient, validating, and supportive.
2. Strategy: Offer practical strategies for sensory overload, routine building, visual schedules, and emotional regulation.
3. Disclaimer: You are an AI coach, NOT a medical doctor or licensed therapist. Always clarify that your advice does not replace medical or professional diagnostic care.
4. Focus: Emphasize strengths, sensory needs, and gentle parenting approaches.
      '''),
    );
    _chat = _model.startChat();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _controller.clear();
    }

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'perci', 'text': response.text ?? 'I am here to support you.'});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'perci',
            'text': 'I encountered an issue connecting right now. Please try again in a moment.'
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.teal.shade50,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF00897B), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERCI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  'Empathetic Parent Support',
                  style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Disclaimer Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PERCI is an AI coach, not a medical professional. For diagnosis or medical care, please consult a specialist.',
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeView()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['sender'] == 'user';
                      return _buildChatBubble(msg['text']!, isUser);
                    },
                  ),
          ),

          // Animated Robot Thinking Indicator
          if (_isLoading) const AnimatedRobotThinking(),

          // Quick Topic Chips (Visible when starting or idle)
          if (_messages.isEmpty) _buildQuickTopics(),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFF00897B), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to PERCI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your non-judgmental space for practical strategies, sensory tips, and daily support.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTopics() {
    final topics = [
      '⚡ Handling sensory overload',
      '📅 Visual schedule ideas',
      '🌙 Bedtime routine tips',
      '💙 Emotional co-regulation'
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(topics[index]),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.teal.shade200),
            labelStyle: TextStyle(color: Colors.teal.shade800, fontSize: 13),
            onPressed: () => _sendMessage(topics[index]),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.smart_toy_rounded, size: 18, color: Color(0xFF00897B)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF00897B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Share what’s on your mind...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF4F7F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: () => _sendMessage(),
              elevation: 0,
              backgroundColor: const Color(0xFF00897B),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartoon Animated Robot for Thinking state
class AnimatedRobotThinking extends StatefulWidget {
  const AnimatedRobotThinking({super.key});

  @override
  State<AnimatedRobotThinking> createState() => _AnimatedRobotThinkingState();
}

class _AnimatedRobotThinkingState extends State<AnimatedRobotThinking>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 24, color: Color(0xFF00897B)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PERCI is thinking',
                  style: TextStyle(fontSize: 13, color: Colors.teal.shade900, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.teal.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}