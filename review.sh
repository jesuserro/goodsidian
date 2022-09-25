#!/bin/bash
# USAGE: 
# - sh review.sh 2297011024 Jesús de Nazareth Tranfiguración
# - sh review.sh 2333083521 Mi corazoón triunfará
# - sh review.sh 2304450830 Arte Recomenzar
# - sh review.sh 2727533981 Retorno Hijo Pródigo
# - sh review.sh 2767408990 Libertad Interior
# - sh review.sh 2297008019 Shegatashya
# - sh review.sh 3258859089 Meditaciones sobre la fe
# - sh review.sh 2313170178 Metamorfosis Kafka

if [ -z "$1" ]; then
  echo "Especifica un reviewid"
  exit 1
fi
shelf=""
if [ -n "$3" ]; then
  shelf=${3}
fi

. ./goodreads.cfg
. ./functions.sh

eval $scalar_review
declare -p review &>/dev/null # escapa comillas e impide print array en shell

# echo "review guid: ${review[guid]}"
 
xpathReview="GoodreadsResponse/review"
xpathBook="${xpathReview}/book"
xpathAuthor="${xpathBook}/authors/author[1]"

url="$urlbase/review/show?id=$1&key=$apikey"

# echo "BOOK $url"

xml=$(curl -s $url)

declare -A review
declare -A book
declare -A author

author['authorid']=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


# Data author desde review
author['name']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['image_url']=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# Remueve saltos de línea de la imagen url
author['image_url']=${author[image_url]//$'\n'/}
author['link']=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['authorFile']="${vaultpath}/${author['name']} - WRITER.md"
author['average_rating']=$( echo $xml | xmllint --xpath "//$xpathAuthor/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['text_reviews_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/text_reviews_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' ) 



book['bookid']=$( echo $xml | xmllint --xpath "//$xpathBook/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['shelf']=$shelf

# # Book data from review
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# # 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')
# book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

book['publication_year']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_year/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_month']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_month/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_day']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_day/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_date']=$(get_publication_date "${book['publication_year']}" "${book['publication_month']}" "${book['publication_day']}")
book['clean_publication_date']=$(get_clean_publication_date "${book['publication_year']}" "${book['publication_month']}" "${book['publication_day']}")

if [ -n "${book['clean_publication_date']}" ]; then
     book['bookFileName']="${book['clean_publication_date']} ${book['cleantitle']}"
else
     book['bookFileName']="${book['cleantitle']}"
fi

# book['isbn']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['isbn13']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['num_pages']=$( echo $xml | xmllint --xpath "//$xpathBook/num_pages/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['uri']=$( echo $xml | xmllint --xpath "//$xpathBook/uri/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publisher']=$( echo $xml | xmllint --xpath "//$xpathBook/publisher/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['format']=$( echo $xml | xmllint --xpath "//$xpathBook/format/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['bookPath']="${vaultpath}/${book[bookFileName]} - GOODREADS.md"

# book['description']=$( echo $xml | xmllint --xpath "//$xpathBook/description/text()" - | sed -e 's|<!\[CDATA\[||' -e 's|\]\]>||' )
# book['description']=$(clean_long_text "${book['description']}")
# book['average_rating']=$( echo $xml | xmllint --xpath "//$xpathBook/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathBook/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['link']=$( echo $xml | xmllint --xpath "//$xpathBook/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['header']=$(get_book_header "${author['name']}" "${book['publication_year']}" "${book['publisher']}" "${book['link']}" "${book['num_pages']}" "${book['ratings_count']}" "${book['average_rating']}" "${book['isbn']}" "${book['kindle_asin']}")
# book['shelf']=${3}


# REVIEW
review['reviewid']="${1}"
review['title']="${book['title']}"
review['rating']=$( echo $xml | xmllint --xpath "//$xpathReview/rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['votes']=$( echo $xml | xmllint --xpath "//$xpathReview/votes/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['read_at']=$( echo $xml | xmllint --xpath "//$xpathReview/read_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['date_added']=$( echo $xml | xmllint --xpath "//$xpathReview/date_added/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
if [ -z "${review['read_at']}" ]; then
    review['read_at']="${review['date_added']}"
fi
review['read_at']=$(date -d "${review['read_at']}" +'%Y-%m-%d %H:%M')
review['read_at_date']=$(date -d "${review['read_at']}" +'%Y-%m-%d')
review['clean_read_at']=$(date -d "${review['read_at']}" +'%Y%m%d%H%M')
review['published_read_at']=$(date -d "${review['read_at']}" +'%A, %d %B %Y a las %H:%Mh.')
review['started_at']=$( echo $xml | xmllint --xpath "//$xpathReview/started_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['started_at']=$(date -d "${review['started_at']}" +'%Y-%m-%d %H:%M')
review['date_added']=$(date -d "${review['date_added']}" +'%Y-%m-%d %H:%M')
review['date_updated']=$( echo $xml | xmllint --xpath "//$xpathReview/date_updated/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['date_updated']=$(date -d "${review['date_updated']}" +'%Y-%m-%d %H:%M')

review['recommended_for']=$( echo $xml | xmllint --xpath "//$xpathReview/recommended_for/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['recommended_for']=$(clean_long_text "${review['recommended_for']}")
review['url']=$( echo $xml | xmllint --xpath "//$xpathReview/url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['recommended_by']=$( echo $xml | xmllint --xpath "//$xpathReview/recommended_by/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['recommended_by']=$(clean_long_text "${review['recommended_by']}")

review['body']=$( echo $xml | xmllint --xpath "//$xpathReview/body/text()" - | sed -e 's|<!\[CDATA\[||' -e 's|\]\]>||' )
review['body']=$(clean_long_text "${review['body']}")


review['shelves']=$( echo $xml | xmllint --xpath "//$xpathReview/shelves/shelf/@name" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' | cut -f 2 -d "=" | tr -d \" )
mapfile -t arrtags <<< "${review['shelves']}"
for index in "${!arrtags[@]}"
do
    arrlinks[$index]="[[${arrtags[$index]}]]"
    arrtags[$index]="\n- ${arrtags[$index]}"
done
review['shelves']=$(echo "${arrtags[*]}")
review['shelves_links']=$(IFS=' ' ; echo "${arrlinks[*]}")
review['book_large_image_url']="${2}"
review['header']=$(get_review_header "${author['name']}" "${book['publication_year']}" "${book['publisher']}" "${book['format']}")

review['reviewNoteFile']="${review[clean_read_at]} ${book[cleantitle]}"

if [ ! -d "${path_reviews}" ]; 
then
    mkdir -p "${path_reviews}"
fi
review['reviewNotePath']="${path_reviews}/${review[reviewNoteFile]}.md"

# PRINTING REVIEW
sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
    -e "s;%isbn%;${book['isbn']};g" \
    -e "s;%isbn13%;${book['isbn13']};g" \
    -e "s;%url%;${review['url']};g" \
    -e "s;%isbn%;${review['isbn']};g" \
    -e "s;%asin%;${book['asin']};g" \
    -e "s;%kindle_uri%;${book['uri']};g" \
    -e "s;%title%;${review['title']};g" \
    -e "s;%author%;${author['name']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s|%body%|${review['body']}|g" \
    -e "s|%image_url%|${book[image_url]}|g" \
    -e "s|%book_large_image_url%|${review[book_large_image_url]}|g" \
    -e "s;%user_rating%;${review['user_rating']};g" \
    -e "s;%read_at%;${review['read_at']};g" \
    -e "s;%read_at_date%;${review['read_at_date']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%publication_year%;${book['publication_year']};g" \
    -e "s;%publication_date%;${book['publication_date']};g" \
    -e "s;%started_at%;${review['started_at']};g" \
    -e "s;%date_added%;${review['date_added']};g" \
    -e "s;%date_updated%;${review['date_updated']};g" \
    -e "s|%shelves_links%|${review['shelves_links']}|g" \
    -e "s|%shelves%|${review['shelves']}|g" \
    -e "s|%bookFileName%|${book['bookFileName']}|g" \
    -e "s|%published_read_at%|${review['published_read_at']}|g" \
    -e "s|%reviewid%|${review['reviewid']}|g" \
    -e "s|%authorid%|${author['authorid']}|g" \
    -e "s|%votes%|${review['votes']}|g" \
    -e "s|%rating%|${review['rating']}|g" \
    -e "s|%recommended_for%|${review['recommended_for']}|g" \
    -e "s|%recommended_by%|${review['recommended_by']}|g" \
    -e "s|%format%|${book['format']}|g" \
    -e "s;%header%;${review['header']};g" \
    -e "s;%shelf%;${shelf};g" \
    review.tpl > "${review['reviewNotePath']}"


# AUTHOR
if [ -n "${author['authorid']}" ]; then
   ./author.sh ${author['authorid']} ${author['image_url']} ${author['average_rating']} ${author['ratings_count']} ${author['text_reviews_count']} ${review['read_at']} ${review['date_added']}
fi