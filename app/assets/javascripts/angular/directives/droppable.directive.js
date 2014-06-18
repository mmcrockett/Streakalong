app.directive('ngDroppable', function($compile) {
  return function (scope, element, attrs) {
    scope.$watch(attrs.ngDroppable, function (value) {
      value['drop'] = function(e, ui){
        scope.$apply(function() {
          var dragElem = jQuery(ui.draggable);
          scope.update_amount(1, dragElem.attr('item-id'), scope.rel_date);
        });
      };
      element.droppable(value);
    });
  }
});
