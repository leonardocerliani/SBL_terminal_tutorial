
# Download the image
for i in $(seq 1 5); do
  echo "Downloading random image to img${i}.jpg"
  wget -O "img_${i}.jpg" "https://picsum.photos/200"
  sleep 0.2
done


# Make it a painting
for i in $(ls); do
  convert ${i} -paint 3 paint_${i} 
done


# Make it a polaroid
# https://linuxhint.com/imagemagick-image-transformations/
# https://legacy.imagemagick.org/Usage/transform/
for i in $(ls paint*.jpg); do
  convert ${i} +polaroid polaroid_${i}
done

