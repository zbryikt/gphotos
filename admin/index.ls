angular.module \main
  ..filter \formatdate, -> -> 
    if !it => return "N/A"
    date = new Date it
    pad = -> if "#it".length < 2 => "0#it" else "#it"
    M = pad date.getMonth! + 1
    d = pad date.getDate!
    h = pad date.getHours!
    m = pad date.getMinutes!
    s = pad date.getSeconds!
    "#M/#d #h:#m:#s"
  ..controller \admin, 
  <[$scope $interval $timeout $firebaseArray $firebaseAuth backend]> ++ 
  ($scope, $interval, $timeout, $firebaseArray, $firebaseAuth, backend) ->
    $scope <<< backend{stream, user}
    $scope.backend = backend
    (authdata) <- backend.email \admin@tw-events.com, \admin .then
    $scope.admin = authdata
    $scope.vote = do
      start: backend.config.start or null
      getstart: -> 
        if !@start => 
          @start = new Date!getTime!
          backend.config.start = @start
          backend.config.$save!
      dur: backend.config.dur or 120
      update: ->
        backend.config.dur = @dur
        backend.config.$save!
    $scope.backend = backend
    $scope.$watch 'backend.config', ->
      $scope.vote.start = backend.config.start or null
      $scope.vote.dur = backend.config.dur or 120
    $scope.upload = do
      concurrent-count: 2
      progress: {}
      queue: []
      current: []
      url: \/d/pic
      _handler: (payload) ->
        <~ storage.upload payload, payload.name, payload.type, payload.base64, ((p, e) ~> $scope.$apply ~>
          console.log "[PROGRESS] #{p.name} / LOADED: #{e.loaded} / TOTAL: #{e.total} / SIZE: #{p.size}"
          p.size = e.total
          p.progress = e.loaded
        ) .then _
        console.log "[UPLOADED] #{payload.name} (#{payload.size})"
        payload.progress = payload.size
        payload.loaded = true
        pad = -> if "#it".length < 6 => ("0"*(6 - "#it".length)) + "#it" else "#it"
        for i from 0 til @current.length => if @current[i].name == payload.name => 
          $scope.stream.$add do
            name: @current[i].name
            url: "https://storage.googleapis.com/thumbnail-gphotos/#{@current[i].name}"
            order: pad($scope.stream.length)
          @current.splice i,1
          $scope.upload.handle!
          break
      handle: (obj = null) ->
        if obj =>
          @queue.push @progress[obj.0]
          console.log "[QUEUEED] #{obj.0}"
        if @current.length >= @concurrent-count => return
        @current ++= @queue.splice(0, 2 - (@current.length))
        for payload in @current => 
          console.log "[PROCESS] #{payload.name}"
          @_handler payload
      sizing: []
      start-consumer-handle: null
      start: (file) ->
        file.name = encodeURIComponent(file.name)
        type = \image/jpeg
        ret = /\.([^.]+)$/.exec file.name
        if ret and ret.1 != \jpg => type = "image/#{ret.1}"
        @progress[file.name] = name: file.name, size: 0, type: type, file: file, img: \/img/default.gif
        @sizing.push @progress[file.name]
        if !@start-consumer-handle =>
          @start-consumer-handle = $interval (~> @start-consumer!), 1000
      start-consumer: ->
        @sizing = @sizing.filter -> !it.resized
        resizing = @sizing.filter(->it.resizing)
        if !resizing.length and @sizing.length => @loadfile @sizing.0

      loadfile: (item) ->
        console.log "load file #{item.name} ... "
        item.resizing = true
        fr = new FileReader!
        fr.onload = ~> 
          (img) <~ $scope.image.frombin fr.result, item.type .then
          (resized-dataurl) <~ $scope.image.resize img, 480 .then
          resized-binary = atob(resized-dataurl.substring(resized-dataurl.indexOf(\,) + 1))
          console.log [
            "[RESIZE] #{item.name} "
            "from: #{parseInt(fr.result.length/1000)}KB "
            "to: #{parseInt(resized-binary.length/1000)}KB"
          ].join("")
          imgnode = new Image!
          imgnode.src = resized-dataurl
          payload = [item.name, "image/jpeg", btoa(resized-binary)]
          data = JSON.stringify(payload)
          @progress[item.name] <<< do
            data: data, base64: payload.2,
            img: "data:#{payload.1};base64,#{payload.2}"
            resized: true, resizing: false
          $scope.upload.handle payload
        fr.readAsBinaryString item.file

    $(\#files).on \change, -> 
      filenode = $(\#files).0
      console.log "[UPLOAD] #{filenode.files.length} files.."
      promises = []
      start = (file) -> $scope.$apply -> $scope.upload.start file
      for i from 0 til filenode.files.length =>
        file = filenode.files[i]
        start file

    $scope.image = do
      init: ->
        @input = document.createElement \canvas
        @output = document.createElement \canvas
        @inctx = @input.getContext \2d
        @outctx = @input.getContext \2d
      # cubic resize until close to target size
      resize: (image, width, height) -> new Promise (res, rej) ~>
        if width => height := ( width / image.width ) * image.height
        else if height => width := ( height / image.height ) * image.width
        else [width, height] := [image.width, image.height]
        [cw,ch,tw,th] = [image.width, image.height, width, height]
        shrink = (cimg, cw,ch) ~>
          final = if cw / 2 <= tw or ch / 2 <= th => true else false
          iw = if final => tw else cw / 2
          ih = if final => th else ch / 2
          @input <<< {width: iw, height: ih}
          @inctx.drawImage cimg, 0, 0, iw, ih
          if !final => 
            ret = @input.toDataURL \image/jpeg, 1.0
            nimg = new Image!
            nimg.onload = ~> shrink nimg, iw, ih
            nimg.src = ret
          else => 
            ret = @input.toDataURL \image/jpeg, 0.85
            res ret
        shrink image, cw, ch
      # implementation from limby-resize
      /*
      resize: (image, width, height) -> new Promise (res, rej) ~>
        if width => height := ( width / image.width ) * image.height
        else if height => width := ( height / image.height ) * image.width
        else [width, height] := [image.width, image.height]
        @input <<< {width: image.width, height: image.height}
        @inctx.drawImage image, 0, 0, image.width, image.height
        @output <<< {width, height}
        <~ canvas-resize @input, @output, _
        res @output.toDataURL \image/jpeg, 0.85
      */
      frombin: (binary, type) -> new Promise (res, rej) ->
        img = new Image!
        img.onload = -> res img
        img.src = "data:#{type};base64,#{btoa(binary)}"
    $scope.image.init!
    storage.init!then -> $scope.inited = true
    $scope.trash = (photo) ->
      backend.stream.$remove photo
