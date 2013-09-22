App = angular.module('App')

App.controller 'ImageTagListCtrl', ($scope, Image, $routeParams) ->
  $scope.header = "#{I18n.t('tag')}: #{$routeParams.q}"
  per_page = 40
  set_data = (scope, data, cur_page) ->
    scope.images = data.results
    scope.paging = {
      total_page: Math.ceil(data.count / per_page),
      current_page: cur_page
      max_size: 10
    }

  Image.tag({limit: per_page, skip: 0, tag: $routeParams.q}, (data) ->
    set_data($scope, data, 1)

  $scope.pageChanged = (page) ->
    Image.tag {limit: per_page, skip: (page - 1) * per_page, tag: $routeParams.q}, (data) ->
      set_data($scope, data, page)
  )

