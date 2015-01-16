
function totalCart() {
	total_cost = 0;
	$('#cart .cost').each(function() {
		console.log($(this).text());
		total_cost += parseFloat($(this).text());

	});
	console.log(total_cost);
	$('#total-cost .value').html("$"+total_cost.toFixed(1));

}

