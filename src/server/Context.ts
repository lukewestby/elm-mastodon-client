export interface Context {}

export interface WithToken {
  token: string
}

export interface WithInstance {
  instance: string
}

export const fromRequest = (request: Request): Promise<Context> => {
  const instance = request.headers.get('x-mastodon-instance')
  
  let token = request.headers.get('authorization')
  if (typeof token === 'string' && token.startsWith('Bearer ')) token = token.replace('Bearer ', '')
  else token = null

  return Promise.resolve({ token, instance })
}

export const requireToken = (_obj: any, _args: any, context: Context): Context & WithToken => {
  const asAny = context as any
  if (typeof asAny.token === 'string') return asAny as WithToken
  else throw Error('Unauthorized')
}

export const requireInstance = (_obj: any, _args: any, context: Context): Context & WithInstance => {
  const asAny = context as any
  if (typeof asAny.instance === 'string') return asAny as WithInstance
  else throw Error('No Mastodon instance')
}
