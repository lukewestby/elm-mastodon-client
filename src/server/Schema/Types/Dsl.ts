import {
  GraphQLObjectType,
  GraphQLString,
  GraphQLID,
  GraphQLNonNull,
  GraphQLObjectTypeConfig,
  GraphQLType,
  GraphQLList,
  GraphQLInt,
  GraphQLFloat,
  GraphQLBoolean
} from 'graphql'

export const id = GraphQLID
export const string = GraphQLString
export const int = GraphQLInt
export const float = GraphQLFloat
export const boolean = GraphQLBoolean
export const object = (info: GraphQLObjectTypeConfig<any, any>) => new GraphQLObjectType(info)
export const nonNull = (type: GraphQLType) => new GraphQLNonNull(type)
export const nonNullList = (type: GraphQLType) => new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(type)))
export const page = (type: GraphQLObjectType) => object({
  name: type.name + 'Page',
  fields: {
    nextId: { type: id },
    previousId: { type: id },
    total: { type: nonNull(int) },
    [type.name[0].toLowerCase() + type.name.slice(1) + 's']: { type: nonNullList(type) }
  }
})
