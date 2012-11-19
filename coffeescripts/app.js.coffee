window.hsl = {}

$(document).ready ->


  window.color = color  = new window.hsl.Color()
  hexHash = ->
    color.isHex(window.location.hash)
  inputs = new window.hsl.Inputs(model: color, el: '#hslpicker')
  window.picker = new window.hsl.Picker(model: color, el: '#controls', hex: hexHash()).render()

window.hsl.Inputs = $.View.extend

  initialize: (options) ->
    @.setElement $(options.el)
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
    if @model[el.attr('id')](el.val()) then el.removeClass 'error' else el.addClass 'error'

  bumpHsl: (e) ->
    if e.keyCode is 38 or e.keyCode is 40
      part  = $(e.target).attr('id')
      shift = if e.shiftKey then 10 else 1
      shift = -(shift) if e.keyCode is 40
      @bumpValue part, shift 
      e.preventDefault()

  bumpValue: (part, shift) ->
    current = @model.get part
    val = if part is 'a' then Math.round(current*100 + shift)/100 else current + shift
    switch part
      when 'h'     then val = @gate val, 360
      when 's','l' then val = @gate val, 100
      when 'a'     then val = @gate val, 1
    @model[part] val

  gate: (val, finish) ->
    if val < 0 then 0
    else if val > finish then finish
    else val

  editHsl: (e)->
    el   = $(e.target)
    part = el.attr 'id'
    val  = parseFloat el.val()
    if @model.inRange part, val
      el.removeClass 'error'
      @model[part] val
    else
      el.addClass 'error'

  setTile: ->
    $('#color').css 'background-color': @model.hslaStr()

  changeHex: ->
    @update $('#hex'), @model.get 'hex'
    @update $('#url'), 'http://hslpicker.com' + @model.get 'hex'

  changeRgb: ->
    @update $('#rgba'), @model.rgbaStr()

  changeHsl: ->
    @update $('#hsla'), @model.hslaStr()

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

  initialize: (options) ->
    @.setElement $(options.el)
    if options.hex?.length and @model.isHex(options.hex)
      @model.hex options.hex
    else if options.rgba?.length and @model.isRgb(options.rgba)
      @model.rgb options.rgba
    else if options.hsla?.length and @model.isHsl(options.hsla)
      @model.hsla options.hsla
    else
      @model.hsla [$._.random(0, 360), 100, 50, 1]

  render: ->
    @hueSlider = @$('#h-slider').dragdealer
      slide: false
      steps: 361
      speed: 100
      x: @model.get('h')/360
      animationCallback: (x,y)=> 
        hue = Math.round(x*360)
        @model.h hue unless @model.get('h') is hue
      
    @satSlider = @$('#s-slider').dragdealer
      slide: false
      steps: 101
      speed: 100
      x: @model.get('s')/100
      animationCallback: (x,y)=>
        sat = Math.round(x*100)
        @model.s sat unless @model.get('s') is sat

    
    @lumSlider = @$('#l-slider').dragdealer
      slide: false
      steps: 101
      speed: 100
      x: @model.get('l')/100
      animationCallback: (x,y)=>
        lum = Math.round(x*100)
        @model.l lum unless @model.get('l') is lum

    @alphaSlider = @$('#a-slider').dragdealer
      slide: false
      steps: 101
      speed: 100
      x: @model.get 'a'
      animationCallback: (x,y)=>
        alpha = Math.round(x*100)/100
        @model.a alpha unless @model.get('a') is alpha

    @updateSliderStyles('all')

    @model.on 'change:h', @setHue, this
    @model.on 'change:s', @setSat, this
    @model.on 'change:l', @setLum, this
    @model.on 'change:a', @setAlpha, this
    @

  setHue: ->
    @setSlider @hueSlider, @model.get('h'), 360
    @updateSliderStyles 'h'
  setSat: ->
    @setSlider @satSlider, @model.get('s'), 100
    @updateSliderStyles 's'
  setLum: ->
    @setSlider @lumSlider, @model.get('l'), 100
    @updateSliderStyles 'l'
  setAlpha: ->
    @setSlider @alphaSlider, @model.get('a')*100, 100
    @updateSliderStyles 'a'

  # Sliders update the model, firing the change event, which will trigger setting the sliders
  # This compares the current values and prevents an unnecessary update.
  setSlider: (slider, value, factor)->
    unless Math.round(slider.value.current[0]*factor) is Math.round(value)
      slider.setValue value/factor

  updateSliderStyles: (part) ->
    parts = $._.without(['h','s','l','a'], part)
    (@setSliderBg p for p in parts)

  setSliderBg: (part) ->
    $("##{part}-slider").attr('style',"background: -webkit-#{@gradient part}")

  gradient: (part)->
    switch part
      when 'h'
        size       = 36
        multiplier = 10
      when 's','l'
        size       = 5
        multiplier = 20
      when 'a'
        size       = 5
        multiplier = .2

    colors = (@model.hslaStr(@tweakHsla(part, num*multiplier)) for num in [0..size])
    "linear-gradient(left, #{colors.join(',')});"

  tweakHsla: (part, value) ->
    color = @model.hsla()
    switch part
      when 'h' then pos = 0
      when 's' then pos = 1
      when 'l' then pos = 2
      when 'a' then pos = 3
    color.splice pos,1,value
    color

window.hsl.Color = $.Model.extend

  defaults: {}

  updateRgb: (rgba) ->
    rgba or= @hslToRgb @hsla()
    @.set rgb: [rgba[0], rgba[1], rgba[2]]
    rgba

  updateHsl: (hsla)->
    @.set h: hsla[0], s: hsla[1], l: hsla[2]

  updateHex: (rgba) ->
    @.set hex: @rgbToHex rgba or @rgba()

  h: (h) ->
    if @inRange 'h', h
      unless @.get('h') is h
        @.set h: h
        @updateHex @updateRgb()
      h
    else false

  s: (s) ->
    if @inRange 's', s
      unless @.get('s') is s
        @.set s: s
        @updateHex @updateRgb()
      s
    else false

  l: (l) ->
    if @inRange 'l', l
      unless @.get('l') is l
        @.set l: l
        @updateHex @updateRgb()
      l
    else false

  a: (a) ->
    if @inRange 'a', a
      unless @.get('a') is a
        @.set a: a
        @updateHex @updateRgb()
      a
    else false

  # Set hsla or get its current value as an array or string
  hsla: (hsla) ->
    if hsla?
      hsla = @isHsl(hsla)
      if hsla
        if $._.difference(@hsla(), hsla).length
          @updateHex @updateRgb(@hslToRgb hsla)
          @updateHsl hsla
          @.set a: hsla[3] or 1
        hsla
      else
        false
    else
      [@.get('h'), @.get('s'), @.get('l'), @.get('a')]

  hslaStr: (hsla) ->
    hsla or= @hsla()
    "hsla(#{hsla[0]}, #{hsla[1]}%, #{hsla[2]}%, #{hsla[3]})"

  rgba: (rgba) ->
    if rgba?
      rgba = @isRgb(rgba)
      if rgba
        if $._.difference(rgba, @rgba()).length
          @.set rgb: [rgba[0], rgba[1], rgba[2]], a: rgba[3] or 1
          @updateHex(rgba)
          @updateHsl(@rgbToHsl rgba)
        rgba
      else
        false
    else
      @.get('rgb').concat @.get('a')

  rgbaStr: ->
    rgb = @.get('rgb')
    "rgba(#{rgb[0]}, #{rgb[1]}, #{rgb[2]}, #{@.get('a')})"

  hex: (hex) ->
    if hex?
      hex = @isHex(hex)
      if hex 
        if @hex() isnt hex
          @.set hex: hex
          rgba = @hexToRgb hex
          @updateRgb rgba
          @.set a: rgba[3] or 1
          @updateHsl(@rgbToHsl rgba)
        hex
      else
        false
    else
      @.get 'hex'

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
      match = hsl.match(/hsla?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\%\s*,\s*(\d{1,3})\%\s*,?\s*(0?\.?\d{1,2})?\s*\)$/)?.slice(1)
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

  inRange: (part, val) ->
    switch part
      when 'h'     then valid = val >= 0 and val <= 360
      when 's','l' then valid = val >= 0 and val <= 100
      when 'a'     then valid = val >= 0 and val <= 1
    valid

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
