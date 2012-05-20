var exec = require('child_process').exec,
    http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs")
    port = process.argv[2] || 8888;

function serveFilename(filename, response) {
  fs.readFile(filename, "binary", function(err, file) {
    if (err) {        
      response.writeHead(500, {"Content-Type": "text/plain"});
      response.write(err + "\n");
      response.end();
      return;
    }

    if (filename.match(/\.html$/))
      mimeType = "text/html";
    else if (filename.match(/\.js$/))
      mimeType = "application/javascript";
    else
      mimeType = "text/plain";

    response.writeHead(200, {"Content-Type": mimeType});
    response.write(file, "binary");
    response.end();
  });
}

http.createServer(function(request, response) {
  var uri = url.parse(request.url).pathname,
    filename = path.join(process.cwd(), uri),
    mimeType;
  
  path.exists(filename, function(exists) {
    if(!exists) {
      response.writeHead(404, {"Content-Type": "text/plain", "Cache-Control": "no-cache" });
      response.write("404 Not Found\n");
      response.end();
      return;
    }

    if (fs.statSync(filename).isDirectory()) filename += '/index.html';

    if (filename.match(/\.coffee$/)) {
      // -c means compile, -b means without containing block
      var command = '/usr/local/bin/coffee -c -b ' + filename;
      child = exec(command, function(error, stdout, stderr) {
        //console.log('stdout: ' + stdout);
        //console.log('stderr: ' + stderr);
        if (error !== null) {
          console.log('error execing ' + command + ': ' + error);
        }

        serveFilename(filename.replace('.coffee', '.js'), response);
      });
    } else {
      serveFilename(filename, response);
    }
  });
}).listen(parseInt(port, 10));

console.log("Static file server running at\n  => http://localhost:" +
  port + "/\nCTRL + C to shutdown");
