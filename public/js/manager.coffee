$ ->
  TRACE_TYPE = Object.freeze
    auto: 1
    valgrind: 2

  class Manager
    constructor: ->

      div1 = $ "<div class='col-md-3'/>"
        .appendTo '#content'
      @cacheHome = $ "<div class='col-md-4 col-md-offset-1'/>"
        .appendTo $ '#content'


      logs = $ "<div class='col-md-3 col-md-offset-1'>
        <div class='row'/>
      </div>"
        .appendTo $ "#content"
        .find $ ".row"

      col = $ "<div class='col-sm-6'/>"
        .appendTo logs
      @logHome = $ "<div class='panel panel-default'>
            <div class='panel-heading'>
              <h3 class='panel-title'>Simulation Breakdown</h3>
            </div>
            <div class='panel-body log'/>
          </div>
        "
        .appendTo col
        .find $ ".panel-body"


      col = $ "<div class='col-sm-6'/>"
        .appendTo logs
      @summaryHome = $ "<div class='panel panel-default'>
            <div class='panel-heading'>
              <h3 class='panel-title'>Simulation Summary</h3>
            </div>
            <div class='panel-body log'/>
          </div>
          "
        .appendTo col
        .find $ ".panel-body"

      $ "<label>Generator Difficulty</label><br/>"
        .appendTo div1

      $ "<select class='selectpicker'
        data-width='auto'
        id='difficulty'>
          <optgroup label='Single Array'>
            <option value='basic'>Basic</option>
            <option value='easy'>Easy</option>
            <option value='medium'>Medium</option>
          </optgroup>
          <optgroup label='Single Struct Array'>
            <option value='structbasic'>Basic</option>
            <option value='structeasy'>Easy</option>
            <option value='structmedium'>Medium</option>
          </optgroup>
        </select>"
        .appendTo div1

      $ "<button class='btn btn-primary' id='gen'>"
        .text "Generate Random Problem"
        .appendTo div1
        .click () =>
          difficulty = $("#difficulty").val().toLowerCase()
          switch difficulty
            when "basic"
              problem = Generator.basic()
            when "easy"
              problem = Generator.easy()
            when "medium"
              problem = Generator.medium()
            when "structbasic"
              problem = Generator.basic(true)
            when "structeasy"
              problem = Generator.easy(true)
            when "structmedium"
              problem = Generator.medium(true)
            else
              console.log "Unsupported type: #{difficulty}"

          @codeHome.val problem.code
          @simManager.setParams problem

      @codeHome = $ "<textarea class='form-control' rows='18' cols='50'/>"
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



      @traceHome = $ "<textarea class='form-control' rows='20' cols='50'/>"
        .attr 'placeholder', "Trace goes here (will be automatically filled if code is traced)"

      @simulator = null

      $ "<button class='btn btn-primary'/>"
        .text "Generate Memory Trace"
        .appendTo div1
        .click () =>
          code = @codeHome.val()
          getTrace code, (res) =>
            console.log res
            error = res['error']
            msg = res['msg']
            if not error
              @traceHome.text ("0x#{t}" for t in msg).join("\n")
              @traceStyle.selectpicker "val", "Auto Generated"
            else
              @traceHome.text "Syntax Error: \n#{msg}"


      @traceHome.appendTo div1

      $ "<label>Trace Type</label><br/>"
        .appendTo div1

      @traceStyle = $ "<select class='selectpicker'
      data-width='auto'>
          <optgroup label='Trace Type'>
            <option>Auto Generated</option>
            <option>Valgrind</option>
          </optgroup>
        </select>"
        .appendTo div1

      @simbtn = $ "<button class='btn btn-primary'/>"
        .text "Simulate"
        .appendTo div1
        .click () =>
          if @simbtn.hasClass "disabled"
            return
          trace = @traceHome.val().split("\n")
          params = @simManager.getParams()
          style = @traceStyle.val()
          console.log style
          switch style
            when "Auto Generated"
              styleCode = TRACE_TYPE.auto
            when "Valgrind"
              styleCode = TRACE_TYPE.valgrind
            else
              console.log "Unsupported trace style: #{style}"

          getSim trace, params, styleCode, (sim) =>
            if @simulator?
              @simulator.destroy()

            @simulator = new CSim params, sim,
              parent: @cacheHome
              log: @logHome
              summary: @summaryHome


      saved = Cookies.getJSON "cache_sim_save"
      console.log saved
      @simManager = new SimManager @cacheHome, @simbtn

      if saved?
        @codeHome.val saved['code']
        @simManager.setParams saved
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

    return

  window.onunload = closer
  window.onbeforeunload = closer
