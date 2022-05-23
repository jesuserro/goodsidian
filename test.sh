#!/bin/sh

# see: https://stackoverflow.com/questions/40273926/convert-html-links-to-markdown-using-command-sed

# link='<a href="www.link.com">Link</a>'
link='<a href="https://www.goodreads.com/author/show/4443885._the_Catholic_Church" title=" the Catholic Church" rel="nofollow noopener"> the Catholic Church</a>'

# echo "${link}" | sed -r 's/.*href="([^"]+).*/[Link](\1)/g' # Pilla el href
# echo "${link}" | sed 's|<a href="\([^\"]+\)".*>\(.*\)<\/a>|[\2](\1)|g'
# echo "${link}" | sed 's|<a href="\(.*\)">\(.*\)<\/a>|[\2](\1)|g'
# echo "${link}" | sed -r 's/<a href="(.*)">(.*)<.*/[\2](\1)/g' # Pilla texto link
echo "${link}" | sed -r 's/<a href="([^"]+).*>(.*)<.*/[\2](\1)/g' # OK