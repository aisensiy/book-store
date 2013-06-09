Parse.initialize("r1AGhZH6QjWaMVsXtOm5pvjAWJhOQtVaExxIuZ3y", "drjVTIqOvdqBF2ohTGfT8e7K48sqpUKAWHrWkTfH")

@App = angular.module('App', [])

App.config ['$routeProvider', ($routeProvider) ->
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
		.when '/books/:id',
			templateUrl: 'book.html',
			controller: 'BookCtrl'
		.otherwise({redirectTo: '/books'})
]

App.directive 'passwordconfirm', () ->
	return {
		require: 'ngModel',
		link: (scope, elem, attrs, ctrl) ->
			console.log 'link'
			ctrl.$parsers.unshift (value) ->
				password = elem.closest('form').find(attrs.passwordconfirm)
				if password.val() == value
					ctrl.$setValidity('password', true)
					value
				else
					ctrl.$setValidity('password', false)
					undefined

	}


App.factory 'UserService', ['$rootScope', '$location', ($rootScope, $location) ->
	service = {}

	service.signin = (email, password) ->
		console.log 'service.signin'
		if email == 'admin@gmail.com'
			console.log 'signin ok'
			service.user = {email: email}
			$rootScope.$broadcast('user:signin')
			$location.path('/')
		else
			console.log 'sigin error'
			service.signin_err_msg = 'bla'

	service.signup = (user) ->
		if user.email == 'admin@gmail.com'
			console.log 'signup ok'
			service.user = {email: user.email}
			$rootScope.$broadcast('user:signin')
			$location.path('/')
		else
			service.signup_err_msg = 'bla'

	service.current_user = () ->
		service.user

	service.signout = () ->
		service.user = undefined
		$rootScope.$broadcast('user:logout')

	return service
]

App.controller 'NaviBarCtrl', ['$scope', 'UserService', ($scope, UserService) ->

	$scope.$on 'user:signin', () ->
		console.log UserService.user
		$scope.user = UserService.user

	$scope.$on 'user:signout', () ->
		$scope.user = undefined
]

SignInCtrl = App.controller 'SignInCtrl', ($scope, UserService, $location) ->
	$scope.user = {}
	$scope.UserService = UserService
	$scope.$watch 'UserService.signin_err_msg', (val) ->
		$scope.error_msg = val

	$scope.submit_form = () ->
		UserService.signin($scope.user.email, $scope.user.password)

SignInCtrl.$inject = ['$scope', 'UserService', '$location']

SignUpCtrl = App.controller 'SignUpCtrl', ($scope, UserService, $location) ->
	$scope.user = {
		'email': 'ai@sina.com',
		'username': 'ai',
		'password': '123'
	}

	$scope.UserService = UserService

	$scope.$watch 'UserService.signup_err_msg', (val) ->
		$scope.error_msg = val

	$scope.submit_form = () ->
		console.log $scope.user
		UserService.signup($scope.user)

SignUpCtrl.$inject = ['$scope', 'UserService', '$location']

App.controller 'BooksCtrl', ['$scope', ($scope) ->
]

App.controller 'BookCtrl', ['$scope', ($scope) ->
]

user_sign_up = ($scope) ->
	console.log $scope.user
	user = new Parse.User()
	user.set 'username', $scope.user.username
	user.set 'email', $scope.user.email
	user.set 'password', $scope.user.password

	user.signUp null, {
		success: (user) ->
			console.log('signup success', arguments)

		error: (user, error) ->
			console.log('signup error', arguments)
	}
