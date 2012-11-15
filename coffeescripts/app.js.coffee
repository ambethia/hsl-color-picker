window.hsl = {}

$(document).ready ->
  window.hsl.color = new window.hsl.Color()
  window.hsl.values = new window.hsl.Values(model: window.hsl.color)
  window.hsl.picker = new window.hsl.Picker(model: window.hsl.color).render()

window.hsl.Values = $.View.extend
  initialize: ->
    @.setElement $('#hslpicker')
    @model.on 'change:h', @setHue, this
    @model.on 'change:s', @setSat, this
    @model.on 'change:l', @setLum, this
    @model.on 'change:a', @setAlpha, this
    @model.on 'change:a', @changeRgb, this
    @model.on 'change:hex', @changeHex, this
    @model.on 'change:rgb', @changeRgb, this

  events:
    'keydown #controls input': 'bumpHsl'
    'keyup #controls input': 'editHsl'
    'keyup #colors input': 'changeColor'

  changeColor: (e) ->
    el = $(e.target)
    switch el.attr('id')
      when 'rgba' then @model.rgba(el.val()) unless @model.rgba() is el.val()
      when 'hex' then @model.hex el.val() unless @model.hex() is el.val()
      when 'hsla' then @model.hsla el.val() unless @model.hsla() is el.val()

  bumpHsl: (e) ->
    if e.keyCode is 38 or e.keyCode is 40
      part = $(e.target).attr('id')
      shift = if e.shiftKey then 10 else 1
      shift = -(shift) if e.keyCode is 40
      @bumpValue(part, shift) 
      e.preventDefault()

  bumpValue: (part, shift) ->
    current = @model.get(part)
    val = current + shift
    switch part
      when 'h' then @model.h val
      when 's' then @model.s val
      when 'l' then @model.l val
      when 'a' then @model.a Math.round(current*100 + shift)/100

  editHsl: (e)->
    el = $(e.target)
    id = el.attr 'id'
    switch id
      when 'h' then @model.h parseInt el.val()
      when 's' then @model.s parseInt el.val()
      when 'l' then @model.l parseInt el.val()
      when 'a' then @model.a parseFloat el.val()

  setTile: ->
    $('#color').css 'background-color': @model.hsla()

  changeHex: ->
    @update $('#hex'), @model.get 'hex'

  changeRgb: ->
    @update $('#rgba'), @model.rgba()

  changeHsl: ->
    @update $('#hsla'), @model.hsla()

  setHue: ->
    @update $('#h'), @model.get('h')
    @changeHsl()
    @setTile()
  setSat: ->
    @update $('#s'), @model.get('s')
    @changeHsl()
    @setTile()
  setLum: ->
    @update $('#l'), @model.get('l')
    @changeHsl()
    @setTile()
  setAlpha: ->
    @update $('#a'), @model.get('a')
    @changeHsl()
    @setTile()

  update: (el, val)->
    el.val "#{val}" unless el.val() is "#{val}"


window.hsl.Picker = $.View.extend

  initialize: ->
    @.setElement $('#controls')
    @model.hsla [$._.random(0, 360), 100, 50, 1]

  render: ->
    @hueSlider = @$('#hue-slider').dragdealer
      slide: false
      steps: 360
      speed: 100
      x: @model.get('h')/360
      
    @satSlider = @$('#saturation-slider').dragdealer
      slide: false
      speed: 100
      x: @model.get('s')/100
    

    @lumSlider = @$('#luminosity-slider').dragdealer
      slide: false
      speed: 100
      x: @model.get('l')/100

    @alphaSlider = @$('#alpha-slider').dragdealer
      slide: false
      speed: 100
      x: @model.get 'a'
    
    @hueSlider.animationCallback = (x,y)=> @model.h Math.round(x*360)
    @satSlider.animationCallback = (x,y)=> @model.s Math.round(x*100)
    @lumSlider.animationCallback = (x,y)=> @model.l Math.round(x*100)
    @alphaSlider.animationCallback = (x,y)=> @model.a Math.round(x*100)/100

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

  defaults: {}

  updateRgb: (rgba) ->
    rgba or= @hslToRgb @hsla(true)
    @.set rgb: [rgba[0], rgba[1], rgba[2]]
    rgba

  updateHsl: (hsla)->
    @.set h: hsla[0], s: hsla[1], l: hsla[2]

  updateHex: (rgba) ->
    @.set hex: @rgbToHex rgba or @rgba(true)

  h: (h) ->
    unless @.get('h') is h
      h = @limit(h, 360)
      @.set h: h
      @updateHex @updateRgb()
      h

  s: (s) ->
    unless @.get('s') is s
      s = @limit(s, 100)
      @.set s: s
      @updateHex @updateRgb()
      s

  l: (l) ->
    unless @.get('l') is l
      l = @limit(l, 100)
      @.set l: l
      @updateHex @updateRgb()
      l

  a: (a) ->
    unless @.get('a') is a
      a = @limit(a, 1)
      @.set a: a
      a

  # Set hsla or get its current value as an array or string
  hsla: (hsla = false) ->
    if $._.isArray(hsla) or typeof hsla is 'string'
      hsla = @isHsl(hsla)
      if hsla
        @updateHex @updateRgb(@hslToRgb hsla)
        @updateHsl hsla
        @.set a: hsla[3] or 1
        hsla
      else
        false
    else if hsla
      [@.get('h'), @.get('s'), @.get('l'), @.get('a')]
    else
      "hsla(#{@.get('h')}, #{@.get('s')}%, #{@.get('l')}%, #{@.get('a')})"


  rgba: (rgba = false) ->
    if $._.isArray(rgba) or typeof rgba is 'string'
      rgba = @isRgb(rgba)
      if rgba
        @.set rgb: [rgba[0], rgba[1], rgba[2]], a: rgba[3] or 1
        @updateHex(rgba)
        @updateHsl(@rgbToHsl rgba)
      else
        false
    else if rgba
      g = @.get('rgb').concat @.get('a')
      g
    else
      rgb = @.get('rgb')
      "rgba(#{rgb[0]}, #{rgb[1]}, #{rgb[2]}, #{@.get('a')})"

  hex: (hex) ->
    if hex?
      hex = @isHex(hex)
      if hex
        @.set hex: hex
        rgba = @hexToRgb hex
        @updateRgb rgba
        @.set a: rgba[3] or 1
        @updateHsl(@rgbToHsl rgba)
      else
        false
    else
      @.get 'hex'

  limit: (val, finish=100) ->
    if val < 0
      0
    else if val > finish
      finish
    else
      val
    
  isHex: (hex, marker = true) -> 
    match = hex.match(/^(#)?([0-9a-fA-F]{3})([0-9a-fA-F]{3})?$/)?.slice(2)
    return false unless match?

    color = $._.compact(match).join('')
    if marker then '#'+color else color

  isRgb: (rgb) -> 
    if typeof rgb is 'string'
      match = rgb.match(/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,?\s*(0?\.?\d{1,2})?\s*\)$/)?.slice(1)
      return false unless match?
      rgb = (parseFloat c for c in $._.compact(match))
    rgb[3] or= 1 # If there isn't an alpha value already
    valid = rgb[0] <= 255 and rgb[1] <= 255 and rgb[2] <= 255 and rgb[3] <= 1
    if valid then rgb else false

  isHsl: (hsl) -> 
    if typeof hsl is 'string'
      match = hsl.match(/hsla?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\%\s*,\s*(\d{1,3})\%\s*,?\s*(\.?\d{1,2})?\s*\)$/)?.slice(1)
      return false unless match?
      hsl = (parseFloat c for c in $._.compact(match))
    hsl[3] or= 1 # If there isn't an alpha value already
    valid = hsl[0] <= 360 and hsl[1] <= 100 and hsl[2] <= 100 and hsl[3] <= 1
    if valid then hsl else false

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
    hex = @isHex hex, false
    return false unless hex

    hex = ("#{c}#{c}" for c in hex).join('') if hex.length isnt 6 # expand the short hex by doubling each character, fc0 -> ffcc00
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
