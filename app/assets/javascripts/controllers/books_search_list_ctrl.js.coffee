App = angular.module('App')

App.controller 'BooksSearchListCtrl', ($scope, Book, $routeParams) ->
  $scope.header = "#{I18n.t('search')} #{I18n.t('title')}: #{$routeParams.q}"
  per_page = 40
  set_data = (scope, data, cur_page) ->
    scope.books = data.results
    scope.paging = {
      total_page: Math.ceil(data.count / per_page),
      current_page: cur_page
      max_size: 10
    }

  Book.search({limit: per_page, skip: 0, q: $routeParams.q}, (data) ->
    set_data($scope, data, 1)

  $scope.pageChanged = (page) ->
    Book.search {limit: per_page, skip: (page - 1) * per_page, q: $routeParams.q}, (data) ->
      set_data($scope, data, page)
  )

