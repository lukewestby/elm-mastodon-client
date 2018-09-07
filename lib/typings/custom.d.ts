declare module '*.elm' {
  export const Elm: any
}

declare module '*.graphql' {
  const typeDefs: string
  export default typeDefs
}

declare module 'graphql-resolvers' {
  type ResolverFunction = (obj: any, args: any, context: any, info: any) => any
  export function combineResolvers(...resolvers: Array<ResolverFunction>): ResolverFunction
  export const skip: any
}

declare function requestIdleCallback(callback: () => void): number
declare function cancelIdleCallback(id: number | null): void
