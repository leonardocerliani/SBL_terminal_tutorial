i=$1

images_dir="$(pwd)/images"
mkdir -p ${images_dir}


echo "Downloading random image to img${i}.jpg"
wget -q -O "${images_dir}/img_${i}.jpg" "https://picsum.photos/600"
sleep 0.2

echo "Asking description to llava"  
python ask_llava.py "img_${i}.jpg" "Describe what is in the image in a very short sentence"

echo "Generating the polaroid"
convert \
  -font Purisa \
  -pointsize 24 \
  -caption "$(cat ${images_dir}/description_img_${i}.txt)" \
  ${images_dir}/img_${i}.jpg \
  +polaroid \
  ${images_dir}/polaroid_${i}.jpg

# rm ${images_dir}/img_${i}.jpg ${images_dir}/description_img_${i}.txt
echo 
echo

