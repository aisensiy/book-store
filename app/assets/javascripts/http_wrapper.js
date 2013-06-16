Service = angular.module('HttpServices', []);

Service.factory('HttpWrapper', ['$http', '$rootScope', function($http, $rootScope) {
  $http.defaults.transformRequest.push(function(data) {
    $rootScope.loading = ($rootScope.loading ? $rootScope.loading + 1 : 1);
    console.log('start request')
    console.log(data);
    return data;
  });
  $http.defaults.transformResponse.push(function(data) {
    $rootScope.loading -= 1;
    console.log('finish request');
    console.log(data);
    return data;
  });
  return $http;
}]);
