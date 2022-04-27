#!/bin/sh

# Enter urls to your goodreads rss feed below.
# You can find it by navigating to one of your goodreads shelves and
# clicking the "RSS" button at the bottom of the page.

# shelf="patata"
# shelf="currently-reading"
# shelf="pausados"
shelf="000-next"
# shelf="read"
# shelf="to-read"


. ./goodreads.cfg

# url for "Currently reading":
# url="https://www.goodreads.com/url-to-your-rss-feed-shelf=currently-reading"
# url="https://www.goodreads.com/review/list_rss/$user?key=$key&shelf=to-read"
url="https://www.goodreads.com/review/list_rss/$user?key=$key&shelf=$shelf"

# url for "Read":
# readurl="https://www.goodreads.com/url-to-your-rss-feed-shelf=read"
readurl="https://www.goodreads.com/review/list_rss/$user?key=$key&shelf=read"

# Enter the path to your Vault
vaultpath=$vaultpath


# Assign times to variables
year=$(date +%Y)
nummonth=$(date +%m)
month=$(date +%B)

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


# Grab the bookid from READ data from the url and format it
IFS=$'\n' readfeed=$(curl --silent "$readurl" | grep -E '(book_id>)' | \
sed -e 's/<book_id>//' -e 's/<\/book_id>/ | /' \
-e 's/^[ \t]*//' -e 's/[ \t]*$//' | \
fmt
)

# Turn the data into an array
arr=($(echo $feed | tr "|" "\n")) # CURRENTLY-READING
readarr=($(echo $readfeed | tr "|" "\n")) # READ

# Remove whitespace on each element: CURRENTLY-READING
for (( i = 0 ; i < ${#arr[@]} ; i++ ))
do
  arr[$i]=$(echo "${arr[$i]}" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
done

# Remove whitespace on each element: READ
for (( i = 0 ; i < ${#readarr[@]} ; i++ ))
do
  readarr[$i]=$(echo "${readarr[$i]}" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
done


# Get the amount of books by dividing array by 5
bookamount=$( expr "${#arr[@]}" / 5)

for (( i = 0 ; i < ${bookamount} ; i++ ))
do
  # Create a temporary counter to loop through books
  counter=$( expr "$i" \* 5)

  # Set variables
  bookid=${arr[$( expr "$counter" + 1)]}

# Check if book already exists in note by bookid
    
    if grep -q "${bookid}" -r "${vaultpath}"
      then
        # code if found
          unset arr["$counter"]
          unset arr[$( expr "$counter" + 1)]
          unset arr[$( expr "$counter" + 2)]
          unset arr[$( expr "$counter" + 3)]
          unset arr[$( expr "$counter" + 4)]
          unset arr[$( expr "$counter" + 5)]
          unset arr[$( expr "$counter" + 6)]
          unset arr[$( expr "$counter" + 7)]
          unset arr[$( expr "$counter" + 8)]
          unset arr[$( expr "$counter" + 9)]
          unset arr[$( expr "$counter" + 10)]
          unset arr[$( expr "$counter" + 11)]
          unset arr[$( expr "$counter" + 12)]
          unset arr[$( expr "$counter" + 13)]
          unset arr[$( expr "$counter" + 14)]
          unset arr[$( expr "$counter" + 15)]

       # code if not found

     fi
done

# Reindex array to take away gaps
for i in "${!arr[@]}"; do
    new_array+=( "${arr[i]}" )
done
arr=("${new_array[@]}")
unset new_array

# Get the amount of books by dividing array by 5
bookamount=$( expr "${#arr[@]}" / 5)

if (( "$bookamount" == 0 )); then
  osascript -e "display notification \"No new books found.\" with title \"Currently-reading: No update\""
fi

# printf '%s\n' "${arr[@]}"
# return

# El Abandono en la Divina Providencia: Clásicos Católicos
# 25239369
# https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1427597020l/25239369.jpg
# Esta breve obra se compone de cartas escritas por un eclesiástico a la superiora de una comunidad religiosa. En ella se ve claro que el autor fue un hombre espiritual, interior y gran amigo de Dios. Él descubre en sus cartas, aquí abreviadas a veces, el verdadero método, el más corto y realmente el único para llegar a Dios. Feliz aquél que reciba fielmente estas lecciones. Los pecadores encontrarán cómo redimir sus pecados, expiando las acciones cumplidas por su propia voluntad, por la adhesión única a la voluntad de Dios. Y los justos comprobarán que, con muy poco esfuerzo y trabajo en sus ocupaciones y quehaceres, podrán llegar muy pronto a un alto grado de perfección y a una eminente santidad. No es otro el fin que aquí se pretende sino la mayor gloria de Dios y la santificación del lector
# Jean-Pierre de Caussade
# Fri, 12 Apr 2019 03:24:53 -0700
# 1861

# Start the loop for each book
for (( i = 0 ; i < ${bookamount} ; i++ ))
do

  counter=$( expr "$i" \* 16)

  # Set variables
  guid=${arr["$counter"]}
  title=${arr[$( expr "$counter" + 1)]}
  bookid=${arr[$( expr "$counter" + 2)]}
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
  

if [ -z "$user_read_at" ]
then
  user_read_at=${user_date_created}
fi

# Clean vars:
# 1. Format date
user_read_at=$(date -d "$user_read_at" +'%Y-%m-%d %H:%M')
clean_user_read_at=$(date -d "$user_read_at" +'%Y%m%d%H%M')

user_date_added=$(date -d "$user_date_added" +'%Y-%m-%d %H:%M')

user_date_created=$(date -d "$user_date_created" +'%Y-%m-%d %H:%M')
clean_user_date_created=$(date -d "$user_date_created" +'%Y%m%d%H%M')

# 2. Delete illegal (':' and '/') and unwanted ('#') characters
cleantitle=$(echo "${title}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')

# 3. Clean tags
IFS=', ' read -ra arrtags <<< "$user_shelves"
for index in "${!arrtags[@]}"
do
    arrlinks[$index]="[[${arrtags[$index]}]]"
    arrtags[$index]="- book/goodreads/tag/${arrtags[$index]}"
done
user_shelves=$(IFS=$'\n' ; echo "${arrtags[*]}")
user_shelves_links=$(IFS=' ' ; echo "${arrlinks[*]}")


  # Write the contents for the book file
  if [[ "$cleantitle" == "" ]];
  then
    osascript -e "display notification \"Failed to create note due to empty array.\" with title \"Error!\""
  else
    echo "---
aliases: []
bookid: ${bookid}
isbn: ${isbn}
asin:
author:: [[${author}]]
pages: ${num_pages}
book_published:: [[${book_published}]]  
cover: ${imglink}   
tags: 
- book/goodreads/profile
- book/goodreads/status/${shelf}
${user_shelves}
date: ${user_read_at}
readed: ${user_read_at}
created: ${user_date_created} 
updated: ${user_date_added} 
rating: ${user_rating}
average_rating: ${average_rating}
emotion:
---

# ${title}
* Author: [[${author}]] [[${clean_user_date_created} ${author}]]

[[goodreads]]
[Review, Private notes & Quotes](${guid})

![b|150](${imglink})

## Estanterías 
${user_shelves_links}

## Descripción
${book_description}

## Review
${user_review}

## Referencias
- 

" >> "${vaultpath}/${clean_user_read_at} ${cleantitle}.md"


# Ficha autor:
FILE="${vaultpath}/${author}.md" 


if [ -f "$FILE" ]; then
    # echo "$FILE exists."
    echo "- [[${clean_user_read_at} ${cleantitle}]]" >> "${FILE}"
else 
    # echo "$FILE does not exist."
echo "---
aliases: []
author:: [[${author}]]  
tags: 
- people/author
${user_shelves}
date: ${user_read_at}
readed: ${user_read_at}
created: ${user_date_created} 
updated: ${user_date_added} 
rating: ${user_rating}
emotion:
---

# ${author}

[[goodreads]]

## Estanterías 
${user_shelves_links}

## Referencias
- [[${clean_user_read_at} ${cleantitle}]]" >> "${FILE}"
  fi



    # Display a notification when creating the file
    osascript -e "display notification \"Booknote created!\" with title \"${cleantitle//\"/\\\"}\""
  fi

done