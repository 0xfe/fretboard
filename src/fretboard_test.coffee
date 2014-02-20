###
Fretboard Tests
Copyright Mohit Cheppudira 2013 <mohit@muthanna.com>
###

class Vex.Flow.Test
  sel = "#notespace_testoutput"
  id = 0

  genID = ->
    id++

  createTestCanvas = (canvas_sel_name, div_sel_name, test_name) ->
    test_div = $('<div></div>').addClass("testcanvas").
      attr("id", div_sel_name)

    test_div.append($('<div></div>').text(test_name))
    test_div.append($('<canvas></canvas>').
      attr("id", canvas_sel_name).
      text(test_name))
    $(sel).append(test_div)

  @resizeCanvas: (sel, width, height) ->
    $("#" + sel).width(width)
    $("#" + sel).attr("width", width)
    $("#" + sel).attr("height", height)

  @runTest: (name, func, params) ->
    test(name, ->
      test_canvas_sel = "canvas_" + genID()
      test_div_sel = "div_" + genID()
      test_canvas = createTestCanvas(test_canvas_sel, test_div_sel, name)

      func({
        canvas_sel: test_canvas_sel,
        div_sel: test_div_sel,
        params: params
        }, Vex.Flow.Renderer.getCanvasContext)
    )

class Vex.Flow.Test.Fretboard
  runTest = Vex.Flow.Test.runTest
  @Start: ->
    module "Vex Fretboard"
    runTest("Basic Test", @basic)
    runTest("Lightup Test", @lightFret)
    runTest("Lightup with Text", @lightFretText)
    test("Parse Options", @parseOptions)
    test("Parse Lights", @parseLights)

    runTest("FretboardDiv Width", @divTestWidth)
    runTest("FretboardDiv Height", @divTestHeight)
    runTest("FretboardDiv Frets", @divTestFrets)
    runTest("FretboardDiv Strings", @divTestStrings)
    runTest("FretboardDiv Seven String", @divTest7String)

    runTest("FretboardDiv Lights", @divLights)
    runTest("FretboardDiv Light Colors", @divLightColors)
    runTest("FretboardDiv Note Syntax", @divLightsWithNotes)
    runTest("FretboardDiv Start Fret", @divStartFret)
    runTest("FretboardDiv Start Fret 10", @divStartFret10)
    runTest("FretboardDiv Start Fret Text", @divStartFretText)

  # Private methods
  parse = (data) ->
    fb = new Vex.Flow.FretboardDiv(null)
    fb.parse data

  catchError = (data, error_type="FretboardError") ->
    error =
      code: "NoError"
      message: "Expected exception not caught"

    try
      parse data
    catch e
      error = e

    equal(error.code, error_type, error.message)

  @basic: (options) ->
    ps = new paper.PaperScope()
    Vex.Flow.Test.resizeCanvas(options.canvas_sel, 650, 120)
    ps.setup(options.canvas_sel)

    fretboard = new Vex.Flow.Fretboard(ps)
    fretboard.draw()

    ok true, "all pass"

  @lightFret: (options) ->
    ps = new paper.PaperScope()
    Vex.Flow.Test.resizeCanvas(options.canvas_sel, 600, 120)
    ps.setup(options.canvas_sel)

    fretboard = new Vex.Flow.Fretboard(ps)
    fretboard.draw()
    fretboard.lightUp({fret: 5, string: 5, color: "red"})
    fretboard.lightUp({fret: 6, string: 5, color: "#666", fillColor: "white"})
    fretboard.lightUp({fret: 6, string: 6, color: "#666"})
    fretboard.lightUp({fret: 7, string: 5, color: "blue"})
    fretboard.lightUp({fret: 0, string: 2, color: "#666", fillColor: "white"})

    ok true, "all pass"

  @lightFretText: (options) ->
    ps = new paper.PaperScope()
    Vex.Flow.Test.resizeCanvas(options.canvas_sel, 600, 150)
    ps.setup(options.canvas_sel)

    fretboard = new Vex.Flow.Fretboard(ps, {end_fret: 17})
    fretboard.draw()
    fretboard.lightText({fret: 9, string: 5, text: "F#"})
    fretboard.lightText({fret: 9, string: 4, text: "B", color: "#2a2", fillColor: "#efe"})

    fretboard.lightText({fret: 3, string: 6, text: "2", color: "black", fillColor: "white"})
    fretboard.lightText({fret: 2, string: 5, text: "1"})
    fretboard.lightText({fret: 3, string: 2, text: "3"})
    fretboard.lightText({fret: 3, string: 1, text: "4"})

    fretboard.lightText({fret: 12, string: 4, text: ""})
    fretboard.lightText({fret: 0, string: 4, text: "D"})
    ok true, "all pass"

  @parseOptions: (options) ->
    catchError "option blah=boo"
    equal true, parse "option tuning=standard"
    equal true, parse "option strings=4"
    equal true, parse "option frets=17"
    ok true, "all pass"

  @parseLights: (options) ->
    equal true, parse "show fret=ha string=boo color=#555"
    catchError "show key=ha string=boo color=#555"

  @divTestWidth: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build("option width=500")
    ok true, "all pass"

  @divTestHeight: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build("option height=100")
    ok true, "all pass"

  @divTestFrets: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build("option frets=10\noption width=700")
    ok true, "all pass"

  @divTestStrings: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build("option strings=4")
    ok true, "all pass"

  @divTest7String: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build("option strings=7")
    ok true, "all pass"

  @divLights: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build(
      "show frets=3,5,7 strings=6,5 color=red\n" +
      "show fret=3 string=1 text=G")
    ok true, "all pass"

  @divLightsWithNotes: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build(
      "show notes=3/6,5/5 color=red\n" +
      "show fret=3 string=1 text=G")
    ok true, "all pass"

  @divLightColors: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build(
      "show frets=3,5,7 strings=6,5 color=red\n" +
      "show fret=4 string=1 text=G#\n" +
      "show fret=5 string=1 text=A color=#666 fill-color=white\n" +
      "show fret=6 string=1 text=Bb fill-color=#afa color=black\n" +
      "show frets=4,5,7 strings=4,3 color=blue fill-color=white\n")
    ok true, "all pass"

  @divStartFret: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build(
      "option start=5\n" +
      "option frets=10\n" +
      "option width=400\n" +
      "show frets=5,7,9 strings=6,5 color=red\n" +
      "show fret=7 string=1 text=G")
    ok true, "all pass"

  @divStartFretText: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build(
      "option start=5\n" +
      "option frets=10\n" +
      "option width=400\n" +
      "option start-text=5th Fret\n" +
      "show frets=5,7,9 strings=6,5 color=red\n" +
      "show fret=7 string=1 text=G")
    ok true, "all pass"

  @divStartFret10: (options) ->
    div = new Vex.Flow.FretboardDiv("#"+options.canvas_sel)
    div.build(
      "option start=10\n" +
      "option frets=16\n" +
      "option width=400\n" +
      "show frets=10,12,15 strings=6,5 color=red\n" +
      "show fret=12 string=1 text=X")
    ok true, "all pass"
