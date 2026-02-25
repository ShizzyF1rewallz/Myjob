/// Modèle d'un message dans une conversation liée à une candidature acceptée.
class ChatMessage {
  final String id;
  final String candidatureId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.candidatureId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'candidatureId': candidatureId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      candidatureId: map['candidatureId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
