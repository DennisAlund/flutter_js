import 'dart:async';

import 'package:flutter_js/flutter_js.dart';

final Map<String, Completer<JsEvalResult>> promiseQueue = {};

const content = '''const PROMISE_LIST = {}

// todo https://www.cnblogs.com/XieJunBao/p/9156134.html
// todo https://segmentfault.com/a/1190000002452115
class MyPromise extends Promise {
  constructor (executor) {
    const id = Date.now().toString(36)
    console.log('创建 MyPromise', id)
    let resolve, reject
    super((_resolve, _reject) => {
      resolve = (val) => {
        console.log('resolve', id)
        _resolve(val) //执行promise._resolve
        sendMessage('PromiseEnd', JSON.stringify([id, val]))
        delete PROMISE_LIST[id]
      }
      reject = (reason) => {
        console.log('reject', id)
        _reject(reason) // 执行promise._reject
        sendMessage('PromiseEnd', JSON.stringify([id, reason]))
        delete PROMISE_LIST[id]
      }
      if (executor) {
        console.log('执行 executor', id)
        executor(
          (val) => resolve(val),
          (reason) => reject(reason),
        )
      } else {
        resolve(null)
      }
    })
    this.resolve = resolve
    this.reject = reject
    this.id = id
    PROMISE_LIST[this.id] = this
    sendMessage('PromiseStart', JSON.stringify([this.id]))
  }

  finally (onFinally) {
    this._finally = function () {
      delete PROMISE_LIST[this.id]
      sendMessage('PromiseEnd', JSON.stringify([this.id]))
      onFinally(arguments)
    }
    const _finally = super.finally(this._finally)
    console.log('finally', _finally.id)
    return _finally
  }

  then (onfulfilled, onrejected) {
    this._resolve = (val) => {
      delete PROMISE_LIST[this.id]
      sendMessage('PromiseEnd', JSON.stringify([this.id]))
      onfulfilled(val)
    }
    // if (onrejected) this.catch(onrejected)
    const then = super.then(this._resolve)
    console.log('then', then.id)
    return then
  }

  catch (onrejected) {
    this._reject = (reason) => {
      delete PROMISE_LIST[this.id]
      sendMessage('PromiseEnd', JSON.stringify([this.id]))
      onrejected(reason)
    }
    const _catch = super.catch(this._reject)
    console.log('catch', _catch.id)
    return _catch
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
      Completer? completer = promiseQueue.remove(promiseId);
      if (completer?.isCompleted == false) {
        print('结束Completer $promiseId');
        completer!.complete(JsEvalResult(
          args[1],
          args[1],
        ));
      }
    });
  }

  Future<JsEvalResult?> evaluateWithAsync(code) {
    final JsEvalResult res = evaluate(code);
    print('evaluateWithAsync: ${res.stringResult}');
    if (res.stringResult.startsWith('Promise:')) {
      final promiseId = res.stringResult.split(':').last;
      if (promiseQueue.containsKey(promiseId)) {
        // 已经存在promise
        print('已存在Completer $promiseId');
        return promiseQueue[promiseId]!.future;
      }
    }
    print('没有Completer');
    return Future.value(null);
  }
}
