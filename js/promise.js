const PROMISE_MAP = {}

class MyPromise extends Promise {
  constructor (Fn) {
    const id = Date.now().toString(36)
    super(Fn)
    this.id = id
    console.log('创建Promise', id)
    PROMISE_MAP[id] = this
  }

  toString () {
    console.log('Promise.toString', this.id)
    return `Promise:${this.id}`
  }
}

Promise = MyPromise