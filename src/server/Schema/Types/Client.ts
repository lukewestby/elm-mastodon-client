import * as Types from './Dsl'

interface ApiClient {
  id: string,
  client_id: string,
  client_secret: string
}

export default Types.object({
  name: 'Client',
  fields: {
    id: { type: Types.nonNull(Types.id) },
    clientId: {
      type: Types.nonNull(Types.string),
      resolve: (client: ApiClient) => client.client_id
    },
    clientSecret: {
      type: Types.nonNull(Types.string),
      resolve: (client: ApiClient) => client.client_secret
    }
  }
})
