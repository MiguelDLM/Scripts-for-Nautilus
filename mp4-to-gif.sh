#!/bin/bash

main() {
    FILES="$NEMO_SCRIPT_SELECTED_FILE_PATHS"

    check_dependencies

    convert_files "$FILES"
}

check_dependencies() {
    FFMPEG_VERSION=$(type ffmpeg &> /dev/null && ffmpeg -version | head -1 | cut -d' ' -f3 | tr -d '\n')

    if [[ "${FFMPEG_VERSION}none" = "none" ]]; then
        zenity --error --width 300 --text="ffmpeg is not installed."
        exit 1
    fi
}

convert_files() {
    FILES="$1"

    echo "$FILES" | while read FILE; do
        if [ -n "$FILE" ]; then
            FILETYPE=$(file "$FILE")

            echo "$FILETYPE" | grep -i "mp4" &> /dev/null

            if [[ $? != 0 ]]; then
                zenity --width=640 --error --text="The file $FILE is not an MP4 file:\n$FILETYPE" && exit 1
                if [ "$?" -eq 1 ]; then
                    exit
                fi
            else
                convert_file "$FILE"
            fi
        fi
    done
}

convert_file() {
    FILE="$1"
    PALETTE="/tmp/palette.png"
    FILTERS="fps=15,scale=640:-1:flags=lanczos"
    OUTPUT_FILE="${FILE%.*}.gif"

    # Generate palette
    ffmpeg -v warning -i "$FILE" -vf "$FILTERS,palettegen" -y "$PALETTE"

    # Create GIF using the palette
    ffmpeg -v warning -i "$FILE" -i "$PALETTE" -lavfi "$FILTERS [x]; [x][1:v] paletteuse" -y "$OUTPUT_FILE"

    if [ $? -eq 0 ]; then
        zenity --info --width=300 --text="Conversion completed: $OUTPUT_FILE"
    else
        zenity --error --width=300 --text="Error converting $FILE"
    fi
}

main