import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myquizapp/Result.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<String, dynamic>? quizData;
  bool isLoading = true;
  String? errorMessage;
  double rTime = 15*60;
  Timer? timer;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  ScrollController _scrollController = ScrollController();

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (rTime > 0) {
        setState(() {
          rTime--;
        });
      } else {
        t.cancel();
        showTimeoutAlert();
      }
    });
  }

  void incrementCorrectAnswers(bool op) {
    if(op)correctAnswers++;
    else wrongAnswers++;

  }

  void fetchQuizData() async {
    final url = Uri.parse('https://api.jsonserve.com/Uw5CrX');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          quizData = jsonDecode(response.body);
          startTimer();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load quiz data: HTTP ${response.statusCode}';
          isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = 'No Internet connection';
        isLoading = false;
      });
    } on FormatException {
      setState(() {
        errorMessage = 'Bad response format';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching quiz data: $e';
        isLoading = false;
      });
    }
  }

  void endQuiz() {
    int totalQuestions = quizData?['questions']?.length ?? 0;
    timer?.cancel();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ResultPage(totalQuestions: totalQuestions, correctAnswers: correctAnswers,wrongAnswers: wrongAnswers,)));
    // Navigate to the summary page
  }
  @override
  void initState() {
    super.initState();
    fetchQuizData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Time: ${(rTime / 60).toInt()} :${(rTime % 60).toInt()} min',),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : quizData != null
          ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("${quizData!['title']}",style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var question in quizData!['questions'] ?? [])
                        QuestionCard(
                          questionText: question['description'],
                          options: question['options'] ?? [],
                          onCorrectAnswers:incrementCorrectAnswers,
                        ),
                    ],
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed:endQuiz,
                  child: Text("SUBMIT",style: TextStyle(color: Colors.green),),
                ),
              )
            ],
          )
          : Center(child: Text('No quiz data available')),
    );
  }

  void showTimeoutAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Time's Up!"),
          content: const Text("The timer has ended. Would you like to submit or restart?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                endQuiz();
              },
              child: const Text("Submit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                endQuiz();
              },
              child: const Text("Restart Quiz"),
            ),
          ],
        );
      },
    );
  }
}

class QuestionCard extends StatefulWidget {
  final String? questionText;
  final List<dynamic> options;
  final void Function(bool) onCorrectAnswers;
  QuestionCard({
    Key? key,
    this.questionText,
    required this.options,
    required this.onCorrectAnswers,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int selectedOptionIndex = -1;
  int? correctOption;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 350,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.questionText ?? 'Question',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [...widget.options.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> option = entry.value;
                  if(option['is_correct']){
                    correctOption=index+1;
                  }
                  Color bgColor = (selectedOptionIndex == index )
                      ? (option['is_correct'] ? Colors.green : Colors.redAccent)
                      : Colors.grey[200]!;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedOptionIndex != index && selectedOptionIndex==-1) {
                          selectedOptionIndex = index;
                          widget.onCorrectAnswers(option['is_correct']);
                          // if () {
                          //    // Notify parent once
                          // }
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        option['description'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 10,),
                if(selectedOptionIndex!=-1)Text("correct answer is $correctOption"),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
