$(document).on('ready page:load', function(){
	var offset_type = "home";
	var offset_weight;
	var offset_cost;
	var offset_quantity;
	var offset_units;
	var offset_title;
	$("#air-travel-button").on('click', function() {
		offset_type = "air";
		$("#air-travel-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$("#car-travel-button").on('click', function() {
		offset_type = "car";
		$("#car-travel-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$("#home-energy-button").on('click', function() {
		$("#home-energy-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$("#quick-button").on('click', function() {
		$("#quick-offset").fadeIn("slow");
		$("#offset-buttons").fadeOut("slow");
	});
	$('.cancel').on('click', function() {
		$(".offset-form").fadeOut("slow");
		$("#offset-buttons").fadeIn("slow");
	});
	$('#checkout').on('click', function() {
		//formulate and post payment query
		$('[name=cost]').val(total_cost);
		$('[name=weight]').val(total_weight);
		$('[name=label]').val('offset total');
		$('#submit-cart').submit();


	});

	$('.quick').on('click', function() {

		offset_weight = parseInt($(this).attr("value"));
		offset_cost = offset_weight * 2.7;
		offset_title = $(this).attr("title");
		var data = {
			pounds: offset_weight,
			cost: offset_cost,
			title: offset_title
		}
		saveOffset(data);

	});

	$('.new-offset').on('click', function() {
		$("#cart").fadeOut("slow");
		$("#offset-buttons").fadeIn("slow");
	});
	$('.calculate-offset').on('click', function() {
		alert('hey');
		switch(offset_type) {
			case 'air':
				// do calculations here
				pounds = 10;
				units = "miles";
				quantity = 100;
				break;
			case 'car':
				alert("sdfsf");
				miles = calcRoute();
				console.log(miles);
				break;
		}




	});
});

function calculateCost() {
	//placeholder equation until I get real numbers
	offset_cost = offset_weight * 5;
}

function saveOffset(data) {

	$.post('/offsets', data);
}

function totalCart() {
	total_cost = 0;
	total_weight = 0;
	$('.cost').each(function() {
		total_cost += parseInt($(this).text());

	});
	$('.weight').each(function() {
		total_weight += parseInt($(this).text());

	});
	$('#total-cost').html(total_cost);
}

