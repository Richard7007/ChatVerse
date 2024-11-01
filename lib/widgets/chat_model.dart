class ChatMessages {
  String senderUid;
  String receiverUid;
  String timestamp;
  String content;
  int type;
  String lastMessage;

  ChatMessages(
      {required this.senderUid,
      required this.lastMessage,
      required this.receiverUid,
      required this.timestamp,
      required this.content,
      required this.type});

  factory ChatMessages.fromJson(Map<String, dynamic> json) => ChatMessages(
    senderUid: json["senderUid"],
    receiverUid: json["receiverUid"],
        timestamp: json["timestamp"],
        content: json["content"],
        type: json["type"],
        lastMessage: json["lastMessage"],
      );

  Map<String, dynamic> toJson() => {
        "senderUid": senderUid,
        "receiverUid": receiverUid,
        "timestamp": timestamp,
        "content": content,
        "type": type,
        "lastMessage": lastMessage,
      };
}
