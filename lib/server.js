// Generated by CoffeeScript 1.7.1
(function() {
  var CORSify, Server, concatStream, express, http, pkg, _;

  http = require("http");

  _ = require("underscore");

  express = require("express");

  concatStream = require("concat-stream");

  pkg = require("../package.json");

  module.exports = Server = (function() {
    Server.version = pkg.version;

    function Server(options) {
      var app;
      if (options == null) {
        options = {};
      }
      if (options.port == null) {
        options.port = 3000;
      }
      if (options.verbose == null) {
        options.verbose = false;
      }
      this.port = options.port, this.verbose = options.verbose;
      this.pullers = [];
      this.logv("options: " + (JSON.stringify(options, null, 4)));
      app = express();
      this.handlePull = this.handlePull.bind(this);
      this.handlePush = this.handlePush.bind(this);
      app.use(CORSify);
      app.get(/^\/events\/(.*)$/, this.handlePull);
      app.all(/^\/events\/(.*)$/, this.handlePush);
      this.server = http.createServer(app);
    }

    Server.prototype.start = function(callback) {
      this.log("server starting: http://localhost:" + this.port);
      this.server.listen(this.port, callback);
      this.interval = setInterval(((function(_this) {
        return function() {
          return _this.pingPullers();
        };
      })(this)), 30 * 1000);
    };

    Server.prototype.stop = function(callback) {
      this.log("server stopping: http://localhost:" + this.port);
      this.server.close(callback);
      clearInterval(this.interval);
    };

    Server.prototype.pingPullers = function() {
      var puller, _i, _len, _ref, _results;
      this.logv("pinging " + this.pullers.length + " pullers");
      _ref = this.pullers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        puller = _ref[_i];
        _results.push(puller.response.write(": ping!\n\n"));
      }
      return _results;
    };

    Server.prototype.handlePush = function(request, response, next) {
      var path;
      if (request.method === "GET") {
        return next();
      }
      path = request.params[0];
      this.logv("pushing " + request.method + " " + path);
      request.pipe(concatStream((function(_this) {
        return function(body) {
          var message;
          body = body.toString();
          message = {
            method: request.method,
            path: request.path,
            headers: request.headers,
            body: body
          };
          return _this.publish(path, message);
        };
      })(this)));
      return response.send(200, "");
    };

    Server.prototype.publish = function(path, message) {
      var puller, _i, _len, _ref, _results;
      this.logv("publishing " + path + " to " + this.pullers.length + " pullers: " + (JSON.stringify(message, null, 4)));
      _ref = this.pullers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        puller = _ref[_i];
        if (puller.path !== path) {
          continue;
        }
        _results.push(puller.response.write("data: " + (JSON.stringify(message)) + "\n\n"));
      }
      return _results;
    };

    Server.prototype.handlePull = function(request, response, next) {
      var path, puller;
      path = request.params[0];
      this.logv("pulling " + path);
      puller = {
        path: path,
        response: response
      };
      this.pullers.push(puller);
      response.writeHead(200, {
        "Content-Type": "text/event-stream"
      });
      response.write(": just opened!\n\n");
      return response.on("close", (function(_this) {
        return function() {
          var index;
          index = _this.pullers.indexOf(puller);
          if (index === -1) {
            return;
          }
          return _this.pullers = _this.pullers.splice(index, 1);
        };
      })(this));
    };

    Server.prototype.log = function(message) {
      return console.log("" + pkg.name + ": " + message);
    };

    Server.prototype.logv = function(message) {
      if (!this.verbose) {
        return;
      }
      return this.log(message);
    };

    return Server;

  })();

  CORSify = function(request, response, next) {
    response.header("Access-Control-Allow-Origin:", "*");
    response.header("Access-Control-Allow-Methods", "POST, GET,");
    return next();
  };

}).call(this);