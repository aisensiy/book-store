App = angular.module('App')

App.controller 'BooksListCtrl', ($scope, Book) ->
  per_page = 40
  set_data = (scope, data, cur_page) ->
    scope.books = data.results
    scope.paging = {
      total_page: Math.ceil(data.count / per_page),
      current_page: cur_page
      max_size: 10
    }

  Book.query({limit: per_page, skip: 0}, (data) ->
    set_data($scope, data, 1)

  $scope.pageChanged = (page) ->
    Book.query {limit: per_page, skip: (page - 1) * per_page}, (data) ->
      set_data($scope, data, page)
  )
