#!/bin/bash

APP_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

if [[ ! -e "$APP_PATH/domains" || ! -s "$APP_PATH/domains" ]]; then
    echo '"domains" file not found or are empty.'
    exit 1
fi

source "$APP_PATH/bin/passive_recon.sh"
