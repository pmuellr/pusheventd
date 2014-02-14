# Licensed under the Apache License. See footer for details.

URL  = require "url"
http = require "http"

expect      = require "expect.js"
EventSource = require "eventsource"

EventSourceOpts =
    rejectUnauthorized: false

main = require ".."

port = null

#-------------------------------------------------------------------------------
describe "server", ->
    server = null

    #----------------------------------
    before (done) ->
        p = main.start verbose: false
        p.then (s) ->
            server = s
            port = server.port
            done()

        p.fail (error) ->
            done error

        p.done()

    #----------------------------------
    after (done) ->
        # @timeout 10000
        p = server.stop()
        done()
        # p.then -> done()
        # p.fail (error) -> done error
        # p.done()

    #----------------------------------
    it "should handle a push", (done) ->
        pushEvent "POST", "foo1", "bar", (response) ->
            expect(response.statusCode).to.be 200
            done()

    #----------------------------------
    it "should handle a pull", (done) ->
        es = new EventSource "http://localhost:#{port}/events/foo2", EventSourceOpts
        es.onopen = (event) ->
            console.log "eventsource: open ",  event
            pushEvent "PUT", "foo2", "barbar"

        es.onerror = (event) ->
            console.log "eventsource: error ", event

        es.onmessage = (event) ->
            data = JSON.parse event.data
            expect(data?.body).to.be "barbar"
            expect(data?.method).to.be "PUT"
            es.close()
            done()

#-------------------------------------------------------------------------------
pushEvent = (method, path, data, cb=->) ->
    url = "http://localhost:#{port}/events/#{path}"
    options = URL.parse url
    options.method = method

    request = http.request options, cb

    request.write data
    request.end()

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
