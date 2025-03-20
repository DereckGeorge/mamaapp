import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mamaapp/services/speech_recognition_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamaapp/models/query_log_model.dart';
import 'dart:math';

class AISymptomsScreen extends StatefulWidget {
  const AISymptomsScreen({super.key});

  @override
  State<AISymptomsScreen> createState() => _AISymptomsScreenState();
}

class _AISymptomsScreenState extends State<AISymptomsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  final ApiService _apiService = ApiService();
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  List<Map<String, String>> _messages = [];
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phone_number');
      print('Debug: Loaded phone number: $phoneNumber');

      setState(() {
        _phoneNumber = phoneNumber;
      });

      if (_phoneNumber != null) {
        print('Debug: Phone number found, loading conversation history');
        await _loadConversationHistory();
      } else {
        print('Debug: No phone number found, showing welcome message');
        _addWelcomeMessage();
      }
    } catch (e) {
      print('Error loading phone number: $e');
      _addWelcomeMessage();
    }
  }

  Future<void> _loadConversationHistory() async {
    if (_phoneNumber == null) {
      print('Debug: Cannot load history - phone number is null');
      return;
    }

    print('Debug: Loading conversation history for phone: $_phoneNumber');
    setState(() => _isLoadingHistory = true);

    try {
      final history = await _apiService.getConversationHistory(_phoneNumber!);
      print('Debug: Received ${history.length} conversation items');

      setState(() {
        _messages = [];
        for (var log in history) {
          print('Debug: Processing log:');
          print('  Query: ${log.query}');
          print('  Response: ${log.response}');
          print('  Timestamp: ${log.timestamp}');
          print('  Audio URL: ${log.audioUrl}');
          print('---');

          if (log.query == null || log.response == null) {
            print('Debug: Warning - Skipping invalid log entry');
            continue;
          }

          _messages.add({
            "role": "user",
            "content": log.query!,
            "timestamp": log.timestamp.toIso8601String(),
          });
          _messages.add({
            "role": "assistant",
            "content": log.response!,
            "timestamp": log.timestamp.toIso8601String(),
          });
        }
        _isLoadingHistory = false;
      });

      print('Debug: Total messages loaded: ${_messages.length}');
      _scrollToBottom();
    } catch (e) {
      print('Error loading conversation history: $e');
      setState(() {
        _isLoadingHistory = false;
        _messages = [];
        _addWelcomeMessage();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load conversation history: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      var available = await _speechService.initialize();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() => _isListening = true);

      await _speechService.startListening((text) {
        setState(() {
          _messageController.text = text;
          _isListening = false;
        });

        // Auto send message when speech is done
        if (_messageController.text.isNotEmpty) {
          _sendMessage();
        }
      });
    } catch (e) {
      print('Error listening: $e');
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to recognize speech. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _addWelcomeMessage() {
    _messages.add({
      "role": "assistant",
      "content":
          "Hello! I'm your AI pregnancy assistant. How can I help you today? You can ask me about any symptoms or concerns you're experiencing. You can type or tap the microphone to speak."
    });
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      print('Debug: Empty message, not sending');
      return;
    }

    final message = _messageController.text;
    print(
        'Debug: Sending message: ${message.substring(0, min(50, message.length))}...');
    _messageController.clear();

    setState(() {
      _messages.add({
        "role": "user",
        "content": message,
        "timestamp": DateTime.now().toIso8601String(),
      });
      _isLoading = true;
    });

    try {
      print('Debug: Calling AI service...');
      final response = await _apiService.queryAI(message);
      print('Debug: Raw AI response: $response');

      if (response == null) {
        throw Exception('Received null response from AI service');
      }

      final textResponse = response['text_response'];
      if (textResponse == null) {
        print('Debug: Warning - text_response is null in response');
        print('Debug: Full response: $response');
        throw Exception('Invalid response format: missing text_response');
      }

      setState(() {
        _messages.add({
          "role": "assistant",
          "content": textResponse,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _messages.add({
          "role": "assistant",
          "content":
              "Sorry, I couldn't process your request. Please try again.",
          "timestamp": DateTime.now().toIso8601String(),
        });
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCB4172),
        elevation: 0,
        title: const Text(
          'AI Pregnancy Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_isLoadingHistory)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFCB4172)),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  final isUser = message["role"] == "user";
                  return _buildMessageBubble(message["content"]!, isUser);
                },
              ),
            ),
          _buildInputArea(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    if (message.isEmpty) {
      print('Debug: Warning - Empty message in bubble');
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFCB4172),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: isUser ? null : () => _speak(message),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xFFCB4172)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      message,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                        height: 1.4,
                        fontFamily: '.SF Pro Text',
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(message),
                      style: TextStyle(
                        color: isUser ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFCB4172),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypingDot(0),
                  const SizedBox(width: 4),
                  _buildTypingDot(1),
                  const SizedBox(width: 4),
                  _buildTypingDot(2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFCB4172).withOpacity(0.5 + (value * 0.5)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(String message) {
    try {
      final messageData = _messages.firstWhere(
        (m) => m['content'] == message,
        orElse: () => {'timestamp': DateTime.now().toIso8601String()},
      );

      final timestamp = DateTime.parse(messageData['timestamp']!);
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Debug: Error formatting timestamp: $e');
      return '--:--';
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Microphone button
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? const Color(0xFFCB4172) : Colors.grey,
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          // Text input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Listening...'
                    : 'Type your symptoms or concerns...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFCB4172)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
