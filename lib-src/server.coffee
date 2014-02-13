# Licensed under the Apache License. See footer for details.

http = require "http"

_            = require "underscore"
express      = require "express"
concatStream = require "concat-stream"

pkg = require "../package.json"

#-------------------------------------------------------------------------------
module.exports = class Server

    #---------------------------------------------------------------------------
    @version: pkg.version

    #---------------------------------------------------------------------------
    constructor: (options={}) ->
        options.port    ?= 3000
        options.verbose ?= false

        {@port, @verbose} = options

        @pullers = []

        @logv "options: #{JSON.stringify options, null, 4}"

        app = express()

        @handlePull = @handlePull.bind @
        @handlePush = @handlePush.bind @

        app.use CORSify
        app.get /^\/events\/(.*)$/, @handlePull
        app.all /^\/events\/(.*)$/, @handlePush

        @server = http.createServer app

    #---------------------------------------------------------------------------
    start: (callback) ->
        @log "server starting: http://localhost:#{@port}"

        @server.listen @port, callback

        @interval = setInterval (=> @pingPullers()), 30 * 1000

        return

    #---------------------------------------------------------------------------
    stop: (callback) ->
        @log "server stopping: http://localhost:#{@port}"

        @server.close callback

        clearInterval @interval

        return

    #---------------------------------------------------------------------------
    pingPullers: ->
        @logv "pinging #{@pullers.length} pullers"

        for puller in @pullers
            puller.response.write ": ping!\n\n"

    #---------------------------------------------------------------------------
    handlePush: (request, response, next) ->
        return next() if request.method is "GET"

        path = request.params[0]
        @logv "pushing #{request.method} #{path}"

        request.pipe concatStream (body) =>
            body = body.toString()

            message =
                method:  request.method
                path:    request.path
                headers: request.headers
                body:    body

            @publish path, message

        response.send 200, ""

    #---------------------------------------------------------------------------
    publish: (path, message) ->
        @logv "publishing #{path} to #{@pullers.length} pullers: #{JSON.stringify message, null, 4}"

        for puller in @pullers
            continue unless puller.path is path

            puller.response.write "data: #{JSON.stringify message}\n\n"

    #---------------------------------------------------------------------------
    handlePull: (request, response, next) ->
        path = request.params[0]

        @logv "pulling #{path}"

        puller = { path, response }

        @pullers.push puller

        response.writeHead 200,
            "Content-Type": "text/event-stream"

        response.write ": just opened!\n\n"

        # remove puller when it stops listening
        response.on "close", =>
            index = @pullers.indexOf puller
            return if index is -1
            @pullers = @pullers.splice index, 1

    #---------------------------------------------------------------------------
    log: (message) ->
        console.log "#{pkg.name}: #{message}"

    #---------------------------------------------------------------------------
    logv: (message) ->
        return unless @verbose
        @log message

#-------------------------------------------------------------------------------
# add CORS headers to response
#-------------------------------------------------------------------------------
CORSify = (request, response, next) ->
    response.header "Access-Control-Allow-Origin:", "*"
    response.header "Access-Control-Allow-Methods", "POST, GET,"
    next()

#-------------------------------------------------------------------------------
# Copyright 2014 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
