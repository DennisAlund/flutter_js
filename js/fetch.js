function fetch (url, options) {
  const promise = new MyPromise((_resolve, _reject) => {
    promise.resolve = _resolve
    promise.reject = _reject
    console.log('执行fetch的promise')
  })
  console.log('fetch.js 创建promise id:', promise.id)
  sendMessage('fetch', JSON.stringify([promise.id, url, options]))
  return promise
}