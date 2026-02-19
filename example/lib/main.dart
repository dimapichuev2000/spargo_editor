import 'package:flutter/material.dart';
import 'package:spargo_editor/spargo_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill Editor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _content = '';
  bool _readOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Quill Editor Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Редактор:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _readOnly = !_readOnly;
                    });
                  },
                  icon: Icon(_readOnly ? Icons.lock : Icons.lock_open),
                  label: Text(_readOnly ? 'Только чтение' : 'Редактирование'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _readOnly ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            QuillEditorWidget(
              initialContent: _content.isNotEmpty ? _content : '<p>Начните вводить текст...</p>',
              height: 400,
              placeholder: 'Введите текст...',
              readOnly: _readOnly,
              onChanged: (html) {
                setState(() {
                  _content = html;
                  // print(_content);
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Предпросмотр HTML:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _content.isEmpty
                    ? const Center(
                        child: Text(
                          'Пусто',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: QuillHtmlWidget(
                          content: _content,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
