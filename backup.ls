
config = do
  api-key: \AIzaSyAsOeIrUa3kSbvHnH0LpjmFfRwAIqRv6q8
  oauth-client-id: \1023821193205-56dpmkeqjob0abkskrv3hkmkchomorl1.apps.googleusercontent.com
  oauth-client-secret: \ouPZLLCivRYaQl9hK3f7l_Pc
  member-group-id: \00b4903a9758a234e8fe33c6ca03cf283bfd270360d057e4da85d2cf96c8217f
  project-id: \gphotos-1181
  scope: 'https://www.googleapis.com/auth/devstorage.full_control'
  version: \v1
  bucket: \thumbnail-gphotos

<- $ document .ready
<- setTimeout _, 1000
gapi.client.setApiKey config.api-key
<- setTimeout _, 1000
(ret) <- gapi.auth.authorize {
  client_id: config.oauth-client-id
  scope: config.scope
  immediate: false
}, _
console.log ret
gapi.client.load \storage, config.version
<- setTimeout _, 1000
# list buckets
#request = gapi.client.storage.buckets.list project: config.project-id
# create buckets
#request = gapi.client.storage.buckets.insert project: config.project-id, resource: name: \thumbnail-gphotos

data = "/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAABLAAD/7gAOQWRvYmUAZMAAAAAB/9sAhAADAgICAgIDAgIDBQMDAwUFBAMDBAUGBQUFBQUGCAYHBwcHBggICQoKCgkIDAwMDAwMDg4ODg4QEBAQEBAQEBAQAQMEBAYGBgwICAwSDgwOEhQQEBAQFBEQEBAQEBEREBAQEBAQERAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAAUABQDAREAAhEBAxEB/8QAhAAAAwEBAAAAAAAAAAAAAAAAAwUGBAcBAAICAwAAAAAAAAAAAAAAAAQFAwcCBggQAAAEBQEFCQAAAAAAAAAAAAERAgMAEhMEBQYhIxQWBzFBUWFiQxUmFxEAAQIEAwYFBQAAAAAAAAAAAQACERIDBDFBBSETFBUGB1FhIjIWoUKCIyX/2gAMAwEAAhEDEQA/ACdK+l2E1hhrjJ5V9cwLFtttsSlIO0YSajqFSg8NaF0n3E7g3+i3rLe3YIETEuGPkFz7UuKbwedvcS05WRbOKQlwO8Ah3QqGpTDjmrq0HUXX+n0rlzZS9oJCWQQn6Y4vUObwqXEYq8ctkugTiW1EAxBUoU6nuEUj1DRLG+LTcUmvLcIjBWfS/p3a6/cvb3LXa0IZEAEEELilK2mIjCrUL42wAaMVVvcDrer062lStqQJcM/aAMtiB+aNfo3JfGbg5q5BNIRkXjGfHnht7Daivnr/AIzzXdevCXKbDHwUFDlXIqbRHPHFvclVqsu/pFKXqm2Qvu+HlG9hBaF1byHct5rJLH0zYx8obVl+280e/wDOVPOtUiT9O6yk+iP/AI/Kvs4SX8JV/9k="

boundary = "-------314159265358979323846"
delimiter = "\r\n--#boundary\r\n"
close_delim = "\r\n--#{boundary}--"

contentType= "image/jpeg"

metadata = do
  name: "sample.png"
  mimeType: contentType


payload = [
  delimiter,
  "Content-Type: application/json\r\n\r\n",
  JSON.stringify(metadata),
  delimiter,
  "Content-Type: #contentType\r\n",
  "Content-Transfer-Encoding: base64\r\n",
  "\r\n",
  data,
  "\r\n--#{boundary}--"
].join("")

request = gapi.client.request do
  path: "/upload/storage/#{config.version}/b/#{config.bucket}/o"
  method: \POST
  params: uploadType: \multipart
  headers: "Content-Type": "multipart/mixed; boundary=\"#boundary\""
  body: payload

(res) <- request.execute 
console.log res

