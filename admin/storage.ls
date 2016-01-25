# sample code
# list buckets
#request = gapi.client.storage.buckets.list project: config.project-id
# create buckets
#request = gapi.client.storage.buckets.insert project: config.project-id, resource: name: \thumbnail-gphotos
# sampel data
#
# doc url
# upload obj https://cloud.google.com/storage/docs/json_api/v1/how-tos/upload
# insert action params: https://cloud.google.com/storage/docs/json_api/v1/objects/insert
# wrapped example: https://cloud.google.com/storage/docs/json_api/v1/json-api-javascript-samples
#  - https://developers.google.com/api-client-library/javascript/reference/referencedocs
# http://stackoverflow.com/questions/31659414/access-denied-error-when-using-gapi-auth-authorize
#  - need immediate = false
data = "/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAABLAAD/7gAOQWRvYmUAZMAAAAAB/9sAhAADAgICAgIDAgIDBQMDAwUFBAMDBAUGBQUFBQUGCAYHBwcHBggICQoKCgkIDAwMDAwMDg4ODg4QEBAQEBAQEBAQAQMEBAYGBgwICAwSDgwOEhQQEBAQFBEQEBAQEBEREBAQEBAQERAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAAUABQDAREAAhEBAxEB/8QAhAAAAwEBAAAAAAAAAAAAAAAAAwUGBAcBAAICAwAAAAAAAAAAAAAAAAQFAwcCBggQAAAEBQEFCQAAAAAAAAAAAAERAgMAEhMEBQYhIxQWBzFBUWFiQxUmFxEAAQIEAwYFBQAAAAAAAAAAAQACERIDBDFBBSETFBUGB1FhIjIWoUKCIyX/2gAMAwEAAhEDEQA/ACdK+l2E1hhrjJ5V9cwLFtttsSlIO0YSajqFSg8NaF0n3E7g3+i3rLe3YIETEuGPkFz7UuKbwedvcS05WRbOKQlwO8Ah3QqGpTDjmrq0HUXX+n0rlzZS9oJCWQQn6Y4vUObwqXEYq8ctkugTiW1EAxBUoU6nuEUj1DRLG+LTcUmvLcIjBWfS/p3a6/cvb3LXa0IZEAEEELilK2mIjCrUL42wAaMVVvcDrer062lStqQJcM/aAMtiB+aNfo3JfGbg5q5BNIRkXjGfHnht7Daivnr/AIzzXdevCXKbDHwUFDlXIqbRHPHFvclVqsu/pFKXqm2Qvu+HlG9hBaF1byHct5rJLH0zYx8obVl+280e/wDOVPOtUiT9O6yk+iP/AI/Kvs4SX8JV/9k="

storage = do
  config: do
    api-key: \AIzaSyAsOeIrUa3kSbvHnH0LpjmFfRwAIqRv6q8
    oauth-client-id: \1023821193205-56dpmkeqjob0abkskrv3hkmkchomorl1.apps.googleusercontent.com
    oauth-client-secret: \ouPZLLCivRYaQl9hK3f7l_Pc
    member-group-id: \00b4903a9758a234e8fe33c6ca03cf283bfd270360d057e4da85d2cf96c8217f
    project-id: \gphotos-1181
    scope: 'https://www.googleapis.com/auth/devstorage.full_control'
    version: \v1
    bucket: \thumbnail-gphotos

  _init: (res, rej) -> 
    if !gapi.client => return setTimeout (~> @_init res,rej ), 100
    gapi.client.setApiKey @config.api-key
    <~ setTimeout _, 1000
    (ret) <~ gapi.auth.authorize {
      client_id: @config.oauth-client-id
      scope: @config.scope
      immediate: false
    }, _
    @token = ret
    console.log ">>>", ret
    gapi.client.load \storage, @config.version
    <~ setTimeout _, 500
    res @token

  init: -> new Promise (res, rej) ~> @_init res, rej

  upload: (p, name = "sample.jpg", type = "image/jpeg", content, progress) -> new Promise (res, rej) ~>
    boundary = "-------314159265358979323846"
    delimiter = "\r\n--#boundary\r\n"
    close_delim = "\r\n--#{boundary}--"
    metadata = name: name, mimeType: type
    payload = [
      delimiter,
      "Content-Type: application/json\r\n\r\n",
      JSON.stringify(metadata),
      delimiter,
      "Content-Type: #type\r\n",
      "Content-Transfer-Encoding: base64\r\n",
      "\r\n",
      content,
      "\r\n--#{boundary}--"
    ].join("")
    url = "https://www.googleapis.com/upload/storage/#{@config.version}/b/#{@config.bucket}/o?uploadType=multipart&predefinedAcl=publicRead"
    request = new XMLHttpRequest!
    request.open \POST, url, true
    request.setRequestHeader \Authorization, "Bearer #{@token.access_token}"
    request.setRequestHeader \Content-Type, "multipart/mixed; boundary=\"#boundary\""
    if progress? => request.onprogress = (e) -> progress p, e
    request.onload = -> res!
    request.send payload

/*
<- $ document .ready
<- storage.init!then
<- storage.upload \test3.jpg, \image/jpeg, data, ((e)-> console.log parseInt(100*(e.loaded / e.total))) .then
console.log \ok
*/
