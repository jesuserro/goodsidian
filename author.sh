#!/bin/sh

if [ -z "$1" ]
then
      echo "No existen params por defecto"
      exit 1
fi

arr=$1

. ./goodreads.cfg

bookamount=$( expr "${#arr[@]}")

if (( "$bookamount" == 0 )); then
  echo "No new books found in shelf $shelf"
fi

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


# Ficha autor:
authorFile="${vaultpath}/${author}.md" 

if [ -f "$authorFile" ]; then
    # echo "$authorFile exists."
    echo "- [[${clean_user_read_at} ${cleantitle}]]" >> "${authorFile}"
else 
    # echo "$authorFile does not exist."
echo "---
aliases: []
author:: [[${author}]]  
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

# ${author}

[[goodreads]]

## Estanterías 
${user_shelves_links}

## Referencias
- [[${clean_user_read_at} ${cleantitle}]]" >> "${authorFile}"

# Display a notification when creating the file
    echo "Author note created: $cleantitle"

  fi

    
















