import 'user.dart';

class Conversation {
  final int id;
  final String type;
  final List<User> members;

  Conversation({
    required this.id,
    required this.type,
    required this.members,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    var membersJson = json['members'] as List;
    List<User> membersList = membersJson.map((i) => User.fromJson(i)).toList();

    return Conversation(
      id: json['id'],
      type: json['type'],
      members: membersList,
    );
  }
}
