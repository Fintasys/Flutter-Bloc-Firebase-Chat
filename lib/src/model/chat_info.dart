import 'package:flutter_demo_chat/src/model/user.dart';

class ChatInfo {
  const ChatInfo(this.fromUser, this.toUser);
  final User fromUser;
  final User toUser;

  String getGroupChatId() {
    if (fromUser.id.hashCode <= toUser.id.hashCode) {
      return '${fromUser.id}-${toUser.id}';
    }
    return '${toUser.id}-${fromUser.id}';
  }
}
