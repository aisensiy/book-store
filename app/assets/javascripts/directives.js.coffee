App = angular.module('App.directives', [])

App.directive('validFile', () ->
  return {
    require: 'ngModel',
    link: (scope, el, attrs, ngModel) ->
      el.bind 'change', () ->
        scope.$apply () ->
          ngModel.$setViewValue(el.val())
          return

      return
  }
)

App.directive 'passwordconfirm', () ->
  return {
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      ctrl.$parsers.unshift (value) ->
        password = elem.closest('form').find(attrs.passwordconfirm)
        if password.val() == value
          ctrl.$setValidity('password', true)
          value
        else
          ctrl.$setValidity('password', false)
          undefined
  }
