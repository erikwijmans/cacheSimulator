$ ->
  class Manager
    constructor: ->

      div1 = $ "<div class='trace'/>"
        .appendTo '#content'
      @cacheHome = $ "<div class='cache'/>"
        .appendTo $ '#content'


      @logHome =  $ '<p class="log"/>'
        .appendTo $ '#content'
      @summaryHome = $ "<p class='log'/>"
        .appendTo $ '#content'

      $ "<select class='selectpicker'
        data-width='fit'
        id='difficulty'>
          <optgroup label='Problem Difficulty'>
            <option>Basic</option>
            <option>Easy</option>
            <option>Medium</option>
          </optgroup>
        </select>"
        .appendTo div1

      $ "<button class='btn' id='gen'>"
        .text "Generate Random Problem"
        .appendTo div1
        .click () =>
          difficulty = $("#difficulty").val().toLowerCase()
          console.log difficulty
          switch difficulty
            when "basic"
              problem = Generator.basic()
            when "easy"
              problem = Generator.easy()
            when "medium"
              problem = Generator.medium()
            else
              console.log "Unsupported type: #{difficulty}"

          @codeHome.val problem.code
          @simManager.setParams problem

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



      @traceHome = $ "<textarea rows='20' cols='50'/>"
        .attr 'placeholder', "Trace goes here (will be automatically filled if code is traced)"
      @simulator = null

      $ "<button class='btn'/>"
        .text "Trace Code"
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


      saved = Cookies.getJSON "cache_sim_save"
      console.log saved
      @simManager = new SimManager @cacheHome, simbtn, saved

      if saved?
        @codeHome.val saved['code']
      else
        $("#gen").click()


  manager = new Manager()

  closer = ->
    code = manager.codeHome.val()
    params = manager.simManager.getParams()
    params['code'] = code
    params['s'] = 1 << params['s']
    params['b'] = 1 << params['b']
    Cookies.set "cache_sim_save", params,
      expires: new Date 2020, 1, 1

  window.onunload = closer
  window.onbeforeunload = closer
