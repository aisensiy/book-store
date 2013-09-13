#= require util
#= require holder
#= require jquery
#= require twitter/bootstrap
#= require angular
#= require ng-upload
#= require ui-bootstrap-tpls-0.3.0
#= require i18n
#= require i18n/translations
#= require app2

`
window.ModalDemoCtrl = function ($scope) {

  $scope.open = function () {
    $scope.shouldBeOpen = true;
  };

  $scope.close = function () {
    $scope.closeMsg = 'I was closed at: ' + new Date();
    $scope.shouldBeOpen = false;
  };

  $scope.items = ['item1', 'item2'];

  $scope.opts = {
    backdropFade: true,
    dialogFade:true
  };

};
`
