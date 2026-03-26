#!/usr/bin/env bash
# rbl_check.sh
# Modes:
#   discovery                -> LLD: list all RBL zones from txt file
#   check <IP> <RBL_ZONE>    -> 0 not listed, 1 listed, 2 error

RBL_FILE="/usr/lib/zabbix/externalscripts/dnsblcheck_blacklist.txt"

mode="$1"

if [[ "$mode" == "discovery" ]]; then
  if [[ ! -f "$RBL_FILE" ]]; then
    echo '{"data":[]}'
    exit 0
  fi

  echo -n '{"data":['
  first=1
  while IFS= read -r zone; do
    zone="${zone%%#*}"
    zone="$(echo "$zone" | xargs)"
    [[ -z "$zone" ]] && continue
    if [[ $first -eq 0 ]]; then
      echo -n ','
    fi
    first=0
    printf '{"{#RBL}":"%s"}' "$zone"
  done < "$RBL_FILE"
  echo ']}'
  exit 0
fi

if [[ "$mode" == "check" ]]; then
  IP="$2"
  ZONE="$3"

  if [[ -z "$IP" || -z "$ZONE" ]]; then
    echo 2
    exit 0
  fi

  if ! [[ "$IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo 2
    exit 0
  fi

  rev_ip="$(echo "$IP" | awk -F. '{print $4"."$3"."$2"."$1}')"
  query="${rev_ip}.${ZONE}"

  if command -v dig >/dev/null 2>&1; then
    answer="$(dig +short "$query" A 2>/dev/null)"
  elif command -v host >/dev/null 2>&1; then
    answer="$(host "$query" 2>/dev/null | awk '/has address/ {print $4}')"
  else
    echo 2
    exit 0
  fi

  if [[ -n "$answer" ]]; then
    echo 1
  else
    echo 0
  fi
  exit 0
fi

# Unknown mode
echo 2
exit 0
