App = angular.module('App.filters', [])

App.filter('newlines', () ->
  (text) ->
    text.replace(/\n/g, '<br/>')
)
.filter('noHTML', () ->
  (text) ->
    text
      .replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;')
      .replace(/</g, '&lt;')
)
.filter('filesize', () ->
  (text) ->
    text = +text
    if text >= 1024 * 1024
      return ( text / 1024 / 1024 ).toFixed(2) + ' MB'
    else if text >= 1024
      return ( text / 1024 ).toFixed(2) + ' KB'
    else
      return text + ' B'
)


