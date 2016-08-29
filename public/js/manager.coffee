$ ->
  class Manager
    constructor: ->

      div1 = $ "<div class='trace'/>"
        .appendTo '#content'
      @cacheHome = $ "<div class='container cache'/>"
        .appendTo $ '#content'


      @logHome =  $ '<p class="log"/>'
        .appendTo $ '#content'
      @summaryHome = $ "<p class='log'/>"
        .appendTo $ '#content'
      @codeHome = $ "<textarea rows='20' cols='50'/>"
        .attr 'placeholder', 'Code goes here'
        .appendTo div1
        .on 'keydown', (e) ->
          self = $(this)
          if e.which is 9 and self.prop("selectionStart")?
            code = self.val()
            start = self.prop "selectionStart"
            end = self.prop "selectionEnd"

            newText = code[...start] + "  " + code[end..]

            self.val newText
            self.prop "selectionStart", start + 2
            self.prop "selectionEnd", start + 2
            false
          else true

      problem = Generator.easy()
      @codeHome.val problem.code

      @traceHome = $ "<textarea rows='20' cols='50'/>"
        .attr 'placeholder', "Trace goes here (will be automatically filled if code is traced)"
      @simulator = null


      $ "<button class='btn'/>"
        .text "Trace"
        .appendTo div1
        .click () =>
          code = @codeHome.val()
          getTrace code, (res) =>
            error = res['error']
            msg = res['msg']
            if not error
              @traceHome.text ("0x#{t}" for t in msg).join("\n")
            else
              @traceHome.text "Syntax Error: \n#{msg}"


      @traceHome.appendTo div1

      simbtn = $ "<button class='btn'/>"
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

      @simManager = new SimManager @cacheHome, simbtn, problem

    new Manager()