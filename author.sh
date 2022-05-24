#!/bin/sh

# USAGE: sh author.sh 4905855

if [ -z "$1" ]
then
    echo "Especifica author_id"
    exit 1
fi

. ./goodreads.cfg
. ./functions.sh



eval $scalar_review
declare -p review &>/dev/null # escapa comillas e impide print array en shell

eval $scalar_book
declare -p book &>/dev/null # escapa comillas e impide print array en shell

echo "review guid: ${review[guid]}"
echo "book title: ${book[title]}"
echo "autorid: ${book[authorId]}"


xpathAuthor="GoodreadsResponse/author[1]"

url="$urlbase/author/show.xml?key=$apikey&id=$1"

xml=$(curl -s $url)

declare -A author
# AUTOR
author['authorId']=${1}
author['authorName']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['authorImage']=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['authorLink']=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['about']=$( echo $xml | xmllint --xpath "//$xpathAuthor/about/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['about']=$(clean_long_text "${author['about']}")
author['authorFile']="${vaultpath}/${author['authorName']}.md" 
author['books']="- [[${book['bookFileName']}]]" 


# 3 bookpath, 5 reviewpath
# bookPathNoteCleaned=$(clean_note_path "${3}")
# reviewPathNoteCleaned=$(clean_note_path "${5}")


# bookNote="${2} [[${authorName}]]"
# authorNote="${authorNote} [[${bookPathNoteCleaned}]]"

# Print REVIEW
# if [ -n "$4" -a -n "$5" ]; then
    # Review exists: concat associated note at the end of file
    # reviewNote="${4}\n - [[${authorName}]]"
    # echo -e "${reviewNote}" >> "${5}" 

    # bookNote="${bookNote}\n- [[${reviewPathNoteCleaned}]]"
    # authorNote="${authorNote}\n- [[${reviewPathNoteCleaned}]]"
# fi

# Review note missing
# Print BOOK
# echo -e "${bookNote}" >> "${3}"

# REVIEW
sleep 1
sed -E \
    -e "s;%bookid%;${review['bookid']};g" \
    -e "s;%guid%;${review['guid']};g" \
    -e "s;%isbn%;${review['isbn']};g" \
    -e "s;%kindle_asin%;${review['kindle_asin']};g" \
    -e "s;%title%;${review['title']};g" \
    -e "s;%author%;${author['authorName']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s|%user_review%|${review['user_review']}|g" \
    -e "s|%imglink%|${review[imglink]}|g" \
    -e "s;%user_rating%;${review['user_rating']};g" \
    -e "s;%user_read_at%;${review['user_read_at']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%publication_year%;${book['publication_year']};g" \
    -e "s|%user_shelves_links%|${review['user_shelves_links']}|g" \
    -e "s|%user_shelves%|${review['user_shelves']}|g" \
    review.tpl > "${review['reviewNotePath']}"

unset review

# BOOK
if [ -f "${book['bookPath']}" ]; then
    exit 1
fi
sleep 1
sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
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
    book.tpl > "${book['bookPath']}"

# AUTHOR
if [ -f "${author['authorFile']}" ]; then
    exit 1
fi
sleep 1
sed -E \
    -e "s;%authorId%;${author['authorId']};g" \
    -e "s;%authorName%;${author['authorName']};g" \
    -e "s;%authorImage%;${author['authorImage']};g" \
    -e "s;%authorLink%;${author['authorLink']};g" \
    -e "s|%about%|${author[about]}|g" \
    -e "s;%books%;${author['books']};g" \
    -e "s;%reviews%;${book['reviews']};g" \
    author.tpl > "${author['authorFile']}"

unset book
unset author
