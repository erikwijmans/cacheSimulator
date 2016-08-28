root = exports ? this

code = """
int main() {
struct pixel_t{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
};

struct pixel_t pixel[16][16];
register int i, j;
int x;
for (i = 0; i < 16; i ++){
    for (j = 0; j < 16; j ++){
        x = pixel[j][i].r;
        pixel[j][i].g = 0;
        pixel[j][i].b = 0;
        pixel[j][i].a = 0;
} }
}
  """


ajaxReq = (url, data, cb) ->
  $.ajax
    dataType: 'json'
    contentType: 'application/json; charset=UTF-8'
    type: "POST"
    url: url
    data: data
    success: cb
    error: (err) ->
      console.log err

root.getTrace = getTrace = (code, cb) ->
 ajaxReq '/trace', JSON.stringify(code), cb

root.getSim = getSim = (trace, cacheParams, cb) ->
  ajaxReq '/simulate', JSON.stringify(
    trace: trace
    s: cacheParams['s']
    b: cacheParams['b']
    E: cacheParams['E']
    memSize: cacheParams['memSize']
  ), cb


() ->
  getTrace code, (res) ->
    getSim res,
      s: 3
      b: 3
      E: 3
      memSize: 64
    , (res) ->
      console.log res

