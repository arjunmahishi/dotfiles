#!/bin/zsh

get_bettery_percent () {
  echo $(upower -i $(upower -e | grep $1) | grep percentage | awk '{print $2}')
}


final_text=""
mouse=$(get_bettery_percent 'mouse')
keyboard=$(get_bettery_percent 'keyboard')

if [[ -n $keyboard ]]; then
  final_text="$final_text \uf11c $keyboard"
fi

if [[ -n $mouse ]]; then
  final_text="$final_text \uf87c $mouse"
fi

if [[ -n $final_text ]]; then
  final_text="| $final_text"
fi

echo $final_text
