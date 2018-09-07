import { combineResolvers } from 'graphql-resolvers'
import { GraphQLFieldConfig } from 'graphql'
import * as Context from '../../Context'
import * as Helpers from '../../Helpers'
import * as Types from '../Types/Dsl'
import Client from '../Types/Client'
import Scope, {ApiScope} from '../Types/Scope'


interface CreateApplicationArgs {
  clientName: string,
  redirectUri: string,
  scopes: Array<ApiScope>,
  website: string | null
}

export const field: GraphQLFieldConfig<any, Context.WithInstance, CreateApplicationArgs> = {
  type: Types.nonNull(Client),
  args: {
    clientName: { type: Types.nonNull(Types.string) },
    redirectUri: { type: Types.nonNull(Types.string) },
    scopes: { type: Types.nonNullList(Scope) },
    website: { type: Types.string }
  },
  resolve: combineResolvers(
    Context.requireInstance,
    (_obj: any, args: CreateApplicationArgs, context: Context.WithInstance) => {
      const body = new FormData()
      body.append('client_name', args.clientName)
      body.append('redirect_uris', args.redirectUri)
      body.append('scopes', args.scopes.map(scope => scope.toLowerCase()).join(' '))
      if (args.website) body.append('website', args.website)
      return fetch(`https://${context.instance}/api/v1/apps`, {
        method: 'POST',
        body: body
      })
      .then(r => r.json())
    }
  )
}
