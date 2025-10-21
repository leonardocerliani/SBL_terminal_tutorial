# For loops and parallel execution

## The basic for loop
Many times we need to execute the same function for different elements, for instance applying the same processing to many images, where the only variable is the image name.

In this case we can proceed in two ways:
- writing a function that takes the variable as an arguments and runs it for all value of the variable
- running the function in parallel for all the values of the variable

Let's start with the simplest case: the for loop. The pseudo-code would be something like:

```bash
for [i = variable values]; do 
  [something with] ${i}
done
```

To put this to work, we will download a few random images from [picsum.photos](https://picsum.photos/) and do some transformations on them.


```bash
# First create an images folder and cd into that
mkdir images && cd images

# Download the images
n=5
for i in $(seq 1 ${n}); do
  echo "Downloading random image to img${i}.jpg"
  wget -O "img_${i}.jpg" "https://picsum.photos/200"
  sleep 0.2
done
```


A few notes:

- The indentation is not necessary, but highly recommended for readability.
- Notice also that I echoed the action in the loop. That's also a good practice, for instance for sending it to a log file. 
- You can also just prepend the echo to the entire `wget` command and do a dry run to see whether you got the syntax right.

Now we will give an artistic touch to our images, making then similar to paintings. This time we could still loop in the range 1..10, but it's much easier to loop over all files, since we have only images.

```bash
# Make it a painting
for i in $(ls); do
  convert ${i} -paint 3 paint_${i} 
done
```

Finally, we will transform the paintings into polaroid images. This time we must be careful with the images we pass to the loop, because we want to pass only the paintings:

```bash
# Make it a polaroid
for i in $(ls paint*.jpg); do
  convert ${i} +polaroid polaroid_${i}
done
```

If you want to explore other effects you can apply with ImageMagick (from which the `convert` command comes in) you can look [here](https://linuxhint.com/imagemagick-image-transformations/) and [here](https://legacy.imagemagick.org/Usage/transform/).

Of course we can do everything in the same loop. Let's first remove all the images we created so far.

```bash
rm *.jpg

n=5
for i in $(seq 1 ${n}); do

  echo "Downloading random image to img${i}.jpg"
  wget -q -O "img_${i}.jpg" "https://picsum.photos/200"
  sleep 0.2

  # Make it a painting
  convert img_${i}.jpg -paint 3 paint_${i}.jpg
  
  # Make the painting a polaroid
  convert paint_${i}.jpg +polaroid polaroid_${i}.jpg
  
  # Remove the initial images and the paintings
  rm img_${i}.jpg paint_${i}.jpg
done
```

## Doing it in parallel with xargs




