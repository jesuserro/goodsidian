#!/bin/sh

# USAGE: sh author.sh 4905855

if [ -z "$1" ]
then
    echo "Especifica author_id"
    exit 1
fi

. ./goodreads.cfg
. ./functions.sh

xpathAuthor="GoodreadsResponse/author[1]"

url="$urlbase/author/show.xml?key=$apikey&id=$1"

xml=$(curl -s $url)

# AUTOR
authorName=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorImage=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorLink=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

echo "AUTHOR $authorName"

authorFile="${vaultpath}/${authorName}.md" 


# 3 bookpath, 5 reviewpath
bookPathNoteCleaned=$(clean_note_path "${3}")
reviewPathNoteCleaned=$(clean_note_path "${5}")


bookNote="${2} [[${authorName}]]"
# authorNote="${authorNote} [[${bookPathNoteCleaned}]]"

# Print REVIEW
if [ -n "$4" -a -n "$5" ]; then
    # Review exists: concat associated note at the end of file
    reviewNote="${4}\n - [[${authorName}]]"
    echo -e "${reviewNote}" >> "${5}" 

    bookNote="${bookNote}\n- [[${reviewPathNoteCleaned}]]"
    # authorNote="${authorNote}\n- [[${reviewPathNoteCleaned}]]"
fi

# Review note missing
# Print BOOK
echo -e "${bookNote}" >> "${3}"


# Print AUTHOR
if [ -f "$authorFile" ]; then
    exit 1
fi

# echo -e "${authorNote}" >> "${authorFile}"
sed -E \
    -e "s;%authorId%;$1;g" \
    -e "s;%authorName%;$authorName;g" \
    -e "s;%authorImage%;$authorImage;g" \
    -e "s;%authorLink%;$authorLink;g" \
    author.tpl > "${authorFile}"
