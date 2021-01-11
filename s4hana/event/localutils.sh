#!/usr/bin/env bash

# Local utilities for use in various other scripts

output=${output:-silent}

log () {
  echo "$(date '+%Y-%m-%d %H:%M:%S')" "$@"
}

err () {
  echo "$@" 1>&2
}

getval () {
  echo "${1}" | jq -r "${2}"
}

gettoken () {
  # Produces an OAuth 2.0 access token from a JSON OAuth 2.0 info stanza
  # that looks like this:
  # {
  #   "clientid": "...",
  #   "clientsecret": "...",
  #   "granttype": "...",
  #   "tokenendpoint": "..."
  # }
  local stanza=${1}
  local clientid clientsecret granttype tokenendpoint

  clientid=$(getval "${stanza}" .clientid)
  clientsecret=$(getval "${stanza}" .clientsecret)
  granttype=$(getval "${stanza}" .granttype)
  tokenendpoint=$(getval "${stanza}" .tokenendpoint)

  # This is basically assuming the use of the OAuth 2.0
  # Client Credentials grant type.
  token=$(
    curl \
      --"${output}" \
      --user "${clientid}:${clientsecret}" \
      --data "grant_type=${granttype}" \
      "${tokenendpoint}" \
    | jq -r '.access_token'
  )
  echo "${token}"
}

# For a given service instance, returns the information
# in a service key, specified by name. Basic cacheing
# in that key data is regenerated from the cloud platform
# and cached for N mins in a local file.
getservicekey () {
  local instance=${1}
  local servicekey=${2}
  local cachetime="+5" # mins
  local file="sk-$instance-$servicekey.json"

  # If the file doesn't exist, or is older than N mins,
  # then we need to (re)refresh from the cloud.
  if [ ! -f "$file" ] || test "$(find "$file" -mmin $cachetime)"; then
    cf service-key "${instance}" "${servicekey}" | sed '1,2d' > "$file"
  fi

  cat "$file"
}





