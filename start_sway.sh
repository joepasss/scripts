#!/bin/bash

if test -z "${XDG_RUNTIME_DIR}"; then
  export XDG_RUNTIME_DIR=/tmp/"${UID}"-runtime-dir

  if ! test -d "${XDG_RUNTIME_DIR}"; then
    mkdir "${XDG_RUNTIME_DIR}"
    chmod 0700 "${XDG_RUNTIME_DIR}"
  fi
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

dbus-run-session sway
