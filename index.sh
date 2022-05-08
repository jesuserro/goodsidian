#!/bin/sh

if [ -z "$1" ]
then
      echo "Especifica una estantería por favor"
      exit 1
fi

. ./goodreads.cfg

url="$urlbase/review/list_rss/$user?key=$key&shelf=$1"

# This grabs the data from the currently reading rss feed and formats it
IFS=$'\n' feed=$(curl --silent "$url" | grep -E '(title>|book_large_image_url>|author_name>|book_published>|book_id>|user_date_created>|book_description>|user_shelves>|num_pages>|isbn>|average_rating>|user_review>|guid>|user_rating>|user_read_at>|user_date_added>)' | \
sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' \
-e 's/Jei.s bookshelf: '$shelf'//' \
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
  guid=${arr["$counter"]}
  title=${arr[$( expr "$counter" + 1)]}
  bookid=${arr[$( expr "$counter" + 2)]}
  bookid=$( echo $bookid | sed -e 's/^[[:space:]]*//')
  imglink=${arr[$( expr "$counter" + 3)]}
  book_description=${arr[$( expr "$counter + 4")]}
  num_pages=${arr[$( expr "$counter + 5")]}
  author=${arr[$( expr "$counter" + 6)]}
  isbn=${arr[$( expr "$counter" + 7)]}
  user_rating=${arr[$( expr "$counter" + 8)]}
  user_read_at=${arr[$( expr "$counter" + 9)]}
  user_date_added=${arr[$( expr "$counter" + 10)]}
  user_date_created=${arr[$( expr "$counter + 11")]}
  user_shelves=${arr[$( expr "$counter" + 12)]}
  user_review=${arr[$( expr "$counter" + 13)]}
  average_rating=${arr[$( expr "$counter" + 14)]}
  book_published=${arr[$( expr "$counter" + 15)]}
  

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
  user_review=$(echo -e "${user_review//$'<br />'/\\n}" | \
    sed 's/<[^\/][^<>]*> *<\/[^<>]*>//g' | \
    sed -e 's|<i>|_|g' -e 's|</i>|_|g' | \
    sed -e 's|<b>|*|g' -e 's|</b>|*|g' | \
    sed -e 's|<strong>|*|g' -e 's|</strong>|*|g' | \
    sed -e 's/^[[:space:]]*//')

  # 4. Clean tags
  IFS=', ' read -ra arrtags <<< "$user_shelves"
  for index in "${!arrtags[@]}"
  do
      arrlinks[$index]="[[${arrtags[$index]}]]"
      arrtags[$index]="- book/goodreads/tag/${arrtags[$index]}"
  done
  user_shelves=$(IFS=$'\n' ; echo "${arrtags[*]}")
  user_shelves_links=$(IFS=' ' ; echo "${arrlinks[*]}")


  # SET book (and author) files here
  # sh ./book.sh $bookid

  echo "---
aliases: []
bookid: ${bookid}
isbn: ${isbn}
asin: ${kindle_asin}
author:: [[${author}]]
pages: ${num_pages}
publisher:: [[${publisher}]]  
book_published:: [[${publication_year}]]  
cover: ${image_url}   
tags: 
- book/goodreads/review
- book/goodreads/status/${shelf}
${user_shelves}
date: ${user_read_at}
rating: ${user_rating}
emotion:
---

# ${title}
Publicado: $published_user_read_at

![b|150](${imglink})

[Goodreads Private Notes & Quotes]($1) 
[[goodreads]] ${user_shelves_links}

## Review
${user_review}

## Referencias
- 

" >> "${vaultpath}/${clean_user_read_at} ${cleantitle}.md"



  # sleep 1

  # Display a notification when creating the file
  echo "REVIEW $i: $cleantitle ($counter)"

done