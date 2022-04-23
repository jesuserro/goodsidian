#!/bin/sh

# Enter urls to your goodreads rss feed below.
# You can find it by navigating to one of your goodreads shelves and
# clicking the "RSS" button at the bottom of the page.

shelf="currently-reading"

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
IFS=$'\n' feed=$(curl --silent "$url" | grep -E '(title>|book_large_image_url>|author_name>|book_published>|book_id>|pubDate>|book_description>)' | \
sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' \
-e 's/Jei.s bookshelf: '$shelf'//' \
-e 's/<book_large_image_url>//' -e 's/<\/book_large_image_url>/ | /' \
-e 's/<title>//' -e 's/<\/title>/ | /' \
-e 's/<book_description>//' -e 's/<\/book_description>/ | /' \
-e 's/<author_name>//' -e 's/<\/author_name>/ | /' \
-e 's/<book_published>//' -e 's/<\/book_published>/ | /' \
-e 's/<book_id>//' -e 's/<\/book_id>/ | /' \
-e 's/<pubDate>//' -e 's/<\/pubDate>/ | /' \
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

# Mon, 13 Sep 2021 06:47:44 -0700
# El Abandono en la Divina Providencia: Clásicos Católicos
# 25239369
# https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1427597020l/25239369.jpg
# Esta breve obra se compone de cartas escritas por un eclesiástico a la superiora de una comunidad religiosa. En ella se ve claro que el autor fue un hombre espiritual, interior y gran amigo de Dios. Él descubre en sus cartas, aquí abreviadas a veces, el verdadero método, el más corto y realmente el único para llegar a Dios. Feliz aquél que reciba fielmente estas lecciones. Los pecadores encontrarán cómo redimir sus pecados, expiando las acciones cumplidas por su propia voluntad, por la adhesión única a la voluntad de Dios. Y los justos comprobarán que, con muy poco esfuerzo y trabajo en sus ocupaciones y quehaceres, podrán llegar muy pronto a un alto grado de perfección y a una eminente santidad. No es otro el fin que aquí se pretende sino la mayor gloria de Dios y la santificación del lector
# Jean-Pierre de Caussade
# 1861




# Start the loop for each book
for (( i = 0 ; i < ${bookamount} ; i++ ))
do

  counter=$( expr "$i" \* 7)

  # Set variables
  pubDate=${arr[$( expr "$counter")]}
  pubDate=$(date -d "$pubDate" +'%Y-%m-%d %H:%M')
  title=${arr["$counter + 1"]}
  bookid=${arr[$( expr "$counter" + 2)]}
  imglink=${arr[$( expr "$counter" + 3)]}
  book_description=${arr[$( expr "$counter + 4")]}
  author=${arr[$( expr "$counter" + 5)]}
  pub=${arr[$( expr "$counter" + 6)]}
  


# Delete illegal (':' and '/') and unwanted ('#') characters
cleantitle=$(echo "${title}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')

  # Write the contents for the book file

  if [[ "$cleantitle" == "" ]];
  then
    osascript -e "display notification \"Failed to create note due to empty array.\" with title \"Error!\""
  else
    echo "---
bookid: ${bookid}
date: ${pubDate}      
tags: 
- book/profile
- goodreads/${shelf}
rating:
emotion:
---

# ${title}

[[goodreads]]

![b|150](${imglink})
* PubDate: ${pubDate}
* Author: [[${author}]]
* Year published: [[${pub}]]

## Descripción
${book_description}

" >> "${vaultpath}/${cleantitle}.md"

    # Display a notification when creating the file
    osascript -e "display notification \"Booknote created!\" with title \"${cleantitle//\"/\\\"}\""
  fi

done

ifbookid=$(find "${vaultpath}" -type f -print0 | xargs -0 grep -li "${cbookid}")
ifcurrread=$(find "${vaultpath}" -type f -print0 | xargs -0 grep -li "#currently-reading")

if find "${vaultpath}" -type f -print0 | xargs -0 grep -li "${cbookid}"
then
  # Code if found: update read books
  fname=$(find "${vaultpath}" -type f -print0 | xargs -0 grep -li "${cbookid}")
  sed -i '' "/Year published: \[\[[0-9][0-9][0-9][0-9]\]\]/ a\\
  \* Year read: #read${year}" "$fname"
  sed -i '' "/Year read: #read${year}/ a\\
  \* Month read: [[${year}-${nummonth}-${month}|${month} ${year}]]" "$fname"
  sed -i '' -e 's/#currently-reading/#read/' "$fname"

  # Grab the name of the changed book
  fname=$(echo ${fname} | sed 's/^.*\///' | sed 's/\.[^.]*$//')
  osascript -e "display notification \"${fname}\" with title \"Updated read books\""
else
 # code if not found: No new books
 osascript -e "display notification \"No new read books.\" with title \"Read: No update\""
fi

for (( i = 0 ; i < ${#readarr[@]} ; i++ ))
do
  #circle through bookid array
  cbookid=${readarr["$i"]}

  # If in the path to the vault, there is a file with the current id, then …
  if find "${vaultpath}" -not -path "*/\.*" -type f \( -iname "*.md" \) -print0 | xargs -0 grep -li "${cbookid}"
  then
  # … set variable fname to that file
  fname=$(find "${vaultpath}" -not -path "*/\.*" -type f \( -iname "*.md" \) -print0 | xargs -0 grep -li "${cbookid}")
    # Check if it has tag "#currently-reading"
      if grep "#currently-reading" "${fname}"
      then
        # If yes, change the formatting, delete the "#currently-reading" tag
        sed -i '' "/Year published: \[\[[0-9][0-9][0-9][0-9]\]\]/ a\\
        \* Year read: #read${year}" "$fname"
        sed -i '' "/Year read: #read${year}/ a\\
        \* Month read: [[${year}-${nummonth}-${month}|${month} ${year}]]" "$fname"
        sed -i '' -e 's/#currently-reading/#outline \/ #welcome/' "$fname"

        # Grab the name of the changed book
        declare -i updatedbooks; updatedbooks+=1
        fname=$(echo ${fname} | sed 's/^.*\///' | sed 's/\.[^.]*$//')
        # Show notification
        osascript -e "display notification \"${fname}\" with title \"Updated read books\""
      fi
  fi
done

# code if not found: No new books
if [[ ${updatedbooks} = "" ]]
then
osascript -e "display notification \"No new read books.\" with title \"Read: No update\""
fi
