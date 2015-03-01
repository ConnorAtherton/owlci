angular.module('owlci', [
  'templates',
  'ui.router',
  'restangular',

  'services',
  'controllers',
  'directives'
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
    })
    .state('dashboard', {
      url: '/dashboard',
      controller: 'DashboardController',
      templateUrl: 'dashboard/dashboard.html'
    })
    .state('login', {
      url: '/login',
      templateUrl: 'login/login.html',
      controller: 'LoginController',
      resolve: {
        redirect: function(AuthManager) {
          return AuthManager.redirectIfAuthenticated();
        }
      }
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

  $scope.loadingMessage = (function() {
    var messages = ['Hey, we are just loading your github information',
                    'Just fetching data, we\'ll be with you asap',
                    'Ooo look, pretty circles',
                    'We\'re waving some wands about',
                    'Something is happening... I think...',
                    'Calm down dear, it\'s just a loading screen'];

    return messages[Math.floor(Math.random() * messages.length)];
  })();

}]);
