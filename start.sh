#!/bin/bash

# export SECRET_KEY_BASE=W68eso5YQOlbtvSNUR50N/HDWj6IaEhAwMR3LtzuBEQAefwYVbX84bvoTA7XtiGi
export MIX_ENV=prod
export PORT=4444

echo "Stopping old copy of app, if any..."

_build/prod/rel/event_app/bin/event_app stop || true

echo "Starting app..."  

_build/prod/rel/event_app/bin/event_app start
