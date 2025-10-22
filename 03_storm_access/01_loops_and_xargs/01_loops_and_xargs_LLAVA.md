# For loops and parallel execution - the LLAVA version

## What we will do & Prerequisites
We will learn how to build for loops in bash, and then use them in bash script. Afterwards we will see how we can speed up running all the processes of the loop in parallel using `xargs`.

The task will be to download some random images from the internet, feed them to an LLVM (Large Language and Vision Model) to get the description of their content, and finally produce a polaroid-like version of the images with the description inside the image.

We need to call a python script from bash (the content of which you can inspect in `ask_llava.py` but you need not to care about), therefore I need you to run the following lines first.

```bash
python -m venv venv_ollama_llava
source venv_ollama_llava/bin/activate
pip install pillow ollama
```


## The basic for loop
Many times we need to execute the same function on different elements, for instance applying the same processing to many images, where the only variable is the image name.

In this case we can proceed in two ways:
- writing a function that takes the variable as an arguments and runs it for all value of the variable
- running the function in parallel for all the values of the variable

Let's start with the simplest case: the for loop. The pseudo-code would be something like:

```bash
# don't run this! only pseudo-code
for [i = variable values]; do 
  [something with] ${i}
done
```

For instance you can run:
```bash
for i in $(seq 10 -1 1); do
	echo "$i seconds left..."
  sleep 1
done
```

To put this to work, we will download a few random images from [picsum.photos](https://picsum.photos/) and do some transformations on them.


```bash
# First create an images folder and cd into that. If the directory esists,
# it will not be overwritten
images_dir="$(pwd)/images"
mkdir -p ${images_dir}

# Download the images
n=3

for i in $(seq 1 ${n}); do
  echo "Downloading random image to img${i}.jpg"
  wget -O "${images_dir}/img_${i}.jpg" "https://picsum.photos/600"
  sleep 0.2
done
```


A few notes:

- The indentation is not necessary, but highly recommended for readability.
- Notice also that I echoed the action in the loop. That's also a good practice, for instance for sending it to a log file. 
- You can also just prepend the echo to the entire `wget` command and do a dry run to see whether you got the syntax right.


Now we will use AI to ask what is the content of the images. Specifically we will use [LLAVA](https://ollama.com/library/llava), an LVLM (Large Language and Vision Model) which I have added to our [Ollama](https://ollama.com/) server. Let's see first how to use it for one image:

```bash
ollama run llava "Describe what is in the image in a very short sentence ${images_dir}/img_1.jpg"
```

From now on however, instead of loading the model every time - which is what `ollama run llava ` does - we will use a python script I previously created, which takes image filename and prompt as arguments, and saves the description to a text file in the `images/` directory.

```bash
# wget -O "images/img_1.jpg" "https://picsum.photos/600"
python ask_llava.py "img_1.jpg" "Describe what is in the image in a very short sentence"
cat images/description_img_1.txt
```

Finally, we can add the AI-generated description as a caption of a polaroid image
```bash
convert \
  -font Purisa \
  -caption "$(cat ${images_dir}/description_img_1.txt)" \
  ${images_dir}/img_1.jpg \
  +polaroid \
  ${images_dir}/polaroid_1.jpg
```

Now let's try to write a loop which does this for all images:

```bash
images_dir="$(pwd)/images"
mkdir -p ${images_dir}

# Download the images
n=3

for i in $(seq 1 ${n}); do
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
done
```

Of course we do not want to write all of this every time. We can instead put everything into a script and run that.

You can use `nano` which is a very simple terminal-based text editor.

```bash
# make sure you are in the directory _above_ the `images` folder, then
nano generate_polaroids.sh

# copy/paste the code above and save it

# give execution priviledges
chmod +x generate_polaroids.sh

# execute
./generate_polaroids.sh

# prepending time will also show the execution time
time ./generate_polaroids.sh
```







## Passing arguments
Instead of having the number of images hard-coded inside the script, we can pass it as input to the script by just doing a few modifications to the existing code. 

Copy the previous script to a new one called  `generate_one_polaroid.sh`, still inside the `images` directory.

```bash
cp generate_polaroids.sh generate_one_polaroid.sh
```

And now modify `generate_one_polaroid.sh` as follows:

- add the line `i=$1` at the beginning (we will immediately see what is this for)
- remove the line with `n=3`
- remove the initial and last line of the loop, to leave only the code _inside_ the loop

The result should look like this:

```bash
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
```


the line `i=$1` instructs the script to take the first argument passed to it and assign it to the variable `i` - in this case the image number. Now we can run the script as follows:

```bash
# Call it with an argument (note the ./)
./generate_one_polaroid.sh 8
```

As expected, we got the `polaroid_8.jpg` image.

Now, if you want to use a for loop, you can do:

```bash
for i in $(seq 1 3); do
  ./generate_one_polaroid.sh ${i}
done
```

### Passing arguments from a text file
Instead of passing the numbers generated by `seq`, we can define them in an external file that we can feed to our script line by line. 

Arguably in the present case of numbers 1..3 it is not very useful however imagine that instead of just numbers we would need to pass subjects ID like `s0203`, `s4040`, `s2233` and so on. In this case, using an external text file with all the IDs becomes very handy. 

_NB: This can also be achieved by defining a bash function inside the script and pass a bash array to it. But that's a bit advanced for the moment, so let's use the simpler implementation involving creating an external text file._

First let's generate an `img_list.txt` file with the numbers from 1 to 3, one for each row.

```bash
images_dir="$(pwd)/images"

rm ${images_dir}/img_list.txt

for i in $(seq 1 3); do
  echo ${i} >> ${images_dir}/img_list.txt
done
```

At this point we can feed the `img_list.txt` in our script to generate the polaroids using a for loop:

```bash
for i in $(cat img_list.txt); do
  ./generate_one_polaroid.sh ${i}
done
```


## Parallelising using xargs

The process we implemented for each image is relatively fast. However in real cases, each process could take several minutes if not hours.

It would be therefore very advantageous if we could generate all the images in parallel.

Enter `xargs`. It takes your list of jobs, calmly fans them out across CPUs, and prints a lot of stuff in the terminal (which makes you look like you know your stuff ;).

```bash
cat ${images_dir}/img_list.txt | xargs -n 1 -P 10 -I{} ./generate_one_polaroid.sh {}
```

What are the arguments of `xargs`?
- `-n 1` : this means that we want to pass to the image processing function only value at the time coming from the img_list.txt

- `-P 10` : this is crucial to control how many instances of the image processing function we want to run in parallel. In this case we run them altogether since the process takes very little time. To verify, try running 5 processes at once instead of 10.

- `-I{}` : indicates that the value passed by the cat will also be the argument of `./generate_one_polaroid.sh`, and that is why there is also a `{}` at the end.

# Conclusion: be considerate
If you manage to survive until here, you have learnt a lot of stuff (although you might not yet realize it) and acquired a tremendous power. Specifically the power to run in one day all the the data (pre)processing that would take you one month.

But power comes with responsibilities.

If for instance you want on your 100 datasets a very intensive script - that would take e.g. one day per dataset - it is not a good idea to run 100 process in parallel, for three reasons:

- we have "only" 72 CPUs (threads actually, but whatever), which means that you would not really be running all the 100 at once.

- still, this would clog our server, especially if each process also requires a lot of RAM. In this case you would consume all the computing _and_ memory power and will potentially crash the server (including all the processes being run by your colleagues)

- your colleagues would be very angry at you

So plan carefully your `xargs`. Check `top` or `btop` to see how busy the server is, and as a rule of thumb try not to use more than 25% of the _currently available_ resources on the server. Remember that having 72 CPUs available is a luxury. Don't be greedy and be considerate about the fact that you share this server with many other people.

This - in a nutshell - boils down to deciding the number that you pass to the `-P` argument of your `xargs`.

In some cases, it might not be that easy. For instance if you use [ANTs](https://github.com/ANTsX/ANTs) for image registration - e.g. in [fmirprep](https://fmriprep.org/en/stable/) - be default it takes all the computing power available, and [you need to set a specific environmental variable](https://github.com/ANTsX/ANTs/wiki/Compiling-ANTs-on-Linux-and-Mac-OS#post-installation-control-multi-threading-at-run-time) to prevent this. This is specific to ANTs, and other software will require other methods. This can be difficult to find but, again, it is important.



