app.factory('DateHelper', ['$log', '$interval', function(Logger, $interval) {
  return function() {
    var FIFTEEN_MINUTES = _.constant(1000*60*15);
    this.today        = null;
    this.selectedDate = null;
    this.display_dates = [];

    this.initialize = function() {
      this.today = new Date();
      this.today.setHours(0,0,0,0);
      this.change_date(0);
      $interval(this.change_current_date, FIFTEEN_MINUTES());
    };

    this.is_today = _.bind(function(d) {
      if (true == angular.isObject(this.today)) {
        return (this.today.getTime() == d.getTime());
      } else {
        return false;
      }
    }, this);

    this.show_datepicker = _.bind(function() {
      this.isOpen = true;
    }, this);

    this.set_display_dates = _.bind(function() {
      if (false == angular.isDate(this.selectedDate)) {
        this.selectedDate = this.today;
      }

      this.display_dates = [this.selectedDate.ago(1), this.selectedDate, this.selectedDate.ago(-1)];
    }, this);

    this.change_date = _.bind(function(offset) {
      if (0 == offset) {
        this.selectedDate = this.today;
      } else {
        this.selectedDate = this.selectedDate.ago(-offset);
      }
    }, this);

    this.change_current_date = _.bind(function() {
      var now = new Date();
      now.setHours(0,0,0,0);

      if (false == this.is_today(now)) {
        if (true == this.is_today(this.selectedDate)) {
          this.today = new Date(now);
          this.change_date(0);
        }
      }
    }, this);
  };
}]);
