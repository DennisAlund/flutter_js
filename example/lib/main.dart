import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/extension/promise.dart';
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
                final JavascriptRuntime js = getJavascriptRuntime(
                  fetch: (String url, Map? _options) async {
                    Options? options;
                    if (_options != null) {
                      options = Options(
                        method: _options['method'] ?? 'GET',
                        headers: _options['headers'],
                      );
                    }
                    final res = await Dio().request(
                      url,
                      data: _options?['data'],
                      options: options,
                    );
                    return FetchResponse(
                      url: res.realUri.toString(),
                      headers: res.headers.map,
                      status: res.statusCode ?? 200,
                      statusText: res.statusMessage ?? 'ok',
                      body: res.data,
                      redirected: res.isRedirect ?? false,
                    );
                  },
                );
                JsEvalResult? fetch = await js.evaluateWithAsync('''
                async function a(){
                  return Promise.resolve('hi')
                }
                a().then(str=>'1 '+str).then(str=>`2 \${str}`)
              ''');
                print('fetch结果 ${fetch?.stringResult}');
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
                JsEvalResult? timeout;
                timeout = await js.evaluateWithAsync('''
                new Promise((resolve)=>{
                    console.log('setTimeout 1000 start')
                      setTimeout(()=>{
                        console.log('setTimeout end')
                        resolve('setTimeout 1000')
                      }, 1000)
                    }).then(str => `then \${str}`)
                ''');
                print('First timeout: ${timeout?.stringResult}');
                timeout = await js.evaluateWithAsync('''
                Promise.all([
                  new Promise(resolve=>{
                    console.log('setTimeout 100 start')
                      setTimeout(()=>{
                        console.log('setTimeout end 100')
                        resolve('setTimeout 100')
                      }, 100)
                    }),
                  new Promise(resolve=>{
                    console.log('setTimeout 500 start')
                      setTimeout(()=>{
                        console.log('setTimeout end 500')
                        resolve('返回结果 setTimeout 500')
                      }, 500)
                    }),
                ]).then(val=>val)
                ''');
                print('Second timeout: ${timeout?.stringResult}');
                js.dispose();
              },
            ),
          ],
        ),
      ),
    );
  }
}
