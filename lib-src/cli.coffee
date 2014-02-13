# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

_    = require "underscore"
nopt = require "nopt"

pkg   = require "../package.json"
main  = require "./main"

PROGRAM     = pkg.name
VERSION     = pkg.version

cli = exports

#-------------------------------------------------------------------------------
exports.main = ->
    options =
        port:    [ "p", Number  ]
        verbose: [ "v", Boolean ]
        help:    [ "h", Boolean ]

    shortOptions = "?": ["--help"]
    for optionName, optionRec of options
        if optionRec[0] isnt ""
            shortOptions[optionRec[0]] = ["--#{optionName}"]

    for optionName, optionRec of options
        options[optionName] = optionRec[1]

    parsed = nopt options, shortOptions, process.argv, 2

    args = parsed.argv.remain

    return help() if args[0] in ["?", "help"]
    return help() if parsed.help

    cmdOptions = {}
    for optionName, ignored of options
        cmdOptions[optionName] = parsed[optionName] if parsed[optionName]?

    envOptions = {}
    envOptions.port = process.env.PORT

    options = _.defaults cmdOptions, envOptions

    main.start options

#-------------------------------------------------------------------------------
help = ->
#       ---------1---------2---------3---------4---------5---------6---------7---------8
    console.log """
        #{PROGRAM} #{VERSION}

            runs a #{PROGRAM} server

        usage: #{PROGRAM} [options]

        options:
            -p --port NUMBER     tcp/ip to run server on
            -v --verbose         be verbose
            -h --help            print this help

        The port can also be specified by setting the PORT environment variable.
    """

    return

#-------------------------------------------------------------------------------
exports.run() if require.main is module

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
