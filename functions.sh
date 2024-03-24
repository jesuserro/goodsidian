#!/bin/sh

# array fns: 
# - https://unix.stackexchange.com/questions/1527/bash-eval-array-variable-name
# - https://www.ludvikjerabek.com/2015/08/24/getting-bashed-by-dynamic-arrays/

get_book_header(){
  local author="${1}"
  local publication_year="${2}"
  local publisher="${3}"
  local link="${4}"
  local num_pages="${5}"
  local ratings_count="${6}"
  local average_rating="${7}"
  local isbn="${8}"
  local kindle_asin="${9}"
  local asin="${10}"
  local result=""

  if [ -n "${author}" ]; then
    result="[[${author}]]"
  fi
  if [ -n "${isbn}" ]; then
    result="${result} | [[${isbn}]]"
  fi
  if [ -n "${kindle_asin}" ]; then
    result="${result} | [[${kindle_asin}]]"
  fi
  if [ -n "${publication_year}" ]; then
    result="${result} | [[${publication_year}]]"
  fi
  if [ -n "${publisher}" ]; then
    result="${result} | [[${publisher}]]" 
  fi
  if [ -n "${link}" ]; then
    result="${result}\n[Goodreads book](${link})"
  fi
  if [ -n "${num_pages}" ]; then
    result="${result} | ${num_pages}"  
  fi
  if [ -n "${ratings_count}" ]; then
    result="${result} | ${ratings_count}"
  fi
  if [ -n "${average_rating}" ]; then
    result="${result} | ${average_rating}"
  fi
  if [ -n "${asin}" ]; then
    result="${result}\n[Amazon book](https://www.amazon.com/dp/${asin})"
  fi

  echo "${result}"
}

get_review_header(){
  local author="${1}"
  local publication_year="${2}"
  local publisher="${3}"
  local format="${4}"
  local result=""

  if [ -n "${author}" ]; then
    result="[[${author}]]"
  fi
  if [ -n "${publication_year}" ]; then
    result="${result} | [[${publication_year}]]"
  fi
  if [ -n "${publisher}" ]; then
    result="${result} | [[${publisher}]]"
  fi
  if [ -n "${format}" ]; then
    result="${result} | [[${format}]]"
  fi

  echo "${result}"
}

get_publication_date(){
    local year="${1}"
    local month=$(printf %02d ${2})
    local day=$(printf %02d ${3})
    local result=""

    if [ -n "${year}" ]; then
      result="${year}"
      if [ -n "${month}" -a "${month}" -ne "00" ]; then
        result="${year}-${month}"
        if [ -n "${day}" -a "${day}" -ne "00" ]; then
          result="${year}-${month}-${day}"
        fi
      fi
      result="${result}"
    fi

    echo "${result}"
}


get_clean_publication_date(){
    local year="${1}"
    local month=$(printf %02d ${2})
    local day=$(printf %02d ${3})
    local result=""

    if [ -n "${year}" ]; then
      result="${year}"
      if [ -n "${month}" -a "${month}" -ne "00" ]; then
        result="${year}${month}"
        if [ -n "${day}" -a "${day}" -ne "00" ]; then
          result="${year}${month}${day}"
        fi
      fi
    fi

    echo "${result}"
}

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


