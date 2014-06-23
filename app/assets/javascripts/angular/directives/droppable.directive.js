app.directive('ngDroppable', function($compile) {
  return function (scope, element, attrs) {
    scope.$watch(attrs.ngDroppable, function (value) {
      value['drop'] = function(e, ui){
        scope.$apply(function() {
          var dragElem = jQuery(ui.draggable);
          var dragDate = dragElem.data('item-date');

          if (scope.rel_date != dragDate) {
            scope.update_amount(1, dragElem.attr('item-id'), scope.rel_date);
            if (true == scope.isDayItem(dragElem.attr('category'))) {
              scope.update_amount(-1, dragElem.attr('item-id'), dragDate);
            }
          }
        });
      };
      element.droppable(value);
    });
  }
});
