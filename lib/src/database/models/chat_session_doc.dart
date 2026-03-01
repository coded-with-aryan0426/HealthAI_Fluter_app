import 'package:isar/isar.dart';

part 'chat_session_doc.g.dart';

@collection
class ChatSessionDoc {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  late DateTime createdAt;

  late DateTime updatedAt;

  bool isPinned = false;

  // Storing messages as embedded objects since they belong strictly to a session
  List<ChatMessageDoc> messages = [];
}

@embedded
class ChatMessageDoc {
  late String text;
  
  late bool isUser;
  
  late DateTime timestamp;

  // Optional: Used to know if this message triggers a UI widget
  // 'workout' = WorkoutPlanCard, 'meal' = MealPlanCard, null/'' = text bubble
  bool isWidget = false;
  String widgetType = ''; // 'workout' | 'meal'
}
