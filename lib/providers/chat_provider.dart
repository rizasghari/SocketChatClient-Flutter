import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  late int conversationId;
  late IOWebSocketChannel socketChannel;
  final List<Message> _messages = [];

  void initialize(int conversationId, IOWebSocketChannel socketChannel) {
    this.conversationId = conversationId;
    this.socketChannel = socketChannel;
    socketChannel.stream.listen((message) {
      final decodedMessage = Message.fromJson(jsonDecode(message)['payload']);
      if (decodedMessage.conversationId == conversationId) {
        _messages.add(decodedMessage);
        notifyListeners();
      }
    });
  }

  List<Message> get messages => _messages;

  void sendMessage(String content) {
    final message = {
      "event": "send_message",
      "conversation_id": conversationId,
      "payload": {
        "content": content,
      }
    };
    socketChannel.sink.add(jsonEncode(message));
  }

  Future<void> fetchConversationMessages(String jwtToken, int conversationId) async {
    await Future.delayed(const Duration(seconds: 1));
    final messages = await ApiService.fetchConversationMessages(jwtToken, conversationId);
    if (messages != null) {
      _messages.addAll(messages);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    socketChannel.sink.close(status.goingAway);
    super.dispose();
  }
}
