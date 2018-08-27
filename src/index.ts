import registerServiceWorker from './server/index'

const loadServiceWorker = () => {
  return registerServiceWorker()
    .then(() => navigator.serviceWorker.ready)
    .then(reg => {
      return new Promise((resolve) => {
        function resolveControllerReady(count: number) {
          count++;
          if(count > 10) {
            window.location.reload()
          } else {
            if (navigator.serviceWorker.controller) {
              resolve();
            } else {
              return setTimeout(()=>{
                resolveControllerReady(count)
              }, 100)
            }
          }
        }
        resolveControllerReady(0)
      })
  })
}

loadServiceWorker()
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

