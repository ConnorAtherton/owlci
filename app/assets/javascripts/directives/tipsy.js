angular.module('directives')

.directive('tipsy', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      element.tipsy({
        delayIn: 0,
        delayOut: 0,
        gravity: attrs.tipsyDir,
        opacity: 1,
        html: true
      });

      element.on('click', function() {
        $('.tipsy').remove();
      });
    }
  }
});
