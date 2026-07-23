import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../ai/coach_service.dart';
import '../../core/theme/app_theme.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final List<CoachChatMessage> _messages = [];
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(CoachChatMessage(
      sender: 'coach',
      text: 'Hallo! Ich bin dein lokaler NutriLocal AI Coach. Wie kann ich dir heute bei deiner Ernährung oder deinen Zielen helfen?',
      timestamp: DateTime.now(),
    ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach 🤖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Chat zurücksetzen',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(CoachChatMessage(
                  sender: 'coach',
                  text: 'Neuer Chat gestartet! Wobei kann ich dir helfen?',
                  timestamp: DateTime.now(),
                ));
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Goal Prompt Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildPromptChip('🔮 30-Tage Prognose'),
                  _buildPromptChip('💪 Proteinziel Check'),
                  _buildPromptChip('💡 Tipps zum Abnehmen'),
                  _buildPromptChip('🏋️ Muskelaufbau Plan'),
                ],
              ),
            ),
            const Divider(height: 1),

            // Messages View
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.sender == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.lightAccent : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isUser ? null : Border.all(color: Colors.grey.withOpacity(0.15)),
                      ),
                      child: SelectableText(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : null,
                          height: 1.45,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isTyping)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('AI Coach denkt nach...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Frage an deinen AI Coach stellen...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.lightAccent, size: 26),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        backgroundColor: AppColors.lightAccent.withOpacity(0.08),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final repo = ref.read(localRepositoryProvider);
    final userMsg = text.trim();

    setState(() {
      _messages.add(CoachChatMessage(sender: 'user', text: userMsg, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    final reply = CoachService.generateCoachReply(
      userQuery: userMsg,
      profile: repo.userProfile,
      recentMeals: repo.getMealsForDate(DateTime.now().toString().split(' ')[0]),
      weights: repo.weightEntries,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(CoachChatMessage(sender: 'coach', text: reply, timestamp: DateTime.now()));
        });
        _scrollToBottom();
      }
    });
  }
}
