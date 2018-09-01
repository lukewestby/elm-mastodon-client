import { GraphQLSchema } from 'graphql'
import * as Types from './Types/Dsl'

import * as CreateApplication from './Mutation/CreateApplication'
import * as Login from './Mutation/Login'

import * as Instances from './Query/Instances'
import * as Account from './Query/Account'

export default new GraphQLSchema({
  query: Types.object({
    name: 'Query',
    fields: {
      instances: Instances.field,
      account: Account.field
    }
  }),
  mutation: Types.object({
    name: 'Mutation',
    fields: {
      createApplication: CreateApplication.field,
      login: Login.field
    }
  })
})
