import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';

const content = '''function fetch (url, options) {
  let resolve, reject
  const promise = new MyPromise((_resolve, _reject) => {
    resolve = _resolve
    reject = _reject
    // console.log('执行fetch的promise')
  })
  promise.resolve = resolve
  promise.reject = reject
  // console.log('fetch.js 创建promise id:', promise.id)
  sendMessage('fetch', JSON.stringify([promise.id, url, options]))
  return promise
}'''; //fetch.js

typedef Fetch = Future<FetchResponse> Function(
  String url,
  Map<String, dynamic>? options,
);

/// From https://developer.mozilla.org/en-US/docs/Web/API/Response
class FetchResponse {
  final Map<String, dynamic> headers;
  final Map<String, dynamic>? request;
  final bool redirected;
  final String url;
  final dynamic body;
  final int status;
  final String statusText;

  FetchResponse({
    this.request,
    required this.headers,
    required this.redirected,
    required this.url,
    required this.body,
    required this.status,
    required this.statusText,
  });

  bool get ok => status >= 200 && status <= 299;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'statusText': statusText,
      'url': url,
      'headers': headers,
      'body': body,
    };
  }
}

extension FetchExtension on JavascriptRuntime {
  enableFetch(Fetch fetch) {
    evaluate(content);
    onMessage('fetch', (dynamic args) async {
      final promiseId = args[0];
      final url = args[1];
      final options = args[2];
      print('fetch $promiseId $url');
      try {
        final res = await fetch(url, options);
        print('fetch $promiseId 结果 ${res.toJson()}');
        evaluate('''
        PROMISE_MAP['$promiseId'].resolve(${jsonEncode(res.toJson())})
      ''');
      } catch (e) {
        // print('fetch $promiseId 错误 $e');
        evaluate('''
        PROMISE_MAP['$promiseId'].reject('hi')
      ''');
      }
    });
  }
}
