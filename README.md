# docker-mtga

<img src="images/magic.png">

The docker image that allows you to play Magic The Gathering Arena on Linux

Basically I got tired of deleting and cleaning up the MTGA Install every time the MTGALauncher needs to update itself, which in most of the cases breaks Wine Installation


## Installation

```bash
git clone https://github.com/yeltcinBorja/docker-mtga.git
cd docker-mtga
docker build -t yeltcinBorja/docker-mtga .
```

## Usage

Allow X11 comms between the host and docker-container
```bash
xhost +Local:*
```

Specify where you want to Download all the Game Assets and Files to (~10GB of Data), in my case its the same folder as Dockerfile/MTGA_Downloads/ (this will be permanently mapped to the game so you dont have to re-download all the data everytime you restart the docker-container)
```bash
mkdir MTGA_Downloads
```

Run Docker
```bash
docker run -v ./MTGA_Downloads:/home/mtga/.wine64_new/drive_c/Program\ Files/Wizards\ of\ the\ Coast/MTGA/MTGA_Data/Downloads \
-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
-v ~/.config/pulse/cookie:/root/.config/pulse/cookie \
--device /dev/dri \
--device /dev/snd \
--env="DISPLAY" \
--net=host \
-it yeltcinBorja/docker-mtga /bin/bash
```

Use bash-script with above
```bash
bash run_docker-mtga
```

## Docker run Parameters

```bash
-v ./MTGA_Downloads:/home/mtga/.wine64_new/drive_c/Program\ Files/Wizards\ of\ the\ Coast/MTGA/MTGA_Data/Downloads
```
Maps the volume where Downloads folder will go, you need this to permanently keep your downloaded Assets and Data to avoid re-downloading it every time you start the docker-container

```bash
-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native 
-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native 
-v ~/.config/pulse/cookie:/root/.config/pulse/cookie 
--device /dev/snd 
```
This will allow sound be played on the host from docker-container (Assuming you run PuseAudio)

```bash
--device /dev/dri
```
This will allow docker-container use your graphics card (OpenGL and drivers)

```bash
--env="DISPLAY"
--net=host
```
X11 Communications between host and docker-container

## Playing MTGA

To start MTGA inside the docker-container
```bash
wine MTGA.exe
```
