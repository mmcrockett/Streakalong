app.factory('DateHelper', ['$log', '$interval', function(Logger, $interval) {
  return function() {
    this.today        = null;
    this.selectedDate = null;
    this.display_dates = [];

    this.initialize = function() {
      this.today = new Date();
      this.today.setHours(0,0,0,0);
      this.change_date(0);
      $interval(this.change_current_date, 1000*60*15);
    };

    this.is_today = function(d) {
      if (true == angular.isObject(this.today)) {
        return (this.today.getTime() == d.getTime());
      } else {
        return false;
      }
    };

    this.show_datepicker = function() {
      this.isOpen = true;
    };

    this.set_display_dates = function() {
      if (false == angular.isDate(this.selectedDate)) {
        this.selectedDate = this.today;
      }

      this.display_dates = [this.selectedDate.ago(1), this.selectedDate, this.selectedDate.ago(-1)];
    };

    this.change_date = function(offset) {
      if (0 == offset) {
        this.selectedDate = this.today;
      } else {
        this.selectedDate = this.selectedDate.ago(-offset);
      }
    };

    this.change_current_date = function() {
      var now = new Date();
      now.setHours(0,0,0,0);

      if (false == this.is_today(now)) {
        if (true == this.is_today(this.selectedDate)) {
          this.today = new Date(now);
          this.change_date(0);
        }
      }
    };
  };
}]);
