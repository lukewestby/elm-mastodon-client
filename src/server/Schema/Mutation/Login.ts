import { combineResolvers } from 'graphql-resolvers'
import { GraphQLFieldConfig } from 'graphql'
import * as Context from '../../Context'
import * as Helpers from '../../Helpers'
import * as Types from '../Types/Dsl'
import Scope, {ApiScope} from '../Types/Scope'
import Credentials from '../Types/Credentials'

interface LoginArgs {
  clientId: string,
  clientSecret: string,
  code: string,
  redirectUri: string,
}

export const field: GraphQLFieldConfig<any, Context.WithInstance, LoginArgs> = {
  type: Types.nonNull(Credentials),
  args: {
    clientId: { type: Types.nonNull(Types.string) },
    redirectUri: { type: Types.nonNull(Types.string) },
    clientSecret: { type: Types.nonNull(Types.string) },
    code: { type: Types.nonNull(Types.string) }
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
      return fetch(`https://${context.instance}/oauth/token`, {
        method: 'POST',
        body: body
      })
      .then(Helpers.validateResponse)
      .then(({ data }) => data)
    }
  )
}
