# EGF + Docker + Jupyter

Docker Jupyter images with (almost) all EGF packages for running them in a Jupyter notebook.


## Introduction

1. Install Docker
2. Try a Jupyter notebook image


### 1. Install Docker

Ubuntu: https://docs.docker.com/engine/install/ubuntu/

Mac OS: https://docs.docker.com/docker-for-mac/install/


### 2. Try a Jupyter notebook image

Run the below in a terminal. Pull a standard Jupyter notebook *image:*
```
docker pull jupyter/minimal-notebook
```

Run the image:
```
docker run -p 8888:8888 jupyter/base-notebook
```
This will create a *container* from the image and start it. Argument `-p` publishes a container's port(s) to the host. You can access the running Jupyter in your browser with the link provided in the output of this command. Check that it works.


## Setup

### Build the EGF notebook image

First we build a custom base image with Python 3.6 (because EGF packages were developed on it), then build another image on top of that, one that contains our packages. We clone the repo into our software directory:
```
git clone https://github.com/jupyter/docker-stacks.git
cd docker-stacks
```
Then [build a Python-3.6 image](https://github.com/jupyter/docker-stacks/issues/1208#issuecomment-755907605):
```
docker build --rm --force-rm \
	-t jupyter/base-notebook:python-3.6 ./base-notebook \
	--build-arg PYTHON_VERSION=3.6
```
Test:
```
docker run --rm -t jupyter/base-notebook:python-3.6 python --version
# Python 3.6.12
```

Build the EGF image *from this repo:*
```
docker build --tag egf-notebook:python-3.6 .
```


### Run the EGF notebook image

By default, the notebooks and the work are not saved in the host filesystem, therefore we run the notebook with a couple of options that *bind mount* a directory on the filesystem, and set proper access permissions so that it will remain editable by both Docker (Jupyter) and the OS user:
```
docker run --rm -p 8888:8888 --name egf-container -e JUPYTER_ENABLE_LAB=yes -e NB_UID=1000 -e NB_GID=1000 -e CHOWN_HOME=yes -e CHOWN_EXTRA_OPTS='-R' --user root -w /home/jovyan/ -v /path/to/notebooks/on/host/:/home/jovyan/ egf-notebook:python-3.6
```
Where `NB_UID` and `NB_GID` values are your user and group ids. Obtain with `cat /etc/passwd` (on Ubuntu); set `/path/to/notebooks/on/host/` to your local working directory; `egf-notebook:python-3.6` is the image name, as specified during build. Environment variable `JUPYTER_ENABLE_LAB=yes` is set [in accordance with recommendations](https://github.com/jupyter/docker-stacks#jupyter-notebook-deprecation-notice). List images with `docker image ls`. Other options used here:
```
-e, --env list               Set environment variables
--name string                Assign a name to the container
-p, --publish list           Publish a container's port(s) to the host
--rm                         Automatically remove the container when it exits
-u, --user string            Username or UID (format: <name|uid>[:<group|gid>])
-w, --workdir string         Working directory inside the container
-v, --volume list            Bind mount a volume
```


## Details

The Dockerfile uses the `jupyter/base-notebook` image and installs EGF packages as listed in `requirements.txt`, in the way [advised here](https://github.com/docker-library/docs/tree/master/python#how-to-use-this-image).


## Alternative builds

Build the EGF image directly from the original base image with the latest Python:
```
docker build --file ./other_versions/Dockerfile_for_std_image --tag egf-notebook .
```
The path to Dockerfile was specified with `--file` (or `-f`) as it is not in the current directory.
