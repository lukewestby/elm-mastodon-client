import { Elm } from './Main.elm'

type PortMessage =
  | { tag: 'SaveSession', data: any }

export const start = () => {
  const session: any | null = localStorage.getItem('Mastodon.session') ? JSON.parse(localStorage.getItem('Mastodon.session')) : null
  
  const app = Elm.Main.init({ flags: session })

  app.ports.outbound.subscribe((message: PortMessage) => {
    switch (message.tag) {
      case 'SaveSession':
        localStorage.setItem('Mastodon.session', JSON.stringify(message.data))
        return
    }
  })
}
