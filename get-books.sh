#!/bin/sh

# Enter urls to your goodreads rss feed below.
# You can find it by navigating to one of your goodreads shelves and
# clicking the "RSS" button at the bottom of the page.

. ./goodreads.cfg

# url for "Currently reading":
# url="https://www.goodreads.com/url-to-your-rss-feed-shelf=currently-reading"
# url="https://www.goodreads.com/review/list_rss/$user?key=$key&shelf=to-read"
url="https://www.goodreads.com/review/list_rss/$user?key=$key&shelf=$shelf"

# Enter the path to your Vault
vaultpath=$vaultpath
shelf=$shelf


# This grabs the data from the currently reading rss feed and formats it
IFS=$'\n' feed=$(curl --silent "$url" | grep -E '(book_id>)' | \
sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' \
-e 's/<book_id>//' -e 's/<\/book_id>/ | /')

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

# Get the amount of books
bookamount=$( expr "${#arr[@]}")

if (( "$bookamount" == 0 )); then
  echo "No books found"
fi

# Start the loop for each book
for (( i = 0 ; i < ${bookamount} ; i++ ))
do

  bookid=${arr[$i]}

  if [ -z "$bookid" ]
  then
    continue
  fi

  urlbook="$urlbase/book/show?format=xml&key=$apikey&id=$bookid"

  echo "BOOKID:$bookid"

done
