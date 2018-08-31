import { combineResolvers } from 'graphql-resolvers'
import * as Context from '../../Context'
import * as Helpers from '../../Helpers'
import * as Types from '../Types/Dsl'
import Client from '../Types/Client'

interface CreateApplicationArgs {
  clientName: string,
  redirectUri: string,
  scopes: Array<string>,
  website: string | null
}

export const field = {
  type: Types.nonNull(Client),
  resolve: combineResolvers(
    Context.requireInstance,
    (_obj: any, args: CreateApplicationArgs, context: Context.WithInstance) => {
      const body = new FormData()
      body.append('client_name', args.clientName)
      body.append('redirect_uris', args.redirectUri)
      body.append('scopes', args.scopes.map(scope => scope.toLowerCase()).join(' '))
      if (args.website) body.append('website', args.website)

      fetch(`https://${context.instance}/api/v1/apps`, {
        method: 'POST',
        body: body
      })
      .then(r => r.json())
      .then(Helpers.camelCaseKeys)
    }
  )
}
