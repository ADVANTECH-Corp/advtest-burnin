#! /bin/bash

sudo cp /home/linaro/.Xauthority /root/.Xauthority
export DISPLAY=:0.0

glmark2

