#!/bin/bash
set -x
# setup pinned core isolation
systemctl set-property --runtime -- user.slice AllowedCPUs=0,1,6,7
systemctl set-property --runtime -- system.slice AllowedCPUs=0,1,6,7
systemctl set-property --runtime -- init.scope AllowedCPUs=0,1,6,7
