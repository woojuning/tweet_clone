// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  MyScreen({
    super.key,
  });
  final descriptionController = TextEditingController();
  final idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late bool isValidation;

  void _tryValidation() {
    isValidation = _formKey.currentState!.validate();
  }

  //const는 compile 동안에 이미 값이 지정이 되는데 final이 붙으면 runtime때 값이 할당이 되므로 const를 붙인 생성자를 만들 수 없는거지.
  void add_todo(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    TextFormField(
                      key: ValueKey(1),
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'description cant be empty';
                        }
                        return null;
                      },
                      controller: descriptionController,
                      decoration: InputDecoration(
                          hintText: 'description!',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          )),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _tryValidation();
                        if (!isValidation) {
                          return;
                        }
                        final todo = Todo(
                          id: Uuid().v1(),
                          completed: false, //처음에 등록할 때는 당연히 안했겟지
                          descprition: descriptionController.text,
                        );
                        print(todo.id);
                        ref.read(todosProvider.notifier).addTodo(todo);
                        Navigator.pop(context);
                      },
                      child: Text('add'),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Todo> todos = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('StateNotifierProvider test'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final todo in todos)
                  Dismissible(
                    key: ValueKey(todo.id),
                    onDismissed: (direction) {
                      ref.read(todosProvider.notifier).remove(todo.id);
                      print('clean!');
                    },
                    child: CheckboxListTile(
                      value: todo.completed,
                      onChanged: (value) {
                        ref.read(todosProvider.notifier).toggle(todo.id);
                      },
                      title: Text(todo.descprition),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              add_todo(context, ref);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

@immutable
class Todo {
  final String id;
  final String descprition;
  final bool completed;
  Todo({
    required this.id,
    required this.descprition,
    required this.completed,
  });

  Todo copyWith({
    String? id,
    String? descprition,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      descprition: descprition ?? this.descprition,
      completed: completed ?? this.completed,
    );
  }
}

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]); // 초기값 설정?

  void addTodo(Todo todo) {
    state = [...state, todo];
  }

  void toggle(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id == todoId)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }

  void remove(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id != todoId) todo,
    ];
  }
}

final todosProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});
//
//List<Todo>의 State를 전달해주는게 StateNotiferProvider인거지 
//