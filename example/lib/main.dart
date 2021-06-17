import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_js/extension/promise.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

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
    return GetMaterialApp(
      home: FlutterJsHomeScreen(),
    );
  }
}

class FlutterJsHomeScreen extends StatefulWidget {
  @override
  _FlutterJsHomeScreenState createState() => _FlutterJsHomeScreenState();
}

class _FlutterJsHomeScreenState extends State<FlutterJsHomeScreen> {
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
              child: const Text('Promise chain'),
              onPressed: () async {
                setState(() => _quickjsVersion = 'loading');
                final JavascriptRuntime js = getJavascriptRuntime();
                JsEvalResult? fetch = await js.evaluateWithAsync('''
                async function a(){
                  return Promise.resolve('hi')
                }
                a().then(str=>'1 '+str).then(str=>`2 \${str}`).then(str=>`3 \${str}`)
              ''');
                print('fetch结果 ${fetch?.stringResult}');
                setState(() => _quickjsVersion = fetch?.stringResult);
                js.dispose();
              },
            ),
            Text(
              'QuickJS Version\n${_quickjsVersion == null
                  ? '<NULL>'
                  : _quickjsVersion}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
                child: Text('fetch'),
                onPressed: () async {
                  final js = getJavascriptRuntime(
                    fetch: (String url, Map? _options) async {
                      Options options = Options(
                        method: _options?['method'] ?? 'GET',
                        headers: _options?['headers'],
                        responseType: ResponseType.bytes,
                      );
                      final res = await Dio().request(
                        url,
                        data: _options?['data'],
                        options: options,
                      );
                      final contentType =
                      res.headers.value(Headers.contentTypeHeader);
                      print('contentType $contentType');
                      dynamic body = res.data;
                      if (contentType?.startsWith('text/') == true ||
                          contentType?.endsWith('/json') == true ||
                          contentType?.endsWith('/xml') == true) {
                        // 文本
                        body = utf8.decode(res.data);
                      }
                      else if (contentType?.startsWith('image/') == true) {
                        // 图片
                        final codec = await ui.instantiateImageCodec(res.data);
                        FrameInfo fi = await codec.getNextFrame();
                        body = {
                          'type': 'image',
                          'width': fi.image.width,
                          'height': fi.image.height,
                          'content': res.data,
                        };
                      } else {
                        body = {'type': 'binary', 'content': res.data};
                      }
                      return FetchResponse(
                        url: res.realUri.toString(),
                        headers: res.headers.map,
                        status: res.statusCode ?? 200,
                        statusText: res.statusMessage ?? 'ok',
                        body: body,
                        redirected: res.isRedirect ?? false,
                      );
                    },
                  );
                  js.evaluate('''
                    fetch('https://www.chiphell.com/static/image/common/logo.png')
                    .then(res=>{
                      console.log('图片', res)
                    })
                    // .then(()=>fetch('http://lkong.cn/index.php?mod=data&sars=thread/2819293'))
                    // .then(res=>console.log('json',res.body))
                  ''');
                }),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Promise.all + setTimout\n看console输出'),
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
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Alert + Promise'),
              onPressed: () async {
                final js = getJavascriptRuntime();
                js.onMessage('alert', (args) async {
                  final promiseId = args[0];
                  final text = args[1];
                  print('alert promise.id $promiseId');
                  await Get.dialog(AlertDialog(
                    title: Text('Alert: $text'),
                  ));
                  js.evaluate('''PROMISE_MAP['$promiseId'].resolve()''');
                });
                await js.evaluateWithAsync(await rootBundle.loadString(
                  'assets/alert.js',
                  cache: false,
                ));
                print('alert.js 结束');
              },
            ),
          ],
        ),
      ),
    );
  }
}
