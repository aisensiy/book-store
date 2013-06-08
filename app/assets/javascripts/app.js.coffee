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


App.factory 'UserInfo', ['$rootScope', ($rootScope) ->
	sharedService = {}

	sharedService.user = {}

	sharedService.prepForBroadcast = (user) ->
		console.log 'prepare broadcast'
		this.user = user
		this.broadcastItem()

	sharedService.broadcastItem = () ->
		console.log 'broadcast'
		console.log $rootScope
		$rootScope.$broadcast('user-signin')

	return sharedService
]

App.controller 'NaviBarCtrl', ['$scope', 'UserInfo', ($scope, UserInfo) ->

	$scope.$on 'user-signin', () ->
		console.log UserInfo.user
		$scope.user = UserInfo.user
]

SignInCtrl = App.controller 'SignInCtrl', ($scope, UserInfo, $location) ->
	$scope.user = {}

	$scope.submit_form = () ->
		console.log $scope.user
		UserInfo.prepForBroadcast($scope.user)
		$location.path('/books')

SignInCtrl.$inject = ['$scope', 'UserInfo', '$location']

SignUpCtrl = App.controller 'SignUpCtrl', ($scope, UserInfo, $location) ->
	$scope.user = {
		'email': 'ai@sina.com',
		'username': 'ai',
		'password': '123'
	}

	$scope.submit_form = () ->
		console.log $scope.user
		UserInfo.prepForBroadcast($scope.user)
		$location.path('/books')

SignUpCtrl.$inject = ['$scope', 'UserInfo', '$location']

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
