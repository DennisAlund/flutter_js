import 'dart:async';

import 'package:flutter_js/flutter_js.dart';

final Map<String, Completer<JsEvalResult?>> promiseQueue = {};

const content = '''const PROMISE_MAP = {}

const Characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
const CharactersLength = Characters.length

function randomCharacters (length = 6) {
  const result = []
  for (var i = 0; i < length; i++) {
    result.push(Characters.charAt(Math.floor(Math.random() *
      CharactersLength)))
  }
  return result.join('')
}

class MyPromise extends Promise {
  constructor (...args) {
    const id = randomCharacters()
    // console.log('创建Promise', id)
    super(...args)
    this.id = id
    PROMISE_MAP[id] = this
    sendMessage('PromiseStart', JSON.stringify([id]))
    this.resolve = null
    this.reject = null
  }
}

Promise.prototype.toString = function () {
  if (!this.id) {
    this.id = randomCharacters()
    PROMISE_MAP[this.id] = this
    sendMessage('PromiseStart', JSON.stringify([this.id]))
    this.resolve = null
    this.reject = null
  }
  // console.log('Promise.toString', this.id)
  return `Promise:\${this.id}`
}

globalThis.Promise = Promise = MyPromise
'''; //promise.js

extension Promise on JavascriptRuntime {
  enablePromise() {
    evaluate(content);
    this.onMessage('PromiseStart', (dynamic args) {
      final promiseId = args[0];
      // print('PromiseStart $promiseId');
      promiseQueue[promiseId] = Completer();
    });
    this.onMessage('PromiseEnd', (dynamic args) {
      final promiseId = args[0];
      // print('PromiseEnd $args');
      late Completer? completer = promiseQueue.remove(promiseId);
      if (completer?.isCompleted == false) {
        print('结束Completer $promiseId');
        completer!.complete(JsEvalResult(
          args[1]?.toString() ?? 'null',
          args[1],
        ));
      }
    });
    this.onMessage('PromiseError', (dynamic args) {
      final promiseId = args[0];
      // print('PromiseError $args');
      late Completer? completer = promiseQueue.remove(promiseId);
      if (completer?.isCompleted == false) {
        print('结束Completer $promiseId');
        completer!.completeError(JsEvalResult(
          args[1]?.toString() ?? 'null',
          args[1],
        ));
      }
    });
  }

  Future<JsEvalResult?> evaluateWithAsync(code) {
    final JsEvalResult res = evaluate(code);
    print('evaluateWithAsync: ${res.stringResult}');
    if (res.stringResult.startsWith('Promise:')) {
      // 获取Promise id
      final promiseId = res.stringResult.split(':').last;
      print('Promise id: $promiseId');
      final Completer<JsEvalResult?> completer =
          promiseQueue[promiseId] = Completer();
      evaluate('''
      PROMISE_MAP['$promiseId'].then(val=>{
        // console.log('promise.dart then $promiseId', val)
        sendMessage('PromiseEnd', JSON.stringify(['$promiseId', val]))
        return val
      }).catch(e=>{
        // console.log('promise.dart error $promiseId', `\${e.toString()}`)
        sendMessage('PromiseError', JSON.stringify(['$promiseId', `\${e.toString()}`]))
        return e
      })
      ''');
      return completer.future;
    }
    return Future.value(null);
  }
}
