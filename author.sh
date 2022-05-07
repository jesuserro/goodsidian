#!/bin/sh

# USAGE: sh author.sh 4905855

if [ -z "$1" ]
then
      echo "Especifica author_id"
      exit 1
fi

. ./goodreads.cfg

xpathAuthor="GoodreadsResponse/author[1]"

url="$urlbase/author/show.xml?key=$apikey&id=$1"

xml=$(curl -s $url)

# AUTOR
authorName=$(echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorImage=$(echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorLink=$(echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

echo "$authorName -> $authorLink"


    
















