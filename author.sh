#!/bin/bash

# USAGE: sh author.sh 4905855

if [ -z "$1" ]; then
    echo "Especifica author_id"
    exit 1
fi

. ./goodreads.cfg
. ./functions.sh

xpathAuthor="GoodreadsResponse/author[1]"

url="$urlbase/author/show.xml?key=$apikey&id=$1"

xml=$(curl -s $url)

declare -A author
# AUTOR
author['authorid']=${1}
author['name']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

author['image_url']=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
if [ -n "$2" ]; then
    author['image_url']=${2}
fi
author['average_rating']=""
if [ -n "$3" ]; then
    author['average_rating']=${3}
fi
author['ratings_count']=""
if [ -n "$4" ]; then
    author['ratings_count']=${4}
fi
author['text_reviews_count']=""
if [ -n "$5" ]; then
    author['text_reviews_count']=${5}
fi
author['read_at']=""
if [ -n "$6" ]; then
    author['read_at']=${6}
fi
author['date_updated']=""
if [ -n "$7" ]; then
    author['date_updated']=${7}
fi
author['date_added']=""
if [ -n "$8" ]; then
    author['date_added']=${8}
fi

author['link']=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['about']=$( echo $xml | xmllint --xpath "//$xpathAuthor/about/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['about']=$(clean_long_text "${author['about']}")

author['born_at']=$( echo $xml | xmllint --xpath "//$xpathAuthor/born_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['died_at']=$( echo $xml | xmllint --xpath "//$xpathAuthor/died_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['hometown']=$( echo $xml | xmllint --xpath "//$xpathAuthor/hometown/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['works_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/works_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


author['books']=$( echo $xml | xmllint --xpath "//$xpathAuthor/books/book/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['bookLinks']=$( echo $xml | xmllint --xpath "//$xpathAuthor/books/book/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['bookRatingsCount']=$( echo $xml | xmllint --xpath "//$xpathAuthor/books/book/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['bookAverageRating']=$( echo $xml | xmllint --xpath "//$xpathAuthor/books/book/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['bookUris']=$( echo $xml | xmllint --xpath "//$xpathAuthor/books/book/uri/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['bookPublicationYear']=$( echo $xml | xmllint --xpath "//$xpathAuthor/books/book/publication_year/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
mapfile -t arrtags <<< "${author['books']}"
mapfile -t arrlinks <<< "${author['bookLinks']}"
mapfile -t arrRatingsCount <<< "${author['bookRatingsCount']}"
mapfile -t arrAverageRating <<< "${author['bookAverageRating']}"
mapfile -t arrUris <<< "${author['bookUris']}"
mapfile -t arrPublicationYear <<< "${author['bookPublicationYear']}"
for index in "${!arrtags[@]}"
do
    books[$index]="\n- [${arrtags[$index]}](${arrlinks[$index]}) \n  - Publication Year: ${arrPublicationYear[$index]} \n  - Num. Ratings: ${arrRatingsCount[$index]} \n  - Average Rating: ${arrAverageRating[$index]} \n  - [Kindle](${arrUris[$index]})"
done
author['books']=$(echo "${books[*]}")

author['authorFile']="${vaultpath}/${author['name']} - WRITER.md"
if [ -n "${author['born_at']}" ]; then
    author['clean_born_at']=$( echo "${author['born_at']}" | sed -e 's|\/||g' )
    author['authorFile']="${vaultpath}/${author['clean_born_at']} ${author['name']} - WRITER.md"
fi


# AUTHOR
sed -E \
    -e "s|%authorid%|${author['authorid']}|g" \
    -e "s|%name%|${author['name']}|g" \
    -e "s|%image_url%|${author[image_url]}|g" \
    -e "s|%link%|${author['link']}|g" \
    -e "s|%about%|${author['about']}|g" \
    -e "s|%average_rating%|${author['average_rating']}|g" \
    -e "s|%ratings_count%|${author['ratings_count']}|g" \
    -e "s|%text_reviews_count%|${author['text_reviews_count']}|g" \
    -e "s|%read_at%|${author['read_at']}|g" \
    -e "s|%date_updated%|${author['date_updated']}|g" \
    -e "s|%date_created%|${author['date_added']}|g" \
    -e "s|%books%|${author['books']}|g" \
    -e "s|%born_at%|${author['born_at']}|g" \
    -e "s|%died_at%|${author['died_at']}|g" \
    -e "s|%hometown%|${author['hometown']}|g" \
    -e "s|%works_count%|${author['works_count']}|g" \
    author.tpl > "${author['authorFile']}"
