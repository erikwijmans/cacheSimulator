

class Manager
  constructor: ->

    div1 = $ "<div class='trace'/>"
      .appendTo '#content'
    @cacheHome = $ "<div class='container cache'/>"
      .appendTo $ '#content'

    @simManager = new SimManager @cacheHome
    @logHome =  $ '<p class="log"/>'
      .appendTo $ '#content'
    @summaryHome = $ "<p class='log'/>"
      .appendTo $ '#content'
    @codeHome = $ "<textarea rows='10' cols='50'/>"
      .attr 'placeholder', 'Code goes here'
      .appendTo div1
    @traceHome = $ "<textarea rows='5' cols='50'/>"
      .attr 'placeholder', "Trace goes here"
    @simulator = null


    $ "<button/>"
      .text "Trace"
      .appendTo div1
      .click () =>
        code = @codeHome.val()
        getTrace code, (trace) =>
          @traceHome.text ("0x#{t}" for t in trace).join("\n")


    @traceHome.appendTo div1

    $ "<button/>"
      .text "Simulate"
      .appendTo div1
      .click () =>
        trace = @traceHome.val().split("\n")
        params = @simManager.getParams()
        console.log params
        getSim trace, params, (sim) =>
          if @simulator?
            @simulator.destroy()

          @simulator = new CSim params['s'], params['E'], sim,
            parent: @cacheHome
            log: @logHome
            summary: @summaryHome




$ ->
  new Manager()