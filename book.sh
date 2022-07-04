#!/bin/sh
# USAGE: sh book.sh 10988371 Resurrección
# USAGE: sh book.sh 82405 Transfiguración

if [ -z "$1" ]; then
  echo "Especifica un bookid"
  exit 1
fi

. ./goodreads.cfg
. ./functions.sh


# echo "review guid: ${review[guid]}"
 
xpathBook="GoodreadsResponse/book"
xpathAuthor="${xpathBook}/authors/author[1]"

url="$urlbase/book/show?format=xml&key=$apikey&id=$1"
xml=$(curl -s $url)

declare -A book
book['bookid']="${1}"
book['shelf']=""
if [ -n "$2" ];
then
    book['shelf']=${2}
fi
book['image_url']=""
if [ -n "$3" ];
then
    book['image_url']=${3}
fi
book['date_updated']=""
if [ -n "$4" ];
then
    book['date_updated']=${4}
fi

# LIBRO

##
# Book data from review
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')
# book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

book['asin']=$( echo $xml | xmllint --xpath "//$xpathBook/asin/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['isbn']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['isbn13']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['num_pages']=$( echo $xml | xmllint --xpath "//$xpathBook/num_pages/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['uri']=$( echo $xml | xmllint --xpath "//$xpathBook/uri/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publisher']=$( echo $xml | xmllint --xpath "//$xpathBook/publisher/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['format']=$( echo $xml | xmllint --xpath "//$xpathBook/format/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

book['description']=$( echo $xml | xmllint --xpath "//$xpathBook/description/text()" - | sed -e 's|<!\[CDATA\[||' -e 's|\]\]>||' )
book['description']=$(clean_long_text "${book['description']}")
book['average_rating']=$( echo $xml | xmllint --xpath "//$xpathBook/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathBook/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['link']=$( echo $xml | xmllint --xpath "//$xpathBook/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['original_publication_year']=$( echo $xml | xmllint --xpath "//$xpathBook/work/original_publication_year/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['authorid']=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['author']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
##

if [ -z "${book['publication_date']}" ];
then
    book['publication_date']=${book['original_publication_year']}
fi

book['header']=$(get_book_header "${book['author']}" "${book['publication_year']}" "${book['publisher']}" "${book['link']}" "${book['num_pages']}" "${book['ratings_count']}" "${book['average_rating']}" "${book['isbn']}" "${book['kindle_asin']}")

book['bookFileName']="${book['cleantitle']}"
if [ -n "${book['clean_publication_date']}" ]; then
    book['bookFileName']="${book['clean_publication_date']} ${book['cleantitle']}"
elif [ -n "${book['publication_date']}" ]; then
    book['bookFileName']="${book['publication_date']} ${book['cleantitle']}"
fi
book['bookPath']="${vaultpath}/${book[bookFileName]} - GOODREADS.md"

if [ -z "${book[bookFileName]}" ];
then
    echo "Missing: ${book['title']}"
    exit
fi

sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
    -e "s;%authorid%;${book['authorid']};g" \
    -e "s;%isbn%;${book['isbn']};g" \
    -e "s;%asin%;${book['asin']};g" \
    -e "s;%kindle_asin%;${book['kindle_asin']};g" \
    -e "s;%title%;${book['title']};g" \
    -e "s;%date_updated%;${book['date_updated']};g" \
    -e "s;%publication_year%;${book['publication_year']};g" \
    -e "s;%publication_date%;${book['publication_date']};g" \
    -e "s|%description%|${book['description']}|g" \
    -e "s;%image_url%;${book['image_url']};g" \
    -e "s;%average_rating%;${book['average_rating']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%author%;${book['author']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%goodreads_url%;${book['link']};g" \
    -e "s;%average_rating%;${book['average_rating']};g" \
    -e "s;%ratings_count%;${book['ratings_count']};g" \
    -e "s;%header%;${book['header']};g" \
    -e "s;%shelf%;${book['shelf']};g" \
    book.tpl > "${book['bookPath']}"