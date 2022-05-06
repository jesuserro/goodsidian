#!/bin/sh

# see: https://unix.stackexchange.com/questions/277861/parse-xml-returned-from-curl-within-a-bash-script

. ./goodreads.cfg

url="$urlbase/review/list_rss/$user?key=$key&shelf=$shelf"

# This grabs the data from the currently reading rss feed and formats it
feed=$(curl --silent "$url" | grep -E '(book_id>)' | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' -e 's/<book_id>//' -e 's/<\/book_id>/ | /')

# Turn the data into an array
arr=($(echo $feed | tr "|" "\n"))

# Get the amount of books
bookamount=$( expr "${#arr[@]}")

if (( "$bookamount" == 0 )); then
  echo "No books found in shelf $shelf"
fi

xpathBook="GoodreadsResponse/book"
xpathAuthor="GoodreadsResponse/book/authors/author[1]"

# Start the loop for each book
for (( i = 0 ; i < ${bookamount} ; i++ ))
do

  bookid=${arr[$i]}

  if [ -z "$bookid" ]
  then
    continue
  fi

  urlBook="$urlbase/book/show?format=xml&key=$apikey&id=$bookid"

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
  # echo "$bookid -> $title -> $authorName -> $authorLink"
  echo "$bookid -> $publisher"

done
