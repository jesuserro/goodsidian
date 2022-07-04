#!/bin/sh

# USAGE: sh shelf.sh patata

if [ -z "$1" ];
then
    echo "Especifica una estantería por favor"
    exit 1
fi

. ./goodreads.cfg
. ./functions.sh


shelf=${1}
url="$urlbase/review/list_rss/$user?key=$key&shelf=$1"

# This grabs the data from the currently reading rss feed and formats it (2 campos)
IFS=$'\n' feed=$(curl --silent "$url" | grep -E '(title>|guid>|book_large_image_url>)' | \
sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' \
-e 's/<title>//' -e 's/<\/title>/ | /' \
-e 's/<guid>//' -e 's/<\/guid>/ | /' \
-e 's/<book_large_image_url>//' -e 's/<\/book_large_image_url>/ | /' \
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
miNumeroDeVariables=3

num_books=$(($bookamount / $miNumeroDeVariables))
echo "Capturando ${num_books} libros de estantería '${shelf}'..."

# Start the loop for each book
for (( i = 0 ; i < $num_books ; i++ ))
do

  bookcounter=$(($i+1))

  counter=$( expr "$i" \* $miNumeroDeVariables)

  declare -A review

  # Set variables 2 (miNumeroDeVariables)
  guid=$( echo ${arr["$counter"]} | xargs)
  title=$( echo ${arr[$( expr "$counter" + 1)]} | xargs)
  book_large_image_url=$( echo ${arr[$( expr "$counter" + 2)]} | xargs)
  book_large_image_url=${book_large_image_url//$'\n'/}
  #https://www.goodreads.com/review/show/2297011024?utm_medium=api%25guid%25utm_source=rss
  last_url=$(echo "${guid##*/}") # último slash de la url
  review['reviewid']=${last_url%\?*} # remove suffix starting with "?"
  
  echo "$( expr "$i" + 1)/${num_books} - ${title}"

  sh ./review.sh ${review['reviewid']} ${book_large_image_url} ${shelf}

  # sleep 1

done