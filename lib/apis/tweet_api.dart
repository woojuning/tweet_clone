import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constant/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/tweet_model.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealTimeProvider),
  );
});

abstract class ITweetAPI {
  FutureEither<Document> shareTweet(Tweet tweet);
  Future<List<Document>> getTweets();
  Stream<RealtimeMessage> getLatestTweet();
  FutureEither<Document> likeTweet(Tweet tweet);
  FutureEither<Document> updateReshareCount(Tweet tweet);
  Future<List<Document>> getRepliesToTweet(Tweet tweet);
  Future<Document> getTweetById(String id);
  Future<List<Document>> getUserTweets(String uid);
}

class TweetAPI implements ITweetAPI {
  final Realtime _realtime;
  final Databases _db;

  TweetAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> shareTweet(Tweet tweet) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollection,
        documentId: ID.unique(), //이 부분 이해가 잘 안가는 부분인듯
        data: tweet.toMap(), //이 부분때문에 TweetModel을 만드는듯.
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Execption Error occured!', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getTweets() async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollection,
        queries: [
          Query.orderDesc('tweetedAt'),
        ]);
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestTweet() {
    return _realtime.subscribe([
      'databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.tweetCollection}.documents'
    ]).stream;
  }

  @override
  FutureEither<Document> likeTweet(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
          databaseId: AppWriteConstants.databaseId,
          collectionId: AppWriteConstants.tweetCollection,
          documentId: tweet.id,
          data: {
            'likes': tweet.likes,
          });
      print(tweet.id);
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'exception error Occured', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<Document> updateReshareCount(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
          databaseId: AppWriteConstants.databaseId,
          collectionId: AppWriteConstants.tweetCollection,
          documentId: tweet.id,
          data: {
            'reshareCount': tweet.reshareCount,
          });
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Exception error occurs', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getRepliesToTweet(Tweet tweet) async {
    final document = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollection,
        queries: [
          Query.equal('repliedTo', tweet.id),
          // Query.orderDesc('tweetedAt'),
        ]);
    return document.documents;
    //이미 여기서 tweet.id와 repliedTo가 같은 document만 list형태로 받아와 지는듯?
  }

  @override
  Future<Document> getTweetById(String id) {
    return _db.getDocument(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollection,
        documentId: id);
  }

  @override
  Future<List<Document>> getUserTweets(String uid) async {
    final documents = await _db.listDocuments(
        databaseId: AppWriteConstants.databaseId,
        collectionId: AppWriteConstants.tweetCollection,
        queries: [
          Query.equal('uid', uid),
        ]);
    return documents.documents;
  }

  Future<List<Document>> getHasHashTagsTweet(String hastags) async {
    final documents = await _db.listDocuments(
      databaseId: AppWriteConstants.databaseId,
      collectionId: AppWriteConstants.tweetCollection,
      queries: [
        Query.isNotNull('hashtags'),
        Query.search('hashtags', hastags),
      ],
    );

    return documents.documents;
  }
}
