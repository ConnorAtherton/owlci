angular.module('Login', [
  'AuthManager'
])

.config(function($stateProvider) {

  $stateProvider
    .state('login', {
      url: '/login',
      templateUrl: 'services/auth/login/login.tpl.html',
      controller: 'LoginCtrl',
      resolve: {
        redirect: function(AuthManager) {
          return AuthManager.redirectIfAuthenticated();
        }
      }
    });

})

.controller('LoginCtrl', function LoginCtrl($scope, $window, AuthManager) {

});
