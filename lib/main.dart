import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventPracticeApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[100],
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _displayText = '';
  Timer? _clearTimer;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
    _ageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    _nameController.removeListener(_onTextChanged);
    _ageController.removeListener(_onTextChanged);
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_displayText.isNotEmpty) {
      setState(() {
        _displayText = '';
      });
    }

    if (_nameController.text.isNotEmpty && _hasNumbers(_nameController.text)) {
      _showSnackBar('Name cannot contain numbers', isError: true);
    }
  }

  bool _hasNumbers(String text) {
    return text.contains(RegExp(r'[0-9]'));
  }

  void _validateName(String name) {
    if (_hasNumbers(name)) {
      throw const FormatException('Name cannot contain numbers.');
    }
  }

  void _updateText() {
    if (_formKey.currentState!.validate()) {
      try {
        _validateName(_nameController.text);
        final age = int.parse(_ageController.text);
        final name = _nameController.text;
        
        _nameController.removeListener(_onTextChanged);
        _ageController.removeListener(_onTextChanged);
        
        _nameController.clear();
        _ageController.clear();
        
        _nameController.addListener(_onTextChanged);
        _ageController.addListener(_onTextChanged);

        setState(() {
          _displayText = 'Given Name: $name\nGiven Age: $age';
        });

        _clearTimer?.cancel();
        _clearTimer = Timer(const Duration(seconds: 8), () {
          if (mounted) {
            setState(() {
              _displayText = '';
            });
          }
        });

        _showSnackBar('Data submitted successfully');
      } on FormatException {
        _showSnackBar('Please enter a valid number', isError: true);
      }
    } else {
      _showSnackBar('Please fill all fields', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventPracticeApp'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.person_add,
                        size: 60,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24.0),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (_hasNumbers(value)) {
                            return 'Name cannot contain numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: const Icon(Icons.cake),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28.0),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _updateText,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      if (_displayText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            _displayText,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
