testing manually
--------------------------------------------------------------------------------

start the server:

    node server -v

start a puller:

    curl http://localhost:3000/events/foo

push a meesage:

    curl -d bar http://localhost:3000/events/foo