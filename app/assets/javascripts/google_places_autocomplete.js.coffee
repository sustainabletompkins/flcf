$ ->
  autocomplete1 = undefined
  autocomplete2 = undefined
  origin = "ithaca, ny"
  destination = undefined
  directionsService = new google.maps.DirectionsService()
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

    calcRoute()

  calcRoute = ->

    request =
      origin: origin
      destination: destination
      travelMode: google.maps.DirectionsTravelMode.FLYING

    directionsService.route request, (response, status) ->

      console.log(response.routes[0].legs[0].distance.value / 1000)
      return

    return

