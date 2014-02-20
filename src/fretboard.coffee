# Vex Fretboard
#
# Uses PaperJS.
# Copyright Mohit Muthanna Cheppudira 2013

class Vex.Flow.Fretboard
  @DEBUG = false
  L = (args...) -> console?.log("(Vex.Flow.Fretboard)", args...) if Vex.Flow.Fretboard.DEBUG

  constructor: (@paper, options) ->
    L "constructor: options=", options
    @options =
      strings: 6
      start_fret: 1
      end_fret: 22
      tuning: "standard"
      color: "black"
      marker_color: "#aaa"
      x: 10
      y: 20
      width: @paper.view.size.width - 20
      height: @paper.view.size.height - 40
      marker_radius: 4
      font_face: "Arial"
      font_size: 12
      font_color: "black"
      nut_color: "#aaa"
      start_fret_text: null

    _.extend(@options, options)

    @reset()

  error = (msg) -> new Vex.RERR("FretboardError", msg)
  reset: ->
    L "reset()"
    throw error("Too few strings: " + @options.strings) if @options.strings < 2
    throw error("Too few frets: " + @options.end_fret) if (@options.end_fret - @options.start_fret) < 3
    @x = @options.x
    @y = @options.y
    @width = @options.width
    @nut_width = 10

    @start_fret = parseInt(@options.start_fret, 10)
    @end_fret = parseInt(@options.end_fret, 10)
    @total_frets = @end_fret - @start_fret
    if @end_fret <= @start_fret
      throw error("Start fret number must be lower than end fret number: #{@start_fret} >= #{@end_fret}")
    @start_fret_text = if @options.start_fret_text? then @options.start_fret_text else @start_fret

    @height = @options.height - (if @start_fret == 0 then 0 else 10)
    @string_spacing = @height / (@options.strings - 1)
    @fret_spacing = (@width - @nut_width) / (@total_frets - 1)
    @light_radius = (@string_spacing / 2) - 1
    @calculateFretPositions()

  calculateFretPositions: ->
    L "calculateFretPositions: width=#{@width}"
    width = @width - @nut_width
    @bridge_to_fret = [width]
    @fretXs = [0]
    k = 1.05946

    for num in [1..@total_frets]
      @bridge_to_fret[num] = width / Math.pow(k, num)
      @fretXs[num] = width - @bridge_to_fret[num]

    # We don't need the entire scale (nut to bridge), so transform
    # the X positions.
    transform = (x) => (x / @fretXs[@total_frets]) * width
    @fretXs = (transform(x) for x in @fretXs)

  hasFret: (num) -> num in [(@start_fret - 1)..@end_fret]
  hasString: (num) -> num in [1..@options.strings]

  getFretX: (num) ->
    @fretXs[num - (@start_fret - 1)] + (if @start_fret > 1 then 3 else @nut_width)

  getStringY: (num) -> @y + ((num - 1) * @string_spacing)
  getFretCenter: (fret, string) ->
    start_fret = @options.start_fret
    end_fret = @options.end_fret

    throw error("Invalid fret: #{fret}") unless @hasFret(fret)
    throw error("Invalid string: #{string}") unless @hasString(string)

    x = 0
    if fret is 0
      x = @getFretX(0) + (@nut_width / 2)
    else
      x = (@getFretX(fret) + @getFretX(fret - 1)) / 2

    y = @getStringY(string)
    return new @paper.Point(x, y)

  drawNut: ->
    L "drawNut()"
    path = new @paper.Path.RoundRectangle(@x, @y - 5, @nut_width, @height + 10)
    path.strokeColor = @options.nut_color
    path.fillColor = @options.nut_color

  showStartFret: ->
    L "showStartFret()"
    center = @getFretCenter(@start_fret, 1)
    L "Center: ", center
    @renderText(new @paper.Point(center.x, @y + @height + 20), @start_fret_text)

  drawString: (num) ->
    path = new @paper.Path()
    path.strokeColor = @options.color

    y = @getStringY(num)
    start = new @paper.Point(@x, y)
    path.moveTo(start)
    path.lineTo(start.add([@width, 0]))

  drawFret: (num) ->
    path = new @paper.Path()
    path.strokeColor = @options.color

    x = @getFretX(num)
    start = new @paper.Point(x, @y)
    path.moveTo(start)
    path.lineTo(start.add([0, @height]))

  drawDot: (x, y, color='red', radius=2) ->
    path = new @paper.Path.Circle(new @paper.Point(x, y), radius)
    path.strokeColor = color
    path.fillColor = color

  drawMarkers: ->
    L "drawMarkers"

    middle_dot = 3
    top_dot = 4
    bottom_dot = 2

    if parseInt(@options.strings, 10) == 4
      middle_dot = 2
      top_dot = 3
      bottom_dot = 1

    drawCircle = (start) =>
      path = new @paper.Path.Circle(start, @options.marker_radius)
      path.strokeColor = @options.marker_color
      path.fillColor = @options.marker_color

    y_displacement = @string_spacing / 2
    for position in [3, 5, 7, 9, 15, 17, 19, 21]
      if @hasFret(position)
        start = @getFretCenter(position, middle_dot).add([0, y_displacement])
        drawCircle(start)

    for position in [12, 24]
      if @hasFret(position)
        start = @getFretCenter(position, bottom_dot).add([0, y_displacement])
        drawCircle(start)
        start = @getFretCenter(position, top_dot).add([0, y_displacement])
        drawCircle(start)

  renderText: (point, value, color=@options.font_color, size=@options.font_size) ->
    text = new @paper.PointText(point)
    text.justification = "center"
    text.characterStyle =
      font: @options.font_face
      fontSize: size
      fillColor: color
    text.content = value

  drawFretNumbers: ->
    for position, value of {5: "V", 12: "XII", 19: "XIX"}
      fret = parseInt(position, 10)
      if @hasFret(fret)
        point = @getFretCenter(fret, 6)
        point.y = @getStringY(@options.strings + 1)
        @renderText(point, value)

  lightText: (options) ->
    opts =
      color: "white"
      fillColor: "#666"

    _.extend(opts, options)

    L "lightUp: ", opts
    point = @getFretCenter(opts.fret, opts.string)
    path = new @paper.Path.Circle(point, @light_radius)
    path.strokeColor = opts.color
    path.fillColor = opts.fillColor

    y_displacement = @string_spacing / 5
    point.y += y_displacement
    @renderText(point, opts.text, opts.color) if opts.text?
    @paper.view.draw()

  lightUp: (options) ->
    options.color ?= '#666'
    options.fillColor ?= options.color
    L "lightUp: ", options
    point = @getFretCenter(options.fret, options.string)
    path = new @paper.Path.Circle(point, @light_radius - 2)
    path.strokeColor = options.color
    path.fillColor = options.fillColor
    @paper.view.draw()

  draw: ->
    L "draw()"
    for num in [1..@options.strings]
      @drawString num

    for num in [@start_fret..@end_fret]
      @drawFret num

    if @start_fret == 1
      @drawNut()
    else
      @showStartFret()

    @drawMarkers()
    @paper.view.draw()


class Vex.Flow.FretboardDiv
  @DEBUG = false
  L = (args...) -> console?.log("(Vex.Flow.FretboardDiv)", args...) if Vex.Flow.FretboardDiv.DEBUG

  error = (msg) -> new Vex.RERR("FretboardError", msg)
  constructor: (@sel, @id) ->
    @options =
      "width": 700
      "height": 150
      "strings": 6
      "frets": 17
      "start": 1
      "start-text": null
      "tuning": "standard"
    throw error("Invalid selector: " + @sel) if @sel? and $(@sel).length == 0
    @id ?= $(@sel).attr('id')
    @lights = []

  setOption: (key, value) ->
    if key in _.keys(@options)
      L "Option: #{key}=#{value}"
      @options[key] = value
    else
      throw error("Invalid option: " + key)

  genFretboardOptions = (options) ->
    fboptions = {}
    for k, v of options
      switch k
        when "width", "height"
          continue
        when "strings"
          fboptions.strings = v
        when "frets"
          fboptions.end_fret = v
        when "tuning"
          fboptions.tuning = v
        when "start"
          fboptions.start_fret = v
        when "start-text"
          fboptions.start_fret_text = v
        else
          throw error("Invalid option: " + k)
    return fboptions

  show: (line) ->
    options = line.split(/\s+/)
    params = {}
    valid_options = ["fret", "frets", "string", "strings",
                     "text", "color", "note", "notes", "fill-color"]
    for option in options
      match = option.match(/^(\S+)\s*=\s*(\S+)/)
      throw error("Invalid 'show' option: " + match[1]) unless match[1] in valid_options
      params[match[1]] = match[2] if match?

    L "Show: ", params
    @lights.push params

  parse: (data) ->
    L "Parsing: " + data
    lines = data.split(/\n/)
    for line in lines
      line.trim()
      match = line.match(/^\s*option\s+(\S+)\s*=\s*(\S+)/)
      @setOption(match[1], match[2]) if match?
      match = line.match(/^\s*show\s+(.+)/)
      @show(match[1]) if match?

    return true

  extractNumbers = (str) ->
    L "ExtractNumbers: ", str
    str.trim()
    str.split(/\s*,\s*/)

  extractNotes = (str) ->
    L "ExtractNotes: ", str
    str.trim()
    notes = str.split(/\s*,\s*/)
    extracted_notes = []
    for note in notes
      parts = note.match(/(\d+)\/(\d+)/)
      if parts?
        extracted_notes.push(
          fret: parseInt(parts[1], 10)
          string: parseInt(parts[2], 10))
      else
        throw error("Invalid note: " + note)
    return extracted_notes

  extractFrets = (light) ->
    frets = extractNumbers(light.fret) if light.fret?
    frets = extractNumbers(light.frets) if light.frets?
    strings = extractNumbers(light.string) if light.string?
    strings = extractNumbers(light.strings) if light.strings?
    notes = extractNotes(light.note) if light.note?
    notes = extractNotes(light.notes) if light.notes?
    throw error("No frets or strings specified on line") if (not (frets? and strings?)) and (not notes?)

    lights = []

    if frets? and strings?
      for fret in frets
        for string in strings
          lights.push({fret: parseInt(fret, 10), string: parseInt(string, 10)})

    if notes?
      for note in notes
        lights.push(note)

    return lights

  lightsCameraAction: ->
    L @lights
    for light in @lights
      params = extractFrets(light)
      for param in params
        param.color = light.color if light.color?
        param.fillColor = light["fill-color"] if light["fill-color"]?
        L "Lighting up: ", param
        if light.text?
          param.text = light.text
          @fretboard.lightText(param)
        else
          @fretboard.lightUp(param)

  build: (code=null) ->
    L "Creating canvas id=#{@id} #{@options.width}x#{@options.height}"
    code ?= $(@sel).text()
    @parse(code)

    canvas = $("<canvas id=#{@id}>").
      attr("width", @options.width).
      attr("height", @options.height).
      attr("id", @id).
      width(@options.width)
    $(@sel).replaceWith(canvas)

    ps = new paper.PaperScope()
    ps.setup(document.getElementById(@id))
    @fretboard = new Vex.Flow.Fretboard(ps, genFretboardOptions(@options))
    @fretboard.draw()
    @lightsCameraAction()
