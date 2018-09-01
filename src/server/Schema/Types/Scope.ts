import * as Types from './Dsl'

export enum ApiScope {
  Read = 'read',
  Write = 'write',
  Follow = 'follow'
}


export default Types.enum_('Scope', {
  READ: ApiScope.Read,
  WRITE: ApiScope.Write,
  FOLLOW: ApiScope.Follow
})
