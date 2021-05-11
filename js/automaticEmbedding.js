/**
 * Automatic embedding the fetch.js and promise.js files content into fetch.dart and promise.dart
 */

const fs = require('fs')
const path = require('path')
const currentPath = process.cwd()
const extensionPath = path.join(currentPath, '..', 'lib', 'extension')
let timeout
fs.watch(currentPath, () => {
  clearTimeout(timeout)
  timeout = setTimeout(() => {
    embed()
  }, 50)
})
embed()

function embed () {
  readAndReplace('fetch')
  readAndReplace('promise')
}

function readAndReplace (file) {
  const readFile = path.join('.', file + '.js')
  const writeFile = path.join(extensionPath, `${file}.dart`)
  console.log(`read => ${readFile} => write => ${writeFile}`)
  const read = fs.readFileSync(readFile, 'utf-8').toString().replace(
    /\${/g, '\\${')
  let content = fs.readFileSync(writeFile, 'utf-8')

  content = content.replace(
    new RegExp(`^const.+?\/\/(?:${readFile}|content)$`, 'sm'),
    `const content = '''${read}'''; //${readFile}`,
  )
  fs.writeFileSync(writeFile, content)
}