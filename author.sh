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
${user_shelves}
date: ${user_read_at}
readed: ${user_read_at}
created: ${user_date_created} 
updated: ${user_date_added} 
rating: ${user_rating}
emotion:
---

# ${authorName}

[[goodreads]]

## Estanterías 
${user_shelves_links}

## Libros
- 

## Referencias
- "



if [ -n "$4" -a -n "$5" ]; then
    # concat associated note at the end of file
    reviewNote="${4}\n - [[${authorName}]]"
    echo -e "${reviewNote}" >> "${5}"   
fi


# Review note missing
bookNote="${2} [[${authorName}]]"
echo -e "${bookNote}" >> "${3}"



# Ficha autor:
authorNote="${authorNote} [[${3}]]"
echo -e "${authorNote}" >> "${authorFile}"
