import 'package:dio/dio.dart';
import 'package:flutter_js/extension/promise.dart';
import 'package:flutter_js/flutter_js.dart';

const content = '''function fetch (url, options) {
  console.log('fetch.js 创建promise')
  const promise = new Promise((resolve, reject) => {
    console.log('fetch waiting to do', promise.id)
  })
  console.log('fetch.js', promise.id)
  sendMessage('fetch', JSON.stringify([promise.id, url, options]))
  return promise
}'''; //fetch.js

extension Promise on JavascriptRuntime {
  enableFetch() {
    evaluate(content);
    onMessage('fetch', (dynamic args) async {
      final promiseId = args[0];
      final url = args[1];
      final options = args[2];
      print('fetch $promiseId $url');
      Dio dio = Dio();
      final res = await dio.get(url);
      print('fetch 结果 ${res.statusCode}');
      evaluate('''
        PROMISE_LIST[$promiseId].resolve('fetch结果')
      ''');
      // promiseQueue[promiseId]!
      //     .complete(JsEvalResult('fetch string result', 'fetch raw result'));
    });
  }
}
