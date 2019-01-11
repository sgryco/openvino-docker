#!/bin/bash
set -e
source /opt/intel/computer_vision_sdk/bin/setupvars.sh

cd $(dirname $0)
# Convert and optimize the onnx model
python3 /opt/intel/computer_vision_sdk/deployment_tools/model_optimizer/mo.py --input_model Modelpotatoestomatoes_softmax.onnx --output_dir ir --data_type FP16

# run example application

python3 classify_pomatoes.py -d MYRIAD -m ir/Modelpotatoestomatoes_softmax.xml --labels pomatoes.labels -nt 1 -i tomatoes_potatoes_images/*
