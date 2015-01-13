$(document).on('ready page:load', function(){

	$("#air-travel-button").on('click', function() {
		$("#air-travel-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$("#car-travel-button").on('click', function() {
		$("#car-travel-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$("#home-energy-button").on('click', function() {
		$("#home-energy-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$("#quick-offset-button").on('click', function() {
		$("#quick-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$('.cancel').on('click', function() {
		$(".offset-form").fadeOut("slow");
		$("#offset-buttons").fadeIn("slow");
	});
	$('#checkout').on('click', function() {
		//formulate and post payment query
	});
	$('.new-offset').on('click', function() {
		$("#cart").fadeOut("slow");
		$("#offset-buttons").fadeIn("slow");
	});
	$('#calculate-offset').on('click', function() {
		$("#cart").fadeIn("slow");
		$(".offset-form").fadeOut("slow");
	});
});
