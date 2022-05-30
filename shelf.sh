#!/bin/sh

# USAGE: sh shelf.sh patata

if [ -z "$1" ]
then
    echo "Especifica una estantería por favor"
    exit 1
fi

. ./goodreads.cfg
. ./functions.sh


shelf=${1}
url="$urlbase/review/list_rss/$user?key=$key&shelf=$1"

# This grabs the data from the currently reading rss feed and formats it (16 campos)
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

# Número de campos del grep -E
miNumeroDeVariables=16

num_books=$(($bookamount / $miNumeroDeVariables))
echo "Capturando ${num_books} libros de estantería '${shelf}'..."

# Start the loop for each book
for (( i = 0 ; i < $miNumeroDeVariables ; i++ ))
do

  bookcounter=$(($i+1))

  counter=$( expr "$i" \* $miNumeroDeVariables)

  if (( "$counter" > $miNumeroDeVariables )); then
    break
  fi

  declare -A review

  # Set variables 16 (miNumeroDeVariables)
  guid=$( echo ${arr["$counter"]} | xargs)
  #https://www.goodreads.com/review/show/2297011024?utm_medium=api%25guid%25utm_source=rss
  last_url=$(echo "${guid##*/}") # último slash de la url
  
  review['reviewid']=${last_url%\?*} # remove suffix starting with "?"
  review['guid']="$guid"
  review['title']=$( echo ${arr[$( expr "$counter" + 1)]} | xargs)
  review['bookid']=$( echo ${arr[$( expr "$counter" + 2)]} | xargs)
  review['imglink']=$( echo ${arr[$( expr "$counter" + 3)]} | xargs)
  review['book_description']=$( echo ${arr[$( expr "$counter" + 4)]} | xargs)
  review['num_pages']=$( echo ${arr[$( expr "$counter" + 5)]} | xargs)
  review['author']=$( echo ${arr[$( expr "$counter" + 6)]} | xargs)
  review['isbn']=$( echo ${arr[$( expr "$counter" + 7)]} | xargs)
  review['user_rating']=$( echo ${arr[$( expr "$counter" + 8)]} | xargs)
  review['user_read_at']=$( echo ${arr[$( expr "$counter" + 9)]} | xargs)
  review['user_date_added']=$( echo ${arr[$( expr "$counter" + 10)]} | xargs)
  review['user_date_created']=$( echo ${arr[$( expr "$counter" + 11)]} | xargs)
  review['user_shelves']=$( echo ${arr[$( expr "$counter" + 12)]} | xargs)
  review['user_review']=$( echo ${arr[$( expr "$counter" + 13)]} | xargs)
  review['average_rating']=$( echo ${arr[$( expr "$counter" + 14)]} | xargs)
  review['book_published']=$( echo ${arr[$( expr "$counter" + 15)]} | xargs)

  echo "Libro ${bookcounter}: ${review['title']}"

  if [ -z "$review['user_read_at']" ]; then
    review['user_read_at']=${user_date_created}
  fi

  # Clean vars:
  # 1. Format date
  review['user_read_at']=$(date -d "${review['user_read_at']}" +'%Y-%m-%d %H:%M')
  review['clean_user_read_at']=$(date -d "${review['user_read_at']}" +'%Y%m%d%H%M')
  review['published_user_read_at']=$(date -d "${review['user_read_at']}" +'%A, %d %B %Y a las %H:%Mh.')

  review['user_date_added']=$(date -d "${review['user_date_added']}" +'%Y-%m-%d %H:%M')

  review['user_date_created']=$(date -d "${review['user_date_created']}" +'%Y-%m-%d %H:%M')
  review['clean_user_date_created']=$(date -d "${review['user_date_created']}" +'%Y%m%d%H%M')

  # 2. Delete illegal (':' and '/') and unwanted ('#') characters
  review['cleantitle']=$(echo "${review['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')

  # 3. Clean long text for Obsidian
  review['user_review']=$(clean_long_text "${review['user_review']}")

  # 4. Clean tags
  IFS=', ' read -ra arrtags <<< "${review['user_shelves']}"
  for index in "${!arrtags[@]}"
  do
      arrlinks[$index]="[[${arrtags[$index]}]]"
      arrtags[$index]="- book/goodreads/tag/${arrtags[$index]}"
  done
  review['user_shelves']=$(IFS=$'\\n' ; echo "${arrtags[*]}")
  review['user_shelves_links']=$(IFS=' ' ; echo "${arrlinks[*]}")

   
  review['reviewNoteFile']="${review[clean_user_read_at]} ${review[cleantitle]}"
  review['reviewNotePath']="${vaultpath}/${review[reviewNoteFile]}.md"

  # echo "${reviewNote}" >> "${reviewNotePath}"
  # doReviewNote=$("${reviewNote}" >> "${reviewNotePath}")

  # SET book (and author) files here
  # sh ./book.sh $bookid "${reviewNote}" "${reviewNotePath}"


  # sleep 1

  # Display a notification when creating the file
  # echo "REVIEW $i: $cleantitle ($counter)"

  export scalar_review=$(declare -p review)

  # sh ./book.sh "${review[@]}"
  sh ./book.sh ${review['bookid']}

  sleep 1

done