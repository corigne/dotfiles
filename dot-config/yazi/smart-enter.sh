#!/usr/bin/env bash
path="$1"
signal="$2"
video_exts="mp4 mkv avi mov wmv flv webm m4v mpg mpeg ts m2ts mts vob ogv"
image_exts="jpg jpeg png gif bmp webp avif tiff tif heic svg raw cr2 nef dng orf arw jxl"

toplevel=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)
if [[ "$toplevel" == "$path" ]]; then
    nvim "$path"
    exit 0
fi

total=0; videos=0; images=0; declare -a vfiles=()
while IFS= read -r f; do
    ((total++))
    ext="${f##*.}"; ext="${ext,,}"
    if [[ " $video_exts " == *" $ext "* ]]; then ((videos++)); vfiles+=("$f")
    elif [[ " $image_exts " == *" $ext "* ]]; then ((images++)); fi
done < <(find "$path" -maxdepth 1 -type f 2>/dev/null)

if [[ $videos -ge 1 && $total -gt 0 ]] && awk "BEGIN{exit !($videos/$total>=0.6)}"; then
    IFS=$'\n' sorted=($(printf '%s\n' "${vfiles[@]}" | sort))
    mpv "${sorted[@]}" &>/dev/null & disown
    exit 0
fi

if [[ $images -ge 2 && $total -gt 0 ]] && awk "BEGIN{exit !($images/$total>=0.7)}"; then
    imv "$path" &>/dev/null & disown
    exit 0
fi

touch "$signal"
