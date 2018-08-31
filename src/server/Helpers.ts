const camelCase = (string: string) => {
  return string.replace(/(\_\w)/g, m => m[1].toUpperCase())
}

export const camelCaseKeys = (obj: {[key: string]: any}) => {
  const output: {[key: string]: any} = {}
  Object.keys(obj).forEach(key => {
    output[camelCase(key)] = obj[key]
  })
  return output
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
