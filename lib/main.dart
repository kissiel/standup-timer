import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

void main() {
  runApp(const MyApp());
}

List<String> shift_names(List<String> names, int shift) {
  // ["foo", "bar", "baz"] shifted by one becomes ["bar", "baz", "foo"]
  // ["foo", "bar", "baz"] shifted by 5 becomes ["baz", "foo", "bar"]
  final real_shift = shift % names.length;

  List<String> shifted = []
    ..addAll(names.sublist(real_shift))
    ..addAll(names.sublist(0, real_shift));

  return shifted;
}

List<String> _all_names = [
  'Adam',
  'Fernando',
  'Maciej',
  'Massimiliano',
  'Paolo',
  'Pierre',
  'Sylvain',
];

int generate_standup_number() {
  // count the weekdays since 2022-03-01, the day on which
  // we started having standups using this standup timer

  final DateTime today = DateTime.now();
  int workingDays = 0;

  // warning: the code below is inefficient AF
  // but it's easy and adding ignored days (like holidays) is straightforward
  for (DateTime date = DateTime.fromMillisecondsSinceEpoch(1709334000000);
      // TODO: if there's holiday on that date, skip it
      date.isBefore(today);
      date = date.add(Duration(days: 1))) {
    if (date.weekday >= DateTime.monday && date.weekday <= DateTime.friday) {
      workingDays++;
    }
  }
  return workingDays;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certification Team Standup Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  CountDownController _controller = CountDownController();
  int _duration = 120; // Seconds
  bool _isRunning = false;
  bool _isDone = true;

  int _whosTalkingIndex = 0;

  List<String> _names = shift_names(_all_names, generate_standup_number());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certification Tech Standup Timer'),
        centerTitle: true,
      ),
      body: Center(
        child: _isDone
            ? Column(
                children: [
                  Text(_isRunning ? "All done!" : "Ready to start!"),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isDone = false;
                        _isRunning = false;
                        _whosTalkingIndex = 0;
                      });
                    },
                    child: const Text('Start'),
                  )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularCountDownTimer(
                    duration: _duration,
                    initialDuration: 0,
                    controller: _controller,
                    width: 400,
                    height: 400,
                    ringColor: Colors.grey,
                    fillColor: Colors.blue,
                    strokeWidth: 10.0,
                    strokeCap: StrokeCap.round,
                    textStyle: const TextStyle(fontSize: 66.0),
                    textFormat: CountdownTextFormat.MM_SS,
                    isReverse: true,
                    isReverseAnimation: true,
                    onComplete: () {
                      setState(() {
                        _whosTalkingIndex =
                            (_whosTalkingIndex + 1) % (_names.length + 1);
                        if (_whosTalkingIndex < _names.length) {
                          _controller.restart(duration: _duration);
                        } else {
                          _isRunning = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _whosTalkingIndex < _names.length
                        ? _names[_whosTalkingIndex]
                        : 'GG',
                    style: const TextStyle(fontSize: 60),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isRunning
                            ? null
                            : () {
                                setState(() {
                                  _whosTalkingIndex = (_whosTalkingIndex + 1) %
                                      (_names.length + 1);
                                  if (_whosTalkingIndex < _names.length) {
                                    _controller.restart(duration: _duration);
                                  } else {
                                    _isDone = true;
                                    _isRunning = false;
                                  }
                                });
                              },
                        child: const Text('Next person'),
                      ),
                      const SizedBox(width: 20),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
