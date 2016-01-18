angular.module \main, <[firebase]>
  ..directive \isotope, -> do
    restrict: \A
    link: (scope, e, attrs, ctrl) ->
      des = $(e.0.parentNode.parentNode.parentNode)
      des.addClass \iso
      if e.prop(\tagName) == \IMG => e.load ->
        des.addClass \iso-show
        scope.isotope.appended des.0
        scope.$on \$destroy ->
          scope.isotope.remove des.0
          scope.isotope.layout!
      else
        scope.isotope.appended e.0.parentNode.parentNode.parentNode
        scope.$on \$destroy ->
          scope.isotope.remove e.0.parentNode.parentNode.parentNode
          scope.isotope.layout!

  ..controller \main, <[$scope $firebaseArray $firebaseAuth]> ++ ($scope, $firebaseArray, $firebaseAuth) ->
    ref = new Firebase(\https://gphotos.firebaseio.com)
    $scope.stream = $firebaseArray ref
    $scope.auth = $firebaseAuth ref
    $scope.user = $scope.auth.$getAuth!
    if !$scope.user =>
      $scope.auth.$authAnonymously!then (ret) -> $scope.user = ret
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
        <~ storage.upload payload.name, type, payload.base64, ((e) ~> $scope.$apply ~>
          payload.progress = e.loaded
        ) .then _
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
        if @current.length >= @concurrent-count => return
        @current ++= @queue.splice(0, 2 - (@current.length))
        for payload in @current => 
          console.log "handle #{payload.name}..."
          @_handler payload

    loadfile = (file) ->
      console.log "load file #{file.name} ... "
      fr = new FileReader!
      fr.onload = -> 
        console.log "file #{file.name} loaded. sending to upload queue..."
        $scope.upload.handle [file.name, btoa(fr.result)]
      fr.readAsBinaryString file

    $(\#files).on \change, -> 
      filenode = $(\#files).0
      console.log "file list changed..."
      promises = []
      for i from 0 til filenode.files.length =>
        file = filenode.files[i]
        loadfile file

    $scope.init-isotope = ->
      if $scope.isotope => $scope.isotope.destroy!
      $scope.isotope = new Isotope $(\#layout)0, do
        itemSelector: \.thumbnail
        layoutMode: \masonry
        getSortData: weight: '[data-order]'
        sortBy: 'weight'
        sortAscending: false
    $scope.init-isotope!
    setTimeout (->
      $scope.isotope.arrange {filter: "*"}
    ),2000
    $scope.ids = []
    storage.init!
    $scope.like = (entry) -> 
      if !$scope.user => return 
      idx = entry.[]like.indexOf($scope.user.uid)
      if idx < 0 => entry.[]like.push $scope.user.uid
      else entry.[]like.splice idx, 1
      $scope.stream.$save entry

window.onSignIn = (user) ->
  profile = user.getBasicProfile!
  console.log profile
