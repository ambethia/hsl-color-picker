(function() {

  window.hsl = {};

  $(document).ready(function() {
    var color, hexHash, inputs;
    color = new window.hsl.Color();
    hexHash = function() {
      return color.isHex(window.location.hash);
    };
    inputs = new window.hsl.Inputs({
      model: color,
      el: '#hslpicker'
    });
    return window.picker = new window.hsl.Picker({
      model: color,
      el: '#controls',
      hex: hexHash()
    }).render();
  });

  window.hsl.Inputs = $.View.extend({
    initialize: function(options) {
      this.setElement($(options.el));
      this.model.on('change:h', this.setHue, this);
      this.model.on('change:s', this.setSat, this);
      this.model.on('change:l', this.setLum, this);
      this.model.on('change:a', this.setAlpha, this);
      this.model.on('change:a', this.changeRgb, this);
      this.model.on('change:hex', this.changeHex, this);
      return this.model.on('change:rgb', this.changeRgb, this);
    },
    events: {
      'keydown #controls input': 'bumpHsl',
      'keyup #controls input': 'editHsl',
      'keyup #colors input': 'changeColor'
    },
    changeColor: function(e) {
      var el;
      el = $(e.target);
      switch (el.attr('id')) {
        case 'rgba':
          if (this.model.rgbaStr() !== el.val()) {
            return this.model.rgba(el.val());
          }
          break;
        case 'hex':
          if (this.model.hex() !== el.val()) {
            return this.model.hex(el.val());
          }
          break;
        case 'hsla':
          if (this.model.hslaStr() !== el.val()) {
            return this.model.hsla(el.val());
          }
      }
    },
    bumpHsl: function(e) {
      var part, shift;
      if (e.keyCode === 38 || e.keyCode === 40) {
        part = $(e.target).attr('id');
        shift = e.shiftKey ? 10 : 1;
        if (e.keyCode === 40) {
          shift = -shift;
        }
        this.bumpValue(part, shift);
        return e.preventDefault();
      }
    },
    bumpValue: function(part, shift) {
      var current, val;
      current = this.model.get(part);
      val = current + shift;
      switch (part) {
        case 'h':
          return this.model.h(val);
        case 's':
          return this.model.s(val);
        case 'l':
          return this.model.l(val);
        case 'a':
          return this.model.a(Math.round(current * 100 + shift) / 100);
      }
    },
    editHsl: function(e) {
      var el, id;
      el = $(e.target);
      id = el.attr('id');
      switch (id) {
        case 'h':
          return this.model.h(parseInt(el.val()));
        case 's':
          return this.model.s(parseInt(el.val()));
        case 'l':
          return this.model.l(parseInt(el.val()));
        case 'a':
          return this.model.a(parseFloat(el.val()));
      }
    },
    setTile: function() {
      return $('#color').css({
        'background-color': this.model.hslaStr()
      });
    },
    changeHex: function() {
      this.update($('#hex'), this.model.get('hex'));
      return this.update($('#url'), 'http://hslpicker.com' + this.model.get('hex'));
    },
    changeRgb: function() {
      return this.update($('#rgba'), this.model.rgbaStr());
    },
    changeHsl: function() {
      return this.update($('#hsla'), this.model.hslaStr());
    },
    setHue: function() {
      this.update($('#h'), this.model.get('h'));
      this.changeHsl();
      return this.setTile();
    },
    setSat: function() {
      this.update($('#s'), this.model.get('s'));
      this.changeHsl();
      return this.setTile();
    },
    setLum: function() {
      this.update($('#l'), this.model.get('l'));
      this.changeHsl();
      return this.setTile();
    },
    setAlpha: function() {
      this.update($('#a'), this.model.get('a'));
      this.changeHsl();
      return this.setTile();
    },
    update: function(el, val) {
      if (el.val() !== ("" + val)) {
        return el.val("" + val);
      }
    }
  });

  window.hsl.Picker = $.View.extend({
    initialize: function(options) {
      var _ref, _ref1, _ref2;
      this.setElement($(options.el));
      if (((_ref = options.hex) != null ? _ref.length : void 0) && this.model.isHex(options.hex)) {
        return this.model.hex(options.hex);
      } else if (((_ref1 = options.rgba) != null ? _ref1.length : void 0) && this.model.isRgb(options.rgba)) {
        return this.model.rgb(options.rgba);
      } else if (((_ref2 = options.hsla) != null ? _ref2.length : void 0) && this.model.isHsl(options.hsla)) {
        return this.model.hsla(options.hsla);
      } else {
        return this.model.hsla([$._.random(0, 360), 100, 50, 1]);
      }
    },
    render: function() {
      var _this = this;
      this.hueSlider = this.$('#h-slider').dragdealer({
        slide: false,
        steps: 360,
        speed: 100,
        x: this.model.get('h') / 360,
        animationCallback: function(x, y) {
          var hue;
          hue = Math.round(x * 360);
          if (_this.model.get('h') !== hue) {
            return _this.model.h(hue);
          }
        }
      });
      this.satSlider = this.$('#s-slider').dragdealer({
        slide: false,
        speed: 100,
        x: this.model.get('s') / 100,
        animationCallback: function(x, y) {
          var sat;
          sat = Math.round(x * 100);
          if (_this.model.get('s') !== sat) {
            return _this.model.s(sat);
          }
        }
      });
      this.lumSlider = this.$('#l-slider').dragdealer({
        slide: false,
        speed: 100,
        x: this.model.get('l') / 100,
        animationCallback: function(x, y) {
          var lum;
          lum = Math.round(x * 100);
          if (_this.model.get('l') !== lum) {
            return _this.model.l(lum);
          }
        }
      });
      this.alphaSlider = this.$('#a-slider').dragdealer({
        slide: false,
        speed: 100,
        x: this.model.get('a'),
        animationCallback: function(x, y) {
          var alpha;
          alpha = Math.round(x * 100) / 100;
          if (_this.model.get('a') !== alpha) {
            return _this.model.a(alpha);
          }
        }
      });
      this.model.on('change:h', this.setHue, this);
      this.model.on('change:s', this.setSat, this);
      this.model.on('change:l', this.setLum, this);
      this.model.on('change:a', this.setAlpha, this);
      return this;
    },
    setHue: function() {
      this.setSlider(this.hueSlider, this.model.get('h'), 360);
      return this.updateSliderStyles('h');
    },
    setSat: function() {
      this.setSlider(this.satSlider, this.model.get('s'), 100);
      return this.updateSliderStyles('s');
    },
    setLum: function() {
      this.setSlider(this.lumSlider, this.model.get('l'), 100);
      return this.updateSliderStyles('l');
    },
    setAlpha: function() {
      this.setSlider(this.alphaSlider, this.model.get('a') * 100, 100);
      return this.updateSliderStyles('a');
    },
    setSlider: function(slider, value, factor) {
      if (Math.round(slider.value.current[0] * factor) !== Math.round(value)) {
        return slider.setValue(value / factor);
      }
    },
    updateSliderStyles: function(part) {
      var p, parts, _i, _len, _results;
      parts = $._.without(['h', 's', 'l', 'a'], part);
      _results = [];
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        p = parts[_i];
        _results.push(this.setSliderBg(p));
      }
      return _results;
    },
    setSliderBg: function(part) {
      return $("#" + part + "-slider").attr('style', "background: -webkit-" + (this.gradient(part)));
    },
    gradient: function(part) {
      var colors, multiplier, num, size;
      size = part === 'h' ? 36 : 2;
      multiplier = part === 'h' ? 10 : 50;
      colors = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 0; 0 <= size ? _i <= size : _i >= size; num = 0 <= size ? ++_i : --_i) {
          _results.push(this.model.hslaStr(this.tweakHsla(part, num * multiplier)));
        }
        return _results;
      }).call(this);
      return "linear-gradient(left, " + (colors.join(',')) + ");";
    },
    tweakHsla: function(part, value) {
      var color, pos;
      color = this.model.hsla();
      switch (part) {
        case 'h':
          pos = 0;
          break;
        case 's':
          pos = 1;
          break;
        case 'l':
          pos = 2;
          break;
        case 'a':
          pos = 3;
      }
      color.splice(pos, 1, value);
      return color;
    }
  });

  window.hsl.Color = $.Model.extend({
    defaults: {},
    updateRgb: function(rgba) {
      rgba || (rgba = this.hslToRgb(this.hsla()));
      this.set({
        rgb: [rgba[0], rgba[1], rgba[2]]
      });
      return rgba;
    },
    updateHsl: function(hsla) {
      return this.set({
        h: hsla[0],
        s: hsla[1],
        l: hsla[2]
      });
    },
    updateHex: function(rgba) {
      return this.set({
        hex: this.rgbToHex(rgba || this.rgba())
      });
    },
    h: function(h) {
      if (this.get('h') !== h) {
        h = this.limit(h, 360);
        this.set({
          h: h
        });
        this.updateHex(this.updateRgb());
        return h;
      }
    },
    s: function(s) {
      if (this.get('s') !== s) {
        s = this.limit(s, 100);
        this.set({
          s: s
        });
        this.updateHex(this.updateRgb());
        return s;
      }
    },
    l: function(l) {
      if (this.get('l') !== l) {
        l = this.limit(l, 100);
        this.set({
          l: l
        });
        this.updateHex(this.updateRgb());
        return l;
      }
    },
    a: function(a) {
      if (this.get('a') !== a) {
        a = this.limit(a, 1);
        this.set({
          a: a
        });
        return a;
      }
    },
    hsla: function(hsla) {
      if (hsla != null) {
        hsla = this.isHsl(hsla);
        if (hsla) {
          this.updateHex(this.updateRgb(this.hslToRgb(hsla)));
          this.updateHsl(hsla);
          this.set({
            a: hsla[3] || 1
          });
          return hsla;
        } else {
          return false;
        }
      } else {
        return [this.get('h'), this.get('s'), this.get('l'), this.get('a')];
      }
    },
    hslaStr: function(hsla) {
      hsla || (hsla = this.hsla());
      return "hsla(" + hsla[0] + ", " + hsla[1] + "%, " + hsla[2] + "%, " + hsla[3] + ")";
    },
    rgba: function(rgba) {
      if (rgba != null) {
        rgba = this.isRgb(rgba);
        if (rgba) {
          this.set({
            rgb: [rgba[0], rgba[1], rgba[2]],
            a: rgba[3] || 1
          });
          this.updateHex(rgba);
          return this.updateHsl(this.rgbToHsl(rgba));
        } else {
          return false;
        }
      } else {
        return this.get('rgb').concat(this.get('a'));
      }
    },
    rgbaStr: function() {
      var rgb;
      rgb = this.get('rgb');
      return "rgba(" + rgb[0] + ", " + rgb[1] + ", " + rgb[2] + ", " + (this.get('a')) + ")";
    },
    hex: function(hex) {
      var rgba;
      if (hex != null) {
        hex = this.isHex(hex);
        if (hex) {
          this.set({
            hex: hex
          });
          rgba = this.hexToRgb(hex);
          this.updateRgb(rgba);
          this.set({
            a: rgba[3] || 1
          });
          return this.updateHsl(this.rgbToHsl(rgba));
        } else {
          return false;
        }
      } else {
        return this.get('hex');
      }
    },
    limit: function(val, finish) {
      if (finish == null) {
        finish = 100;
      }
      if (val < 0) {
        return 0;
      } else if (val > finish) {
        return finish;
      } else {
        return val;
      }
    },
    isHex: function(hex, marker) {
      var color, match, _ref;
      if (marker == null) {
        marker = true;
      }
      match = (_ref = hex.match(/^(#)?([0-9a-fA-F]{3})([0-9a-fA-F]{3})?$/)) != null ? _ref.slice(2) : void 0;
      if (match == null) {
        return false;
      }
      color = $._.compact(match).join('');
      if (marker) {
        return '#' + color;
      } else {
        return color;
      }
    },
    isRgb: function(rgb) {
      var c, match, valid, _ref;
      if (typeof rgb === 'string') {
        match = (_ref = rgb.match(/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,?\s*(0?\.?\d{1,2})?\s*\)$/)) != null ? _ref.slice(1) : void 0;
        if (match == null) {
          return false;
        }
        rgb = (function() {
          var _i, _len, _ref1, _results;
          _ref1 = $._.compact(match);
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            c = _ref1[_i];
            _results.push(parseFloat(c));
          }
          return _results;
        })();
      }
      rgb[3] || (rgb[3] = 1);
      valid = rgb[0] <= 255 && rgb[1] <= 255 && rgb[2] <= 255 && rgb[3] <= 1;
      if (valid) {
        return rgb;
      } else {
        return false;
      }
    },
    isHsl: function(hsl) {
      var c, match, valid, _ref;
      if (typeof hsl === 'string') {
        match = (_ref = hsl.match(/hsla?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\%\s*,\s*(\d{1,3})\%\s*,?\s*(\.?\d{1,2})?\s*\)$/)) != null ? _ref.slice(1) : void 0;
        if (match == null) {
          return false;
        }
        hsl = (function() {
          var _i, _len, _ref1, _results;
          _ref1 = $._.compact(match);
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            c = _ref1[_i];
            _results.push(parseFloat(c));
          }
          return _results;
        })();
      }
      hsl[3] || (hsl[3] = 1);
      valid = hsl[0] <= 360 && hsl[1] <= 100 && hsl[2] <= 100 && hsl[3] <= 1;
      if (valid) {
        return hsl;
      } else {
        return false;
      }
    },
    valid: function(color) {
      var type;
      type = this.type(color);
      if (type === 'hex') {
        return this.isHex(color);
      } else if (type === 'rgb') {
        return this.isRgb(color);
      } else if (type === 'hsl') {
        return this.isHsl(color);
      } else {
        return false;
      }
    },
    type: function(color) {
      var str, type;
      str = color.toString();
      return type = str.indexOf('#') >= 0 || str.length === 3 || str.length === 6 ? 'hex' : str.indexOf('%') ? 'hsl' : 'rgb';
    },
    hexToRgb: function(hex) {
      var c, color;
      hex = this.isHex(hex, false);
      if (!hex) {
        return false;
      }
      if (hex.length !== 6) {
        hex = ((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = hex.length; _i < _len; _i++) {
            c = hex[_i];
            _results.push("" + c + c);
          }
          return _results;
        })()).join('');
      }
      color = hex.match(/#?(.{2})(.{2})(.{2})/).slice(1);
      return color = ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = color.length; _i < _len; _i++) {
          c = color[_i];
          _results.push(parseInt(c, 16));
        }
        return _results;
      })()).concat([1]);
    },
    hexToHsl: function(hex) {
      if (hex.indexOf('#') >= 0 || hex.length < 6) {
        hex = this.isHex(hex);
      }
      if (!hex) {
        return false;
      }
      return this.rgbToHsl(this.hexToRgb(hex));
    },
    rgbToHex: function(rgb) {
      var c, hex;
      if (typeof rgb === 'string') {
        rgb = this.isRgb(rgb);
      }
      if (rgb) {
        hex = (function() {
          var _i, _len, _ref, _results;
          _ref = rgb.slice(0, 3);
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(parseFloat(c).toString(16));
          }
          return _results;
        })();
        hex = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = hex.length; _i < _len; _i++) {
            c = hex[_i];
            if (c.length === 1) {
              _results.push("0" + c);
            } else {
              _results.push(c);
            }
          }
          return _results;
        })();
        return '#' + hex.join('').toUpperCase();
      }
    },
    rgbToHsl: function(rgb) {
      var a, add, b, diff, g, h, hue, l, lum, max, min, r, s, sat;
      if (typeof rgb === 'string') {
        rgb = this.isRgb(rgb);
      }
      if (!rgb) {
        return false;
      }
      r = parseFloat(rgb[0]) / 255;
      g = parseFloat(rgb[1]) / 255;
      b = parseFloat(rgb[2]) / 255;
      max = Math.max(r, g, b);
      min = Math.min(r, g, b);
      diff = max - min;
      add = max + min;
      hue = min === max ? 0 : r === max ? ((60 * (g - b) / diff) + 360) % 360 : g === max ? (60 * (b - r) / diff) + 120 : (60 * (r - g) / diff) + 240;
      lum = 0.5 * add;
      sat = lum === 0 ? 0 : lum === 1 ? 1 : lum <= 0.5 ? diff / add : diff / (2 - add);
      h = Math.round(hue);
      s = Math.round(sat * 100);
      l = Math.round(lum * 100);
      a = parseFloat(rgb[3]) || 1;
      return [h, s, l, a];
    },
    hslToRgb: function(hsl) {
      var a, b, bt, g, gt, hue, lum, p, q, r, rt, sat;
      if (typeof hsl === 'string') {
        hsl = this.isHsl(hsl);
      }
      if (!hsl) {
        return false;
      }
      hue = parseInt(hsl[0]) / 360;
      sat = parseInt(hsl[1]) / 100;
      lum = parseInt(hsl[2]) / 100;
      q = lum <= .5 ? lum * (1 + sat) : lum + sat - (lum * sat);
      p = 2 * lum - q;
      rt = hue + (1 / 3);
      gt = hue;
      bt = hue - (1 / 3);
      r = Math.round(this.hueToRgb(p, q, rt) * 255);
      g = Math.round(this.hueToRgb(p, q, gt) * 255);
      b = Math.round(this.hueToRgb(p, q, bt) * 255);
      a = parseFloat(hsl[3]) || 1;
      return [r, g, b, a];
    },
    hslToHex: function(hsl) {
      if (typeof hsl === 'string') {
        hsl = this.isHsl(hsl);
      }
      if (!hsl) {
        return false;
      }
      return this.rgbToHex(this.hslToRgb(hsl));
    },
    hueToRgb: function(p, q, h) {
      if (h < 0) {
        h += 1;
      }
      if (h > 1) {
        h -= 1;
      }
      if ((h * 6) < 1) {
        return p + (q - p) * h * 6;
      } else if ((h * 2) < 1) {
        return q;
      } else if ((h * 3) < 2) {
        return p + (q - p) * ((2 / 3) - h) * 6;
      } else {
        return p;
      }
    }
  });

}).call(this);
