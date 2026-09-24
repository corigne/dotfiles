#!/bin/sh

nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk 'BEGIN{FS=","}{print $1"% /"$2"°C"}'
