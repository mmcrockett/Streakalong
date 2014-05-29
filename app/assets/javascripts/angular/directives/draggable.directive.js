app.directive('ngDraggable', function() {
    return function (scope, element, attrs) {
        scope.$watch(attrs.ngDraggable, function (value) {
          element.draggable(value);
        });
    }
});
