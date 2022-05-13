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
authorName=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorImage=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
authorLink=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

echo "AUTHOR $authorName -> $authorLink"

authorFile="${vaultpath}/${authorName}.md" 

authorNote="---
aliases: []
author:: [[${authorName}]]  
tags: 
- people/goodreads/author
popular_shelves:
date: ${user_read_at}
readed: ${user_read_at}
created: ${user_date_created} 
updated: ${user_date_added} 
rating: ${user_rating}
emotion:
---

# ${authorName}

**Tags**:: [[goodreads]] 
${user_shelves_links}

## Libros del autor
- 

## Referencias (mis reseñas)
- "

# 3 bookpath, 5 reviewpath

clean_note_path(){
    prefix="${vaultpath}/"
    suffix=".md"
    local a="${1}"
    local x=${a#"$prefix"}
    x=${x%"$suffix"}
    echo "${x}"
}
bookPathNoteCleaned=$(clean_note_path "${3}")
reviewPathNoteCleaned=$(clean_note_path "${5}")


bookNote="${2} [[${authorName}]]"
authorNote="${authorNote} [[${bookPathNoteCleaned}]]"

# Print REVIEW
if [ -n "$4" -a -n "$5" ]; then
    # Review exists: concat associated note at the end of file
    reviewNote="${4}\n - [[${authorName}]]"
    echo -e "${reviewNote}" >> "${5}" 

    bookNote="${bookNote}\n- [[${reviewPathNoteCleaned}]]"
    authorNote="${authorNote}\n- [[${reviewPathNoteCleaned}]]"
fi

# Review note missing
# Print BOOK
echo -e "${bookNote}" >> "${3}"


# Print AUTHOR
if [ -f "$authorFile" ]; then
    exit 1
fi

echo -e "${authorNote}" >> "${authorFile}"
