app.directive('streakalongNgDeviceMode', ['$log', 'localStorageService', function(Logger, LocalStorage) {
  var MOUSE = _.constant('mouse');
  var TOUCH = _.constant('touch');
  var TOUCH_SIZE = _.constant(768);

  function link(scope, element, attrs) {
    LocalStorage.bind(scope, 'isTouch');

    if (false === _.isBoolean(scope.isTouch)) {
      if (TOUCH_SIZE() < jQuery(window).width()) {
        scope.isTouch = false;
      } else {
        scope.isTouch = true;
      }
    }

    scope.switch_device_mode = function() {
      if (true === scope.isTouch) {
        scope.isTouch = false;
      } else {
        scope.isTouch = true;
      }
    };
  }

  return {
    scope: {
      isTouch:'=ngIsTouch'
    },
    restrict: 'E',
    template: '<button type="button" class="btn btn-default btn-xs" ng-class="{\'active\':isTouch}" style="float:right;" ng-click="switch_device_mode()">' + 
        '<span class="glyphicon glyphicon-phone" aria-hidden="true"></span> {{isTouch | boolean:["Touch","Mouse"]}}' + 
      '</button>',
    link: link
  };
}]);
