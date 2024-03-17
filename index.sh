#!/bin/sh

if [ -z "$1" ]
then
    echo "Especifica una estantería por favor"
    exit 1
fi

. ./goodreads.cfg
. ./functions.sh

url="$urlbase/review/list_rss/$user?key=$key&shelf=$1"

# This grabs the data from the currently reading rss feed and formats it
IFS=$'\n' feed=$(curl --silent "$url" | grep -E '(title>|book_large_image_url>|author_name>|book_published>|book_id>|user_date_created>|book_description>|user_shelves>|num_pages>|isbn>|average_rating>|user_review>|guid>|user_rating>|user_read_at>|user_date_added>)' | \
sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' \
-e 's/Your Bookshelf: '$shelf'//' \
-e 's/<book_large_image_url>//' -e 's/<\/book_large_image_url>/ | /' \
-e 's/<title>//' -e 's/<\/title>/ | /' \
-e 's/<book_description>//' -e 's/<\/book_description>/ | /' \
-e 's/<author_name>//' -e 's/<\/author_name>/ | /' \
-e 's/<book_published>//' -e 's/<\/book_published>/ | /' \
-e 's/<book_id>//' -e 's/<\/book_id>/ | /' \
-e 's/<user_shelves>//' -e 's/<\/user_shelves>/ | /' \
-e 's/<num_pages>//' -e 's/<\/num_pages>/ | /' \
-e 's/<isbn>//' -e 's/<\/isbn>/ | /' \
-e 's/<guid>//' -e 's/<\/guid>/ | /' \
-e 's/<user_rating>//' -e 's/<\/user_rating>/ | /' \
-e 's/<user_read_at>//' -e 's/<\/user_read_at>/ | /' \
-e 's/<user_date_added>//' -e 's/<\/user_date_added>/ | /' \
-e 's/<average_rating>//' -e 's/<\/average_rating>/ | /' \
-e 's/<user_review>//' -e 's/<\/user_review>/ | /' \
-e 's/<user_date_created>//' -e 's/<\/user_date_created>/ | /' \
-e 's/^[ \t]*//' -e 's/[ \t]*$//' | \
tail +3 | \
fmt
)


# Turn the data into an array
arr=($(echo $feed | tr "|" "\n")) # shelf

bookamount=$( expr "${#arr[@]}")

if (( "$bookamount" == 0 )); then
  echo "No new books found in shelf $shelf"
fi

miNumeroDeVariables=16

# Start the loop for each book
for (( i = 0 ; i < $miNumeroDeVariables ; i++ ))
do
  counter=$( expr "$i" \* $miNumeroDeVariables)

  if (( "$counter" > $miNumeroDeVariables )); then
    break
  fi

  # Set variables 16 (miNumeroDeVariables)
  guid=$( echo ${arr["$counter"]} | xargs)
  title=$( echo ${arr[$( expr "$counter" + 1)]} | xargs)
  bookid=$( echo ${arr[$( expr "$counter" + 2)]} | xargs)
  imglink=$( echo ${arr[$( expr "$counter" + 3)]} | xargs)
  book_description=$( echo ${arr[$( expr "$counter" + 4)]} | xargs)
  num_pages=$( echo ${arr[$( expr "$counter" + 5)]} | xargs)
  author=$( echo ${arr[$( expr "$counter" + 6)]} | xargs)
  isbn=$( echo ${arr[$( expr "$counter" + 7)]} | xargs)
  user_rating=$( echo ${arr[$( expr "$counter" + 8)]} | xargs)
  user_read_at=$( echo ${arr[$( expr "$counter" + 9)]} | xargs)
  user_date_added=$( echo ${arr[$( expr "$counter" + 10)]} | xargs)
  user_date_created=$( echo ${arr[$( expr "$counter" + 11)]} | xargs)
  user_shelves=$( echo ${arr[$( expr "$counter" + 12)]} | xargs)
  user_review=$( echo ${arr[$( expr "$counter" + 13)]} | xargs)
  average_rating=$( echo ${arr[$( expr "$counter" + 14)]} | xargs)
  book_published=$( echo ${arr[$( expr "$counter" + 15)]} | xargs)

  

  if [ -z "$user_read_at" ]; then
    user_read_at=${user_date_created}
  fi

  # Clean vars:
  # 1. Format date
  user_read_at=$(date -d "$user_read_at" +'%Y-%m-%d %H:%M')
  clean_user_read_at=$(date -d "$user_read_at" +'%Y%m%d%H%M')
  published_user_read_at=$(date -d "$user_read_at" +'%A, %d %B %Y a las %H:%Mh.')

  user_date_added=$(date -d "$user_date_added" +'%Y-%m-%d %H:%M')

  user_date_created=$(date -d "$user_date_created" +'%Y-%m-%d %H:%M')
  clean_user_date_created=$(date -d "$user_date_created" +'%Y%m%d%H%M')

  # 2. Delete illegal (':' and '/') and unwanted ('#') characters
  cleantitle=$(echo "${title}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')

  # 3. Clean long text for Obsidian
  user_review=$(clean_long_text "${user_review}")

  # 4. Clean tags
  IFS=', ' read -ra arrtags <<< "$user_shelves"
  for index in "${!arrtags[@]}"
  do
      arrlinks[$index]="[[${arrtags[$index]}]]"
      arrtags[$index]="- book/goodreads/tag/${arrtags[$index]}"
  done
  user_shelves=$(IFS=$'\n' ; echo "${arrtags[*]}")
  user_shelves_links=$(IFS=' ' ; echo "${arrlinks[*]}")

  reviewNote="---
aliases: []
bookid: ${bookid}
isbn: ${isbn}
asin: ${kindle_asin}
author:: [[${author}]]
pages: ${num_pages}
publisher:: [[${publisher}]]  
book_published:: [[${book_published}]]  
cover: ${image_url}   
tags: 
- review/goodreads
- review/goodreads/status/${1}
${user_shelves}
date: ${user_read_at}
rating: ${user_rating}
emotion:
---

# ${title}

**Fecha Review**: $published_user_read_at
**Ficha Goodreads**: [Goodreads Private Notes & Quotes]($1) 
**Tags**: [[goodreads]] ${user_shelves_links}
**Rating**: ${user_rating} 

![b|150](${imglink})

${user_review}

## Referencias
- " 

  reviewNotePath="${vaultpath}/${clean_user_read_at} ${cleantitle}.md"

  # echo "${reviewNote}" >> "${reviewNotePath}"
  # doReviewNote=$("${reviewNote}" >> "${reviewNotePath}")

  # SET book (and author) files here
  sh ./book.sh $bookid "${reviewNote}" "${reviewNotePath}"


  # sleep 1

  # Display a notification when creating the file
  echo "REVIEW $i: $cleantitle ($counter)"

done