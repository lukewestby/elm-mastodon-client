import * as Types from './Dsl'

interface ApiClient {
  id: string,
  name: string,
  client_id: string,
  client_secret: string,
  redirect_uri: string
}

export default Types.object({
  name: 'Client',
  fields: {
    id: { type: Types.nonNull(Types.id) },
    name: { type: Types.nonNull(Types.string) },
    redirect: {
      type: Types.nonNull(Types.string),
      resolve: (client: ApiClient) => client.redirect_uri
    },
    clientId: {
      type: Types.nonNull(Types.string),
      resolve: (client: ApiClient) => client.client_id
    },
    clientSecret: {
      type: Types.nonNull(Types.string),
      resolve: (client: ApiClient) => client.client_secret
    },
  }
})
