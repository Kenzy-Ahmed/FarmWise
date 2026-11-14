import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final AppState state;
  const ChatScreen({super.key, required this.state});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! Ask me about water stress, soil health, pests or which strategy fits you.",
      isUser: false,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _getReply(String q) {
    q = q.toLowerCase();
    var strategies = widget.state.strategies;
    var scored = strategies.map((s) => [widget.state.calculateScore(s), s.name]).toList();
    scored.sort((a, b) => (b[0] as int).compareTo(a[0] as int));

    if (RegExp(r'water|stress|dry|drought').hasMatch(q)) {
      return "In the demo data, soil moisture is low (0.18) and rain over 30 days is only about 4 mm, while evapotranspiration is high. Together that points to water stress. Check with a soil moisture probe in your field.";
    }
    if (RegExp(r'soil|organic|nitrogen').hasMatch(q)) {
      return "Legumes such as faba bean or clover fix nitrogen, and cover crops add organic matter and protect against erosion. Deep-rooted crops also improve soil structure.";
    }
    if (RegExp(r'pest|disease').hasMatch(q)) {
      return "Changing crop families each season interrupts pests and diseases that depend on one host. It lowers pressure but rarely removes it, so keep scouting.";
    }
    if (RegExp(r'strateg|rotation|best|which').hasMatch(q)) {
      return 'With your priorities, "${scored[0][1]}" scores highest (${scored[0][0]}/100). That is a decision-support indicator, not a guarantee. See Compare for trade-offs.';
    }
    return "I can explain water stress, soil health, pests, or which rotation suits your priorities. Try one of those.";
  }

  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: _getReply(text), isUser: false));
    });
    _controller.clear();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FarmWise Advisor", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          Text("A simple rule-based helper using your demo field data. It is not a live AI model.", style: TextStyle(color: mutedColor)),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: msg.isUser 
                            ? (isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C)) 
                            : (isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser 
                              ? (isDark ? const Color(0xFF10221A) : Colors.white) 
                              : textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Why is my land water stressed?",
                    hintStyle: TextStyle(color: mutedColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C),
                  foregroundColor: isDark ? const Color(0xFF10221A) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _sendMessage,
                child: const Text("Ask"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}