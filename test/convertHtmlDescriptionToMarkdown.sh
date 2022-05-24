#!/bin/sh

# Sinopsis Transfig
link='<![CDATA[<p>As its title suggests, this book by Pope Benedict XVI, follows Jesus from his final arrival in Jerusalem to his trial, crucifixion, and resurrection. This narrative raises a central question that the sitting pope contends must be answered by every Christian: Is the Nazarene the Son of God? Benedict answers that challenge with biblical insights and historical scholarship. This 315-page opus is certain to be received as a major response to revisionist historians and skeptics.</p>]]>'

# Resurrección
link2=''

link2=$(cat <<'EOF'
<![CDATA[God is all around! His <b>fingerprints</b> are everywhere! You don't have to lead the most daring life to find Him. He's present in metaphysical theories and on tennis courts, in the beauty of a thirty-foot waterfall and in the power of a lightning strike. No matter who you are or what life you lead, you can learn to see God everywhere you go. This book will help you get excited about hearing from God and allowing Him to enter into the hours and minutes of your days. This is taking "quiet time" out into a very loud world, marinating all your experiences in the riches of God's truth, not just a few minutes a day. Through this book's thirty-one devotions, you'll discover that we all can learn to find God's fingerprints - redemptive <i>reflections</i> in everyday moments, concrete examples of intangible concepts.]]>
EOF
)

echo -e "${link2}" | \
    sed 's|<br \/>|\\n|g' | \
    sed 's|<[^\/][^<>]*> *<\/[^<>]*>||g' | \
    sed -e 's|<i>|_|g' -e 's|</i>|_|g' | \
    sed -e 's|<b>|*|g' -e 's|</b>|*|g' | \
    sed -e 's|<strong>|*|g' -e 's|</strong>|*|g' | \
    sed -e 's|<p>|\n|g' -e 's|</p>|\n|g' | \
    sed -e 's|^[[:space:]]*||'