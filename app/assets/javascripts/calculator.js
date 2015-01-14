
function totalCart() {
	total_cost = 0;
	$('.cost').each(function() {
		console.log($(this).text());
		total_cost += parseInt($(this).text());

	});
	console.log(total_cost);
	$('#total-cost .value').html("$"+total_cost);

}

