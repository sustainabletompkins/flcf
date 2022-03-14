$ ->
  cost_per_pound = .0125
  propane_rate = 12.17
  fuel_oil_rate = 22.37
  natural_gas_rate = 25.2
  electricity_rate = 0.233
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
  urlParams = new URLSearchParams(window.location.search);
  session_id = urlParams.get('session_cookie');

  monthly_avgs = {}
  monthly_avgs["home energy"] = 1240
  monthly_avgs["car travel"] = 722
  monthly_avgs["air travel"] = 425
  
  offset_costs = {}
  offset_costs["home energy"] = 35.32

  $("#donation-value").focus()

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
    gallons_gas = miles/mpg
    offset_weight = gallons_gas * lbs_co2_per_gallon
    offset_cost = offset_weight * cost_per_pound
    data =
      pounds: offset_weight.toFixed(2)
      cost: offset_cost.toFixed(2)
      title: offset_title
      session_id: session_id

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
      session_id: session_id

    saveOffset data

  saveOffset = (data) ->
    
    $('#checkout').css("display","inline")
    $('#total-cost').show()
    $('#offset-buttons').css('right','45px')
    $.post "/cart_items", (data)
    return

  titleCartItem = ->
    cart_item_title = "$" + offset_cost + " (" + offset_weight + "lbs.)"
    if ($("#offset_frequency").val() == 'recurring') 
      cart_item_title += " - " + $("#offset_interval").val() + "ly"
    switch ($("#offset_interval").val()) 
      when 'month'
        offset_title = $("#offset_type").val() + " - 1 Month" 
      when 'quarter'
        offset_title = $("#offset_type").val() + " - 3 Months"
      when 'year'
        offset_title = $("#offset_type").val() + " - 1 Year"
    $('.offset_title').html(cart_item_title)
    $('.offset_cost').html(offset_title)
    return

  saveCartItem = ->
    switch ($("#offset_interval").val()) 
      when 'month'
        offset_weight = monthly_avgs[$("#offset_type").val()] * 1
      when 'quarter'
        offset_weight = monthly_avgs[$("#offset_type").val()] * 3
      when 'year'
        offset_weight = monthly_avgs[$("#offset_type").val()] * 12 
    offset_cost = offset_weight * cost_per_pound  

    data =
      pounds: offset_weight.toFixed(2)
      cost: offset_cost.toFixed(2)
      title: offset_title
      offset_type: $("#offset_type").val()
      offset_interval: $("#offset_interval").val()
      frequency: $("#offset_frequency").val()
      session_id: session_id

    saveOffset data
    return

  $('.clearer').on "click", ->

    $('input.clearable').val("")

  $(".show-calc").on "click", ->
    $(".offset-form").hide()
    $("#offset-choices").show()

    return

  $(".air-travel-button").on "click", ->
    offset_type = "air"
    $('.arrow_box').hide()
    $("#cart").hide()
    $(".offset-form").hide()
    $("#air-travel-offset").show()
    $(".button").removeClass('selected_btn')
    $(this).addClass('selected_btn')
    return

  $(".car-travel-button").on "click", ->
    offset_type = "car"
    $('.arrow_box').hide()
    $(".offset-form").hide()
    $("#cart").hide()
    $(".button").removeClass('selected_btn')
    $(this).addClass('selected_btn')
    $("#car-travel-offset").show()

    return
  $(".saved-button").on "click", ->
    $('.arrow_box').hide()
    $(".offset-form").hide()
    $("#cart").hide()
    $("#saved-offsets").show()
    $(".button").removeClass('selected_btn')
    $(this).addClass('selected_btn')

    return
  $(".home-energy-button").on "click", ->
    $('.arrow_box').hide()
    $(".offset-form").hide()
    $("#cart").hide()
    $("#home-energy-offset").show() 
    $(".button").removeClass('selected_btn')
    $(this).addClass('selected_btn')
    $("#home-energy-offset input").val("")
    return

  $(".quick-button").on "click", ->
    $('.arrow_box').hide()
    $(".offset-form").hide()
    $("#cart").hide()
    $(".button").removeClass('selected_btn')
    $(this).addClass('selected_btn')
    $("#quick-offset").fadeIn "fast"

    return

  $(".donate-button").on "click", ->
    $('.arrow_box').hide()
    $(".offset-form").hide()
    $("#cart").hide()
    $(".button").removeClass('selected_btn')
    $(this).addClass('selected_btn')
    $("#donate-form").fadeIn "fast"

    return

  $(".cancel").on "click", ->
    $(".offset-form").fadeOut "fast"
    $("#offset-buttons").fadeIn "fast"
    $("#donation-value").focus()
    return

  $(".checkout").on "click", ->
    costs = ""
    $("#cart .cost").each ->
      costs += $(this).text() + "|"
      return

    weights = ""
    $("#cart .weight").each ->
      weights += $(this).text() + "|"
      return

    titles = ""
    $("#cart .offset-name").each ->
      titles += $(this).text() + "|"
      return
    $("[name=cost]").val costs
    $("[name=weight]").val weights
    $("[name=label]").val titles

    if $('#login-status').attr('value') == "guest"
      $('#myModal').foundation('reveal', 'open')
    else

      $('#user-offsets').foundation('reveal', 'open')

    return

  $('#guest-checkout').on "click", ->
    $("#user-info").fadeIn "fast"
    $(".show-login").fadeOut "fast"

  $("#save-offset").on "click", ->
    saveCartItem()
    return

  $("#offset_type").change ->
    offset_weight = monthly_avgs[$("#offset_type").val()]
    offset_cost = offset_weight * cost_per_pound
    titleCartItem()
    return  

  $("#offset_interval").change ->
    switch ($("#offset_interval").val()) 
      when 'month'
        offset_weight = monthly_avgs[$("#offset_type").val()] * 1
      when 'quarter'
        offset_weight = monthly_avgs[$("#offset_type").val()] * 3
      when 'year'
        offset_weight = monthly_avgs[$("#offset_type").val()] * 12 
    offset_cost = offset_weight * cost_per_pound  
    titleCartItem()
    return

  $("#offset_frequency").change ->
    titleCartItem()
    return    

  $(".new-offset").on "click", ->
    $("#cart").hide()
    $("#air-travel-offset").show()
    $("#donation-value").focus()
    return

  $("#calculate-home-offset").on "click", ->
    offset_weight = 0
    if parseInt($('#propane').val()) > 0
      co2 = propane_rate * parseInt($('#propane').val())
      offset_weight += co2
    if parseInt($('#natural-gas').val()) > 0
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
      session_id: session_id

    saveOffset data

  $("#calculate-car-offset").on "click", ->
    miles = undefined
    mpg = parseInt($('#mpg').val())
    unless parseInt($("#car-miles").val()) > 0
      request =
        origin: origin
        destination: destination
        travelMode: google.maps.DirectionsTravelMode.DRIVING

      l1 = autocomplete1.getPlace().formatted_address.substring(0, autocomplete1.getPlace().formatted_address.lastIndexOf(','))
      l2 = autocomplete2.getPlace().formatted_address.substring(0, autocomplete2.getPlace().formatted_address.lastIndexOf(','))
      offset_title =  l1+ " > " + l2


      directionsService.route request, (response, status) ->
        miles = response.routes[0].legs[0].distance.text.split(' ')[0]
        if $("#car-travel-offset input[type=checkbox]")[0].checked
          miles = miles*2
          offset_title += " (RT)"
        calculateCarOffset miles
    else
      miles = parseFloat($("#car-miles").val())
      offset_title = "Car Trip"
      if $("#car-travel-offset input[type=checkbox]")[0].checked
        miles = miles*2
        offset_title += " (RT)"
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

    miles = miles * $("#air-travel-offset input[type=number]")[0].value

    if $("#air-travel-offset input[type=checkbox]")[0].checked
      miles = miles*2
      offset_title += " (RT)"
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
        session_id: session_id

      saveOffset data

    return

  $('.checkout-without-login').on "click", ->
    $("#submit-cart").submit()

  $('.redo').on "click", ->
    data = {
      offset_id: parseInt($(this).attr("value"))    }
    $.post "offsets/duplicate", data

