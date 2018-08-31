// This is to trick TypeScript into thinking this is a ServiceWorker module until
// it gets full first class support
import {} from './Worker'
declare var self: ServiceWorkerGlobalScope

import { graphql } from 'graphql'
import schema from './Schema'

interface RequestParams {
  query: string | null,
  variables: { [varName: string]: any } | null,
  operationName: string | null
}

const getParams = async (request: Request): Promise<RequestParams> => {
  try {
    const body = await request.json()
    if (typeof body !== 'object' || body === null) throw Error('Not an object body')
    return {
      query: typeof body.query === 'string' ? body.query : null,
      variables: typeof body.variables === 'object' ? body.variables : null,
      operationName: typeof body.operationName === 'string' ? body.operationName : null
    }
  } catch (e) {
    return {
      query: null,
      variables: null,
      operationName: null
    }
  }
}

const exec = async (request: Request): Promise<Response> => {
  try {
    const params = await getParams(request)
    const result = await graphql(schema, params.query, null, {}, params.variables, params.operationName)
    return new Response(JSON.stringify(result))
  } catch (error) {
    return new Response(error.message, { status: 500 })
  }
}

self.addEventListener('install', (event: ExtendableEvent) => {
  return event.waitUntil(self.skipWaiting())
})

self.addEventListener('activate', (event: ExtendableEvent) => {
  return self.clients.claim()
})

self.addEventListener('fetch', (event: FetchEvent) => {
  if (event.request.method === 'POST' && event.request.url.includes('/virtual/api')) {
    event.respondWith(exec(event.request))
  } else {
    event.respondWith(fetch(event.request))
  }
})

export default () => Promise.resolve()
