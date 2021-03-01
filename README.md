# EGF + Docker + Jupyter

Docker Jupyter images with (almost) all EGF packages for running them in a Jupyter notebook.

1. Install Docker
2. Try a Jupyter notebook image
3. Build & run the EGF notebook image


## Setup

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
docker run -p 8888:8888 jupyter/minimal-notebook
```
This will create a *container* from the image and start it. Argument `-p` publishes a container's port(s) to the host. You can access the running Jupyter in your browser with the link provided in the output of this command. Check that it works.


### 3. Build & run the EGF notebook image

Build the EGF image from the directory where `Dockerfile` is:
```
docker build --tag egf-notebook .
```
(The path can also be specified with argument `-f` or `--file` if not in current directory.)


By default, the notebooks and the work are not saved in the host filesystem, therefore we run the notebook with a couple of options that *bind mount* a directory on the filesystem, and set proper access permissions so that it will remain editable by both Docker (Jupyter) and the OS user:
```
docker run --rm -p 8888:8888 --name egf-notebook -e NB_UID=1001 -e NB_GID=1001 -e CHOWN_HOME=yes -e CHOWN_EXTRA_OPTS='-R' --user root -w /home/jovyan/ -v /path/to/notebooks/on/host/:/home/jovyan/ egf-notebook
```
Where `NB_UID` and `NB_GID` values are your user and group ids. Obtain with `cat /etc/passwd` (on Ubuntu); `egf-notebook` is the image name, as specified during build. List images with `docker image ls`. Other options used here:
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

The Dockerfile uses the `jupyter/minimal-notebook` image and installs EGF packages as listed in `requirements.txt`,in the way [advised here](https://github.com/docker-library/docs/tree/master/python#how-to-use-this-image).
