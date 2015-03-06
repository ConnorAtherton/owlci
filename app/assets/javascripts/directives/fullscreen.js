angular.module('directives')

.directive('fullscreen', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var el = $(element);
       el.on('click', function() {
         if (screenfull.enabled) {
           screenfull.request(el[0]);
         }
       })
    }
  }
});
