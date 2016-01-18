angular.module \main
  ..controller \upload, 
  <[$scope $interval $timeout $firebaseArray $firebaseAuth backend]> ++ 
  ($scope, $interval, $timeout, $firebaseArray, $firebaseAuth, backend) ->
    $scope <<< backend{stream, user}
    $scope.upload = do
      concurrent-count: 2
      progress: {}
      queue: []
      current: []
      url: \/d/pic
      _handler: (payload) ->
        ret = /\.([^.]+)$/.exec(payload.name)
        if !ret => type = \image/jpeg
        if ret.1 == \jpg => type = \image/jpeg
        type = "image/#{ret.1}"
        <~ storage.upload payload, payload.name, type, payload.base64, ((p, e) ~> $scope.$apply ~>
          console.log "[PROGRESS] #{p.name} / LOADED: #{e.loaded} / TOTAL: #{e.total} / SIZE: #{p.size}"
          p.size = e.total
          p.progress = e.loaded
        ) .then _
        console.log "[UPLOADED] #{payload.name} (#{payload.size})"
        payload.progress = payload.size
        for i from 0 til @current.length => if @current[i].name == payload.name => 
          $scope.stream.$add do
            name: @current[i].name
            url: "https://storage.googleapis.com/thumbnail-gphotos/#{@current[i].name}"
          @current.splice i,1
          $scope.upload.handle!
          break
      handle: (obj = null) ->
        if obj =>
          data = JSON.stringify(obj)
          @progress[obj.0] = item = {name: obj.0, size: data.length, data, base64: obj.1, img: "data:image/png;base64,#{obj.1}"}
          @queue.push item
          console.log "[QUEUEED] #{obj.0}"
        if @current.length >= @concurrent-count => return
        @current ++= @queue.splice(0, 2 - (@current.length))
        for payload in @current => 
          console.log "[PROCESS] #{payload.name}"
          @_handler payload

    loadfile = (file) ->
      console.log "load file #{file.name} ... "
      fr = new FileReader!
      fr.onload = -> 
        file.name = encodeURIComponent(file.name)
        $scope.upload.handle [file.name, btoa(fr.result)]
      fr.readAsBinaryString file
    $(\#files).on \change, -> 
      filenode = $(\#files).0
      console.log "[UPLOAD] #{filenode.files.length} files.."
      promises = []
      for i from 0 til filenode.files.length =>
        file = filenode.files[i]
        loadfile file

    storage.init!
