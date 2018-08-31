import * as Types from './Dsl'

export interface ApiEmoji {
  shortcode: string,
  static_url: string,
  url: string,
  visible_in_picker: boolean
}

export default Types.object({
  name: 'Emoji',
  fields: {
    shortcode: { type: Types.nonNull(Types.string) },
    url: { type: Types.nonNull(Types.string) },
    staticUrl: {
      type: Types.nonNull(Types.string),
      resolve: (emoji: ApiEmoji) => emoji.static_url
    },
    visibleInPicker: {
      type: Types.nonNull(Types.boolean),
      resolve: (emoji: ApiEmoji) => emoji.visible_in_picker
    }
  }
})
