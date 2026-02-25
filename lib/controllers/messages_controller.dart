import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

/// Contrôleur pour l'envoi et l'écoute des messages (candidature acceptée).
class MessagesController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  Stream<List<ChatMessage>> messagesStream(String candidatureId) {
    return _firestore.messagesStream(candidatureId);
  }

  Future<void> sendMessage({
    required String candidatureId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final message = ChatMessage(
      id: '',
      candidatureId: candidatureId,
      senderId: senderId,
      senderName: senderName,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    await _firestore.sendMessage(message);
  }
}
