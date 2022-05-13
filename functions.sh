#!/bin/sh

clean_note_path(){
    prefix="${vaultpath}/"
    suffix=".md"
    local a="${1}"
    local x=${a#"$prefix"}
    x=${x%"$suffix"}
    echo "${x}"
}