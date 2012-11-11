window.hsl = {}

$(document).ready ->
  window.hsl.color = new window.hsl.Color()
  window.hsl.picker = new window.hsl.Picker(model: window.hsl.color).render()
  window.hsl.tile = new window.hsl.Tile(model: window.hsl.color).render()
  window.hsl.values = new window.hsl.Values(model: window.hsl.color).render()

window.hsl.Tile = $.View.extend

  initialize: ->
    @.setElement $('#color')
    @model.on 'change', @render, this

  render: ->
    @$el.css 'background-color': @model.hsla()

window.hsl.Values = $.View.extend
  initialize: ->
    @model.on 'change', @render, this

  render: ->
    $('#hue').attr 'value', @model.get('h')
    $('#saturation').attr 'value', "#{@model.get('s')}%"
    $('#luminosity').attr 'value', "#{@model.get('l')}%"
    $('#alpha').attr 'value', @model.get('a')

    $('#hex').attr 'value', @model.hex()
    $('#rgba').attr 'value', @model.rgba()
    $('#hsla').attr 'value', @model.hsla()

window.hsl.Picker = $.View.extend

  initialize: ->
    @.setElement $('#controls')

  render: ->
    @hueSlider = @$('#hue-slider').dragdealer
      slide: false
      steps: 360
      speed: 100
      x: @model.get('h')/360
      snap: true
      animationCallback: (x,y)=> @model.set h: Math.round(x*360)
      
    @satSlider = @$('#saturation-slider').dragdealer
      slide: false
      steps: 100
      speed: 100
      xPrecision: 360
      x: @model.get('s')/100
      snap: true
      animationCallback: (x,y)=> @model.set s: Math.round(x*100)

    @lumSlider = @$('#luminosity-slider').dragdealer
      slide: false
      steps: 100
      speed: 100
      x: @model.get('l')/100
      snap: true
      animationCallback: (x,y)=> @model.set l: Math.round(x*100)

    @alphaSlider = @$('#alpha-slider').dragdealer
      slide: false
      steps: 100
      speed: 100
      x: @model.get 'a'
      snap: true
      animationCallback: (x,y)=> @model.set a: Math.round(x*100)/100

    @model.on 'change:h', @setHue, this
    @model.on 'change:s', @setSat, this
    @model.on 'change:l', @setLum, this
    @model.on 'change:a', @setAlpha, this

  setHue: ->
    @setSlider @hueSlider, @model.get('h'), 360
  setSat: ->
    @setSlider @satSlider, @model.get('s'), 100
  setLum: ->
    @setSlider @lumSlider, @model.get('l'), 100
  setAlpha: ->
    @setSlider @alphaSlider, @model.get('a')*100, 100

  # Sliders update the model, firing the change event, which will trigger setting the sliders
  # This compares the current values and prevents an unnecessary update.
  setSlider: (slider, value, factor)->
    unless Math.round(slider.value.current[0]*factor) is Math.round(value)
      slider.setValue value/factor

window.hsl.Color = $.Model.extend

  defaults:
    h: $._.random(0, 360)
    s: 100
    l: 50
    a: 1
    r: null
    g: null
    b: null
    hex: null

  initialize: ->
    @.on 'change', @setColors, this

  setColors: ->
    rgba = @hslToRgb @hsla(true)
    @.set r: rgba[0], g: rgba[1], b: rgba[2]
    @.set hex: @rgbToHex rgba

  hsla: (array = false) ->
    if array
      [@.get('h'), @.get('s'), @.get('l'), @.get('a')]
    else
      "hsla(#{@.get('h')}, #{@.get('s')}%, #{@.get('l')}%, #{@.get('a')})"

  rgba: (array = false)->
    if array
      [@.get('r'), @.get('g'), @.get('b'), @.get('a')]
    else
      "rgba(#{@.get('r')}, #{@.get('g')}, #{@.get('b')}, #{@.get('a')})"

  hex: ->
    @hslToHex @hsla(true)

  isHex: (hex) -> 
    match = hex.match(/^(#)?([0-9a-fA-F]{3})([0-9a-fA-F]{3})?$/)?.slice(2)
    return false unless match?

    color = $._.compact(match).join('')
    color = ("#{c}#{c}" for c in color).join('') if color.length isnt 6 # expand the short hex by doubling each character, fc0 -> ffcc00
    '#'+color

  isRgb: (rgb) -> 
    match = rgb.match(/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,?\s*(0?\.?\d{1,2})?\s*\)$/)?.slice(1)
    return false unless match?

    color = (parseFloat c for c in $._.compact(match))
    color.push 1 if color.length is 3
    valid = color[0] <= 255 and color[1] <= 255 and color[2] <= 255 and color[3]? <= 1
    if valid then color else false

  isHsl: (hsl) -> 
    match = hsl.match(/hsla?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\%\s*,\s*(\d{1,3})\%\s*,?\s*(\.?\d{1,2})?\s*\)$/)?.slice(1)
    if match?
      color = $._.compact(match)
      color.push 1 if color.length is 3
      valid = parseInt(color[0]) <= 360 and parseInt(color[1]) <= 100 and parseInt(color[2]) <= 100 and parseFloat(color[3]) <= 1
      if valid then color else false
    else
      false

  valid: (color) -> 
    type = @type color
    if type is 'hex' then @isHex(color)
    else if type is 'rgb' then @isRgb(color)
    else if type is 'hsl' then @isHsl(color)
    else false

  type: (color) ->
    str = color.toString()
    type = 
      if str.indexOf('#') >= 0 or str.length is 3 or str.length is 6
        'hex'
      else if str.indexOf('%')
        'hsl'
      else
        'rgb'

  hexToRgb: (hex) ->
    hex = @isHex hex
    return false unless hex

    color = hex.match(/#?(.{2})(.{2})(.{2})/).slice(1)
    color = (parseInt(c, 16) for c in color).concat [1]
  
  hexToHsl: (hex) ->
    hex = @isHex hex if hex.indexOf('#') >= 0 or hex.length < 6
    return false unless hex
    @rgbToHsl @hexToRgb(hex)

  rgbToHex: (rgb) ->
    rgb = @isRgb rgb if typeof rgb is 'string'
    if rgb
      hex = (parseFloat(c).toString(16) for c in rgb.slice(0,3))
      hex = for c in hex
        if c.length is 1 then "0#{c}" else c
      '#'+hex.join('').toUpperCase()

  rgbToHsl: (rgb) ->
    rgb = @isRgb rgb if typeof rgb is 'string'
    return false unless rgb

    r = parseFloat(rgb[0]) / 255
    g = parseFloat(rgb[1]) / 255
    b = parseFloat(rgb[2]) / 255

    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    diff = max - min
    add = max + min

    hue =
      if min is max
        0
      else if r is max
        ((60 * (g - b) / diff) + 360) % 360
      else if g is max
        (60 * (b - r) / diff) + 120
      else 
        (60 * (r - g) / diff) + 240

    lum = 0.5 * add

    sat =
      if lum is 0
        0
      else if lum is 1
        1
      else if lum <= 0.5
        diff / add
      else 
        diff / (2 - add)

    h = Math.round hue
    s = Math.round sat*100
    l = Math.round lum*100
    a = parseFloat(rgb[3]) or 1

    [h,s,l,a]
  

  hslToRgb: (hsl) ->
    if typeof hsl is 'string'
      hsl = @isHsl hsl
    return false unless hsl

    hue = parseInt(hsl[0]) / 360
    sat = parseInt(hsl[1]) / 100
    lum = parseInt(hsl[2]) / 100

    q = if lum <= .5 
      lum * (1 + sat)
    else
      lum + sat - (lum * sat)

    p = 2 * lum - q

    rt = hue + (1/3)
    gt = hue
    bt = hue - (1/3)

    r = Math.round @hueToRgb(p, q, rt) * 255
    g = Math.round @hueToRgb(p, q, gt) * 255
    b = Math.round @hueToRgb(p, q, bt) * 255
    a = parseFloat(hsl[3]) or 1

    [r,g,b,a]

  hslToHex: (hsl) ->
    hsl = @isHsl hsl if typeof hsl is 'string'
    return false unless hsl
    @rgbToHex @hslToRgb(hsl)

  hueToRgb: (p, q, h) ->
    h += 1 if h < 0
    h -= 1 if h > 1

    if (h * 6) < 1 
      p + (q - p) * h * 6
    else if (h * 2) < 1
      q
    else if (h * 3) < 2
      p + (q - p) * ((2 / 3) - h) * 6
    else 
      p
