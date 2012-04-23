(function() {
  var BROWSER_INFO, browser_info_hash, default_cb, version_compare;
  BROWSER_INFO = {
    mozilla: {
      to_s: 'Mozilla Firefox',
      url: 'http://www.firefox.com'
    },
    msie: {
      to_s: 'Internet Explorer',
      url: 'http://www.microsoft.com/ie/'
    },
    opera: {
      to_s: 'Opera',
      url: 'http://www.opera.com/download/'
    },
    chrome: {
      to_s: 'Google Chrome',
      url: 'http://www.google.com/chrome'
    },
    safari: {
      to_s: 'Safari',
      url: 'http://www.apple.com/safari/download/'
    }
  };
  version_compare = function(v1, v2) {
    var a, b, i, p, q, valueOf, values, _ref;
    valueOf = function(t) {
      if (isNaN(t)) {
        return t.charCodeAt(0);
      } else {
        return Number(t) - Math.pow(2, 32);
      }
    };
    values = [v1, v2].map(function(s) {
      return s.toString().toLowerCase().match(/([a-z]|[0-9]+(?:\.[0-9]+)?)/ig);
    });
    a = values[0];
    b = values[1];
    for (i = 0, _ref = Math.min(a.length, b.length); 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      p = valueOf(a[i]);
      q = valueOf(b[i]);
      if (p !== q) {
        return p - q;
      }
    }
    return a.length - b.length;
  };
  browser_info_hash = function() {
    var browser, v, version, _ref;
    browser = {
      ua: navigator.userAgent.toLowerCase(),
      version: $.browser.version
    };
    if ($.browser.mozilla) {
      browser.flag = 'mozilla';
    }
    if ($.browser.msie) {
      browser.flag = 'msie';
    }
    if ($.browser.opera) {
      browser.flag = 'opera';
    }
    if (!(browser.flag != null) && /chrome/.test(browser.ua)) {
      browser.flag = 'chrome';
    }
    if (!(browser.flag != null) && /safari/.test(browser.ua)) {
      browser.flag = 'safari';
    }
    if ((_ref = browser.flag) === 'chrome' || _ref === 'safari') {
      v = browser.flag === 'chrome' ? 'chrome' : 'version';
      version = browser.ua.substring(browser.ua.indexOf("" + v + "/") + v.length + 1);
      browser.version = version.split(" ")[0];
    }
    return browser;
  };
  default_cb = function(browser, content, min_version) {
    var info, modal;
    info = BROWSER_INFO[browser.flag];
    if (min_version) {
      if (content == null) {
        content = "<h1>Please upgrade your browser.</h1>    <h2>This site requires " + info.to_s + " " + min_version + " or higher.</h2>    <h3><a href='" + info.url + "' target='_blank'>Download the newest " + info.to_s + " &rarr;</a></h3>";
      }
    } else {
      if (content == null) {
        content = "<h1>Please use a different browser.</h1>    <h2>This site does not work on " + info.to_s + ".</h2>";
      }
    }
    modal = "<div class='jqmWrap'><div class=jqmInner>" + content + "</div></div>";
    return $(modal).appendTo("body").jqm({
      trigger: false,
      modal: true
    }).jqmShow();
  };
  $.extend({
    deprecate: function(opts, cb) {
      var browser;
      browser = browser_info_hash();
      if (cb == null) {
        cb = default_cb;
      }
      return $.each(opts, function(flag, min_version) {
        if (browser.flag !== flag) {
          return true;
        }
        if (!min_version || version_compare(min_version, browser.version) > 0) {
          return cb(browser, opts.content, min_version);
        }
      });
    }
  });
}).call(this);