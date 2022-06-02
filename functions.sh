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
  local cleaned_txt; orig=$'\n'; replace=$'\\\n'
  IFS= read -r -d '' cleaned_txt <<EOC
    ${1}
EOC

  cleaned_txt=$( echo ${cleaned_txt} | sed -e 's|${orig}|${replace}|g' )
  
  echo -e "${cleaned_txt}" | \
    sed -e 's|\s*<br \/>\s*|\\n|g' -e 's|\s*&lt;br /&gt;\s*|\\n|g' | \
    sed 's|<[^\/][^<>]*> *<\/[^<>]*>||g' | \
    sed -e 's|<i>\s*|_|g' -e 's|\s*</i>|_|g' -e 's|&lt;i&gt;\s*|_|g' -e 's|\s*&lt;/i&gt;|_|g' -e 's|<em>\s*|_|g' -e 's|\s*</em>|_|g' | \
    sed -e 's|<b>\s*|*|g' -e 's|\s*</b>|*|g' -e 's|&lt;b&gt;\s*|*|g' -e 's|\s*&lt;/b&gt;|*|g' -e 's|<strong>\s*|*|g' -e 's|\s*</strong>|*|g' | \
    sed -e 's|<p>\s*|\\n|g' -e 's|\s*</p>|\\n|g' -e 's|&lt;p&gt;\s*|\\n|g' -e 's|\s*&lt;/p&gt;|\\n|g' | \
    sed -e 's|<blockquote>\s*|\\n\\n >|g' -e 's|\s*</blockquote>|\\n\\n|g' | \
    sed -e 's|<a\(.*\)href="\s*\([^"]+\)\(\s*.*\)>\s*\(.*\)\s*</a>|[\4](\2)|g' | \
    sed -e 's|^[[:space:]]*||'
}

clean_long_text_test(){
  local cleaned_txt
  IFS= read -r -d '' cleaned_txt <<EOC
    ${1}
EOC
  
  echo -e "${cleaned_txt}" | \
    sed 's|<br \/>|\\n|g' | \
    sed 's|<[^\/][^<>]*> *<\/[^<>]*>||g' | \
    sed -e 's|<i>|_|g' -e 's|</i>|_|g' | \
    sed -e 's|<b>|*|g' -e 's|</b>|*|g' | \
    sed -e 's|<strong>|*|g' -e 's|</strong>|*|g' | \
    sed -e 's|<p>|\\n|g' -e 's|</p>|\\n|g' | \
    # sed -e $'s|<a.+?\s*href\s*=\s*["\']?\([^"\'\s>]+\)["\']?.*>\(.*\)</a>|[\2](\1)|g' | \
    sed -e $'s|<a\(.*\)href="?\s*\(.*\)"?[\s.]*>\s*\(.*\)\s*</a>|[\3](\2)|g' | \
    sed -e 's|^[[:space:]]*||'
}


