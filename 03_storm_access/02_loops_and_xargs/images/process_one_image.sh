#!/bin/bash

i=$1

echo "Downloading random image to img${i}.jpg"
wget -q -O "img_${i}.jpg" "https://picsum.photos/200"
sleep 0.2

# Make it a painting
convert img_${i}.jpg -paint 3 paint_${i}.jpg

# Make the painting a polaroid
convert paint_${i}.jpg +polaroid polaroid_${i}.jpg

# Remove the initial images and the paintings
rm img_${i}.jpg paint_${i}.jpg

