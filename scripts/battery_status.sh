#!/bin/zsh

get_bettery_percent () {
        echo $(upower -i $(upower -e | grep $1) | grep percentage | awk '{print $2}')
}

echo "[k: $(get_bettery_percent 'keyboard') m: $(get_bettery_percent 'mouse')]"
