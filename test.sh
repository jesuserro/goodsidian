#!/bin/sh

link='<a href="www.link.com">Link</a>'
link='<a href="https://www.goodreads.com/author/show/4443885._the_Catholic_Church" title=" the Catholic Church" rel="nofollow noopener"> the Catholic Church</a>'

echo "${link}" | sed 's/<a href="\(.*\)">\(.*\)<\/a>/[\2](\1)/'