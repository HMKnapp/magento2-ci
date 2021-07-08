#!/bin/bash

set -xe

function get_ngrok_url() {
  curl --fail -s localhost:4040/api/tunnels | jq -r .tunnels\[0\].public_url | sed 's/^http:/https:/'
}

function wait_for_ngrok() {
  while [[ -z ${RESPONSE} || ${RESPONSE} == 'null' ]]; do
    RESPONSE=$(get_ngrok_url)
    sleep 3;
  done
}

NGROK_TOKEN=${1}

echo ${NGROK_TOKEN} | sed 's/\(..\).*\(..\)/\1\2/' >&2

if [[ -z ${NGROK_TOKEN} ]]; then
  echo 'NGROK token missing. Set NGROK_TOKEN env' >&2
  exit 1
fi

./node_modules/ngrok/bin/ngrok authtoken ${NGROK_TOKEN}
./node_modules/ngrok/bin/ngrok http 80 >&/dev/null &
wait_for_ngrok
export NGROK_URL=$(get_ngrok_url)
echo ${NGROK_URL}
