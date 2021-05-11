function fetch (url, options) {
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
}