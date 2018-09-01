import * as Types from '../Types/Dsl'
import * as Helpers from '../../Helpers'

const INSTANCE_SOCIAL_TOKEN = 'narCDHH9MJhnzjYN0SAv2A3Pk90qlTxl7jxOYv2yvY0RsfYnt7OPRri6CmQ03NpX8qPnoxcE9INU7YO3j7o0Iykcw1PniXhWMBqHYLLK85J1eDMp1Z7T8OXp92pnihQq'

export const field = {
  type: Types.nonNullList(Types.string),
  args: {
    query: { type: Types.nonNull(Types.string) }
  },
  resolve: (_obj: any, args: { query: string }) => {
    const url = new URL('https://instances.social/api/1.0/instances/search')
    url.searchParams.append('q', args.query)
    url.searchParams.append('count', '10')
    url.searchParams.append('name', 'true')
    return fetch(url.href, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${INSTANCE_SOCIAL_TOKEN}` }
    })
    .then(Helpers.validateResponse)
    .then(({ data }) => data.instances.map((i: any) => i.name))
  }
}
