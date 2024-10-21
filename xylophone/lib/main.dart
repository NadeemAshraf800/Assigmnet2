import 'package:flutter/material.dart';

void main() => runApp(const QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  List<Icon> scoreKeeper = [];
  int score = 0;
  bool isQuizStarted = false;
  int timer = 300; // Total time of 5 minutes (300 seconds)
  int questionTimer = 30; // 30 seconds per question
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  bool _isStartAnimationCompleted = false;

  int selectedIndex = -1; // Track selected option index

  // List of Islamic questions with 4 options each
  List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the first pillar of Islam?',
      'options': ['Salah', 'Zakat', 'Shahada', 'Hajj'],
      'answer': 'Shahada',
    },
    {
      'question': 'How many times is Salah offered in a day?',
      'options': ['2', '3', '5', '7'],
      'answer': '5',
    },
    {
      'question': 'Which is the holy book of Islam?',
      'options': ['Torah', 'Quran', 'Bible', 'Gita'],
      'answer': 'Quran',
    },
    {
      'question': 'What is the name of the last Prophet in Islam?',
      'options': ['Musa', 'Isa', 'Ibrahim', 'Muhammad (PBUH)'],
      'answer': 'Muhammad (PBUH)',
    },
    {
      'question': 'How many surahs are there in the Quran?',
      'options': ['114', '110', '115', '120'],
      'answer': '114',
    },
    {
      'question': 'What is the Arabic term for charity in Islam?',
      'options': ['Sadaqah', 'Hajj', 'Zakat', 'Fitrana'],
      'answer': 'Zakat',
    },
    {
      'question': 'What does the word "Islam" mean?',
      'options': ['Peace', 'Obedience', 'Submission', 'All of these'],
      'answer': 'All of these',
    },
    {
      'question': 'What is the second month of the Islamic calendar?',
      'options': ['Ramadan', 'Muharram', 'Safar', 'Shawwal'],
      'answer': 'Safar',
    },
    {
      'question': 'What is the significance of Ramadan in Islam?',
      'options': ['Pilgrimage', 'Fasting', 'Charity', 'Prayer'],
      'answer': 'Fasting',
    },
    {
      'question': 'Which city is the holiest in Islam?',
      'options': ['Mecca', 'Jerusalem', 'Medina', 'Cairo'],
      'answer': 'Mecca',
    },
  ];

  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void checkAnswer(String userPickedAnswer) {
    String correctAnswer = questions[currentQuestionIndex]['answer'];

    setState(() {
      if (correctAnswer == userPickedAnswer) {
        scoreKeeper.add(const Icon(Icons.check, color: Colors.green));
        score++;
      } else {
        scoreKeeper.add(const Icon(Icons.close, color: Colors.red));
      }

      // Auto-move to the next question after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (currentQuestionIndex < questions.length - 1) {
          nextQuestion();
        } else {
          showResult();
        }
      });
    });
  }

  void startQuiz() {
    setState(() {
      _isStartAnimationCompleted = true;
      startTimer();
      _controller!.forward(from: 0);
    });
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (timer > 0) {
            timer--;
            questionTimer--;
            startTimer();
          } else {
            showResult();
          }
        });
      }
    });
  }

  void showResult() {
    double percentage = (score / questions.length) * 100;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Quiz Completed!"),
          content: Text("Your score is $score/${questions.length}\nPercentage: ${percentage.toStringAsFixed(2)}%"),
          actions: [
            TextButton(
              child: const Text("Restart"),
              onPressed: () {
                setState(() {
                  resetQuiz();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void resetQuiz() {
    currentQuestionIndex = 0;
    scoreKeeper.clear();
    score = 0;
    timer = 300; // Reset timer to 5 minutes
    questionTimer = 30; // Reset question timer
    isQuizStarted = false;
    _isStartAnimationCompleted = false;
    selectedIndex = -1; // Reset selected option
  }

  void nextQuestion() {
    setState(() {
      currentQuestionIndex++;
      questionTimer = 30;
      selectedIndex = -1; // Reset selected option for the next question
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Stack(
        children: [
          // Start button animation
          if (!isQuizStarted)
            AnimatedPositioned(
              left: _isStartAnimationCompleted ? MediaQuery.of(context).size.width / 2 - 100 : 15,
              top: _isStartAnimationCompleted ? MediaQuery.of(context).size.height / 2 - 100 : 15,
              duration: const Duration(seconds: 2),
              onEnd: () => setState(() {
                isQuizStarted = true;
              }),
              child: GestureDetector(
                onTap: () {
                  startQuiz();
                },
                child: Container(
                  width: _isStartAnimationCompleted ? 200 : 300, // Increased width
                  height: _isStartAnimationCompleted ? 200 : 100, // Increased height
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "Start Quiz",
                      style: TextStyle(color: Colors.white, fontSize: 28), // Adjusted text size
                    ),
                  ),
                ),
              ),
            ),

          if (isQuizStarted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Timer
                  Center(
                    child: Text(
                      'Total Time Left: ${(timer / 60).floor()}m ${(timer % 60)}s',
                      style: const TextStyle(fontSize: 24.0, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Question Timer
                  Center(
                    child: Text(
                      'Time for this question: $questionTimer',
                      style: const TextStyle(fontSize: 20.0, color: Colors.purple),
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  // Question
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation!,
                      child: Center(
                        child: Text(
                          questions[currentQuestionIndex]['question'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 30.0),
                        ),
                      ),
                    ),
                  ),

                  // Options with solid color for selected option
                  Column(
                    children: (questions[currentQuestionIndex]['options'] as List<String>).asMap().entries.map((entry) {
                      int index = entry.key;
                      String option = entry.value;

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedIndex == index ? Colors.orange : Colors.green,
                            padding: const EdgeInsets.all(15.0),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedIndex = index; // Set selected index
                            });
                            checkAnswer(option);
                          },
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10.0),

                  // ScoreKeeper
                  Row(
                    children: scoreKeeper,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
