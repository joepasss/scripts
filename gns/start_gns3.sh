#!/bin/bash

# shellcheck disable=SC1091
source "$HOME/misc/gns3/bin/activate"

export GNS3_USER=gns3
export GNS3_PASSWORD=gns3pass

pushd "$HOME/misc/gns3-server" >/dev/null || exit
gns3server --host 0.0.0.0 --port 3080
popd >/dev/null || exit
