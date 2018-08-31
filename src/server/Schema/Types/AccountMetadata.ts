import * as Types from './Dsl'

export interface ApiAccountMetadata {
  name: string,
  value: string
}

export default Types.object({
  name: 'AccountMetadata',
  fields: {
    name: { type: Types.nonNull(Types.string) },
    value: { type: Types.nonNull(Types.string) }
  }
})
