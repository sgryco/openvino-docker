docker run --net=host --rm -it --privileged -v /dev:/dev -v $PWD/code/:/app openvino $@

