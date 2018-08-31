#! npx ts-node 

import schema from '../../src/Server/Schema/index'
import { graphql, introspectionQuery } from 'graphql'
import * as fs from 'fs'
import * as path from 'path'
import * as child from 'child_process'

const ensureDirectories = () => {
  if (fs.existsSync(path.resolve(process.cwd(), '.generated'))) return
  fs.mkdirSync(path.resolve(process.cwd(), '.generated'))
}

const generateSchemaJson = () => {
  return graphql(schema, introspectionQuery)
    .then(result => {
      if (result.errors) throw Error('In schema introspection: \n' + JSON.stringify(result.errors, null, 2))
      fs.writeFileSync(path.resolve(process.cwd(), '.generated/schema.json'), JSON.stringify(result, null, 2))
    })
}

const generateApi = () => {
  child.execSync(
    path.resolve(process.cwd(), 'node_modules/.bin/elm-graphql') +
      ' --introspection-file .generated/schema.json --base Mastodon.Graphql --output .generated'
  )
}

ensureDirectories()
generateSchemaJson()
  .then(() => generateApi())
