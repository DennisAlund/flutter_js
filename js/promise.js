const PROMISE_LIST = {}

class MyPromise extends Promise {
  constructor (func) {
    super((resolve, reject) => {
      setTimeout(() => {
        console.log('运行 func')
        if (func) {
          func(
            (val) => {
              console.log('resolve')
              resolve(val)
              sendMessage('PromiseEnd', JSON.stringify([this.id, val]))
              delete PROMISE_LIST[this.id]
            },
            (reason) => {
              reject(reason)
              sendMessage('PromiseEnd', JSON.stringify([this.id, reason]))
              delete PROMISE_LIST[this.id]
            },
          )
        } else {
          resolve()
          sendMessage('PromiseEnd', JSON.stringify([this.id, reason]))
          delete PROMISE_LIST[this.id]
        }
      }, 0)
    })
    this.id = Date.now().toString(36)
    console.log('MyPromise', this.id)
    PROMISE_LIST[this.id] = this
    sendMessage('PromiseStart', JSON.stringify([this.id]))
  }

  finally (onFinally) {
    this._finally = function () {
      delete PROMISE_LIST[this.id]
      sendMessage('PromiseEnd', JSON.stringify([this.id]))
      onFinally(arguments)
    }
    return super.finally(this._finally)
  }

  then (onfulfilled, onrejected) {
    this._resolve = (val) => {
      delete PROMISE_LIST[this.id]
      sendMessage('PromiseEnd', JSON.stringify([this.id]))
      onfulfilled(val)
    }
    if (onrejected) this.catch(onrejected)
    return super.then(this._resolve, this._reject)
  }

  catch (onrejected) {
    this._reject = (reason) => {
      delete PROMISE_LIST[this.id]
      sendMessage('PromiseEnd', JSON.stringify([this.id]))
      onrejected(reason)
    }
    return super.catch(this._reject)
  }

  toString () {
    return `Promise:${this.id}`
  }
}

Promise = MyPromise