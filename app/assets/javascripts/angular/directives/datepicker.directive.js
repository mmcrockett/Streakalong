app.directive('streakalongNgDatePicker', function() {
  return function (scope, element, attrs) {
    scope.$watch(attrs.streakalongNgDatePicker, function (value) {
      element.datepicker({showOn: 'button'
                          ,buttonText: ''
                          ,showButtonPanel: true
                          ,onClose: function(dText, dPicker) {
                            scope.$apply(function(){scope.set_display_dates(element.datepicker("getDate"));});
                          }
                        }).datepicker("setDate", "0");
      scope.set_display_dates(element.datepicker("getDate"));
      scope.datepicker_element = element;
    });
  }
});
