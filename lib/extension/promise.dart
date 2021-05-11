import 'dart:async';

import 'package:flutter_js/flutter_js.dart';

final Map<String, Completer<JsEvalResult?>> promiseQueue = {};

const content = '''const PROMISE_MAP = {}

class MyPromise extends Promise {
  constructor (Fn) {
    const id = Date.now().toString(36)
    super(Fn)
    this.id = id
    PROMISE_MAP[id] = this
  }

  toString () {
    return `Promise:\${this.id}`
  }
}

Promise = MyPromise'''; //promise.js

extension Promise on JavascriptRuntime {
  enablePromise() {
    evaluate(content);
    this.onMessage('PromiseStart', (dynamic args) {
      final promiseId = args[0];
      print('PromiseStart $promiseId');
      promiseQueue[promiseId] = Completer();
    });
    this.onMessage('PromiseEnd', (dynamic args) {
      final promiseId = args[0];
      print('PromiseEnd $args');
      late Completer? completer = promiseQueue.remove(promiseId);
      if (completer?.isCompleted == false) {
        print('结束Completer $promiseId');
        completer!.complete(JsEvalResult(
          args[1].toString(),
          args[1],
        ));
      }
    });
  }

  Future<JsEvalResult?> evaluateWithAsync(code) {
    final JsEvalResult res = evaluate(code);
    print('evaluateWithAsync: ${res.stringResult}');
    if (res.stringResult.startsWith('Promise:')) {
      // For Javascript Core at the iOS and macOS systems
      final promiseId = res.stringResult.split(':').last;
      print('Promise id: $promiseId');
      final Completer<JsEvalResult?> completer = Completer();
      promiseQueue[promiseId] = completer;
      evaluate('''
      PROMISE_MAP['$promiseId'].then(val=>{
        sendMessage('PromiseEnd',JSON.stringify(['$promiseId', val]))
        return val
      })
      ''');
      return completer.future;
    } else if (res.rawResult is Future) {
      // For the QuickJS
      print('is future');
      executePendingJob();
      final Future future = res.rawResult as Future;
      return future.then((value) {
        print('future 完成了');
        return JsEvalResult(value.toString(), value);
      });
    }
    return Future.value(null);
  }
}
