# SSDF dockerfiles

## core-devel

Download [NVIDIA Video Codec SDK](https://developer.nvidia.com/nvidia-video-codec-sdk/download), extract to **dockerfiles** folder and rename it to `Video_Codec_SDK`.

```bash
docker build -t ssdf:core-devel -f core-devel.Dockerfile \
  --build-arg USERNAME=ssdf \
  --build-arg VID_CODEC_VER=11.1.5.0 \
  --build-arg FFMPEG_VER=4.4 \
  --build-arg OPENCV_VER=4.5.3 \
  --build-arg VISION_CV_VER=1.15.0 \
  --build-arg IMG_TRANSPORT_PLUGIN_VER=1.14.0 .
```
