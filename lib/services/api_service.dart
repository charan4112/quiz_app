// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions({
    required String category,
    required String difficulty,
  }) async {
    final url =
        "https://opentdb.com/api.php?amount=10&category=$category&difficulty=$difficulty&type=multiple";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Question> questions = (data['results'] as List)
          .map((questionData) => Question.fromJson(questionData))
          .toList();
      return questions;
    } else {
      throw Exception("Failed to load questions");
    }
  }
}
