# EGF + Docker + Jupyter

![version](https://img.shields.io/badge/current_version-0.2.1-blue)

Docker Jupyter images with (almost) all EGF packages for running them in a Jupyter notebook.

## TLDR

Build the EGF image locally, *in the directory of the cloned repo:*

```shell
docker build --tag egf-notebook .
```

To run the image, switch to a working directory, then:

```shell
docker run --rm -p 8888:8888 --name egf-container -e JUPYTER_ENABLE_LAB=yes -e NB_UID=1000 \
    -e NB_GID=1000 -e CHOWN_HOME=yes -e CHOWN_EXTRA_OPTS='-R' --user root -w /home/jovyan/ \
    -v /path/to/notebooks/on/host:/home/jovyan/ egf-notebook
```

* Change `NB_UID` and `NB_GID` values to your user and group ids. You can obtain them with `cat /etc/passwd` (on Ubuntu);
* Change `/path/to/notebooks/on/host/` to your local working directory.

Environment variable `JUPYTER_ENABLE_LAB=yes` is set [in accordance with recommendations](https://github.com/jupyter/docker-stacks#jupyter-notebook-deprecation-notice). Other options used here:

```shell
-e, --env list               Set environment variables
--name string                Assign a name to the container
-p, --publish list           Publish a container's port(s) to the host
--rm                         Automatically remove the container when it exits
-u, --user string            Username or UID (format: <name|uid>[:<group|gid>])
-w, --workdir string         Working directory inside the container
-v, --volume list            Bind mount a volume
```

See details [here for EGF staff members](EGF_readme.md).

---

## Details

The github actions workflow creates an egf-notebook image and uploads privately to ghcr.io.

The Dockerfile builds from a base-notebook image, based on `jupyter/base-notebook`, and installs EGF packages as listed in `requirements.txt`, in the way [advised here](https://github.com/docker-library/docs/tree/master/python#how-to-use-this-image).

See instructions [here for building with a custom base-notebook, or using image files on hard disk](EGF_readme.md).

You can list images with `docker image ls`. By default, the notebooks and the work are not saved in the host filesystem, therefore we run the notebook image with a couple of options that *bind mount* a directory on the filesystem, and set proper access permissions so that it will remain editable by both Docker (Jupyter) and the OS user.

## Introduction to Docker

Install Docker, then try a Jupyter notebook image.

### 1. Install Docker

Ubuntu: https://docs.docker.com/engine/install/ubuntu/

Mac OS: https://docs.docker.com/docker-for-mac/install/

### 2. Try a Jupyter notebook image

Run the below in a terminal. Pull a standard Jupyter notebook *image:*

```shell
docker pull jupyter/base-notebook
```

Run the image:

```bash
docker run -p 8888:8888 jupyter/base-notebook
```

This will create a *container* from the image and start it. Argument `-p` publishes a container's port(s) to the host. You can access the running Jupyter in your browser with the link provided in the output of this command. Check that it works.

### Using image files on hard disk

**Save**: `docker save egf-notebook:latest | gzip > egfnotebook_latest.tar.gz`

**Load**:

```bash
gunzip egfnotebook_latest.tar.gz
docker image load --input egfnotebook_latest.tar
```
