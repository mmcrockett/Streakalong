app.directive('streakalongNgEditable', function() {
  return {
    templateUrl: 'streakalong-ng-editable-template'
    ,link: function(scope, element, attrs) {
      var inputElem = element.find('input');
      scope.editorEnabled = false;
      var cancelFunction = function() {
        scope.$apply(function() {
          scope.editorEnabled = false;
        });
      };
      inputElem.blur(function(e) {
        cancelFunction();
      });
      inputElem.keydown(function(e) {
        if (13 == e.keyCode) {
          scope.process_amount(inputElem.val(), scope.item.item_id, scope.rel_date)
          cancelFunction();
        } else if (27 == e.keyCode) {
          cancelFunction();
        }
      });
      element.click(function(e) {
        scope.$apply(function() {
          scope.editorEnabled = true;
          inputElem.val(scope.item.amount);
          var intervalId = setInterval(function() {
            if (true == inputElem.is(":visible")) {
              inputElem.focus().select();
              clearInterval(intervalId);
            } else {
              console.warn("not visible");
            }
          }, 10);
        });
      });
    }
  };
});
