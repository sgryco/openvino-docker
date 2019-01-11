# OpenVino docker and application example
These steps will install openvino in a docker container and will run a squeezenet demo on an
Intel CPU and on a NCS.
## Install docker-ce
```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
# reload user groups
exec su -l $USER
```
## Build the docker image
Run:
```
./build.sh
```

## Add the USB access rights
```
cat <<EOF > 97-usbboot.rules
SUBSYSTEM=="usb", ATTRS{idProduct}=="2150", ATTRS{idVendor}=="03e7", GROUP="users", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
SUBSYSTEM=="usb", ATTRS{idProduct}=="2485", ATTRS{idVendor}=="03e7", GROUP="users", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
SUBSYSTEM=="usb", ATTRS{idProduct}=="f63b", ATTRS{idVendor}=="03e7", GROUP="users", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
EOF
sudo mv 97-usbboot.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo ldconfig
```
## Test OpenVino on an Intel CPU
```
./demo_cpu.sh
```

## Test OpenVino on a NCS
```
./demo_myriad.sh
```


# Training our own classifier and running the inference on the Neural compute stick
Here, we will see how to train a custom image classifier and run it on the NCS.
## Setup fast.ai
See [fastai-docker](https://github.com/sgryco/fastaidocker)

## Potatoes/Tomatoes dataset
The `potatoestomatoes` dataset can be downloaded from
 [here](https://drive.google.com/file/d/18HKti6EaXHkT2NFCJFEbI297yCbrYzGP/view?usp=sharing).


## Training
Train the network and export it to Onnx using the notebook:
`lesson1_export_to_onnx-pomatoes.ipynb`

To get the notbook working, copy it to the `fastai/courses/dl1` folder.

## Inference
* Model
Copy the Onnx model to `code/pomatoes/Modelpotatoestomatoes_softmax.onnx` in this repository
* Labels
Edit the file named `code/pomatoes/pomatoes.labels`, checking that each line contains the
 correct category.
* Preprocessing
Edit the file named `code/pomatoes/classify_pomatoes.py`, verify that the variables
`resnet_mean` and `resnet_scale` have the correct values
* Run
Plug in an NCS, and run:
```
./run_with_usb.sh pomatoes/pomatoes.sh
```
This script will first convert the model to run on the NCS with OpenVino and then run the
 inference on the images located in `code/pomatoes/tomatoes_potatoes_images`




