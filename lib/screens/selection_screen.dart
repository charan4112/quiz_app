// lib/screens/selection_screen.dart

import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String selectedCategory = "9"; // Default: General Knowledge
  String selectedDifficulty = "easy"; // Default difficulty

  final List<Map<String, String>> categories = [
    {"id": "9", "name": "General Knowledge"},
    {"id": "10", "name": "Entertainment: Books"},
    {"id": "11", "name": "Entertainment: Film"},
    // Add more categories here if needed.
  ];

  final List<String> difficulties = ["easy", "medium", "hard"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Quiz Options")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Category"),
              value: selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat["id"],
                  child: Text(cat["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Difficulty"),
              value: selectedDifficulty,
              items: difficulties.map((difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(
                      difficulty[0].toUpperCase() + difficulty.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDifficulty = value;
                  });
                }
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to QuizScreen with selected options.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      category: selectedCategory,
                      difficulty: selectedDifficulty,
                    ),
                  ),
                );
              },
              child: Text("Start Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}
