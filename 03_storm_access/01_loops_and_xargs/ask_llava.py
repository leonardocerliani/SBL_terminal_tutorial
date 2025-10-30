#!/usr/bin/env python3
import os
import sys
from PIL import Image
import ollama

# Ensure two arguments are passed
if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <image_filename> <instruction>")
    sys.exit(1)

file_name = sys.argv[1]
instruction = sys.argv[2]

# Path to the images directory
images_location = os.path.join(os.getcwd(), "images")
file_path = os.path.join(images_location, file_name)

# Check if the image exists
if not os.path.isfile(file_path):
    print(f"Error: {file_path} not found.")
    sys.exit(1)

def generate_text(instruction, file_path):
    # Generate text using ollama
    result = ollama.generate(
        model='llava',
        prompt=instruction,
        images=[file_path],
        stream=False
    )['response']

    # Output file inside images/, following your convention
    image_stem = os.path.splitext(file_name)[0]  # e.g. "img_1"
    output_file = os.path.join(
        images_location, f"description_{image_stem}.txt"
    )

    # Write result to file
    with open(output_file, "w") as f:
        for i in result.split('.'):
            f.write(i)
            print(i)

    # print(f"Description saved to {output_file}")

generate_text(instruction, file_path)
