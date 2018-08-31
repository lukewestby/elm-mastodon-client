import * as Types from './Dsl'
import * as Context from '../../Context'
import * as Helpers from '../../Helpers'
import AccountMetadata, { ApiAccountMetadata } from './AccountMetadata'
import Emoji, { ApiEmoji } from './Emoji'

export interface ApiAccount {
  id: string,
  username: string,
  acct: string,
  display_name: string,
  locked: boolean,
  created_at: string,
  followers_count: number,
  following_count: number,
  statuses_count: number,
  note: string,
  url: string,
  avatar: string,
  avatar_static: string,
  header: string,
  header_static: string,
  emojis: Array<ApiEmoji>,
  moved?: boolean,
  fields?: Array<ApiAccountMetadata>,
  bot?: boolean
}

interface FollowersArgs {
  maxId: string | null,
  sinceId: string | null,
  limit: number | null
}

interface FollowingArgs {
  maxId: string | null,
  sinceId: string | null,
  limit: number | null
}

const Account = Types.object({
  name: 'Account',
  fields: () => ({
    id: { type: Types.nonNull(Types.id) },
    username: { type: Types.nonNull(Types.string) },
    locked: { type: Types.nonNull(Types.boolean) },
    url: { type: Types.nonNull(Types.string) },
    avatar: { type: Types.nonNull(Types.string) },
    header: { type: Types.nonNull(Types.string) },
    emojis: { type: Types.nonNullList(Emoji) },
    account: {
      type: Types.nonNull(Types.string),
      resolve: (account: ApiAccount) => account.acct
    },
    displayName: {
      type: Types.nonNull(Types.string),
      resolve: (account: ApiAccount) => account.display_name
    },
    biography: {
      type: Types.nonNull(Types.string),
      resolve: (account: ApiAccount) => account.note
    },
    avatarStatic: {
      type: Types.nonNull(Types.string),
      resolve: (account: ApiAccount) => account.avatar_static
    },
    headerStatic: {
      type: Types.nonNull(Types.string),
      resolve: (account: ApiAccount) => account.header_static
    },
    bot: {
      type: Types.nonNull(Types.boolean),
      resolve: (account: ApiAccount) => account.bot || false
    },
    moved: {
      type: Types.nonNull(Types.boolean),
      resolve: (account: ApiAccount) => account.moved || false
    },
    fields: {
      type: Types.nonNullList(AccountMetadata),
      resolve: (account: ApiAccount) => account.fields || []
    },
    followers: {
      type: Types.nonNull(AccountPage),
      args: {
        maxId: { type: Types.id },
        sinceId: { type: Types.id },
        limit: { type: Types.int }
      },
      resolve: (account: ApiAccount, args: FollowersArgs, context: Context.Context & Context.WithInstance & Context.WithToken) => {
        const url = new URL(`https://${context.instance}/api/v1/${account.id}/followers`)
        if (args.limit) url.searchParams.append('limit', args.limit.toString())
        if (args.maxId) url.searchParams.append('max_id', args.maxId)
        if (args.sinceId) url.searchParams.append('since_id', args.sinceId)
        fetch(url.href, {
          method: 'GET',
          headers: { 'Authorization': `Bearer ${context.token}` }
        })
        .then(Helpers.validateResponse)
        .then(({ links, data }) => ({
          nextId: links.hasOwnProperty('next') ? links.next.searchParams.get('max_id') : null,
          previousId: links.hasOwnProperty('prev') ? links.prev.searchParams.get('since_id') : null,
          total: account.followers_count,
          accounts: data
        }))
      }
    },
    following: {
      type: Types.nonNull(AccountPage),
      args: {
        maxId: { type: Types.id },
        sinceId: { type: Types.id },
        limit: { type: Types.int }
      },
      resolve: (account: ApiAccount, args: FollowingArgs, context: Context.Context & Context.WithInstance & Context.WithToken) => {
        const url = new URL(`https://${context.instance}/api/v1/${account.id}/following`)
        if (args.limit) url.searchParams.append('limit', args.limit.toString())
        if (args.maxId) url.searchParams.append('max_id', args.maxId)
        if (args.sinceId) url.searchParams.append('since_id', args.sinceId)
        fetch(url.href, {
          method: 'GET',
          headers: { 'Authorization': `Bearer ${context.token}` }
        })
        .then(Helpers.validateResponse)
        .then(({ links, data }) => ({
          nextId: links.hasOwnProperty('next') ? links.next.searchParams.get('max_id') : null,
          previousId: links.hasOwnProperty('prev') ? links.prev.searchParams.get('since_id') : null,
          total: account.following_count,
          accounts: data
        }))
      }
    }
  })
})

export const AccountPage = Types.page(Account)

export default Account

// id: String!
// username: String!
// account: String!
// displayName: String!
// locked: Boolean!
// biography: String!
// url: String!
// avatar: String!
// avatarStatic: String!
// header: String!
// headerStatic: String!
// emojis: [Emoji!]!
// fields: [AccountMetadata!]!
// bot: Boolean!
// statuses(onlyMedia: Boolean, pinned: Boolean, excludeReplies: Boolean, maxId: String, sinceId: String, limit: Int): StatusList!
// followers(maxId: String, sinceId: String, limit: Int): AccountList!
// following(maxId: String, sinceId: String, limit: Int): AccountList!
