# Automatically converts assets from 2x to 1x

import os
from PIL import Image

def downsample_images(input_folder, output_folder):
    os.makedirs(output_folder, exist_ok=True)
    images = [file for file in os.listdir(input_folder) if file.endswith('.png')]
    for file in images:
        image = Image.open(os.path.join(input_folder, file))
        width, height = image.size
        new_width = width // 2
        new_height = height // 2
        downsampled_image = image.resize((new_width, new_height),resample=Image.NEAREST)
        downsampled_image.save(os.path.join(output_folder, file))
        image.close()
    print("Downsampling complete!")

input_folder = "./assets/2x"
output_folder = "./assets/1x"

downsample_images(input_folder, output_folder)