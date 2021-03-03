# EGF + Docker + Jupyter

Docker Jupyter images with (almost) all EGF packages for running them in a Jupyter notebook.


## TLDR

```
docker pull ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest

docker run --rm -p 8888:8888 --name egf-container -e JUPYTER_ENABLE_LAB=yes -e NB_UID=1000 -e NB_GID=1000 -e CHOWN_HOME=yes -e CHOWN_EXTRA_OPTS='-R' --user root -w /home/jovyan/ -v /path/to/notebooks/on/host/:/home/jovyan/ ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest
```

---

## Introduction to Docker

Install Docker then try a Jupyter notebook image.


### 1. Install Docker

Ubuntu: https://docs.docker.com/engine/install/ubuntu/

Mac OS: https://docs.docker.com/docker-for-mac/install/


### 2. Try a Jupyter notebook image

Run the below in a terminal. Pull a standard Jupyter notebook *image:*
```
docker pull jupyter/base-notebook
```

Run the image:
```
docker run -p 8888:8888 jupyter/base-notebook
```
This will create a *container* from the image and start it. Argument `-p` publishes a container's port(s) to the host. You can access the running Jupyter in your browser with the link provided in the output of this command. Check that it works.

---

## Run egf-notebook

In order to download images, we need access to the GHCR (GitHub Container Registry). [Create a personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) (PAT) for ghcr.io, with `read:packages` access. Keep the token private (in a password manager). Log in to GHCR:
```
docker login ghcr.io -u username  # replace with yours, and provide the token in the prompt
```
Pull the image:
```
docker pull ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest
```
You can list images with `docker image ls`. By default, the notebooks and the work are not saved in the host filesystem, therefore we run the notebook image with a couple of options that *bind mount* a directory on the filesystem, and set proper access permissions so that it will remain editable by both Docker (Jupyter) and the OS user:
```
docker run --rm -p 8888:8888 --name egf-container -e JUPYTER_ENABLE_LAB=yes -e NB_UID=1000 -e NB_GID=1000 -e CHOWN_HOME=yes -e CHOWN_EXTRA_OPTS='-R' --user root -w /home/jovyan/ -v /path/to/notebooks/on/host/:/home/jovyan/ ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest
```
Where `NB_UID` and `NB_GID` values are your user and group ids. Obtain them with `cat /etc/passwd` (on Ubuntu); set `/path/to/notebooks/on/host/` to your local working directory. Environment variable `JUPYTER_ENABLE_LAB=yes` is set [in accordance with recommendations](https://github.com/jupyter/docker-stacks#jupyter-notebook-deprecation-notice). Other options used here:
```
-e, --env list               Set environment variables
--name string                Assign a name to the container
-p, --publish list           Publish a container's port(s) to the host
--rm                         Automatically remove the container when it exits
-u, --user string            Username or UID (format: <name|uid>[:<group|gid>])
-w, --workdir string         Working directory inside the container
-v, --volume list            Bind mount a volume
```

---

## Details

The github actions workflow creates an egf-notebook image and uploads privately to ghcr.io.

The Dockerfile builds from a custom base-notebook image, based on `jupyter/base-notebook`, and installs EGF packages as listed in `requirements.txt`, in the way [advised here](https://github.com/docker-library/docs/tree/master/python#how-to-use-this-image).


### Build the custom base-notebook:python-3.6 image

Steps showing how the base image was built are below.
We clone the jupyter/docker-stacks repo into our software directory:
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
# Python 3.6.13
```
Push to ghcr.io:
```
docker push ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/base-notebook:python-3.6
```
We pull this image during the build process.

---

## Alternative approaches

### Local builds

We build the EGF image locally, *in the directory of the cloned repo.*


#### Build the EGF notebook image

We build on top of a custom base-notebook image with Python v3.6, because EGF packages were developed on it:
```
docker build --tag egf-notebook .
```
Then run as shown above with the locally built image: `egf-notebook`.


#### Build from jupyter/base-notebook

Alternatively, build the EGF image directly from the original base image with the latest Python:
replace the first line (`FROM ...`) in the Dockerfile with `FROM jupyter/base-notebook`.
The path to the Dockerfile can be specified with `--file` (or `-f`) if not in current directory.


#### Build with multiple conda environments

See [Contributed Recipes: Add a Python 3.x environment](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#add-a-python-3-x-environment). However, this approach didn't work as the Python kernel was not visible in JupyterLab.


### Using image files on hard disk

**Save**: `docker save egf-notebook:latest | gzip > egfnotebook_latest.tar.gz`

**Load**:
```
gunzip egfnotebook_latest.tar.gz
docker image load --input egfnotebook_latest.tar
```
