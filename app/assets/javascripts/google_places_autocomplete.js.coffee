$ ->
  autocomplete1 = undefined
  autocomplete2 = undefined
  origin = "ithaca, ny"
  destination = undefined
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

    input1 = $('.starting-city')
    autocomplete1 = new google.maps.places.Autocomplete(input1[0], options)
    google.maps.event.addListener(autocomplete1, 'place_changed', setOrigin)

    input2 = $('.ending-city')
    autocomplete2 = new google.maps.places.Autocomplete(input2[0], options)
    google.maps.event.addListener(autocomplete2, 'place_changed', setDestination)

  google.maps.event.addDomListener(window, 'load', initialize)

  setOrigin = ->

    place = autocomplete1.getPlace()
    origin = place.geometry.location

  setDestination = ->

    place = autocomplete2.getPlace()
    destination = place.geometry.location


  calcRoute = ->


    return


  $("#air-travel-button").on "click", ->
    offset_type = "air"
    $("#air-travel-offset").fadeIn "slow"
    $("#offset-buttons").fadeOut "slow"
    return

  $("#car-travel-button").on "click", ->
    offset_type = "car"
    $("#car-travel-offset").fadeIn "slow"
    $("#offset-buttons").fadeOut "slow"
    return

  $("#home-energy-button").on "click", ->
    $("#home-energy-offset").fadeIn "slow"
    $("#offset-buttons").fadeOut "slow"
    return

  $("#quick-button").on "click", ->
    $("#quick-offset").fadeIn "slow"
    $("#offset-buttons").fadeOut "slow"
    return

  $(".cancel").on "click", ->
    $(".offset-form").fadeOut "slow"
    $("#offset-buttons").fadeIn "slow"
    return

  $("#checkout").on "click", ->

    #formulate and post payment query
    $("[name=cost]").val total_cost
    $("[name=weight]").val total_weight
    $("[name=label]").val "offset total"
    $("#submit-cart").submit()
    return

  $(".quick").on "click", ->
    offset_weight = parseInt($(this).attr("value"))
    offset_cost = offset_weight * 2.7
    offset_title = $(this).attr("title")
    data =
      pounds: offset_weight
      cost: offset_cost
      title: offset_title

    saveOffset data
    return

  $(".new-offset").on "click", ->
    $("#cart").fadeOut "slow"
    $("#offset-buttons").fadeIn "slow"
    return

  $("#calculate-car-offset").on "click", ->
    request =
      origin: origin
      destination: destination
      travelMode: google.maps.DirectionsTravelMode.DRIVING
    offset_title = autocomplete1.getPlace().formatted_address + " > " + autocomplete2.getPlace().formatted_address
    directionsService.route request, (response, status) ->

      miles = response.routes[0].legs[0].distance.value / 1000
      console.log miles
      offset_weight = miles * 4
      console.log offset_weight



      offset_cost = offset_weight * 5
      data =
        pounds: offset_weight
        cost: offset_cost
        title: offset_title
      console.log(data)
      saveOffset data

  calculateCost = ->

    #placeholder equation until I get real numbers

    return

  saveOffset = (data) ->
    $.post "/offsets", data
    return

  totalCart = ->
    total_cost = 0
    total_weight = 0
    $(".cost").each ->
      total_cost += parseInt($(this).text())
      return

    $(".weight").each ->
      total_weight += parseInt($(this).text())
      return

    $("#total-cost").html total_cost
    return