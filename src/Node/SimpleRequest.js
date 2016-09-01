exports.collapseStream = function (stream) {
  return function (onErr) {
    return function (onSucc) {
      return function () {
        var body = "";
        stream.on("data", function (chunk) {
          body += chunk;
        });
        stream.on("end", function () {
          onSucc(body)();
        });
        stream.on("error", function (err) {
          onErr(err)();
        });
        return {};
      }
    }
  }
}

exports.collapseStreamB = function (size) {
  return function (stream) {
    return function (onErr) {
      return function (onSucc) {
        return function () {
          var buf = Buffer.alloc(size);
          var off = 0;
          stream.on("data", function (chunk) {
            if (chunk.length + off <= buf.length) {
              chunk.copy(buf, off);
            } else {
              buf = Buffer.concat([buf, chunk], buf.length + chunk.length);
            }
            off += chunk.length;
          });
          stream.on("end", function () {
            onSucc(buf)();
          });
          stream.on("error", function (err) {
            onErr(err)();
          });
          return {};
        }
      }
    }
  }
}
