#!/bin/sh

yarn --cwd /api/ start:prod &
yarn --cwd /front/ start &
redis-server &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?