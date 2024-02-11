import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textController = TextEditingController();
  List<String> _records = [];
  bool _isTextFieldEmpty = false;
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initDatabase();
    final updatedRecords = await _getRecords();
    setState(() {
      _records = updatedRecords;
    });
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'records_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY, text TEXT)',
        );
      },
      version: 1,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _database.close();
    super.dispose();
  }

  void _handleButtonPress() async {
    String enteredText = _textController.text.trim();
    if (enteredText.isNotEmpty) {
      await _insertRecord(enteredText);
      final updatedRecords = await _getRecords();
      setState(() {
        _records = updatedRecords;
        _textController.clear();
        _isTextFieldEmpty = false;
      });
    } else {
      setState(() {
        _isTextFieldEmpty = true;
      });
    }
  }

  Future<void> _insertRecord(String text) async {
    await _database.insert(
      'records',
      {'text': text},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> _getRecords() async {
    final List<Map<String, dynamic>> maps = await _database.query('records');

    return List.generate(maps.length, (i) {
      return maps[i]['text'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Wprowadź tekst',
                errorText: _isTextFieldEmpty ? 'Proszę wprowadzić tekst' : null,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleButtonPress,
              child: Text('Utwórz'),
            ),
            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: Text(
                _records.length > 0 ? 'Twoje wyniki' : 'Brak wyników',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_records[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
