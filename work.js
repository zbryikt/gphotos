var x$;x$=angular.module("main",["firebase"]),x$.directive("isotope",function(){return{restrict:"A",link:function(e,n){var t;return t=$(n[0].parentNode.parentNode.parentNode),t.addClass("iso"),"IMG"===n.prop("tagName")?n.load(function(){return t.addClass("iso-show"),e.isotope.appended(t[0]),e.$on("$destroy",function(){return e.isotope.remove(t[0]),e.isotope.layout()})}):(e.isotope.appended(n[0].parentNode.parentNode.parentNode),e.$on("$destroy",function(){return e.isotope.remove(n[0].parentNode.parentNode.parentNode),e.isotope.layout()}))}}}),x$.controller("main",["$scope","$firebaseArray","$firebaseAuth"].concat(function(e,n,t){var r,o;return r=new Firebase("https://gphotos.firebaseio.com"),e.stream=n(r),e.auth=t(r),e.user=e.auth.$getAuth(),e.user||e.auth.$authAnonymously().then(function(n){return e.user=n}),e.upload={concurrentCount:2,progress:{},queue:[],current:[],url:"/d/pic",_handler:function(n){var t,r,o=this;return t=/\.([^.]+)$/.exec(n.name),t||(r="image/jpeg"),"jpg"===t[1]&&(r="image/jpeg"),r="image/"+t[1],storage.upload(n.name,r,n.base64,function(t){return e.$apply(function(){return n.progress=t.loaded})}).then(function(){var t,r,a,i=[];for(n.progress=n.size,t=0,r=o.current.length;r>t;++t)if(a=t,o.current[a].name===n.name){e.stream.$add({name:o.current[a].name,url:"https://storage.googleapis.com/thumbnail-gphotos/"+o.current[a].name}),o.current.splice(a,1),e.upload.handle();break}return i})},handle:function(e){var n,t,r,o,a,i,s=[];if(null==e&&(e=null),e&&(n=JSON.stringify(e),this.progress[e[0]]=t={name:e[0],size:n.length,data:n,base64:e[1],img:"data:image/png;base64,"+e[1]},this.queue.push(t)),!(this.current.length>=this.concurrentCount)){for(this.current=this.current.concat(this.queue.splice(0,2-this.current.length)),r=0,a=(o=this.current).length;a>r;++r)i=o[r],console.log("handle "+i.name+"..."),s.push(this._handler(i));return s}}},o=function(n){var t;return console.log("load file "+n.name+" ... "),t=new FileReader,t.onload=function(){return console.log("file "+n.name+" loaded. sending to upload queue..."),e.upload.handle([n.name,btoa(t.result)])},t.readAsBinaryString(n)},$("#files").on("change",function(){var e,n,t,r,a,i,s=[];for(e=$("#files")[0],console.log("file list changed..."),n=[],t=0,r=e.files.length;r>t;++t)a=t,i=e.files[a],s.push(o(i));return s}),e.initIsotope=function(){return e.isotope&&e.isotope.destroy(),e.isotope=new Isotope($("#layout")[0],{itemSelector:".thumbnail",layoutMode:"masonry",getSortData:{weight:"[data-order]"},sortBy:"weight",sortAscending:!1})},e.initIsotope(),setTimeout(function(){return e.isotope.arrange({filter:"*"})},2e3),e.ids=[],storage.init(),e.like=function(n){var t;if(e.user)return t=(n.like||(n.like=[])).indexOf(e.user.uid),0>t?(n.like||(n.like=[])).push(e.user.uid):(n.like||(n.like=[])).splice(t,1),e.stream.$save(n)}})),window.onSignIn=function(e){var n;return n=e.getBasicProfile(),console.log(n)};