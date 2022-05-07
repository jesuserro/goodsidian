#!/bin/sh

# see: https://unix.stackexchange.com/questions/277861/parse-xml-returned-from-curl-within-a-bash-script

if [ -z "$1" ]
then
  echo "Especifica un bookid"
  exit 1
fi

. ./goodreads.cfg

xpathBook="GoodreadsResponse/book"
xpathAuthor="GoodreadsResponse/book/authors/author[1]"

urlBook="$urlbase/book/show?format=xml&key=$apikey&id=$1"

xmlBook=$(curl -s $urlBook)

# LIBRO
title=$(echo $xmlBook | xmllint --xpath "//$xpathBook/title[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
image_url=$(echo $xmlBook | xmllint --xpath "//$xpathBook/image_url[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
description=$(echo $xmlBook | xmllint --xpath "//$xpathBook/description[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
publisher=$(echo $xmlBook | xmllint --xpath "//$xpathBook/publisher[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# isbn=$(echo $xmlBook | xmllint --xpath "//$xpathBook/isbn[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# isbn13=$(echo $xmlBook | xmllint --xpath "//$xpathBook/isbn13[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# kindle_asin=$(echo $xmlBook | xmllint --xpath "//$xpathBook/kindle_asin[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# publication_year=$(echo $xmlBook | xmllint --xpath "//$xpathBook/publication_year[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

# AUTOR
# authorId=$(echo $xmlBook | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# urlAuthor="$urlbase/author/show.xml?key=$apikey&id=$authorId"

authorName=$(echo $xmlBook | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorImage=$(echo $xmlBook | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorLink=$(echo $xmlBook | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


# echo "$bookid -> $title -> $kindle_asin -> $isbn -> $isbn13 -> $publication_year"
echo "$1 -> $title -> $authorName -> $authorLink -> $publisher"



