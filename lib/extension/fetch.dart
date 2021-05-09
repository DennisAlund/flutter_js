import 'package:flutter_js/extension/promise.dart';
import 'package:flutter_js/flutter_js.dart';

const content = '''function fetch (url, options) {
  const promise = new Promise((resolve, reject) => {
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
      await Future.delayed(Duration(seconds: 1));
      evaluate('''
        PROMISE_LIST[$promiseId]
      ''');
      promiseQueue[promiseId]!
          .complete(JsEvalResult('fetch string result', 'fetch raw result'));
    });
  }
}
