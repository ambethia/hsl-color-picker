(function() {

  window.hsl = {};

  $(document).ready(function() {
    window.hsl.color = new window.hsl.Color();
    window.hsl.picker = new window.hsl.Picker({
      model: window.hsl.color
    }).render();
    window.hsl.tile = new window.hsl.Tile({
      model: window.hsl.color
    }).render();
    return window.hsl.values = new window.hsl.Values({
      model: window.hsl.color
    }).render();
  });

  window.hsl.Tile = $.View.extend({
    initialize: function() {
      this.setElement($('#color'));
      return this.model.on('change', this.render, this);
    },
    render: function() {
      return this.$el.css({
        'background-color': this.model.hsla()
      });
    }
  });

  window.hsl.Values = $.View.extend({
    initialize: function() {
      return this.model.on('change', this.render, this);
    },
    render: function() {
      $('#hue').attr('value', this.model.get('h'));
      $('#saturation').attr('value', "" + (this.model.get('s')) + "%");
      $('#luminosity').attr('value', "" + (this.model.get('l')) + "%");
      $('#alpha').attr('value', this.model.get('a'));
      $('#hex').attr('value', this.model.hex());
      $('#rgba').attr('value', this.model.rgba());
      return $('#hsla').attr('value', this.model.hsla());
    }
  });

  window.hsl.Picker = $.View.extend({
    initialize: function() {
      return this.setElement($('#controls'));
    },
    render: function() {
      var _this = this;
      this.hueSlider = this.$('#hue-slider').dragdealer({
        slide: false,
        steps: 360,
        speed: 100,
        x: this.model.get('h') / 360,
        snap: true,
        animationCallback: function(x, y) {
          return _this.model.set({
            h: Math.round(x * 360)
          });
        }
      });
      this.satSlider = this.$('#saturation-slider').dragdealer({
        slide: false,
        steps: 100,
        speed: 100,
        xPrecision: 360,
        x: this.model.get('s') / 100,
        snap: true,
        animationCallback: function(x, y) {
          return _this.model.set({
            s: Math.round(x * 100)
          });
        }
      });
      this.lumSlider = this.$('#luminosity-slider').dragdealer({
        slide: false,
        steps: 100,
        speed: 100,
        x: this.model.get('l') / 100,
        snap: true,
        animationCallback: function(x, y) {
          return _this.model.set({
            l: Math.round(x * 100)
          });
        }
      });
      this.alphaSlider = this.$('#alpha-slider').dragdealer({
        slide: false,
        steps: 100,
        speed: 100,
        x: this.model.get('a'),
        snap: true,
        animationCallback: function(x, y) {
          return _this.model.set({
            a: Math.round(x * 100) / 100
          });
        }
      });
      this.model.on('change:h', this.setHue, this);
      this.model.on('change:s', this.setSat, this);
      this.model.on('change:l', this.setLum, this);
      return this.model.on('change:a', this.setAlpha, this);
    },
    setHue: function() {
      return this.setSlider(this.hueSlider, this.model.get('h'), 360);
    },
    setSat: function() {
      return this.setSlider(this.satSlider, this.model.get('s'), 100);
    },
    setLum: function() {
      return this.setSlider(this.lumSlider, this.model.get('l'), 100);
    },
    setAlpha: function() {
      return this.setSlider(this.alphaSlider, this.model.get('a') * 100, 100);
    },
    setSlider: function(slider, value, factor) {
      if (Math.round(slider.value.current[0] * factor) !== Math.round(value)) {
        return slider.setValue(value / factor);
      }
    }
  });

  window.hsl.Color = $.Model.extend({
    defaults: {
      h: $._.random(0, 360),
      s: 100,
      l: 50,
      a: 1,
      r: null,
      g: null,
      b: null,
      hex: null
    },
    initialize: function() {
      return this.on('change', this.setColors, this);
    },
    setColors: function() {
      var rgba;
      rgba = this.hslToRgb(this.hsla(true));
      this.set({
        r: rgba[0],
        g: rgba[1],
        b: rgba[2]
      });
      return this.set({
        hex: this.rgbToHex(rgba)
      });
    },
    hsla: function(array) {
      if (array == null) {
        array = false;
      }
      if (array) {
        return [this.get('h'), this.get('s'), this.get('l'), this.get('a')];
      } else {
        return "hsla(" + (this.get('h')) + ", " + (this.get('s')) + "%, " + (this.get('l')) + "%, " + (this.get('a')) + ")";
      }
    },
    rgba: function(array) {
      if (array == null) {
        array = false;
      }
      if (array) {
        return [this.get('r'), this.get('g'), this.get('b'), this.get('a')];
      } else {
        return "rgba(" + (this.get('r')) + ", " + (this.get('g')) + ", " + (this.get('b')) + ", " + (this.get('a')) + ")";
      }
    },
    hex: function() {
      return this.hslToHex(this.hsla(true));
    },
    isHex: function(hex) {
      var c, color, match, _ref;
      match = (_ref = hex.match(/^(#)?([0-9a-fA-F]{3})([0-9a-fA-F]{3})?$/)) != null ? _ref.slice(2) : void 0;
      if (match == null) {
        return false;
      }
      color = $._.compact(match).join('');
      if (color.length !== 6) {
        color = ((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = color.length; _i < _len; _i++) {
            c = color[_i];
            _results.push("" + c + c);
          }
          return _results;
        })()).join('');
      }
      return '#' + color;
    },
    isRgb: function(rgb) {
      var c, color, match, valid, _ref;
      match = (_ref = rgb.match(/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,?\s*(0?\.?\d{1,2})?\s*\)$/)) != null ? _ref.slice(1) : void 0;
      if (match == null) {
        return false;
      }
      color = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = $._.compact(match);
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          c = _ref1[_i];
          _results.push(parseFloat(c));
        }
        return _results;
      })();
      if (color.length === 3) {
        color.push(1);
      }
      valid = color[0] <= 255 && color[1] <= 255 && color[2] <= 255 && (color[3] != null) <= 1;
      if (valid) {
        return color;
      } else {
        return false;
      }
    },
    isHsl: function(hsl) {
      var color, match, valid, _ref;
      match = (_ref = hsl.match(/hsla?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\%\s*,\s*(\d{1,3})\%\s*,?\s*(\.?\d{1,2})?\s*\)$/)) != null ? _ref.slice(1) : void 0;
      if (match != null) {
        color = $._.compact(match);
        if (color.length === 3) {
          color.push(1);
        }
        valid = parseInt(color[0]) <= 360 && parseInt(color[1]) <= 100 && parseInt(color[2]) <= 100 && parseFloat(color[3]) <= 1;
        if (valid) {
          return color;
        } else {
          return false;
        }
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
      hex = this.isHex(hex);
      if (!hex) {
        return false;
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
