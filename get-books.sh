#!/bin/sh

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

  title=$(echo $xmlBook | xmllint --xpath "//$xpathBook/title[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
  publication_year=$(echo $xmlBook | xmllint --xpath "//$xpathBook/publication_year[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

  echo "$bookid -> $title -> $publication_year"

done
