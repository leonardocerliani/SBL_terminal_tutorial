# For loops and parallel execution

## The basic for loop
Many times we need to execute the same function on different elements, for instance applying the same processing to many images, where the only variable is the image name.

In this case we can proceed in two ways:
- writing a function that takes the variable as an arguments and runs it for all value of the variable
- running the function in parallel for all the values of the variable

Let's start with the simplest case: the for loop. The pseudo-code would be something like:

```bash
for [i = variable values]; do 
  [something with] ${i}
done

# example
for i in $(seq 10 -1 1); do
	echo "$i seconds left..."
  sleep 1
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



## Passing arguments

Of course we do not want to write all the times the commands line by line. Better making a bash script and running that with one command only.

To edit a script, you can use the `nano` editor in the terminal.

```bash
nano process_images.sh
```

We can then write or copy/paste the same code we wrote above and run the script

```
# First give execution priviledges
chmod +x process_images.sh

# run it
./process_images.sh
```



## Parallel execution with xargs

The processes we have used so far are very fast, but in real cases, each of them could take several minutes if not hours.

It would be therefore very advantageous if we could do them all in parallel.

To show the advantage in time, we will make a slight modification. We will put all the code in a script, which accepts a variable for the numbers 1..10. We will then pass a list (a text file) containing the numbers 1..10. 

NB: It is not necessary to create a separate list. We could also define a bash function inside the script and pass a bash array to it. But that's a bit advanced for the moment, so let's use a simpler implementation.

Create a script called `process_one_image.sh` inside the `images` directory and put the following code inside

```bash
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
```

the line `i=$1` instructs the script to take the first argument passed to it and assign it to the variable `i`. Now we can run the script as follows:

```bash
# First make sure it is executable
chmod +x process_one_image.sh

# Call it with an argument (note the ./)
./process_one_image.sh 8
```

As expected, we got the `polaroid_8.jpg` image.

Now, if you want to use a for loop, you can do:

```bash
for i in $(seq 1 5); do
  ./process_one_image.sh ${i}
done
```

If we prepend the command `time` to the for loop, we can see that it takes just below 3 seconds.

Now let's create a list with the numbers from 1..10:
```bash
rm img_list.txt
for i in $(seq 1 10); do
  echo ${i} >> img_list.txt
done
```

Then we use the `xargs` command to feed all the elements in the img_list.txt file into the script to (download and) process the images

```bash
cat img_list.txt | xargs -n 1 -P 10 -I{} ./process_one_image.sh {}
```

If we prepend the `time` command, we can see that the whole process took about half a second. That is because all the images were downloaded and processed at once.

What are the arguments of `xargs`?
- `-n 1` : this means that we want to pass to the image processing function only value at the time coming from the img_list.txt

- `-P 10` : this is crucial to control how many instances of the image processing function we want to run in parallel. In this case we run them altogether since the process takes very little time. To verify, try running 5 processes at once instead of 10.

- `-I{}` : indicates that the value passed by the cat will also be the argument of `./process_one_image.sh`, and that is why there is also a `{}` at the end.



