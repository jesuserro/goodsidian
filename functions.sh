#!/bin/sh

# array fns: 
# - https://unix.stackexchange.com/questions/1527/bash-eval-array-variable-name
# - https://www.ludvikjerabek.com/2015/08/24/getting-bashed-by-dynamic-arrays/

# my functions
clean_note_path(){
    prefix="${vaultpath}/"
    suffix=".md"
    local a="${1}"
    local x=${a#"$prefix"}
    x=${x%"$suffix"}
    echo "${x}"
}

clean_long_text(){
  local long_text="${1}"
  long_text=$(echo -e "${long_text//$'<br />'/\\n}" | \
    sed 's/<[^\/][^<>]*> *<\/[^<>]*>//g' | \
    sed -e 's|<i>|_|g' -e 's|</i>|_|g' | \
    sed -e 's|<b>|*|g' -e 's|</b>|*|g' | \
    sed -e 's|<strong>|*|g' -e 's|</strong>|*|g' | \
    sed -e 's|<p>|\n|g' -e 's|</p>|\n|g' | \
    sed -e 's/^[[:space:]]*//')

  echo "${long_text}"
}

