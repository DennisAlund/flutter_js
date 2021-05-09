# 魔改 flutter_js

### [原 flutter_js 说明](https://github.com/abner/flutter_js/readme.md)

改动:

1. 更精简的promise机制
2. fetch和promise的js代码在js文件编写 自动插入到dart文件避免异步读取资源文件
   *（自动插入机制需要使用node.js运行）
3. 删除XMLHttpRequest和fetch代码，改为传参
4. 精简example代码，更多使用例子请参考原仓库的代码