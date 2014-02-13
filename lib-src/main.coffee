# Licensed under the Apache License. See footer for details.

Q = require "q"

pkg = require "../package.json"

Server = require "./server"

main = exports

main.version = pkg.version

#-------------------------------------------------------------------------------
# returns promise on server object when server starts
#-------------------------------------------------------------------------------
main.start = (options) ->
    server = new Server options

    deferred = Q.defer()

    server.start (error) ->
        return deferred.reject error if error

        serverShell =
            port: server.port
            stop: -> stop server

        deferred.resolve serverShell

    return deferred.promise

#-------------------------------------------------------------------------------
# returns promise of stopping server (resolves to null)
#-------------------------------------------------------------------------------
stop = (server) ->
    deferred = Q.defer()

    server.stop (error) ->
        return deferred.reject error if error

        deferred.resolve null

    return deferred.promise

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
