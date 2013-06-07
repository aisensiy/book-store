@App = angular.module('app', [])

App.config ($routeProvider) ->
	$routeProvider
		.when '/sign_in',
			templateUrl: 'sign_in.html'
			controller: 'SignInCtrl'
		.when '/sign_up',
			templateUrl: 'sign_up.html',
			controller: 'SignUpCtrl'
		.when '/books',
			templateUrl: 'books.html',
			controller: 'BooksCtrl'
		.when '/book',
			templateUrl: 'book.html',
			controller: 'BookCtrl'
		.otherwise({redirectTo: '/books'});


App.controller 'SignInCtrl', ($scope) ->
	$scope.user = {}

App.controller 'SignUpCtrl', ($scope) ->
	$scope.user = {}

App.controller 'BooksCtrl', ($scope) ->

App.controller 'BookCtrl', ($scope) ->
