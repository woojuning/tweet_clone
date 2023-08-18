// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:twitter_clone/core/enums/noticiation_type_enum.dart';

class NotificationModel {
  final String text;
  final String postId;
  final String id; //이거는 생성 uid
  final String uid;
  final NotificationType notificationType;
  NotificationModel({
    required this.text,
    required this.postId,
    required this.id,
    required this.uid,
    required this.notificationType,
  });

  NotificationModel copyWith({
    String? text,
    String? postId,
    String? id,
    String? uid,
    NotificationType? notificationType,
  }) {
    return NotificationModel(
      text: text ?? this.text,
      postId: postId ?? this.postId,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      notificationType: notificationType ?? this.notificationType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'postId': postId,
      'id': id,
      'uid': uid,
      'notificationType': notificationType.type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      text: map['text'] as String,
      postId: map['postId'] as String,
      id: map['\$id'] as String,
      uid: map['uid'] as String,
      notificationType:
          (map['notificationType'] as String).toNotificationEnum(),
    );
  }
  @override
  String toString() {
    return 'NotificationModel(text: $text, postId: $postId, id: $id, uid: $uid, notificationType: $notificationType)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return other.text == text &&
        other.postId == postId &&
        other.id == id &&
        other.uid == uid &&
        other.notificationType == notificationType;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        postId.hashCode ^
        id.hashCode ^
        uid.hashCode ^
        notificationType.hashCode;
  }
}
