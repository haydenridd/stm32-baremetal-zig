#!/bin/bash
JLINK_EXE="/usr/bin/JLinkExe"

DEVICE="STM32F750N8"

${JLINK_EXE} -NoGui 1 << EOF
device ${DEVICE}
si SWD
speed 4000
h
r
loadfile $1
r
g
exit
EOF