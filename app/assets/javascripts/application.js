// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require jquery.fancybox
//= require helpers/jquery.fancybox-media
//= require_tree .
$(document).on('ready', function() {
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '1752616198297352',
      xfbml      : true,
      version    : 'v2.2'
    });
  };

  (function(d, s, id){
     var js, fjs = d.getElementsByTagName(s)[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement(s); js.id = id;
     js.src = "//connect.facebook.net/en_US/sdk.js";
     fjs.parentNode.insertBefore(js, fjs);
   }(document, 'script', 'facebook-jssdk'));

	if ($.cookie('session_id')==undefined) {
		var id = Math.random();
		$.cookie('session_id', id, { expires: 1 });
	}
	else console.log($.cookie('session_id'));

	$(".fancybox").fancybox({
	});
	$('.fancybox-media').fancybox({
        openEffect: 'none',
        closeEffect: 'none',
        helpers: {
          media: {}
        }
    });
	var data = {
		session_id: $.cookie("session_id")
	}
	$.post("offsets/populate_cart", data);

})
$(function(){ $(document).foundation(); });
