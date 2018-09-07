const camelCase = (string: string) => {
  return string.replace(/(\_\w)/g, m => m[1].toUpperCase())
}

export const camelCaseKeys = (obj: any): any => {
  if (typeof obj === 'object' && obj !== null && Object.prototype.toString.call(obj) === '[Object object]') {
    return Object.keys(obj).reduce((memo: { [key: string]: any }, next) => {
      memo[next] = camelCaseKeys(obj[next])
      return memo
    }, {})
  } else if (Array.isArray(obj)) {
    return obj.map(camelCaseKeys)
  } else {
    return obj
  }
}

export const log = (a: any): any => {
  console.log(a)
  return a
}

const linkHeaderEntry = /<([^>]+)>;\s*rel="([^"]+)"/

export const parseLinkHeader = (string: string) => {
  return string.split(/,\s*/).reduce((acc: any, entry: string) => {
    const parsed = entry.match(linkHeaderEntry)
    const url = parsed[1]
    const rel = parsed[2]
    acc[rel] = new URL(url)
    return acc
  }, {})
}

export const validateResponse = (response: Response): Promise<{ data: any, links: { [key: string]: URL } }> => {
  if (response.status < 200 || response.status >= 400) {
    return response.json().then((data: any) => {
      if (typeof data.error === 'string') return Promise.reject(Error(data.error))
      else return Promise.reject(Error('Request failed'))
    })
  }

  return response.json().then((data: any) => ({
    data,
    links: response.headers.has('link') ? parseLinkHeader(response.headers.get('link')) : {}
  }))
}


export const logError = (error: Error) => {
  console.error(error)
  return Promise.reject(error)
}
