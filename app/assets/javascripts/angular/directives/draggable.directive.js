app.directive('streakalongNgDraggable', function() {
  return function (scope, element, attrs) {
    scope.$watch(attrs.streakalongNgDraggable, function (value) {
      element.draggable(value);
      if (true == angular.isDate(scope.rel_date)) {
        element.data('item-date', scope.rel_date);
      }
    });
  }
});
