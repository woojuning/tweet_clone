enum NotificationType {
  like('like'),
  reply('reply'),
  follow('follow'),
  retweet('retweet');

  final String type;
  const NotificationType(this.type);
}

extension ConvertNotification on String {
  NotificationType toNotificationEnum() {
    switch (this) {
      case 'like':
        return NotificationType.like;
      case 'reply':
        return NotificationType.reply;
      case 'follow':
        return NotificationType.follow;
      case 'retweet':
        return NotificationType.retweet;
      default:
        return NotificationType.like;
    }
  }
}
