import registerServiceWorker from './worker'

export const start = () => {
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
