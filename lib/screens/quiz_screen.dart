// lib/screens/quiz_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String difficulty;

  const QuizScreen({Key? key, required this.category, required this.difficulty})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  
  Timer? _timer;
  int _timeRemaining = 10; // seconds per question

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions(
        category: widget.category,
        difficulty: widget.difficulty,
      );
      setState(() {
        _questions = questions;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      print(e);
      // Handle error appropriately
    }
  }

  Future<void> _saveQuizResult() async {
    final result = {
      'score': _score,
      'total': _questions.length,
      'category': widget.category,
      'difficulty': widget.difficulty,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('quiz_results').add(result);
      print("Quiz result saved successfully.");
    } catch (e) {
      print("Error saving quiz result: $e");
    }
  }

  void _startTimer() {
    _timeRemaining = 10;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer?.cancel();
        if (!_answered) {
          setState(() {
            _answered = true;
            _feedbackText =
                "Time's up! The correct answer is ${_questions[_currentQuestionIndex].correctAnswer}.";
          });
        }
      }
    });
  }

  void _submitAnswer(String selectedAnswer) {
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    setState(() {
      _answered = false;
      _selectedAnswer = "";
      _feedbackText = "";
      _currentQuestionIndex++;
    });
    if (_currentQuestionIndex < _questions.length) {
      _startTimer();
    } else {
      _saveQuizResult();
    }
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: _answered ? null : () => _submitAnswer(option),
      child: Text(option),
      style: ElevatedButton.styleFrom(primary: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        body: Center(
          child: Text('Quiz Finished! Your Score: $_score/${_questions.length}'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("Time: $_timeRemaining")),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ...question.options.map((option) => _buildOptionButton(option)),
            SizedBox(height: 20),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedAnswer == question.correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text('Next Question'),
              ),
          ],
        ),
      ),
    );
  }
}
