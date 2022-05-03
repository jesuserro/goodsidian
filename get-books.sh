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


# Turn the data into an array
arr=($(echo $feed | tr "|" "\n")) # shelf

# Remove whitespace on each element: shelf
for (( i = 0 ; i < ${#arr[@]} ; i++ ))
do
  arr[$i]=$(echo "${arr[$i]}" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
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
# cmd /k
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
  

if [ -z "$bookid" ]
then
  continue
fi

urlbook="$urlbase/book/show?format=xml&key=$apikey&id=$bookid"

echo "BOOKID:$bookid -> $title"

done
