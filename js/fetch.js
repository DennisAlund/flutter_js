function fetch (url, options) {
  const promise = new Promise((resolve, reject) => {
  })
  console.log('fetch.js', promise.id)
  sendMessage('fetch', JSON.stringify([promise.id, url, options]))
  return promise
}