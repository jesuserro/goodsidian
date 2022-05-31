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
  
  sh ./review.sh ${review['reviewid']}

  sleep 1

done