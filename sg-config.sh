#!/usr/bin/env bash

set -e

SG_ADMIN_URL=http://localhost:4985
SG_ADMIN_USER=sg-admin
SG_ADMIN_PASSWORD=password
SG_DB_NAME="sg"
SG_DB_BUCKET="sg"

SG_CONFIG=$(
    cat <<EOF
{
    "bucket": "$SG_DB_BUCKET",
    "num_index_replicas": 0
}
EOF
)

function create-db() {
    curl -u $SG_ADMIN_USER:$SG_ADMIN_PASSWORD \
        -X PUT \
        -H "Content-Type: application/json" \
        -d "$SG_CONFIG" \
        $SG_ADMIN_URL/$SG_DB_NAME/
}

function update-db-config() {
    curl -u $SG_ADMIN_USER:$SG_ADMIN_PASSWORD \
        -X PUT \
        -H "Content-Type: application/json" \
        -d "$SG_CONFIG" \
        $SG_ADMIN_URL/$SG_DB_NAME/_config
}

function get-db() {
    curl -u $SG_ADMIN_USER:$SG_ADMIN_PASSWORD \
        -L \
        -X GET \
        $SG_ADMIN_URL/$SG_DB_NAME/
}

function get-db-config() {
    curl -u $SG_ADMIN_USER:$SG_ADMIN_PASSWORD \
        -L \
        -X GET \
        $SG_ADMIN_URL/$SG_DB_NAME/_config/
}

"$@"
