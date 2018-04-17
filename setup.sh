#!/usr/bin/env bash

unset SITE_URL

# Site Configurations

export SITE_USERNAME=admin@phptravels.com
export SITE_PASSWORD=demoadmin
export SITE_URL=https://www.phptravels.net

# Jmeter Configurations

export THROUGHPUT_PER_MINUTE=10
export THREAD_COUNT=1
export USERS_RAMPUP_TIME=10
export LOOP_COUNT=2


# Influx DB Configurations

export DATABASE_NAME=performance_jmeter
export DB_HOST=127.0.0.1
export DB_PORT=8086
export TEST_ENV=phptravels