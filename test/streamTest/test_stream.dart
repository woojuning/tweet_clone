// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(ProviderScope(
    child: MaterialApp(
      home: Mainview(),
    ),
  ));
}

class Mainview extends ConsumerStatefulWidget {
  const Mainview({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainviewState();
}

class _MainviewState extends ConsumerState<Mainview> {
  List<String> nameLists = [];
  String name = '';
  final nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stream test'),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 8,
            ),
            width: 200,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'name : ',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              print('hi');
              ref.read(testAPI1Provider).createModel(nameController.text);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: RealTimeWidget(),
    );
  }
}

class RealTimeWidget extends ConsumerWidget {
  const RealTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTestModelDataListProvider).when(
          data: (modelLists) {
            return ref.watch(getLatestTestData1Provider).when(
                data: (data) {
                  if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants1.testCollectionId}.documents.*.create')) {
                    final model = TestModel1.fromMap(data.payload);
                    if (!modelLists.contains(model)) {
                      modelLists.add(model);
                    }
                  } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants1.testCollectionId}.documents.*.update')) {
                    final newModel = TestModel1.fromMap(data.payload);
                    final oldModel = modelLists
                        .where((element) => element.uid == newModel.uid)
                        .first;
                    final modelIndex = modelLists.indexOf(oldModel);
                    modelLists.removeAt(modelIndex);
                    modelLists.insert(modelIndex, newModel);
                  }

                  return ListView.builder(
                    itemCount: modelLists.length,
                    itemBuilder: (context, index) {
                      final model = modelLists[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(
                                modelLists[index].name,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                              ),
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    onSubmitted: (value) {
                                                      ref
                                                          .read(
                                                              testAPI1Provider)
                                                          .updateData(
                                                              model.copyWith(
                                                                  name: value));
                                                    },
                                                    decoration: InputDecoration(
                                                        hintText: 'name : '),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.edit),
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                error: (error, stackTrace) => Center(
                      child: Text(
                        error.toString(),
                      ),
                    ),
                loading: () {
                  return ListView.builder(
                    itemCount: modelLists.length,
                    itemBuilder: (context, index) {
                      final model = modelLists[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(
                                modelLists[index].name,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                              ),
                                              child: Column(
                                                children: [
                                                  TextField(
                                                    onSubmitted: (value) {
                                                      ref
                                                          .read(
                                                              testAPI1Provider)
                                                          .updateData(model);
                                                      Navigator.pop(context);
                                                    },
                                                    decoration: InputDecoration(
                                                        hintText: 'name : '),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.edit),
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
          },
          error: (error, stackTrace) => Center(
            child: Text(
              error.toString(),
            ),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

class AppwriteConstants1 {
  static const String projectId = '64dde8fae28c9595e8f5';
  static const String databaseId = '64dde946e295eabedcc3';
  static const String testCollectionId = '64dded6265206a9126a2';
  static const String endPoint = 'http://218.146.47.2:80/v1';
}

final clientProvider = Provider((ref) {
  final client = Client();
  return client
      .setEndpoint(AppwriteConstants1.endPoint)
      .setProject(AppwriteConstants1.projectId)
      .setSelfSigned(status: true);
});

final realTimeProvider = Provider((ref) {
  return Realtime(ref.watch(clientProvider));
});

final databasesProvider = Provider((ref) {
  return Databases(ref.watch(clientProvider));
});

//TestAPI
class TestAPI {
  final Realtime realtime;
  final Databases db;
  TestAPI({
    required this.realtime,
    required this.db,
  });

  Stream<RealtimeMessage> getLatestTestData1() {
    return realtime.subscribe(
      [
        'databases.${AppwriteConstants1.databaseId}.collections.${AppwriteConstants1.testCollectionId}.documents',
      ],
    ).stream;
  }

  Future<List<Document>> getTestModelDataList() async {
    final documents = await db.listDocuments(
        databaseId: AppwriteConstants1.databaseId,
        collectionId: AppwriteConstants1.testCollectionId);
    return documents.documents;
  }

  void updateData(TestModel1 model) async {
    print(model.uid);
    await db.updateDocument(
      databaseId: AppwriteConstants1.databaseId,
      collectionId: AppwriteConstants1.testCollectionId,
      documentId: model.uid,
      data: {'name': model.name},
    );
  }

  void createModel(String name) async {
    final id = Uuid().v4();
    print(id);
    await db.createDocument(
      databaseId: AppwriteConstants1.databaseId,
      collectionId: AppwriteConstants1.testCollectionId,
      documentId: id,
      data: TestModel1(name: name, uid: id).toMap(),
    );
  }
}

final testAPI1Provider = Provider((ref) {
  return TestAPI(
    realtime: ref.watch(realTimeProvider),
    db: ref.watch(databasesProvider),
  );
});

final getLatestTestData1Provider = StreamProvider((ref) {
  final testAPI = ref.watch(testAPI1Provider);
  return testAPI.getLatestTestData1();
});

//TestController
class TestController1 extends StateNotifier<bool> {
  TestController1({required this.testAPI}) : super(false);
  final TestAPI testAPI;

  Future<List<TestModel1>> getTestModelDataList() async {
    final testModelDocuments = await testAPI.getTestModelDataList();
    return testModelDocuments.map((e) => TestModel1.fromMap(e.data)).toList();
  }
}

final testController1Provider =
    StateNotifierProvider<TestController1, bool>((ref) {
  return TestController1(testAPI: ref.watch(testAPI1Provider));
});

final getTestModelDataListProvider = FutureProvider((ref) {
  final testcontroller1 = ref.watch(testController1Provider.notifier);
  return testcontroller1.getTestModelDataList();
});

class TestModel1 {
  final String name;
  final String uid;
  TestModel1({required this.name, required this.uid});

  TestModel1 copyWith({
    String? name,
    String? uid,
  }) {
    return TestModel1(
      name: name ?? this.name,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
    };
  }

  factory TestModel1.fromMap(Map<String, dynamic> map) {
    return TestModel1(
      name: map['name'] as String,
      uid: map['uid'] as String,
    );
  }

  @override
  String toString() => 'TestModel(name: $name)';

  @override
  bool operator ==(covariant TestModel1 other) {
    if (identical(this, other)) return true;

    return other.name == name && other.uid == uid;
  }

  @override
  int get hashCode => name.hashCode ^ uid.hashCode;
}
