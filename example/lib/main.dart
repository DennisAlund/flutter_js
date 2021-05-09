import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlutterJsHomeScreen(),
    );
  }
}

class FlutterJsHomeScreen extends StatefulWidget {
  @override
  _FlutterJsHomeScreenState createState() => _FlutterJsHomeScreenState();
}

class _FlutterJsHomeScreenState extends State<FlutterJsHomeScreen> {
  String _jsResult = '';

  String? _quickjsVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterJS Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Fetch Remote Data'),
              onPressed: () async {
                setState(() => _quickjsVersion = 'loading');
                final JavascriptRuntime js = getJavascriptRuntime();
                JsEvalResult? fetch = await js.evaluateWithAsync("""
                fetch('https://www.chiphell.com/static/image/common/logo.png').then(response => response.text());
              """);
                setState(() => _quickjsVersion = fetch?.stringResult);
                js.dispose();
              },
            ),
            Text(
              'QuickJS Version\n${_quickjsVersion == null ? '<NULL>' : _quickjsVersion}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('promise + setTimout\n看console输出'),
              onPressed: () async {
                final JavascriptRuntime js = getJavascriptRuntime();
                var timeout = await js.evaluateWithAsync('''
                new Promise((resolve)=>{
                  console.log('setTimeout start')
                  setTimeout(()=>{
                    console.log('setTimeout end')
                    resolve('setTimeout')
                  }, 5000)
                }).then(val=>val).catch(reason=>reason).finally(final=>console.log(final))
                ''');
                print('timeout结束 ${timeout?.stringResult}');
                js.dispose();
              },
            ),
          ],
        ),
      ),
    );
  }
}
