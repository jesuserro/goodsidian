#!/bin/sh
# USAGE: sh review.sh 2297011024

if [ -z "$1" ]; then
  echo "Especifica un reviewid"
  exit 1
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

: <<'END'
# AUTOR
author['image_url']=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['link']=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['average_rating']=$( echo $xml | xmllint --xpath "//$xpathAuthor/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['text_reviews_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/text_reviews_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['authorFile']="${vaultpath}/${author['name']}.md" 

# LIBRO
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')
book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['link']=$( echo $xml | xmllint --xpath "//$xpathBook/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['format']=$( echo $xml | xmllint --xpath "//$xpathBook/format/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['average_rating']=$( echo $xml | xmllint --xpath "//$xpathBook/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathBook/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['description']=$( echo $xml | xmllint --xpath "//$xpathBook/description/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['description']=$(clean_long_text "${book['description']}")
book['bookPath']="${vaultpath}/${book[bookFileName]}.md"
END


author['authorid']=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['name']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


book['bookid']=$( echo $xml | xmllint --xpath "//$xpathBook/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')
book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_day']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_day/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['publication_day']=$(date -d "${book['publication_day']}" +'%d')
book['publication_year']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_year/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_month']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_month/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_date']="${book['publication_year']}-${book['publication_month']}-${book['publication_day']}"
book['publication_date']=$(date -d "${book['publication_date']}" +'%Y-%m-%d')
book['clean_publication_date']=$(date -d "${book['publication_date']}" +'%Y%m%d')
book['bookFileName']="${book['publication_year']}${book['publication_month']}${book['publication_day']} ${book['cleantitle']}"
book['isbn']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['isbn13']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['num_pages']=$( echo $xml | xmllint --xpath "//$xpathBook/num_pages/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['uri']=$( echo $xml | xmllint --xpath "//$xpathBook/uri/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publisher']=$( echo $xml | xmllint --xpath "//$xpathBook/publisher/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['bookFileName']="${book['clean_publication_date']} ${book['cleantitle']}"


# REVIEW
review['reviewid']="${1}"
review['title']="${book['title']}"
review['rating']=$( echo $xml | xmllint --xpath "//$xpathReview/rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['votes']=$( echo $xml | xmllint --xpath "//$xpathReview/votes/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

review['read_at']=$( echo $xml | xmllint --xpath "//$xpathReview/read_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['read_at']=$(date -d "${review['read_at']}" +'%Y-%m-%d %H:%M')
review['clean_read_at']=$(date -d "${review['read_at']}" +'%Y%m%d%H%M')
review['published_read_at']=$(date -d "${review['read_at']}" +'%A, %d %B %Y a las %H:%Mh.')

review['recommended_for']=$( echo $xml | xmllint --xpath "//$xpathReview/recommended_for/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['recommended_for']=$(clean_long_text "${review['recommended_for']}")
review['url']=$( echo $xml | xmllint --xpath "//$xpathReview/url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
#review['recommended_by']=$( echo $xml | xmllint --xpath "//$xpathReview/recommended_by/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
#review['recommended_by']=$(clean_long_text "${review['recommended_by']}")

review['body']=$( echo $xml | xmllint --xpath "//$xpathReview/body/text()" - | sed -e 's|<!\[CDATA\[||' -e 's|\]\]>||' )
review['body']=$(clean_long_text "${review['body']}")


review['shelves']=$( echo $xml | xmllint --xpath "//$xpathReview/shelves/shelf/@name" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' | cut -f 2 -d "=" | tr -d \" )
mapfile -t arrtags <<< "${review['shelves']}"
for index in "${!arrtags[@]}"
do
    arrlinks[$index]="[[${arrtags[$index]}]]"
    arrtags[$index]="\n- book/goodreads/tag/${arrtags[$index]}"
done
review['shelves']=$(echo "${arrtags[*]}")
review['shelves_links']=$(IFS=' ' ; echo "${arrlinks[*]}")



: <<'END'
# review['shelves']=$( echo $xml | xmllint --xpath "//$xpathReview/shelves/shelf/@name" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['shelves']="Shelves..."

review['started_at']=$( echo $xml | xmllint --xpath "//$xpathReview/started_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['started_at']=$(date -d "${review['started_at']}" +'%Y-%m-%d %H:%M')


review['date_added']=$( echo $xml | xmllint --xpath "//$xpathReview/date_added/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['date_added']=$(date -d "${review['date_added']}" +'%Y-%m-%d %H:%M')
review['date_updated']=$( echo $xml | xmllint --xpath "//$xpathReview/date_updated/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['date_updated']=$(date -d "${review['date_updated']}" +'%Y-%m-%d %H:%M')

review['comments_count']=$( echo $xml | xmllint --xpath "//$xpathReview/comments_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
END

review['reviewNoteFile']="${review[clean_read_at]} ${book[cleantitle]}"
review['reviewNotePath']="${vaultpath}/${review[reviewNoteFile]}.md"



# PRINTING REVIEW
sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
    -e "s;%isbn%;${book['isbn']};g" \
    -e "s;%isbn13%;${book['isbn13']};g" \
    -e "s;%url%;${review['url']};g" \
    -e "s;%isbn%;${review['isbn']};g" \
    -e "s;%kindle_uri%;${book['uri']};g" \
    -e "s;%title%;${review['title']};g" \
    -e "s;%author%;${author['name']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s|%body%|${review['body']}|g" \
    -e "s|%image_url%|${book[image_url]}|g" \
    -e "s;%user_rating%;${review['user_rating']};g" \
    -e "s;%read_at%;${review['read_at']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%publication_date%;${book['publication_date']};g" \
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
    review.tpl > "${review['reviewNotePath']}"





: <<'END'
# BOOK
if [ -f "${book['bookPath']}" ]; then
    exit 1
fi
sleep 1
sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
    -e "s;%authorId%;${author['authorId']};g" \
    -e "s;%isbn%;${book['isbn']};g" \
    -e "s;%title%;${book['title']};g" \
    -e "s;%publication_year%;${book['publication_year']};g" \
    -e "s|%description%|${book[description]}|g" \
    -e "s;%image_url%;${book['image_url']};g" \
    -e "s;%average_rating%;${book['average_rating']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%author%;${author['authorName']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%kindle_asin%;${book['kindle_asin']};g" \
    -e "s;%goodreads_url%;${book['goodreads_url']};g" \
    -e "s;%reviewNoteFile%;${review['reviewNoteFile']};g" \
    -e "s;%my_reviews%;${review['reviewid']};g" \
    book.tpl > "${book['bookPath']}"

# AUTHOR
if [ -f "${author['authorFile']}" ]; then
    exit 1
fi
sleep 1
sed -E \
    -e "s;%authorid%;${author['authorid']};g" \
    -e "s;%name%;${author['name']};g" \
    -e "s;%image_url%;${author['image_url']};g" \
    -e "s;%link%;${author['link']};g" \
    -e "s|%about%|${author[about]}|g" \
    -e "s;%books%;${author['books']};g" \
    -e "s;%reviews%;${book['reviews']};g" \
    -e "s;%user_read_at%;${review['user_read_at']};g" \
    -e "s;%user_date_created%;${review['user_date_created']};g" \
    -e "s;%user_date_added%;${review['user_date_added']};g" \
    -e "s;%user_rating%;${review['user_rating']};g" \
    author.tpl > "${author['authorFile']}"
END