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
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

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
        title: Text('By: Nour Mohammed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              height: 100,
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
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              color: Colors.purple,
              child: Text("اتصال",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),),
                onPressed:_lastWords.isNotEmpty&&_speechToText.isNotListening?(){
                  Navigator.push(context, MaterialPageRoute(builder: (ctx)=>BluetoothApp(
                    message: _lastWords,
                  )));
                }:null),
            SizedBox(
              height: 150,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
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
    );
  }
}