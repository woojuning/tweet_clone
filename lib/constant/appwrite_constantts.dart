class AppWriteConstants {
  static const String databaseId = '64d3635cab6b3f30858b';
  static const String projectId = '64d36306b329341ffcb9';
  static const String endPoint = 'http://218.146.47.2:80/v1';

  static const String userCollection = '64d36368672d237d1374';
  static const String tweetCollection = '64d4a8990f9da50887c5';

  static const String imagesBucketId = '64d4baabb2a79b208486';

  static String imageUrl(String imagedId) =>
      '$endPoint/storage/buckets/$imagesBucketId/files/$imagedId/view?project=$projectId&mode=admin';
}
