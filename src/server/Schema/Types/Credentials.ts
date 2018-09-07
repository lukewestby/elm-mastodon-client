import * as Types from './Dsl'

interface ApiCredentials {
  access_token: string,
}

export default Types.object({
  name: 'Credentials',
  fields: {
    token: {
      type: Types.nonNull(Types.string),
      resolve: (credentials: ApiCredentials) => credentials.access_token
    }
  }
})
