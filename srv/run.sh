#!/bin/bash
set -eo pipefail

rm /etc/redis.conf

while read -d $'\0' variable; do
  name=$(echo $variable | cut -d "=" -f 1)
  pointer_variable="${name}_VARIABLE"

  config_name=$(echo $variable | sed -n 's/^REDIS_\(.*\)=.*/\1/p' | tr '[:upper:]_' '[:lower:]-')
  if [ -n "${!pointer_variable}" ]; then
    config_value_variable_name=${!pointer_variable}
    config_value=${!config_value_variable_name}
  else
    config_value=${!name}
  fi

  echo $config_name $config_value >> /etc/redis.conf
done < <(env -0 | grep -zE '^REDIS' | grep -zv 'VARIABLE=' | sort -z)

exec /usr/bin/redis-server /etc/redis.conf
