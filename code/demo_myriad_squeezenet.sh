#!/bin/bash

# Copyright (c) 2018 Intel Corporation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


error() {
    local code="${3:-1}"
    if [[ -n "$2" ]];then
        echo "Error on or near line $1: $2; exiting with status ${code}"
    else
        echo "Error on or near line $1; exiting with status ${code}"
    fi
    exit "${code}"
}
trap 'error ${LINENO}' ERR

target="MYRIAD"
target_precision="FP16"

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


models_path="$HOME/openvino_models/models/${target_precision}"
irs_path="$HOME/openvino_models/ir/${target_precision}/"

model_name="squeezenet"
model_version="1.1"
model_type="classification"
model_framework="caffe"
dest_model_proto="${model_name}${model_version}.prototxt"
dest_model_weights="${model_name}${model_version}.caffemodel"

model_dir="${model_type}/${model_name}/${model_version}/${model_framework}"
ir_dir="${irs_path}/${model_dir}"

proto_file_path="${models_path}/${model_dir}/${dest_model_proto}"
weights_file_path="${models_path}/${model_dir}/${dest_model_weights}"

target_image_path="$ROOT_DIR/car.png"

source /opt/intel/computer_vision_sdk/bin/setupvars.sh

# Step 1. Download the Caffe model and the prototxt of the model
printf "${dashes}"
printf "\n\nDownloading the Caffe model and the prototxt"

cur_path=$PWD

downloader_path="${INTEL_CVSDK_DIR}/deployment_tools/model_downloader/downloader.py"

printf "\nRun $downloader_path --name ${model_name}${model_version} --output_dir ${models_path}\n\n"
$python_binary $downloader_path --name ${model_name}${model_version} --output_dir ${models_path};

  
# Step 3. Convert a model with Model Optimizer
printf "${dashes}"
printf "Convert a model with Model Optimizer\n\n"

mo_path="${INTEL_CVSDK_DIR}/deployment_tools/model_optimizer/mo.py"

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
$python_binary $mo_path --input_model ${weights_file_path} --output_dir $ir_dir --data_type $target_precision


# Step 4. Build samples
printf "${dashes}"
printf "Build Inference Engine samples\n\n"

samples_path="${INTEL_CVSDK_DIR}/deployment_tools/inference_engine/samples"
build_dir="$HOME/inference_engine_samples"
binaries_dir="${build_dir}/intel64/Release"
mkdir -p $build_dir
cd $build_dir
cmake -DCMAKE_BUILD_TYPE=Release $samples_path
make -j8 classification_sample

# Step 5. Run samples
printf "${dashes}"
printf "Run Inference Engine classification sample\n\n"

cd $binaries_dir

cp -f $ROOT_DIR/${model_name}${model_version}.labels ${ir_dir}/

printf "Run ./classification_sample -d $target -i $target_image_path -m ${ir_dir}/${model_name}${model_version}.xml ${sampleoptions}\n\n"
./classification_sample -d $target -i $target_image_path -m "${ir_dir}/${model_name}${model_version}.xml" ${sampleoptions}

printf "${dashes}"
printf "Demo completed successfully.\n\n"
