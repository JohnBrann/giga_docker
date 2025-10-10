# GIGA Docker Setup

This repository provides a setup for running the GIGA inference inside a Docker container.

Pre-built image is hosted on Docker Hub (coming soon):

```bash
docker pull johnbrann/giga
```

Contains:

- The ability to produce grasps on a scene using GIGA's pretrained models
- The ability to train a new GIGA model
## Requirements

- Docker and/or Docker Compose installed on a Linux machine
- Not tested outside of Linux, instructions are for Ubuntu but should work on any machine capable of running Docker

## Setup Instructions

### 1. Installing Docker & Compose on your machine

```bash
sudo apt update
sudo apt install docker.io docker-compose
```

### 2. Clone the repository

```bash
git clone https://github.com/JohnBrann/giga_docker
cd giga_docker
```

### 3. Start the container

```bash
docker-compose up -d
```

Then enter the container:

```bash
docker exec -it giga bash
```

#### 3.1 (Optional alternative: no docker compose)
If you do not wish to use docker compose but still don't want to build the image yourself:

<pre>
# Enable X11 access from Docker containers
xhost +local:docker

# Run the container
docker run -it --rm --gpus all \
  --net=host \
  -v "$HOME/GIGA/data:/GIGA/data:rw" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -e DISPLAY=$DISPLAY \
   giga bash 
</pre>

#### 3.2  (Optional alternative: local image build)
Lastly, if you wish to build the docker image yourself:

<pre>
# Build the image
docker build -t giga:latest .

# Enable X11 access from Docker containers
xhost +local:docker
  
# Run the container
docker run -it --rm --gpus all \
  --net=host \
  -v "$HOME/GIGA/data:/GIGA/data:rw" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -e DISPLAY=$DISPLAY \
   giga bash 
</pre>

### 4. Generate Grasps

Inside the container:

```bash
python3 scripts/sim_grasp_multiple.py --num-view 1 --object-set pile/test --scene pile --num-rounds 100 --sideview --add-noise dex --force --best --model /GIGA/data/models/giga_pile.pt   --type giga   --result-path /results/ --sim-gui
```

This will perform simulated grasps in pybullet

## Download Models and Data
  You will need to modify the mounted location of the model checkpoints in the run commands above. It does not matter the directory at which these files are located on your system, as long as they mounted into the docker workspace it should work. If you are using docker compose, put the data folder in giga_docker. You can also modify the mounted volume location in docker-compose.yml

### Model
Download trained models from [here](https://utexas.app.box.com/s/h3ferwjhuzy6ja8bzcm3nu9xq1wkn94s)


## Troubleshooting: Reset Docker Environment

To fully reset Docker:

```bash
docker ps -q | xargs -r docker stop
docker ps -aq | xargs -r docker rm
docker images -q | xargs -r docker rmi
```

To remove just this image:

```bash
docker stop arm_driver_ws
docker rm arm_driver_ws
docker rmi flynnbm/arm_driver_ws:jazzy
```

## Future Improvements

- 
