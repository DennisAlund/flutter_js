import 'package:flutter_js/flutter_js.dart';

const content = '''function fetch (url, options) {
  const promise = new MyPromise((_resolve, _reject) => {
    promise.resolve = _resolve
    promise.reject = _reject
    console.log('执行fetch的promise')
  })
  console.log('fetch.js 创建promise id:', promise.id)
  sendMessage('fetch', JSON.stringify([promise.id, url, options]))
  return promise
}'''; //fetch.js

typedef Fetch = Future<dynamic> Function(
  String url,
  Map<String, dynamic>? options,
);

extension Promise on JavascriptRuntime {
  enableFetch(Fetch fetch) {
    evaluate(content);
    onMessage('fetch', (dynamic args) async {
      final promiseId = args[0];
      final url = args[1];
      final options = args[2];
      print('fetch $promiseId $url');
      try {
        final get = fetch(url, options);
        print('get $get');
        final res = await get;
        print('fetch $promiseId 结果 ${res.statusCode}');
        evaluate('''
        PROMISE_MAP['$promiseId'].resolve('hi')
      ''');
      } catch (e) {
        print('fetch $promiseId 错误 $e');
        evaluate('''
        PROMISE_MAP['$promiseId'].reject('hi')
      ''');
      }
    });
  }
}
