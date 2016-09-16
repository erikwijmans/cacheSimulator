root = exports ? this

baseURL = "http://ec2-52-10-240-194.us-west-2.compute.amazonaws.com"

ajaxReq = (url, data, cb) ->
  $.ajax
    dataType: 'json'
    contentType: 'application/json; charset=UTF-8'
    type: "POST"
    url: "#{baseURL}#{url}"
    data: data
    success: cb
    error: (err) ->
      console.log err

root.getTrace = getTrace = (code, cb) ->
 ajaxReq "/trace", JSON.stringify(code), cb

root.getSim = getSim = (trace, cacheParams, style, cb) ->
  ajaxReq "/simulate", JSON.stringify(
    trace: trace
    s: cacheParams['s']
    b: cacheParams['b']
    E: cacheParams['E']
    memSize: cacheParams['memSize']
    style: style
  ), cb
