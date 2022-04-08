import 'dart:typed_data';
import 'package:controll_car/blutooth_state.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: BluetoothApp(),
    );
  }
}
class MyHomePage extends StatefulWidget {
 Future Function(Uint8List value) sendMessage;
 MyHomePage({this.sendMessage});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<int> list;
  Uint8List command;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Control Car'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  // If listening is active show the recognized words
                      _speechToText.isListening
                      ? '$_lastWords'
                  // If listening isn't active but could be tell the user
                  // how to start it, otherwise indicate that speech
                  // recognition is not yet ready or not supported on
                  // the target device
                      : _speechEnabled
                      ?_lastWords==""?"اضغط على المايكروفون":_lastWords
                      : 'التحدث غير متاح قم بتحميل برنامج كوكل وفعله',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            AvatarGlow(
              animate:_speechToText.isNotListening ? false:true ,
              glowColor: Colors.purple,
              endRadius: 60,
              child: FloatingActionButton(
                backgroundColor: Colors.purple,
                onPressed:
                // If not yet listening for speech start, otherwise stop
                _speechToText.isNotListening ? _startListening : _stopListening,
                tooltip: 'تكلم',
                child: Icon(_speechToText.isNotListening ? Icons.mic_none : Icons.mic,),
              ),
            ),
            _lastWords!=""&&_speechToText.isNotListening?FloatingActionButton(
              backgroundColor: Colors.purple,
              onPressed:()async{
                await widget.sendMessage(Uint8List.fromList(_lastWords.codeUnits));
              },
              tooltip: 'ارسال',
              child: Icon(Icons.send_sharp),
            ):Container(),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}