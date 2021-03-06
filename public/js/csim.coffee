root = exports ? this

root.AccessType = AccessType = Object.freeze
  hit: 1
  miss: 2
  evict: 3

nameMap =
  1: 'Hit'
  2: 'Miss'
  3: 'Evict'


baseTime = 2000
range = Math.exp 2
minVal = Math.log baseTime/range
maxVal = Math.log baseTime * range
scale = (maxVal - minVal)


performance.now = (performance.now or date.now)

root.CSim = class CSim
  constructor: (@params, res, options) ->
    options = options ? {}
    @parent = options['parent'] ? $ 'body'
    @log = options['log']
    @summary = options['summary']
    @numSets = (1 << @params.s)
    @currentIndex = 0
    @cache = []
    @out = []
    @states = []
    @missRati
    @intervalID = null
    @home = $ "<div/>"
      .appendTo @parent

    if @summary?
      @summary.html "
    Hits: #{res['hits']} <br/>
    Misses: #{res['misses']} <br/>
    Evicts: #{res['evicts']} <br/>
    Miss Ratio: #{res['miss_rate']}"


    $ "<div class='row'> <hr>
        <h1 class='panel-title'>Simulation Controls</h1>
        <br/>
      </div>"
      .appendTo @home

    controlDiv = $ "<div class='btn-group row'/>"
      .appendTo @home

    btnHome = $ "<div class='col-sm-7'/>"
      .appendTo controlDiv

    $ "<button
        class='btn btn-primary'
        id='autobtn'
        data-toggle='tooltip'
        data-title='Automatically advanced the simulation.
  Use the slider to control speed'
        data-placement='auto'
      />"
      .attr "role", "play"
      .text "Play"
      .tooltip('delay':
        show: 1000
        hide: 100
      )
      .appendTo btnHome
      .click () =>
        self = $("#autobtn")
        if self.attr('role') is 'play'
          @lastTime = 0
          autoFunc = () =>
            @intervalID = setInterval () =>
              sliderval = @slider.slider "getValue"
              time = Math.exp(maxVal - sliderval * scale)

              if (performance.now() - @lastTime) > time
                @lastTime = performance.now()
                @next()
              else if not @hasNext()
                clearInterval @intervalID
                self.text "Play"
                  .attr "role", "play"
            , 2

          autoFunc()

          self.text "Pause"
            .attr "role", 'pause'
        else
          clearInterval @intervalID
          self.text "Play"
            .attr "role", 'play'

    $ "<button
        class='btn btn-primary'
        data-toggle='tooltip'
        data-title='Moves the simulation back one memory accesses'
        data-placement='auto'
      />"
      .text "Prev"
      .appendTo btnHome
      .tooltip('delay':
        show: 1000
        hide: 100
      )
      .click () =>
        @prev()

    $ "<button
        class='btn btn-primary'
        data-toggle='tooltip'
        data-title='Moves the simulation forward one memory accesses'
        data-placement='auto'
      />"
      .text "Next"
      .appendTo btnHome
      .tooltip('delay':
        show: 1000
        hide: 100
      )
      .click () =>
        @next()


    $ "<button
        class='btn btn-primary'
        data-toggle='tooltip'
        data-title='Resets the simulation back to accesses 0'
        data-placement='auto'
      />"
      .text "Reset"
      .appendTo btnHome
      .tooltip('delay':
        show: 1000
        hide: 100
      )
      .click () =>
        @currentIndex = 0
        @print()

    sliderHome = $ "<div class='col-sm-5'/>"
      .appendTo controlDiv

    $ "<label>Speed</label>"
      .appendTo sliderHome
    @slider = $ "<input
                  type='text'
                  name='somename'
                  data-provide='slider'
                  data-slider-min='0'
                  data-slider-max='1'
                  data-slider-step='0.001'
                  data-slider-value='0.5'
                  data-slider-tooltip='show'
                />"
      .appendTo sliderHome
      .slider()


    $ "<div class='row'/>"
      .appendTo @home
      .append $ "<hr><h1 class='panel-title'>Cache</h1><br/>"

    state = []
    for i in [0...@numSets]
      row = $("<div class='row panel-group'/>").appendTo @home

      $ "<p class='col-sm-2' style='margin-top: 15px;'>
          Set #{i}
        </p>"
        .appendTo row

      inner = $ "<div class='row col-sm-10'/>"
        .appendTo row

      for _ in [0...@params.E]
        block = $ "<div class='col-sm-3'>
          <div class='panel panel-default empty'>
            <div class='panel-body'/>
          </div>
        </div>"
          .appendTo inner
          .find $ ".panel-body"
          .text "Empty"


        @cache.push block

        state.push
          tag: -1
          type: 0

    @states.push state
    @out.push ""

    for line in res['trace']

      block = line['block']
      tag = line['tag']
      accType = line['acc_type']
      address = line['address']
      set = line['set']

      if @log?
        @out.push """<strong>Address:</strong> 0x#{address.toString 16}
        <strong>Tag:</strong> 0x#{tag.toString 16} <strong>Set:</strong> #{set}
        <strong>#{nameMap[accType]}</strong>""".split("\n").join("<br/>")

      #Deep copy of array
      newState = @states[@states.length - 1][..]
      newState[block] =
        tag: tag
        type: accType
        address: address

      @states.push newState
      @blockSize = (1 << @params.b)

  print: ->
    if @log?
      text = "#{@out[1..@currentIndex].join("<br><br>")}<br>"

      @log.html text
      @log.scrollTop @log[0].scrollHeight


    for b, i in @states[@currentIndex]
      @cache[i].parent().removeClass "hit miss evict empty"
      @cache[i].text if b.tag != -1 then "0x#{b.address.toString 16} to 0x#{(b.address + @blockSize - 1).toString 16}" else "Empty"
      switch b.type
        when 0
          @cache[i].parent().addClass "empty"
        when AccessType.hit
          @cache[i].parent().addClass "hit"
        when AccessType.miss
          @cache[i].parent().addClass "miss"
        when AccessType.evict
          @cache[i].parent().addClass "evict"
        else
          console.log "Unsupported Type: #{b.type}"

    true

  next: ->
    if @hasNext()
      ++@currentIndex
      @print()
      true
    else
      false

  prev: ->
    if @hasPrev()
      --@currentIndex
      @print()
      true
    else
      false

  hasNext: ->
    @currentIndex + 1 < @states.length

  hasPrev: ->
    @currentIndex > 0

  destroy: ->
    @home.remove()

    if @log?
      @log.text ""

    clearInterval @intervalID


STATUS = Object.freeze
  OK: 0
  nonPowOf2: 1
  nan: 2

powOf2Checker = (num) ->
  if isNaN(num) or num is 0
    STATUS.nan
  else
    if (num | (num - 1)) is (num + num - 1) then STATUS.OK else STATUS.nonPowOf2


root.SimManager = class SimManager
  constructor: (@home, @simbtn, params) ->
    $ "<div class='row'>
        <h1 class='panel-title'>Cache Settings</h1>
      </div>
      <br/>"
      .appendTo @home

    nameDiv = $ "<div class='row'/>"
      .appendTo @home

    $ "<h3 class='col-sm-3 panel-title'/>"
      .text "Number of Sets"
      .appendTo nameDiv

    $ "<h3 class='col-sm-3 panel-title'/>"
      .text "Bytes per Block"
      .appendTo nameDiv

    $ "<h3 class='col-sm-3 panel-title'/>"
      .text "Associativity"
      .appendTo nameDiv

    $ "<h3 class='col-sm-3 panel-title'/>"
      .text "Memory Size"
      .appendTo nameDiv

    inputDiv = $ "<div class='row'/>"
      .appendTo @home

    params = params ? {}

    @checkDir = {}
    @createCheckedInput 's', params['s'], inputDiv, powOf2Checker
    @createCheckedInput 'b', params['b'], inputDiv, powOf2Checker
    @createCheckedInput 'E', params['E'], inputDiv, (val) ->
      if isNaN(val) or val is 0 then STATUS.nan else STATUS.OK


    $ "<div class='col-sm-3'/>"
      .appendTo inputDiv
      .append($ "<input type='text' id='memSize'/>"
        .val "64"
        .attr "style", "width: 100%;"
        )

  getParams: ->
    s: parseInt Math.log($("#s").val()) / Math.log(2)
    b: parseInt Math.log($("#b").val()) / Math.log(2)
    E: parseInt($("#E").val())
    memSize: parseInt($("#memSize").val())

  setParams: (p) ->
    $ "#s"
      .val p.s
      .trigger "change"
    $ "#b"
      .val p.b
      .trigger "change"
    $ "#E"
      .val p.E
      .trigger "change"

  createCheckedInput: (id, initialVal, parent, checker) ->
    $ "<div class='col-sm-3'/>"
      .appendTo parent
      .append($ "<input type='text' id='#{id}'
                data-toggle='tooltip'
                data-placement='auto'
                data-trigger='manual'
                />"
        .tooltip()
        .val initialVal
        .attr "style", "width: 100%;"
        .on 'input change', () =>
          @checkInput id, checker
        .trigger "change"
      )


  checkInput: (id, checker) ->
    val = parseInt $("##{id}").val()
    stat =  checker val
    self = $("##{id}")
    switch stat
      when STATUS.OK
        $("##{id}").tooltip 'hide'

        @checkDir[id] = true
      when STATUS.nonPowOf2
        if self.attr('data-original-title') != 'Must be a power of 2'
          self.attr 'data-original-title', 'Must be a power of 2'
            .tooltip 'fixTitle'
            .tooltip 'show'

        @checkDir[id] = false
      when STATUS.nan
        if self.attr('data-original-title') != 'Must be a non-zero number'
          self.attr 'data-original-title', 'Must be a non-zero number'
            .tooltip 'fixTitle'
            .tooltip 'show'

        @checkDir[id] = false
      else
        console.log "STATUS of #{stat} is unsupported"

    isAllTrue = true
    for own _, val of @checkDir
      if not val
        isAllTrue = false
        break


    if isAllTrue
      @simbtn.removeClass 'disabled'
    else
     @simbtn.addClass 'disabled'