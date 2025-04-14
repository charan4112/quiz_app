class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Combine the incorrect answers with the correct answer and shuffle the list.
    List<String> options = List<String>.from(json['incorrect_answers']);
    options.add(json['correct_answer']);
    options.shuffle();

    return Question(
      question: json['question'] as String,
      options: options,
      correctAnswer: json['correct_answer'] as String,
    );
  }
}
