function repeatString$(i,t){for(var e="";t>0;(t>>=1)&&(i+=i))1&t&&(e+=i);return e}var ids,x$;ids=["i269ham48uivdkajlx2e6u8g84c8000g880k4","i269e6tue1ryc0zvdho5ymo8sw80kskg40s44","i26947apegha1tkgkcq4jycksw4wo8w4gg0go","i268mjuu9eha6o8hxqiwopc84oc8gk4oc8kss","i25xyhud8ga99u7m2yilgow0g808owwok0wco","hzs1x41r3bug12yiguo0ug6os8kkg040c4g84","pic1409972207346_18041221168","pic1409651417531_35168461169","pic1409557786553_32000532775","pic1409499673445_35828110737","pic1409499337843_11079410258","pic1409473497217_17536616216","pic1409458840688_40334590483","pic1409458816182_9662582","pic1409458776028_17876608630","pic1409458722903_39330406946","pic1409458688748_6836020839","pic1409458669554_8994953588","pic1409458622240_15099582729","pic1409458591904_26173532225","pic1409458562009_1686259337","pic1409458536249_4874060295","pic1409458500271_36328375561","pic1409458462742_30065369954","pic1409458419460_22018527314","pic1409458385385_2467304851","pic1409455675784_30610309762","pic1409455644399_87431253","pic1409409884463_23978014996","pic1409402264811_17285210770","pic1409402131954_1497834869","pic1409401869730_4320335144","pic1409391197852_35536450921","pic1409391171299_6784377112","pic1409391149190_18810954832","pic1409391128561_9281553157","pic1409391106810_36129166454","pic1409391080252_8933147288","pic1409391048601_36566366613","pic1409391014938_2154988104","pic1409390986111_17841067925","pic1409389834518_26899657225","pic1409389799829_2471900528","pic1409389766658_8733619316","pic1409389706986_4973744517","pic1409389674037_27419215616","pic1409389645496_17330959140","pic1409389600773_34717505874","pic1409389560523_10307016807","pic1409389504814_8590152724","pic1409389484752_18007418217","pic1409389455562_31262654741","pic1409388778441_9519263768","pic1409388712317_19635832402","pic1409388669135_40270596213","pic1409386288130_39846106420","pic1409385460370_18647169399","pic1409384167684_22017357912","pic1409384115632_18598002789","pic1409384111176_26378248548","pic1409384059976_32020723842","pic1409384000905_9462354729","pic1409383561854_1670388112","pic1409383084311_14027403881","pic1409380156468_23108716896","pic1409379978352_14068060977","pic1409379270668_32585777681","pic1409379064373_39042941992","pic1409378682736_17599318280","pic1409376636655_17736995096","pic1403345167224_26346008582","pic1403345105351_9143673445","pic1403343683229_36028641830","pic1403343424995_35258828179","pic1403343059903_35524011280","pic1403342989848_39754016103","pic1403342919581_10361537282","pic1403342871526_6768576545","pic1403342324352_27155055398","pic1403342307825_6747161625","pic1403341342364_30116489300","pic1403341156520_40114680729","pic1403341009328_40925201008","pic1403340936270_30754756241","pic1403340910017_31559476308","pic1403340592845_6296999702","pic1403340516211_4335891749","pic1403340381962_41155584791","pic1403340322835_26060792326","pic1403339868156_15049642598","pic1403339519793_36632080720","pic1403338917351_22886573154","pic1403338808700_6309812096","pic1403338785113_34499334176","pic1403338702691_5167841656","pic1403338541010_23139422867","pic1403338486581_22368387907","pic1403338458308_9539290696","pic1403337155865_39040788120","pic1403337057488_14098184279"],x$=angular.module("main",["firebase"]),x$.directive("isotope",function(){return{restrict:"A",link:function(i,t){var e;return e=$(t[0].parentNode.parentNode.parentNode),e.addClass("iso"),"IMG"===t.prop("tagName")?t.load(function(){return e.addClass("iso-show"),i.isotope.ctrl.appended(e[0]),i.$on("$destroy",function(){return i.isotope.ctrl.remove(e[0]),i.isotope.ctrl.layout()})}):(i.isotope.ctrl.appended(t[0].parentNode.parentNode.parentNode),i.$on("$destroy",function(){return i.isotope.ctrl.remove(t[0].parentNode.parentNode.parentNode),i.isotope.ctrl.layout()}))}}}),x$.service("backend",["$rootScope","$firebaseArray","$firebaseAuth"].concat(function(i,t,e){var c;return c={inited:!1,init:function(){var i,c=this;return i=new Firebase("https://gphotos.firebaseio.com"),this.stream=t(i),this.auth=e(i),this.user=this.auth.$getAuth(),this.user||this.auth.$authAnonymously().then(function(i){return c.user=i}),this.inited=!0}},c.inited||c.init(),c})),x$.controller("main",["$scope","$interval","$timeout","$firebaseArray","$firebaseAuth","backend"].concat(function(i,t,e,c,p,o){var r,n;return r=!0,i.stream=[],r?i.user=o.user:(i.stream=o.stream,i.user=o.user),n=function(i){return i=repeatString$("0",4-(i+"").length)+(i+"")},ids=ids.map(function(i,t){return{url:"//thumb.g0v.photos/"+i,order:n(999-t)}}),i.full={photo:null,set:function(i){return this.photo=i,this.show=!0,this},show:!1},i.like=function(t,e){var c;if(o.user)return c=(t.like||(t.like=[])).indexOf(o.user.uid),0>c?(t.like||(t.like=[])).push(i.user.uid):(t.like||(t.like=[])).splice(c,1),r||i.stream.$save(t),e?(e.preventDefault(),e.stopPropagation(),!1):void 0},i.backtop=function(){return document.body.scrollTop=0},i.isotope={obj:null,init:function(){return i.isotope.ctrl&&i.isotope.ctrl.destroy(),i.isotope.ctrl=new Isotope($("#layout")[0],{itemSelector:".thumbnail",layoutMode:"masonry",getSortData:{weight:"[data-order]"},sortBy:"weight",sortAscending:!1})},update:function(){return e(function(){return i.isotope.ctrl.arrange({filter:"*"})},0)}},i.$watch("stream",function(){return i.lastLength!==i.stream.length?(i.isotope.update(),i.lastLength=i.stream.length):void 0},!0),i.isotope.init(),r?t(function(){var t;return t=ids.splice(0,10),i.stream=i.stream.concat(t),i.isotope.update()},1e3):void 0})),window.onSignIn=function(i){var t;return t=i.getBasicProfile(),console.log(t)};