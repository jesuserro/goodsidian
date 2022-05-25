#!/bin/sh

. ./functions.sh

# Sinopsis Transfig
link='<![CDATA[<p>As its title suggests, this book by Pope Benedict XVI, follows Jesus from his final arrival in Jerusalem to his trial, crucifixion, and resurrection. This narrative raises a central question that the sitting pope contends must be answered by every Christian: Is the Nazarene the Son of God? Benedict answers that challenge with biblical insights and historical scholarship. This 315-page opus is certain to be received as a major response to revisionist historians and skeptics.</p>]]>'

# Resurrección
link2=$(cat <<'EOF'
<![CDATA[God is all around! His <b>fingerprints</b> are everywhere! You don't have to lead the most daring life to find Him. He's present in metaphysical theories and on tennis courts, in the beauty of a thirty-foot waterfall and in the power of a lightning strike. No matter who you are or what life you lead, you can learn to see God everywhere you go. This book will help you get excited about hearing from God and allowing Him to enter into the hours and minutes of your days. This is taking "quiet time" out into a very loud world, marinating all your experiences in the riches of God's truth, not just a few minutes a day. Through this book's thirty-one devotions, you'll discover that we all can learn to find God's <a href="patata.com">fingerprints</a> - redemptive <i>reflections</i> in everyday moments, concrete examples of intangible concepts.]]>
EOF
)

link3=$(cat <<'EOF'
El primer tomo <a href=https://www.goodreads.com/book/show/16099176.Jesus_of_Nazareth_The_Infancy_Narratives title=Jesus of Nazareth The Infancy Narratives by Benedict XVI rel=nofollow noopener>Jesus of Nazareth: The Infancy Narratives</a>
El segundo <a href=https://www.goodreads.com/book/show/82405.Jesus_of_Nazareth_From_the_Baptism_in_the_Jordan_to_the_Transfiguration title=Jesus of Nazareth From the Baptism in the Jordan to the Transfiguration by Benedict XVI rel=nofollow noopener>Jesus of Nazareth: From the Baptism in the Jordan to the Transfiguration</a>
El tercero <a href=https://www.goodreads.com/book/show/9488716.Jesus_of_Nazareth__Part_Two_Holy_Week_From_the_Entrance_into_Jerusalem_to_the_Resurrection title=Jesus of Nazareth, Part Two Holy Week From the Entrance into Jerusalem to the Resurrection by Benedict XVI rel=nofollow noopener>Jesus of Nazareth, Part Two: Holy Week: From the Entrance into Jerusalem to the Resurrection</a>. 
400 páginas divididas en 10 capítulos. He podido recoger más de 40 citas en Goodreads. Se describen los hechos históricos relevantes de la vida pública de Jesús, así como el núcleo de su mensaje.
EOF
)


result=$(clean_long_text_test "${link3}")

echo -e "${result}"