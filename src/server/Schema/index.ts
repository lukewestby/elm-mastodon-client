import { GraphQLSchema } from 'graphql'
import * as CreateApplication from './Mutation/CreateApplication'
import * as Instances from './Query/Instances'
import * as Account from './Query/Account'
import * as Types from './Types/Dsl'

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
      createApplication: CreateApplication.field
    }
  })
})
