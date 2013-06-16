angular.module('SharedServices', [])
/*
.config(function ($httpProvider, $rootScope) {
  $httpProvider.responseInterceptors.unshift('myHttpInterceptor');
  var spinnerFunction = function (data, headersGetter) {
    // todo start the spinner here
    $rootScope.loading = true
    return data;
  };
  $httpProvider.defaults.transformRequest.push(spinnerFunction);
})
*/
.factory('HttpWrapper', ['$http', '$rootScope', function($http, $rootScope) {
  $http.defaults.transformRequest.push(function(data) {
    $rootScope.loading = true;
    return data;
  });
  $http.defaults.transformResponse.push(function(data) {
    $rootScope.loading = false;
    return data;
  });
  return $http;
}])
// register the interceptor as a service, intercepts ALL angular ajax http calls
/*
.factory('myHttpInterceptor', function ($q, $window, $rootScope) {
  return function (promise) {
    return promise.then(function (response) {
      // do something on success
      // todo hide the spinner
      $rootScope.loading = false
      return response;

    }, function (response) {
      // do something on error
      // todo hide the spinner
      $rootScope.loading = false
      return $q.reject(response);
    });
  };
})
*/
