function fetch (url, options) {
  console.log('fetch.js 创建promise')
  const promise = new Promise((resolve, reject) => {
    console.log('fetch waiting to do', promise.id)
  })
  console.log('fetch.js', promise.id)
  sendMessage('fetch', JSON.stringify([promise.id, url, options]))
  return promise
}