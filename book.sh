#!/bin/sh
# USAGE: sh book.sh 82405
# see: https://unix.stackexchange.com/questions/277861/parse-xml-returned-from-curl-within-a-bash-script

if [ -z "$1" ]
then
  echo "Especifica un bookid"
  exit 1
fi

. ./goodreads.cfg

xpathBook="GoodreadsResponse/book"
xpathAuthor="GoodreadsResponse/book/authors/author[1]"

url="$urlbase/book/show?format=xml&key=$apikey&id=$1"

xml=$(curl -s $url)

# LIBRO
title=$( echo $xml | xmllint --xpath "//$xpathBook/title[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
image_url=$( echo $xml | xmllint --xpath "//$xpathBook/image_url[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
description=$( echo $xml | xmllint --xpath "//$xpathBook/description[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
publisher=$( echo $xml | xmllint --xpath "//$xpathBook/publisher[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# isbn=$( echo $xml | xmllint --xpath "//$xpathBook/isbn[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# isbn13=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# kindle_asin=$( echo $xml | xmllint --xpath "//$xpathBook/kindle_asin[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# publication_year=$( echo $xml | xmllint --xpath "//$xpathBook/publication_year[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorId=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

# echo "$bookid -> $title -> $kindle_asin -> $isbn -> $isbn13 -> $publication_year"
echo "$1 -> $title -> $publisher"


# AUTOR
if [ -z "$authorId" ]
then
  echo "Missing author_id"
  exit 1
fi
sleep 1

sh ./author.sh $authorId



