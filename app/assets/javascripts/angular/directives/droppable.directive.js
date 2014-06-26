app.directive('streakalongNgDroppable', function($compile) {
  return function (scope, element, attrs) {
    scope.$watch(attrs.streakalongNgDroppable, function (value) {
      value['drop'] = function(e, ui){
        scope.$apply(function() {
          var dragElem = jQuery(ui.draggable);
          var dragDate = dragElem.data('item-date');

          if (scope.rel_date != dragDate) {
            scope.process_amount("+1", dragElem.attr('item-id'), scope.rel_date);
            if (true == scope.isDayItem(dragElem.attr('category'))) {
              scope.process_amount("-1", dragElem.attr('item-id'), dragDate);
            }
          }
        });
      };
      element.droppable(value);
    });
  }
});
