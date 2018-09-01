import { combineResolvers } from 'graphql-resolvers'
import { GraphQLFieldConfig } from 'graphql'
import * as Context from '../../Context'
import * as Helpers from '../../Helpers'
import * as Types from '../Types/Dsl'
import Client from '../Types/Client'
import Scope, {ApiScope} from '../Types/Scope'

interface LoginArgs {
  clientId: string,
  clientSecret: string,
  code: string,
  redirectUri: string,
}

export const field: GraphQLFieldConfig<any, Context.WithInstance, LoginArgs> = {
  type: Types.nonNull(Client),
  args: {
    clientName: { type: Types.nonNull(Types.string) },
    redirectUri: { type: Types.nonNull(Types.string) },
    scopes: { type: Types.nonNullList(Scope) },
    website: { type: Types.string }
  },
  resolve: combineResolvers(
    Context.requireInstance,
    (_obj: any, args: LoginArgs, context: Context.WithInstance) => {
      const body = new FormData()
      body.append('client_id', args.clientId)
      body.append('client_secret', args.clientSecret)
      body.append('redirect_uri', args.redirectUri)
      body.append('code', args.code)
      body.append('grant_type', 'authorization_code')
      fetch(`https://${context.instance}/auth/token`, {
        method: 'POST',
        body: body
      })
      .then(Helpers.validateResponse)
      .then(({ data }) => data)
      .then(Helpers.camelCaseKeys)
    }
  )
}
