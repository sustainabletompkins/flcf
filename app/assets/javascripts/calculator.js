
function totalCart() {
	total_cost = 0;
	$('#cart .cost').each(function() {
		total_cost += parseFloat($(this).text());

	});
	$('#total-cost .value').html("$"+total_cost.toFixed(2));
	$('.stripe-button').attr("data-amount", parseInt(total_cost.toFixed(2)*100));

}

