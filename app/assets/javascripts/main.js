angular.module('nghack', [
  'templates',
  'ui.router',
  'restangular',

  'Directives',
  'Services',

  'Dashboard'

])

.config(['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider', 'RestangularProvider',
    function myAppConfig($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider, RestangularProvider) {

  $urlRouterProvider.otherwise('/404');
  $locationProvider.html5Mode(true);

  $stateProvider
    .state('home', {
      url: "/",
      templateUrl: "home.html",
    })
    .state('about', {
      url: "/about",
      templateUrl: "about.html"
      // resolve: {
      //   loggedIn: function (AuthManager) {
      //     return AuthManager.requireAuthenticatedUser('about');
      //   }
      // }
    })
    .state('404', {
      url: "/404",
      templateUrl: "404.html",
    });

  $httpProvider.interceptors.push(function($q, $location, $rootScope) {
    return {
      'responseError': function (response) {
        if (response.status === 401 || response.status === 403) {
          $rootScope.appErrorMessage = response.data.message;
        }
        return $q.reject(response);
      }
    };
  });

  // fetch csrf token and pass with every request
  var headers = $httpProvider.defaults.headers.common;
  var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  headers['X-CSRF-TOKEN'] = token;
  headers['X-Requested-With'] = 'XMLHttpRequest';

  //
  //  Restnagular conf
  //
  RestangularProvider.setBaseUrl('/api/v1/');
}])

.run(function($rootScope, $state, AuthManager) {
  // Check to see if a user is already logged in
  // from a previous session.
  AuthManager.requestCurrentUser();
  // add class to ui-view based on current state
  $rootScope.currentAppClass = 'state-' + $state.current;

  $rootScope.$watch(function () {
    return $state.current;
  }, function(current) {
    $rootScope.currentAppClass = 'state-' + current.name;
  });

})

.controller('AppCtrl', ['$scope', '$state', '$window', 'AuthManager', function AppCtrl($scope, $state, $window, AuthManager) {

  $scope.isAuthenticating = false;

  $scope.authenticated = AuthManager.isAuthenticated;

  $scope.isPage = function(page) {
    return $state.is(page);
  };

  $scope.getState = function() {
    return $state.current();
  };

  $scope.$watch(function () {
    return AuthManager.isAuthenticated();
  }, function (currentUser) {
    $scope.authenticated = currentUser;
  });

  $scope.getLoginReason = function() {
    return AuthManager.getLoginReason();
  };

  $scope.loginWith = function(provider) {
    $scope.isAuthenticating = true;
    $window.location.href = ('/auth/' + provider);
  };

  $scope.logout = function() {
    AuthManager.logout();
  }

}]);
