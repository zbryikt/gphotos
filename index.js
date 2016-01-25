function repeatString$(t,e){for(var r="";e>0;(e>>=1)&&(t+=t))1&e&&(r+=t);return r}var x$;x$=angular.module("main",["firebase"]),x$.directive("isotope",function(){return{restrict:"A",link:function(t,e){var r;return r=$(e[0].parentNode.parentNode.parentNode),r.addClass("iso"),"IMG"===e.prop("tagName")?e.load(function(){return r.addClass("iso-show"),t.isotope.ctrl.appended(r[0]),t.$on("$destroy",function(){return t.isotope.ctrl.remove(r[0]),t.isotope.ctrl.layout()})}):(t.isotope.ctrl.appended(e[0].parentNode.parentNode.parentNode),t.$on("$destroy",function(){return t.isotope.ctrl.remove(e[0].parentNode.parentNode.parentNode),t.isotope.ctrl.layout()}))}}}),x$.filter("rank",function(){return function(t){return["1st","2nd","3rd","4th","5th"][t]||t}}),x$.filter("likecheck",function(){return function(t){var e;return function(){var r=[];for(e in t)r.push(e);return r}().filter(function(e){return t[e].value})}}),x$.filter("decode",function(){return function(t){return atob(t)}}),x$.filter("count",function(){return function(t){var e;return function(){var r=[];for(e in t)r.push(e);return r}().filter(function(e){return(t[e]||(t[e]={})).value}).length}}),x$.filter("escape",function(){return function(t){var e,r,n;return t?(e=t.lastIndexOf("/")+1,r=t.substring(0,e),n=t.substring(e),r+""+encodeURIComponent(n)):t}}),x$.service("backend",["$rootScope","$firebaseArray","$firebaseObject","$firebaseAuth"].concat(function(t,e,r,n){var i;return i={inited:!1,scren:[],user:{},auth:{},ref:{},init:function(){var t=this;return this.ref.root=new Firebase("https://gphotos.firebaseio.com/"),this.ref.stream=new Firebase("https://gphotos.firebaseio.com/stream"),this.ref.config=new Firebase("https://gphotos.firebaseio.com/config"),this.auth=n(this.ref.root),this.stream=e(this.ref.stream),this.config=r(this.ref.config),this.user=this.auth.$getAuth(),this.user?this.getinfo():this.auth.$authAnonymously().then(function(e){return t.user=e,t.getinfo()})},getinfo:function(){var t=this;return this.ref.user=new Firebase("https://gphotos.firebaseio.com/user/"+this.user.uid+"/"),this.info=r(this.ref.user),this.info.$loaded().then(function(){return t.inited=!0})},email:function(t,e){return this.auth.$authWithPassword({email:t,password:e})}},i.inited||i.init(),i})),x$.controller("rank",["$scope","$interval","$timeout","backend"].concat(function(t,e,r,n){var i;return t.backend=n,i=function(){var e;return e=n.stream.map(function(t){var e;return{like:t.like,url:t.url,count:function(){var r=[];for(e in t.like)r.push(e);return r}().filter(function(e){return t.like[e].value}).length}}).filter(function(t){return t.url}),e.sort(function(t,e){return e.count-t.count}),t.stream=e.splice(0,5),t.inited=!0},e(i,2e3),$(window).on("resize",function(){return t.$apply(function(){var e,r;return e=$(".prj-row img").height(),r=$(window).height(),t.prjrowheight=(r-e)/2})}),t.backhome=function(){return window.location.href="/"}})),x$.controller("main",["$scope","$interval","$timeout","$firebaseArray","$firebaseObject","$firebaseAuth","backend"].concat(function(t,e,r,n,i,o,u){var a;return t.backend=u,a=function(t){return t=repeatString$("0",4-(t+"").length)+(t+"")},t.full={photo:null,set:function(t){return this.photo=t,this.show=!0,this},show:!1},t.like=function(e,r,n){var o,a,s,c,f,l,h;return null==n&&(n=!1),u.user&&e.$id&&!t.tick.end&&t.tick.start?(o=t.backend.info,a=function(){var t=[];for(s in o.like||(o.like={}))t.push(s);return t}().filter(function(t){return(o.like||(o.like={}))[t].value}).length,c=((f=e.like||(e.like={}))[l=u.user.uid]||(f[l]={})).value,3>a||c||n?(h=i(new Firebase("https://gphotos.firebaseio.com/stream/"+e.$id+"/like/"+u.user.uid)),h.$loaded().then(function(){var t,r;return h.value=!((t=e.like||(e.like={}))[r=u.user.uid]||(t[r]={})).value,n&&(h.value=!1),h.$save(),(o.like||(o.like={}))[btoa(e.url)]={value:h.value},o.$save()})):t.revote=!0,r?(r.preventDefault(),r.stopPropagation(),!1):void 0):void 0},t.backtop=function(){return $(document.body).animate({scrollTop:0},"500","swing",function(){})},t.isotope={obj:null,init:function(){return $("#layout")[0]?(t.isotope.ctrl&&t.isotope.ctrl.destroy(),t.isotope.ctrl=new Isotope($("#layout")[0],{itemSelector:".x-card",layoutMode:"masonry",getSortData:{weight:"[data-order]"},sortBy:"weight",sortAscending:!1})):void 0},update:function(){return t.isotope.ctrl?(r(function(){return t.isotope.ctrl.arrange({filter:"*"})},100),r(function(){return t.isotope.ctrl.arrange({filter:"*"})},1e3)):void 0}},t.$watch("backend.stream",function(){return t.lastLength!==t.backend.stream.length?(t.isotope.update(),t.lastLength=t.backend.stream.length):void 0},!0),t.isotope.init(),t.tick={hrs:0,min:0,sec:0,start:null,dur:72e5,end:!1,count:function(){var t;return this.dur=60*(u.config.dur||120)*1e3,this.start=u.config.start,this.start?(t=parseInt((this.dur-((new Date).getTime()-this.start))/1e3),0>t&&(t=0),this.sec=t%60,this.min=parseInt(t/60)%60,this.hrs=parseInt((t-t%3600)/3600),this.end=0>=t):void 0}},t.remove=function(e){var r;return(r=t.backend.stream.filter(function(t){return t.url===atob(e)})[0])?t.like(r,null,!0):void 0},e(function(){return t.tick.count()},1e3),t.inited=!0})),window.onSignIn=function(t){var e;return e=t.getBasicProfile(),console.log(e)};