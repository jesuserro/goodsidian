#!/bin/sh
# USAGE: sh book.sh 82405
# see: https://unix.stackexchange.com/questions/277861/parse-xml-returned-from-curl-within-a-bash-script



. ./goodreads.cfg
. ./functions.sh



# review=( "$@" )

# for key in "${!review[@]}"; { data+=" $key=${review[$key]}"; }
# echo "$data" 


# declare -p scalar_array
eval $scalar_array
declare -p review # escapa comillas

echo "title: ${review[title]}"

exit 1



xpathBook="GoodreadsResponse/book"
xpathAuthor="GoodreadsResponse/book/authors/author[1]"

url="$urlbase/book/show?format=xml&key=$apikey&id=$1"

# echo "BOOK $url"

xml=$(curl -s $url)

# LIBRO
title=$( echo $xml | xmllint --xpath "//$xpathBook/title[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
cleantitle=$(echo "${title}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')

image_url=$( echo $xml | xmllint --xpath "//$xpathBook/image_url[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
description=$( echo $xml | xmllint --xpath "//$xpathBook/description[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
description=$(clean_long_text "${description}")
publisher=$( echo $xml | xmllint --xpath "//$xpathBook/publisher[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
isbn=$( echo $xml | xmllint --xpath "//$xpathBook/isbn[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
isbn13=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
if [ -z "$isbn" ]; then
  isbn=$isbn13
fi
kindle_asin=$( echo $xml | xmllint --xpath "//$xpathBook/kindle_asin[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
publication_year=$( echo $xml | xmllint --xpath "//$xpathBook/publication_year[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
average_rating=$( echo $xml | xmllint --xpath "//$xpathBook/average_rating[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
num_pages=$( echo $xml | xmllint --xpath "//$xpathBook/num_pages[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


# AUTHOR
authorId=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

# echo "$bookid -> $title -> $kindle_asin -> $isbn -> $isbn13 -> $publication_year"
echo "BOOK $1 -> $title -> $publisher"


bookNote="---
aliases: []
bookid: ${1}
isbn: ${isbn}
asin: ${kindle_asin}
author:: [[${author}]]
pages: ${num_pages}
publisher:: [[${publisher}]]  
book_published:: [[${publication_year}]]  
cover: ${image_url}   
tags: 
- book/goodreads/profile
date: ${publication_year}
rating: ${average_rating}
emotion:
---

# ${title}

**Author**: [[${author}]]
**Fecha Publicación**: $publication_year
**Ficha Goodreads**: [Review, Private notes & Quotes]($1)
**Tags**: [[goodreads]]

![b|150](${image_url})

## Sinopsis
${description}

## Índice

## Referencias
- " 

  bookFileName="${publication_year} ${cleantitle}"
  bookPath="${vaultpath}/${bookFileName}.md"




# AUTOR
if [ -z "$authorId" ]; then
  echo "Missing author_id"
  exit 1
fi
sleep 1

authorIdCleaned=$( echo $authorId | sed -e 's/^[[:space:]]*//')

if [ -z "$2" -a -z "$3" ]; then
  # Review note missing
  sh ./author.sh $authorIdCleaned "${bookNote}" "${bookPath}"
  exit 1
fi

# Review note exist
reviewNote="${2} [[${bookFileName}]]"
sh ./author.sh $authorIdCleaned "${bookNote}" "${bookPath}" "${reviewNote}" "${3}"



