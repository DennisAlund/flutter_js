# 魔改 flutter_js

### 专注改善 [flutter_js](https://github.com/abner/flutter_js) 的Promise和网络请求方面的运行效率和开发体验。

改动:

1. 新开发了[evaluateWithAsync](/lib/extension/promise.dart#46)方法代替原来的 evaluateAsync + [handlePromise](https://github.com/abner/flutter_js/blob/0dbf4138da63d1cfdd5ad4d53b9bdd974c4dfcfd/lib/extensions/handle_promises.dart#L96) 组合方法；
1. 创建QuickJS后自动执行`dispatch()`建立事件循环，[代码文件](./lib/flutter_js.dart#28)
   ，[dispatch的说明](https://github.com/ekibun/flutter_qjs/blob/master/README-CN.md#%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8)
    * 原 flutter_js 的 [handlerPromise方法](https://github.com/abner/flutter_js/blob/0dbf4138da63d1cfdd5ad4d53b9bdd974c4dfcfd/example/lib/main.dart#L128) 每次都要调用一次dispatch()，每次都报`Bad
    state: Stream has already been listened to`错误，从此忘了handleProse方法吧；
1. 修复了js的`console.log('第一','第二')`只能输出一个变量的问题，[代码文件](./lib/javascript_runtime.dart#110)
1. 删除原XMLHttpRequest、fetch、Promise js和dart相关的实现代码；
1. 使用现代化的fetch而弃用XMLHttpRequest，所以没有实现XMLHttpRequest功能；
1. 重写了JavaScriptCore和QuickJS的Promise机制，更精简，更搞笑；
1. fetch和promise的js代码在js文件编写(更准确的开发)；

    * js代码自动写入到dart文件避免异步读取资源文件；
    * 使用Node.js实现，不改动这两个js文件代码不需要安装和运行Node.js；
1. 精简了example mian.dart的代码，更多使用例子请浏览原仓库的代码；