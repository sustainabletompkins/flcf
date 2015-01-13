$(document).on('ready page:load', function(){
	var offset_type = "home";
	$("#air-travel-button").on('click', function() {
		offset_type = "air";
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
		switch(offset_type) {
			case 'air':
				// do calculations here
				pounds = 10;
				units = "miles";
				quantity = 100;
				break;
		}

		var data = {
			pounds: pounds,
			units: units,
			quantity: quantity,
			cost: 10,
			title: "air travel"
		}
		$.post('/offsets', data);

	});
});


function totalCart() {
	total_cost = 0;
	$('.cost').each(function() {
		total_cost += parseInt($(this).text());

	});
	$('#total-cost').html(total_cost);
}

