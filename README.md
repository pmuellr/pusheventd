pusheventd
================================================================================

Converts non-GET HTTP requests to
[server-sent events](http://dev.w3.org/html5/eventsource/).

The server accepts non-GET HTTP requests on path `/events/<event-name>` and echoes
them on an event source along the path `/events/<event-name>`.  Example, if you
submit an HTTP POST request to `/events/my-event/foo`, it will be available in the
event stream `/events/my-event/foo`.

The data sent on the event is a JSON object with the following properties:

* `method`: the HTTP request method used to push the event
* `headers`: the HTTP request headers
* `body`: the body of the request that pushed the event



usage
--------------------------------------------------------------------------------

    pusheventd [options]

options:

    -p --port NUMBER     tcp/ip to run server on
    -v --verbose         be verbose
    -h --help            print this help

The port may also be specified in the PORT environment variable.



notes / caveats
--------------------------------------------------------------------------------

This server is not currently designed to scale, in terms of running
multiple instances "on the cloud".

There is no security at all.  You probably don't want to advertise the URL to
your server to the world, or at least don't advertise the path you push and
pull from.

Send me a [Pull Request](https://github.com/pmuellr/pusheventd/pulls)!



license
--------------------------------------------------------------------------------

Apache License, Verison 2.0

<http://www.apache.org/licenses/LICENSE-2.0.html>
