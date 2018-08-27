import * as Server from './server'

Server
  .start()
  .then(() => {
    
    fetch('/virtual/api', {
      method: "POST",
      mode: "no-cors",
      headers: {
        "Content-Type": "application/json; charset=utf-8"
      },
      body: JSON.stringify({ query: `{ instanceSearch(query: "mastodon.technology") }` }),
    })
    .then(response => response.json())
    .then(r => console.log(r))
    .catch(e => console.error(e))
    
  })
  .catch(e => console.error(e))

