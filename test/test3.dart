// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyScreen(),
    );
  }
}

class MyScreen extends ConsumerWidget {
  MyScreen({super.key});

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: '이름을 입력해라.'),
          ),
          Text('${ref.watch(Test4Provider).name}'),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              ref.read(Test4Provider).change(nameController.text);
            },
            child: Text('test'),
          ),
        ],
      )),
    );
  }
}

final testProvider = Provider((ref) {
  return Test(name: 'kimwoojun');
});

class Test {
  final String name;
  Test({
    required this.name,
  });
}

final test2Provider = StateProvider<String>((ref) {
  return '김우준';
});

final test3Provider = StateNotifierProvider<Test2, String>((ref) {
  final test4 = ref.watch(Test4Provider);
  final name = ref.watch(testProvider).name;
  return Test2(name);
});

class Test2 extends StateNotifier<String> {
  Test2(super.state); //초기값 설정

  void change(String name) {
    state = name;
  }
}

class Test4 {
  String name = '';

  void change(String str) {
    name = str;
    print(name);
  }
}

final Test4Provider = Provider<Test4>((ref) {
  return Test4();
});
