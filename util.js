(function() {
  var _ref;
  var __slice = Array.prototype.slice;
  if ((_ref = window.console) == null) {
    window.console = {};
  }
  console.p = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (window.location.hostname === "localhost") {
      return console.log.apply(console, args);
    }
  };
}).call(this);
