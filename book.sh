#!/bin/sh
# USAGE: sh book.sh 82405

if [ -z "$1" ]; then
  echo "Especifica un bookid"
  exit 1
fi

. ./goodreads.cfg
. ./functions.sh

eval $scalar_review
declare -p review &>/dev/null # escapa comillas e impide print array en shell

# echo "review guid: ${review[guid]}"
 
xpathBook="GoodreadsResponse/book"
xpathAuthor="${xpathBook}/authors/author[1]"

url="$urlbase/book/show?format=xml&key=$apikey&id=$1"

# echo "BOOK $url"

xml=$(curl -s $url)

declare -A book
book['bookid']="${1}"
# LIBRO
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')

book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['description']=$( echo $xml | xmllint --xpath "//$xpathBook/description[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['description']=$(clean_long_text "${book['description']}")
book['publisher']=$( echo $xml | xmllint --xpath "//$xpathBook/publisher[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['isbn']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['isbn13']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
if [ -z "${book['isbn']}" ]; then
  book['isbn']="${book['isbn13']}"
fi
book['kindle_asin']=$( echo $xml | xmllint --xpath "//$xpathBook/kindle_asin[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_year']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_year[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['average_rating']=$( echo $xml | xmllint --xpath "//$xpathBook/average_rating[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['num_pages']=$( echo $xml | xmllint --xpath "//$xpathBook/num_pages[1]/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


# AUTHOR
book['authorId']=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['authorId']="${book['authorId']}"
book['author']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

# echo "$bookid -> $title -> $kindle_asin -> $isbn -> $isbn13 -> $publication_year"
# echo "BOOK ${book['bookid']} -> ${book['title']} -> ${book['publisher']}"

book['bookFileName']="${book['publication_year']} ${book['cleantitle']}"
book['bookPath']="${vaultpath}/${book[bookFileName]}.md"

book['goodreads_url']="https://goodreads.com/book/show/${book[bookid]}"
book['reviews']="- [[${review['reviewNoteFile']}]]"


# AUTOR
if [ -z "${book['authorId']}" ]; then
  echo "Missing author_id"
  exit 1
fi
sleep 1

book['authorIdCleaned']=$( echo $authorId | sed -e 's/^[[:space:]]*//')

# Review note exist
# reviewNote="${2} [[${bookFileName}]]"
# sh ./author.sh $authorIdCleaned "${bookNote}" "${bookPath}" "${reviewNote}" "${3}"

# echo "Book author: ${book['author']}"

export scalar_book=$(declare -p book)
export scalar_review=$(declare -p review)

# sh ./book.sh "${review[@]}"
sh ./author.sh ${book['authorId']}
