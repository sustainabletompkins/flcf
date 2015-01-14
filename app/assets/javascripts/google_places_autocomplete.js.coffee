$ ->
  cost_per_pound = .01
  propane_rate = 12.17
  fuel_oil_rate = 22.37
  natural_gas_rate = 11
  electricity_rate = 0.7208
  lbs_co2_per_gallon = 19.64
  mpg = 25
  miles_per_meter = 0.000621371
  autocomplete1 = undefined
  autocomplete2 = undefined
  air_autocomplete1 = undefined
  air_autocomplete2 = undefined
  origin = "ithaca, ny"
  destination = undefined
  air_origin = undefined
  air_destination = undefined
  origin_latlng = undefined
  destination_latlng = undefined
  directionsService = new google.maps.DirectionsService()
  offset_type = "home"
  offset_weight = undefined
  offset_cost = undefined
  offset_quantity = undefined
  offset_units = undefined
  offset_title = undefined
  initialize = () ->
    options = {
      language: 'en-GB',
      types: ['(cities)']
    }

    input1 = $('.starting-car-city')
    autocomplete1 = new google.maps.places.Autocomplete(input1[0], options)
    google.maps.event.addListener(autocomplete1, 'place_changed', setOrigin)

    input2 = $('.ending-car-city')
    autocomplete2 = new google.maps.places.Autocomplete(input2[0], options)
    google.maps.event.addListener(autocomplete2, 'place_changed', setDestination)

    input3 = $('.starting-air-city')
    air_autocomplete1 = new google.maps.places.Autocomplete(input3[0], options)
    google.maps.event.addListener(air_autocomplete1, 'place_changed', setAirOrigin)

    input4 = $('.ending-air-city')
    air_autocomplete2 = new google.maps.places.Autocomplete(input4[0], options)
    google.maps.event.addListener(air_autocomplete2, 'place_changed', setAirDestination)

  google.maps.event.addDomListener(window, 'load', initialize)

  setOrigin = ->

    place = autocomplete1.getPlace()
    origin = place.geometry.location


  setDestination = ->

    place = autocomplete2.getPlace()
    destination = place.geometry.location

  setAirOrigin = ->

    place = air_autocomplete1.getPlace()
    air_origin = place.geometry.location
    origin_latlng = new google.maps.LatLng(parseFloat(place.geometry.location.lat()), parseFloat(place.geometry.location.lng()));


  setAirDestination = ->

    place = air_autocomplete2.getPlace()
    air_destintion = place.geometry.location
    destination_latlng = new google.maps.LatLng(parseFloat(place.geometry.location.lat()), parseFloat(place.geometry.location.lng()));

  calculateHomeEnergy = ->

    propane_co2 = propane_rate * parseInt($('#propane').text())
    propane_co2 = propane_rate * parseInt($('#propane').text())


  calculateCarOffset = (miles) ->
    console.log miles
    gallons_gas = miles/mpg
    offset_weight = gallons_gas * lbs_co2_per_gallon
    offset_cost = offset_weight * cost_per_pound
    data =
      pounds: offset_weight.toFixed(2)
      cost: offset_cost.toFixed(2)
      title: offset_title

    saveOffset data

  calculateAirOffset = (miles) ->
    console.log miles
    # need to add plane specific numbers
    if miles < 400
      offset_weight = miles * .56
    else if miles < 1500
      offset_weight = miles * .45
    else if miles < 3000
      offset_weight = miles * .4
    else
      offset_weight = miles * .39

    offset_cost = offset_weight * cost_per_pound
    data =
      pounds: offset_weight.toFixed(2)
      cost: offset_cost.toFixed(2)
      title: offset_title

    saveOffset data

  $('.clearer').on "click", ->

    $('input.clearable').val("")

  $("#air-travel-button").on "click", ->
    offset_type = "air"
    $("#air-travel-offset").fadeIn "fast"
    $("#offset-buttons").fadeOut "fast"
    return

  $("#car-travel-button").on "click", ->
    offset_type = "car"
    $("#car-travel-offset").fadeIn "fast"
    $("#offset-buttons").fadeOut "fast"
    return

  $("#home-energy-button").on "click", ->
    $("#home-energy-offset").fadeIn "fast"
    $("#offset-buttons").fadeOut "fast"
    return

  $("#quick-button").on "click", ->
    $("#quick-offset").fadeIn "fast"
    $("#offset-buttons").fadeOut "fast"
    return

  $(".cancel").on "click", ->
    $(".offset-form").fadeOut "fast"
    $("#offset-buttons").fadeIn "fast"
    return

  $(".checkout").on "click", ->
    costs = ""
    $(".cost").each ->
      costs += $(this).text() + "|"
      return

    weights = ""
    $(".weight").each ->
      weights += $(this).text() + "|"
      return

    titles = ""
    $(".name").each ->
      titles += $(this).text() + "|"
      return
    $("[name=cost]").val costs
    $("[name=weight]").val weights
    $("[name=label]").val titles
    $("#submit-cart").submit()
    return

  $(".quick").on "click", ->
    offset_weight = parseInt($(this).attr("value"))
    offset_cost = offset_weight * cost_per_pound
    offset_title = $(this).attr("title")
    data =
      pounds: offset_weight
      cost: offset_cost
      title: offset_title

    saveOffset data
    return

  $(".new-offset").on "click", ->
    $("#cart").fadeOut "fast"
    $("#offset-buttons").fadeIn "fast"
    return

  $("#calculate-home-offset").on "click", ->
    offset_weight = 0
    if parseInt($('#propane').val()) > 0
      co2 = propane_rate * parseInt($('#propane').val())
      offset_weight += co2
    if parseInt($('#natural_game').val()) > 0
      co2 = natural_gas_rate * parseInt($('#natural-gas').val())
      offset_weight += co2
    if parseInt($('#fuel-oil').val()) > 0
      co2 = fuel_oil_rate * parseInt($('#fuel-oil').val())
      offset_weight += co2
    if parseInt($('#electricity').val()) > 0
      co2 = electricity_rate * parseInt($('#electricity').val())
      offset_weight += co2

    offset_cost = offset_weight * cost_per_pound
    offset_title = "Home Energy Use"
    data =
      pounds: offset_weight.toFixed(2)
      cost: offset_cost.toFixed(2)
      title: offset_title

    saveOffset data

  $("#calculate-car-offset").on "click", ->
    miles = undefined
    unless parseInt($("#car-miles").val()) > 0
      request =
        origin: origin
        destination: destination
        travelMode: google.maps.DirectionsTravelMode.DRIVING

      l1 = autocomplete1.getPlace().formatted_address.substring(0, autocomplete1.getPlace().formatted_address.lastIndexOf(','))
      l2 = autocomplete2.getPlace().formatted_address.substring(0, autocomplete2.getPlace().formatted_address.lastIndexOf(','))
      offset_title =  l1+ " > " + l2


      directionsService.route request, (response, status) ->

        miles = response.routes[0].legs[0].distance.value / 1000
        calculateCarOffset miles
    else
      miles = parseInt($("#car-miles").val())
      offset_title = "Car Trip"
      calculateCarOffset miles

  $("#calculate-air-offset").on "click", ->

    miles = undefined
    unless parseInt($("#air-miles").val()) > 0
      air_meters = google.maps.geometry.spherical.computeDistanceBetween origin_latlng, destination_latlng
      miles = air_meters * miles_per_meter
      l1 = air_autocomplete1.getPlace().formatted_address.substring(0, air_autocomplete1.getPlace().formatted_address.lastIndexOf(','))
      l2 = air_autocomplete2.getPlace().formatted_address.substring(0, air_autocomplete2.getPlace().formatted_address.lastIndexOf(','))
      offset_title =  l1+ " > " + l2

    else
      miles = $("#air-miles").val()
      offset_title = "Plane Trip"
    calculateAirOffset miles

  $("#donate").on "click", ->
    if $("#donation-value").val() == ""
      $("#donation-value").css("border","2px solid red")
      $("#donation-value").attr("placeholder","enter an amount ($)")

    else
      $("#offset-buttons").fadeOut "fast"
      offset_cost = parseInt($("#donation-value").val().replace('$', ''))
      offset_weight = offset_cost * 100
      offset_title = "Quick Donation"
      data =
        pounds: offset_weight.toFixed(2)
        cost: offset_cost.toFixed(2)
        title: offset_title

      saveOffset data

    return


  saveOffset = (data) ->
    $('#checkout').css("display","block")
    $.post "/offsets", data
    return

