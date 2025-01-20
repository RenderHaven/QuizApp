import 'package:flutter/material.dart';
import 'package:myquizapp/QuizePage.dart';
class ResultPage extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;

  const ResultPage({
    Key? key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quiz Completed!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Questions: $totalQuestions',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Correct Answers: $correctAnswers',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              'Correct Answers: $wrongAnswers',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            Text(
              'Not Attempt: ${totalQuestions-(correctAnswers+wrongAnswers)}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>QuizPage())); 
              },
              child: const Text('Retry Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
