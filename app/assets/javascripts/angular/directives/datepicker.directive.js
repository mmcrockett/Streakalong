app.directive('ngDatePicker', function() {
    return function (scope, element, attrs) {
        scope.$watch(attrs.ngDatePicker, function (value) {
          element.datepicker({ showOn: 'button', buttonText: '', showButtonPanel: true}).datepicker("setDate", "0");
          scope.selected_date = element.datepicker("getDate");
        });
    }
});
