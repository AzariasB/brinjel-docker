#!/bin/sh -e

if [ "$1" = 'run' ]; then
    # Create and migrate database before running the server.
    /app/createdb  
    /app/migrate
    exec /app/bin/server start
elif [ "$1" = 'db' ]; then
    exec /app/bin/"$2"
else
    exec "$@"
fi

exec "$@"
