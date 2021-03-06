#!/bin/bash

export MIX_ENV=prod
export PORT=4444

echo "Stopping old copy of app, if any..."

_build/prod/rel/event_app/bin/event_app stop || true

echo "Starting app..."  

_build/prod/rel/event_app/bin/event_app start
