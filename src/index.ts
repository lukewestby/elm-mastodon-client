import * as Server from './Server'
import * as Client from './Client'

Server.start()
  .then(() => Client.start())
  .catch(e => console.error(e))
