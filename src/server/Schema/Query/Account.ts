import Account from '../Types/Account'
import * as Types from '../Types/Dsl'
import * as Context from '../../Context'
import * as Helpers from '../../Helpers'

interface AccountArgs {
  id: string
}

export const field = {
  type: Types.nonNull(Account),
  arguments: {
    id: { type: Types.id }
  },
  resolve: (_obj: any, args: AccountArgs, context: Context.Context & Context.WithInstance & Context.WithToken) => {
    fetch(`https://${context.instance}/api/v1/accounts/${args.id}`, {
      method: 'GET',
      headers: { Authorization: `Bearer ${context.token}` }
    })
    .then(Helpers.validateResponse)
    .then(({ data }) => data)
  }
}
