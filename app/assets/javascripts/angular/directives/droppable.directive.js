app.directive('ngDroppable', function() {
    return function (scope, element, attrs) {
        scope.$watch(attrs.ngDroppable, function (value) {
          element.droppable(value);
        });
    }
});
