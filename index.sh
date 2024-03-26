#!/bin/bash

# Ejecutar con: `bash index.sh read` 

# Comprobar si se proporciona un argumento para la estantería
if [ -z "$1" ]; then
    echo "Especifica una estantería, por favor."
    exit 1
fi

# Configuración de Goodreads
source ./goodreads.cfg
source ./functions.sh

# Construir la URL de la API de reviews de Goodreads para la estantería indicada (read, currently-reading, to-read)
url="https://www.goodreads.com/review/list_rss/$user?key=$key&shelf=$1"

# Mostrar la URL en pantalla
echo "URL de la API de Goodreads: $url"

# Obtener la lista de mis reviews desde la API de Goodreads
feed=$(curl --silent "$url")

# Extraer información XML del feed
IFS=$'\n' read -r -d '' -a xml_tags < <(echo "$feed" | awk -F'</item>' '{for(i=1;i<=NF;i++) print $i}' | grep -E '(title>|book_large_image_url>|author_name>|book_published>|book_id>|user_date_created>|book_description>|user_shelves>|num_pages>|isbn>|average_rating>|user_review>|guid>|user_rating>|user_read_at>|user_date_added>)')

# Contar el número de tags xml devueltos por la api
num_tags=${#xml_tags[@]}

# Comprobar si hay tags en el feed de la api
if [ "$num_tags" -eq 0 ]; then
    echo "No se encontraron tags en el feed \"$1\"."
    exit 0
fi

# Inicializar array para almacenar libros
declare -a books

# Variables para almacenar datos del libro actual
title=""
guid_found=0

# Iterar por todos los tags xml del feed
for tag in "${xml_tags[@]}"; do
    if [[ "$tag" == *"<guid>"* ]]; then
        # Si encontramos un tag <guid>, es el comienzo de un nuevo libro
        guid_found=1
        title=""
    fi

    if [[ "$tag" == *"<title>"* ]]; then
        # Si encontramos un tag <title>, almacenamos el título del libro
        title=$(echo "$tag" | sed -e 's/<title>//g' -e 's/<\/title>//g' -e 's/<!\[CDATA\[\(.*\)\]\]>/\1/g')
    fi

    if [[ "$guid_found" -eq 1 && ! -z "$title" ]]; then
        # Si se encontró el tag <guid> y tenemos un título, almacenamos el libro en el array de libros
        books+=("Título: $title")
        # Restablecer la bandera y la variable del título para el próximo libro
        guid_found=0
        title=""
    fi
done

# Mostrar el número de libros encontrados
num_books=${#books[@]}
echo "Número de libros encontrados: $num_books"
echo "Títulos de los libros encontrados:"
for book in "${books[@]}"; do
    echo "$book"
done
