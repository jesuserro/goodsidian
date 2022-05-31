#!/bin/sh
# USAGE: sh review.sh 2297011024

if [ -z "$1" ]; then
  echo "Especifica un reviewid"
  exit 1
fi

. ./goodreads.cfg
. ./functions.sh

eval $scalar_review
declare -p review &>/dev/null # escapa comillas e impide print array en shell

# echo "review guid: ${review[guid]}"
 
xpathReview="GoodreadsResponse/review"
xpathBook="${xpathReview}/book"
xpathAuthor="${xpathBook}/authors/author[1]"

url="$urlbase/review/show?id=$1&key=$apikey"

# echo "BOOK $url"

xml=$(curl -s $url)

declare -A review
declare -A book
declare -A author

: <<'END'
# AUTOR
author['image_url']=$( echo $xml | xmllint --xpath "//$xpathAuthor/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['link']=$( echo $xml | xmllint --xpath "//$xpathAuthor/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['average_rating']=$( echo $xml | xmllint --xpath "//$xpathAuthor/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['text_reviews_count']=$( echo $xml | xmllint --xpath "//$xpathAuthor/text_reviews_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['authorFile']="${vaultpath}/${author['name']}.md" 

# LIBRO
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')
book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['link']=$( echo $xml | xmllint --xpath "//$xpathBook/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['format']=$( echo $xml | xmllint --xpath "//$xpathBook/format/link/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['average_rating']=$( echo $xml | xmllint --xpath "//$xpathBook/average_rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['ratings_count']=$( echo $xml | xmllint --xpath "//$xpathBook/ratings_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['description']=$( echo $xml | xmllint --xpath "//$xpathBook/description/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['description']=$(clean_long_text "${book['description']}")
book['bookPath']="${vaultpath}/${book[bookFileName]}.md"
END


author['authorid']=$( echo $xml | xmllint --xpath "//$xpathAuthor/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
author['name']=$( echo $xml | xmllint --xpath "//$xpathAuthor/name/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )


book['bookid']=$( echo $xml | xmllint --xpath "//$xpathBook/id/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['title']=$( echo $xml | xmllint --xpath "//$xpathBook/title/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# 2. Delete illegal (':' and '/') and unwanted ('#') characters
book['cleantitle']=$(echo "${book['title']}" | sed -e 's/\///' -e 's/:/ –/' -e 's/#//')
book['image_url']=$( echo $xml | xmllint --xpath "//$xpathBook/image_url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_day']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_day/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
# book['publication_day']=$(date -d "${book['publication_day']}" +'%d')
book['publication_year']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_year/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_month']=$( echo $xml | xmllint --xpath "//$xpathBook/publication_month/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publication_date']="${book['publication_year']}-${book['publication_month']}-${book['publication_day']}"
book['publication_date']=$(date -d "${book['publication_date']}" +'%Y-%m-%d')
book['clean_publication_date']=$(date -d "${book['publication_date']}" +'%Y%m%d')
book['bookFileName']="${book['publication_year']}${book['publication_month']}${book['publication_day']} ${book['cleantitle']}"
book['isbn']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['isbn13']=$( echo $xml | xmllint --xpath "//$xpathBook/isbn13/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['num_pages']=$( echo $xml | xmllint --xpath "//$xpathBook/num_pages/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['uri']=$( echo $xml | xmllint --xpath "//$xpathBook/uri/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['publisher']=$( echo $xml | xmllint --xpath "//$xpathBook/publisher/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
book['bookFileName']="${book['clean_publication_date']} ${book['cleantitle']}"



# REVIEW
review['reviewid']="${1}"
review['title']="${book['title']}"
review['rating']=$( echo $xml | xmllint --xpath "//$xpathReview/rating/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['votes']=$( echo $xml | xmllint --xpath "//$xpathReview/votes/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )

review['read_at']=$( echo $xml | xmllint --xpath "//$xpathReview/read_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['read_at']=$(date -d "${review['read_at']}" +'%Y-%m-%d %H:%M')
review['clean_read_at']=$(date -d "${review['read_at']}" +'%Y%m%d%H%M')
review['published_read_at']=$(date -d "${review['read_at']}" +'%A, %d %B %Y a las %H:%Mh.')

review['recommended_for']=$( echo $xml | xmllint --xpath "//$xpathReview/recommended_for/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['recommended_for']=$(clean_long_text "${review['recommended_for']}")
review['url']=$( echo $xml | xmllint --xpath "//$xpathReview/url/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
#review['recommended_by']=$( echo $xml | xmllint --xpath "//$xpathReview/recommended_by/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
#review['recommended_by']=$(clean_long_text "${review['recommended_by']}")

# review['body']=$( echo -e $xml | xmllint --xpath "//$xpathReview/body/text()" - | sed -e 's|<!\[CDATA\[||' -e 's|\]\]>||' )
review['body']=$( echo $xml | xmllint --xpath "//$xpathReview/body/text()" - | sed -e 's|<!\[CDATA\[||' -e 's|\]\]>||' )
orig=$'\n'; replace=$'\\\n'
# sed "s|COMMIT|${morerules//$orig/$replace}|g"
patata=$( echo ${review[body]} | sed -e 's|${orig}|${replace}|g' )
# echo "${patata}"
# exit 1
# review['body']='En Mayo del 2000, el <i>Prefecto de la Doctrina de la Fe</i> – Cardenal Joseph Ratzinger – leía ante el mundo el misterioso <i> <a href="http://www.vatican.va/roman_curia/congregations/cfaith/documents/rc_con_cfaith_doc_20000626_message-fatima_en.html" rel="nofollow noopener">Tercer Secreto de Fátima</a> </i>. El texto – confuso y repleto de imágenes oníricas – fue sometido al implacable criterio de Ratzinger. Sólo entonces cobraba sentido y resultaba coherente con la doctrina. En aquel momento supe que leería a este hombre. Observar la figura de Cristo bajo el prisma de esta mente privilegiada, era tentador. Así llegué a esta obra.<br /><br />El libro es un bello y profundo análisis de la vida pública de Jesús. Es el segundo tomo perteneciente a la trilogía sobre la vida de Cristo: <br />El primer tomo <a href="https://www.goodreads.com/book/show/16099176.Jesus_of_Nazareth_The_Infancy_Narratives" title="Jesus of Nazareth The Infancy Narratives by Benedict XVI" rel="nofollow noopener">Jesus of Nazareth: The Infancy Narratives</a><br />El segundo <a href="https://www.goodreads.com/book/show/82405.Jesus_of_Nazareth_From_the_Baptism_in_the_Jordan_to_the_Transfiguration" title="Jesus of Nazareth From the Baptism in the Jordan to the Transfiguration by Benedict XVI" rel="nofollow noopener">Jesus of Nazareth: From the Baptism in the Jordan to the Transfiguration</a><br />El tercero <a href="https://www.goodreads.com/book/show/9488716.Jesus_of_Nazareth__Part_Two_Holy_Week_From_the_Entrance_into_Jerusalem_to_the_Resurrection" title="Jesus of Nazareth, Part Two Holy Week From the Entrance into Jerusalem to the Resurrection by Benedict XVI" rel="nofollow noopener">Jesus of Nazareth, Part Two: Holy Week: From the Entrance into Jerusalem to the Resurrection</a>. <br />400 páginas divididas en 10 capítulos. He podido recoger más de 40 citas en Goodreads. Se describen los hechos históricos relevantes de la vida pública de Jesús, así como el núcleo de su mensaje.<br /><br />Como un buen ajedrecista, Ratzinger abre la partida posicionando de forma clara y firme sus piezas, su criterio exegético. Su interpretación del Jesús histórico está basada en la confianza en los Evangelios. Permite el despliegue de toda la potencialidad de la palabra. No la aprisiona en el momento histórico. De este modo, la biblia brilla como un cuerpo homogéneo, cobra auténtico sentido y desemboca en una única imagen coherente de Jesucristo.<br /><br />Ratzinger es capaz de revelar amplios registros evangélicos. Desde una teología elevada – casi metafísica – hasta los comportamientos más humanos de los discípulos. Por ejemplo, la descripción de las <i>experiencias teofánicas</i> de los Apóstoles es maravillosa. También puedes encontrar detalles sorprendentes de la figura de Cristo, como a un Jesús aventurero y amante de la naturaleza que lleva a sus discípulos de viaje – a lo que hoy es la <i>Reserva Natural de Hermón</i> – en el episodio de la <i>Confesión de Pedro</i>.<br /><br />¿Quieres conocer a Cristo? Este libro es para ti. ¿Necesitas esperanza en tu vida? Ratzinger te aclarará el mensaje de Cristo para que florezca tu fe en ti y en los demás. ¿Te gusta el misterio? Encontrarás fascinantes episodios de la vida pública de Jesús, dignos de una película de ciencia ficción: <i>la Transfiguración</i>, <i>la Pesca Milagrosa</i> y <i>Caminando sobre las Aguas</i>. ¿Eres fan de la Biblia? El libro está plagado de referencias y relaciones bíblicas que clarificarán tu entendimiento. ¿Eres fan de la literatura? Encontrarás buenas referencias de libros aquí. ¿Te gusta la oración? Encontrarás un completo estudio de las principales plegarias cristianas. ¿Eres un enamorado del lenguaje alegórico y parábolas? Se hace un amplio análisis de ellas. Además hay un capítulo entero dedicado al Evangelio de Juan y sus imágenes características.<br /><br />Además de acontecimientos históricos, el libro guarda otras sorpresas. Ratzinger destapa una teología que desde Cristo, entronca con nuestra realidad cotidiana. Es decir, el libro puede servirte también como auto ayuda espiritual. En este sentido, el capítulo 3 <i>“El Evangelio del Reino”</i> es muy instructivo. Uno puede identificar sus miserias en la explicación de la <i>Parábola del Fariseo y el Publicano</i>.<br /><br />Es el misterio de la figura de Jesús. Su mensaje sigue siendo cercano, conmovedor y universal. Ha sobrevivido al poder de emperadores y reyes, con algo tan aparentemente débil como la fe y el amor. Responde a las preguntas del hombre de hoy. Ha superado mitos, maestros y sabios. Ratzinger explica las novedades introducidas por el cristianismo. Y lo protege de la teología liberal, que trata de adaptar el mensaje de Cristo a sus propias necesidades.'

# echo "${review[body]}"
# exit 1

# IFS= read -r -d '' patata <<EOC
#     "${review[body]}"
# EOC

# review['body']=$(cat "${review[body]}")

# review['body']=$(echo "$xml" | sed -e 's|\<body\>\<!\[CDATA\[||')
# review['body']=$(sed -e 's|<body><!\[CDATA\[||' <<< "${xml}")




: <<'END'
review['body']=$(clean_long_text "${review['body']}")

# review['shelves']=$( echo $xml | xmllint --xpath "//$xpathReview/shelves/shelf/@name" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['shelves']="Shelves..."

review['started_at']=$( echo $xml | xmllint --xpath "//$xpathReview/started_at/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['started_at']=$(date -d "${review['started_at']}" +'%Y-%m-%d %H:%M')


review['date_added']=$( echo $xml | xmllint --xpath "//$xpathReview/date_added/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['date_added']=$(date -d "${review['date_added']}" +'%Y-%m-%d %H:%M')
review['date_updated']=$( echo $xml | xmllint --xpath "//$xpathReview/date_updated/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
review['date_updated']=$(date -d "${review['date_updated']}" +'%Y-%m-%d %H:%M')

review['comments_count']=$( echo $xml | xmllint --xpath "//$xpathReview/comments_count/text()" - | sed -e 's/<!\[CDATA\[//' -e 's/\]\]>//' )
END

review['reviewNoteFile']="${review[clean_read_at]} ${book[cleantitle]}"
review['reviewNotePath']="${vaultpath}/${review[reviewNoteFile]}.md"



# PRINTING REVIEW
sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
    -e "s;%isbn%;${book['isbn']};g" \
    -e "s;%isbn13%;${book['isbn13']};g" \
    -e "s;%url%;${review['url']};g" \
    -e "s;%isbn%;${review['isbn']};g" \
    -e "s;%kindle_uri%;${book['uri']};g" \
    -e "s;%title%;${review['title']};g" \
    -e "s;%author%;${author['name']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s|%body%|${patata}|g" \
    -e "s|%image_url%|${book[image_url]}|g" \
    -e "s;%user_rating%;${review['user_rating']};g" \
    -e "s;%read_at%;${review['read_at']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%publication_date%;${book['publication_date']};g" \
    -e "s|%user_shelves_links%|${review['user_shelves_links']}|g" \
    -e "s|%user_shelves%|${review['user_shelves']}|g" \
    -e "s|%bookFileName%|${book['bookFileName']}|g" \
    -e "s|%published_read_at%|${review['published_read_at']}|g" \
    -e "s|%reviewid%|${review['reviewid']}|g" \
    -e "s|%authorid%|${author['authorid']}|g" \
    -e "s|%votes%|${review['votes']}|g" \
    -e "s|%rating%|${review['rating']}|g" \
    -e "s|%recommended_for%|${review['recommended_for']}|g" \
    -e "s|%recommended_by%|${review['recommended_by']}|g" \
    review.tpl > "${review['reviewNotePath']}"





: <<'END'
# BOOK
if [ -f "${book['bookPath']}" ]; then
    exit 1
fi
sleep 1
sed -E \
    -e "s;%bookid%;${book['bookid']};g" \
    -e "s;%authorId%;${author['authorId']};g" \
    -e "s;%isbn%;${book['isbn']};g" \
    -e "s;%title%;${book['title']};g" \
    -e "s;%publication_year%;${book['publication_year']};g" \
    -e "s|%description%|${book[description]}|g" \
    -e "s;%image_url%;${book['image_url']};g" \
    -e "s;%average_rating%;${book['average_rating']};g" \
    -e "s;%publisher%;${book['publisher']};g" \
    -e "s;%author%;${author['authorName']};g" \
    -e "s;%num_pages%;${book['num_pages']};g" \
    -e "s;%kindle_asin%;${book['kindle_asin']};g" \
    -e "s;%goodreads_url%;${book['goodreads_url']};g" \
    -e "s;%reviewNoteFile%;${review['reviewNoteFile']};g" \
    -e "s;%my_reviews%;${review['reviewid']};g" \
    book.tpl > "${book['bookPath']}"

# AUTHOR
if [ -f "${author['authorFile']}" ]; then
    exit 1
fi
sleep 1
sed -E \
    -e "s;%authorid%;${author['authorid']};g" \
    -e "s;%name%;${author['name']};g" \
    -e "s;%image_url%;${author['image_url']};g" \
    -e "s;%link%;${author['link']};g" \
    -e "s|%about%|${author[about]}|g" \
    -e "s;%books%;${author['books']};g" \
    -e "s;%reviews%;${book['reviews']};g" \
    -e "s;%user_read_at%;${review['user_read_at']};g" \
    -e "s;%user_date_created%;${review['user_date_created']};g" \
    -e "s;%user_date_added%;${review['user_date_added']};g" \
    -e "s;%user_rating%;${review['user_rating']};g" \
    author.tpl > "${author['authorFile']}"
END