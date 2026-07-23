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

  @override
  void initState() {
    super.initState();
    _messages.add(CoachChatMessage(
      sender: 'coach',
      text: 'Hallo! Ich bin dein lokaler NutriLocal AI Coach. Wie kann ich dir heute bei deinem Ziel helfen?',
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach 🤖'),
      ),
      body: Column(
        children: [
          // Prompt Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildPromptChip('🔮 30-Tage Prognose'),
                _buildPromptChip('💪 Proteinziel Check'),
                _buildPromptChip('💡 Tipps zum Abnehmen'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Message List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.lightAccent : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: isUser ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : null,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Frage an deinen Coach...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.lightAccent),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final repo = ref.read(localRepositoryProvider);
    setState(() {
      _messages.add(CoachChatMessage(sender: 'user', text: text, timestamp: DateTime.now()));
    });
    _textController.clear();

    final reply = CoachService.generateCoachReply(
      userQuery: text,
      profile: repo.userProfile,
      recentMeals: [],
      weights: repo.weightEntries,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _messages.add(CoachChatMessage(sender: 'coach', text: reply, timestamp: DateTime.now()));
      });
    });
  }
}
