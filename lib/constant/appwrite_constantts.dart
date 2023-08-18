class AppWriteConstants {
  static const String databaseId = '64dde946e295eabedcc3';

  static const String projectId = '64dde8fae28c9595e8f5';
  static const String endPoint = 'http://218.146.47.2:80/v1';

  static const String userCollection = '64dde95306d2744dff6d';

  static const String tweetCollection = '64dde94dbba0a7048213';

  static const String testCollection = '64db697e46d690da4105';

  static const String imagesBucketId = '64ddea8a04582d3b3ab0';

  static const String woojunCollectionId = '64dded6265206a9126a2';
  static const String notificationsCollectionId = '64df11b414714f08d861';

  static String imageUrl(String imagedId) =>
      '$endPoint/storage/buckets/$imagesBucketId/files/$imagedId/view?project=$projectId&mode=admin';
}
