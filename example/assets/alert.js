function alert (index) {
  let res, rej
  const promise = new Promise((
    (resolve, reject) => {
      res = resolve
      rej = reject
    }
  )).then(() => console.log('alert', index))
  promise.resolve = res
  promise.reject = rej
  sendMessage('alert', JSON.stringify([promise.id, index]))
  return promise
}

async function a () {
  await alert(1)
  await alert(2)
}

a()