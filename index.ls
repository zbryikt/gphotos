angular.module \main, <[firebase]>
  ..directive \isotope, -> do
    restrict: \A
    link: (scope, e, attrs, ctrl) ->
      des = $(e.0.parentNode.parentNode.parentNode)
      des.addClass \iso
      if e.prop(\tagName) == \IMG => e.load ->
        des.addClass \iso-show
        scope.isotope.ctrl.appended des.0
        scope.$on \$destroy ->
          scope.isotope.ctrl.remove des.0
          scope.isotope.ctrl.layout!
      else
        scope.isotope.ctrl.appended e.0.parentNode.parentNode.parentNode
        scope.$on \$destroy ->
          scope.isotope.ctrl.remove e.0.parentNode.parentNode.parentNode
          scope.isotope.ctrl.layout!
  ..filter \rank, -> (order) -> (<[1st 2nd 3rd 4th 5th]>[order] or order)
  ..filter \likecheck, -> (hash) -> 
    [k for k of hash].filter(->hash[it].value)
  ..filter \decode, -> -> atob(it)
  ..filter \count, -> (hash)-> [k for k of hash].filter(->hash{}[it].value).length
  ..filter \escape, -> -> 
    if !it => return it
    idx = it.lastIndexOf(\/) + 1
    path = it.substring(0,idx)
    name = it.substring(idx)
    "#path#{encodeURIComponent(name)}"

  ..service \backend,
  <[$rootScope $firebaseArray $firebaseObject $firebaseAuth]> ++
  ($rootScope, $firebaseArray, $firebaseObject, $firebaseAuth) ->
    ret = do
      inited: false
      scren: []
      user: {}
      auth: {}
      ref: {}
      init: ->
        @ref.root = new Firebase(\https://gphotos.firebaseio.com/)
        @ref.stream = new Firebase(\https://gphotos.firebaseio.com/stream)
        @ref.config = new Firebase(\https://gphotos.firebaseio.com/config)
        @auth = $firebaseAuth @ref.root
        @stream = $firebaseArray @ref.stream
        @config = $firebaseObject @ref.config
        @user = @auth.$getAuth!
        if !@user => 
          (ret) <~ @auth.$authAnonymously!then
          @user = ret
          @getinfo!
        else @getinfo!
      getinfo: ->
        @ref.user = new Firebase("https://gphotos.firebaseio.com/user/#{@user.uid}/")
        @info = $firebaseObject @ref.user
        @info.$loaded!then ~> @inited = true
      email: (email, password) ->
        @auth.$authWithPassword({email, password})

    if !ret.inited => ret.init!
    ret

  ..controller \rank,
  <[$scope $interval $timeout backend]> ++
  ($scope, $interval, $timeout, backend) ->
    $scope.backend = backend
    update = (->
      stream = backend.stream.map(
        (p)-> {like: p.like, url: p.url, count: [k for k of p.like].filter(->p.like[it].value).length}
      ).filter(->it.url)
      stream.sort((a,b)-> b.count - a.count)
      $scope.stream = stream.splice 0,5
      $scope.inited = true
    )
    $interval update, 2000
    $(window).on \resize, -> $scope.$apply ->
      img-height = $(".prj-row img").height!
      win-height = $(window).height!
      $scope.prjrowheight = ( win-height - img-height ) / 2
    $scope.backhome = ->
      window.location.href = "/"

  ..controller \main, 
  <[$scope $interval $timeout $firebaseArray $firebaseObject $firebaseAuth backend]> ++
  ($scope, $interval, $timeout, $firebaseArray, $firebaseObject, $firebaseAuth, backend) ->
    $scope.backend = backend
    pad = -> it = ("0" * (4 - "#it".length)) + "#it"

    $scope.full = do
      photo: null
      set: -> @ <<< {photo: it, show: true}
      show: false

    $scope.like = (entry, e, force-dislike = false) -> 
      if !backend.user or !entry.$id => return 
      if $scope.tick.end or !$scope.tick.start => return
      userinfo = $scope.backend.info #$scope.backend.{}info{}[backend.user.uid]
      userlikes = [k for k of userinfo.{}like].filter(->userinfo.{}like[it].value).length
      targetlike = entry.{}like{}[backend.user.uid].value
      if userlikes < 3 or targetlike or force-dislike => 
        entrylike = $firebaseObject(
          new Firebase("https://gphotos.firebaseio.com/stream/#{entry.$id}/like/#{backend.user.uid}")
        )
        <- entrylike.$loaded!then 
        entrylike.value = !!!(entry.{}like{}[backend.user.uid].value)
        if force-dislike => entrylike.value = false
        entrylike.$save!
        userinfo.{}like[btoa(entry.url)] = {value: entrylike.value}
        userinfo.$save!
      else $scope.revote = true 
      if e => 
        e.prevent-default!
        e.stop-propagation!
        return false

    $scope.backtop = ->
      $(document.body).animate({scrollTop: 0}, '500', 'swing', ->)
    $scope.isotope = do
      obj: null
      init: ->
        if !$(\#layout)0 => return
        if $scope.isotope.ctrl => $scope.isotope.ctrl.destroy!
        $scope.isotope.ctrl = new Isotope $(\#layout)0, do
          itemSelector: \.x-card
          layoutMode: \masonry
          getSortData: weight: '[data-order]'
          sortBy: 'weight'
          sortAscending: false
      update: -> if $scope.isotope.ctrl =>
        $timeout (~> $scope.isotope.ctrl.arrange {filter: "*"}), 100
        $timeout (~> $scope.isotope.ctrl.arrange {filter: "*"}), 1000

    $scope.$watch 'backend.stream', (->
      if $scope.last-length != $scope.backend.stream.length =>
        $scope.isotope.update!
        $scope.last-length = $scope.backend.stream.length
    ), true

    $scope.isotope.init!

    $scope.tick = do
      hrs: 0
      min: 0
      sec: 0
      start: null
      dur: 2 * 60 * 60 * 1000
      end: false
      count: ->
        @dur = ((backend.config.dur) or 120 ) * 60 * 1000
        @start = backend.config.start
        if !@start => return
        diff = parseInt((@dur - (new Date!getTime! - @start))/1000)
        if diff < 0 => diff = 0
        @sec = diff % 60
        @min = parseInt(diff / 60) % 60
        @hrs = parseInt((diff - (diff % 3600))/3600)
        @end = (diff <= 0)
    $scope.remove = (url) ->
      photo = $scope.backend.stream.filter(->it.url == atob(url)).0
      if !photo => return
      $scope.like(photo, null, true)
    $interval (-> $scope.tick.count!), 1000
    $scope.inited = true

window.onSignIn = (user) ->
  profile = user.getBasicProfile!
  console.log profile
