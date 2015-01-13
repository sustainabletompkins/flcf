



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
	$('#total-weight').html(total_weight);
}

