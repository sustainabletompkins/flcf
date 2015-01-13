$ ->
  initialize = () ->
    options = {
      language: 'en-GB',
      types: ['(cities)']
    }

    input1 = $('.starting-city')
    autocomplete1 = new google.maps.places.Autocomplete(input1[0], options)
    google.maps.event.addListener(autocomplete1, 'place_changed', startSpotSet)

    input2 = $('.ending-city')
    autocomplete2 = new google.maps.places.Autocomplete(input2[0], options)
    google.maps.event.addListener(autocomplete2, 'place_changed', onPlaceChanged)

  google.maps.event.addDomListener(window, 'load', initialize)
