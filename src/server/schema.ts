import { makeExecutableSchema } from 'graphql-tools'

// HELPERS

const log = (a: any): any => {
  console.log(a)
  return a
}

const camelCase = (string: string) => {
  return string.replace(/(\_\w)/g, m => m[1].toUpperCase())
}

const camelCaseKeys = (obj: {[key: string]: any}) => {
  const output: {[key: string]: any} = {}
  Object.keys(obj).forEach(key => {
    output[camelCase(key)] = obj[key]
  })
  return output
}

// TYPEDEFS

const typedefs = `
type Query {
  instanceSearch(query: String!): [String!]!
}

input type ClientSpec {
  clientName: String!
  redirectUris: [String!]!
  scopes: [Strint!]!
  website: String!
}

type Mutation {
  createApplication(spec: ClientSpec): Client!
}

type Client {
  id: String!
  clientId: String!
  clientSecret: String!
}
`

// RESOLVERS

const INSTANCE_SOCIAL_TOKEN = 'narCDHH9MJhnzjYN0SAv2A3Pk90qlTxl7jxOYv2yvY0RsfYnt7OPRri6CmQ03NpX8qPnoxcE9INU7YO3j7o0Iykcw1PniXhWMBqHYLLK85J1eDMp1Z7T8OXp92pnihQq'

const resolvers = {
  Query: {
    instanceSearch(_obj: any, args: { query: string }, _context: any) {
      return fetch(`https://instances.social/api/1.0/instances/search?q=${encodeURIComponent(args.query)}&count=10&name=true`, {
        method: 'GET',
        headers: { 'Authorization': `Bearer ${INSTANCE_SOCIAL_TOKEN}` }
      })
      .then(r => r.json())
      .then((data: any) => data.instances.map((i: any) => i.name))
    }
  },

  Client: {
    id: (obj: any) => obj.id,
    clientId: (obj: any) => obj.client_id,
    clientSecret: (obj: any) => obj.client_secret
  }
}

// EXPORT

export default makeExecutableSchema({
  typeDefs: typedefs,
  resolvers: resolvers
})
