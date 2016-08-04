app.directive('streakalongNgEditable', function() {
  return {
    scope: {
      disableEditable: '=ngDisableEditable',
      item: '=ngItem',
      processAmount: '&ngProcessAmount',
      itemDate: '=ngDate'
    },
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
          scope.processAmount({expression:inputElem.val(), item_id:scope.item.item_id, d:scope.itemDate});
          cancelFunction();
        } else if (27 == e.keyCode) {
          cancelFunction();
        }
      });
      element.click(function(e) {
        scope.$apply(function() {
          if (true !== scope.disableEditable) {
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
          }
        });
      });
    }
  };
});
