## TLDR

```shell
docker pull ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest

docker run --rm -p 8888:8888 --name egf-container -e JUPYTER_ENABLE_LAB=yes -e NB_UID=1000 -e NB_GID=1000 -e CHOWN_HOME=yes -e CHOWN_EXTRA_OPTS='-R' --user root -w /home/jovyan/ -v /path/to/notebooks/on/host/:/home/jovyan/ ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest
```

This works only for EGF members. Replace `edinburgh-genome-foundry` with your GHCR (GitHub Container Registry) username.

---

## Download egf-notebook

In order to download images, we need access to the GHCR (GitHub Container Registry). [Create a personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) (PAT) for ghcr.io, with `read:packages` access. Keep the token private (in a password manager). Log in to GHCR:

```shell
docker login ghcr.io -u username  # replace with yours, and provide the token in the prompt
```

Pull the image:

```shell
docker pull ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/egf-notebook:latest
```

## Build the EGF notebook image

### Build the custom base-notebook:python-3.6 image

The Dockerfile can build from a custom base-notebook image, based on `jupyter/base-notebook`. The first version of the project used this method, but this is not required anymore as all packages have been updated to work with Python 3.9.

Steps showing how the base image was built are below.
We clone the jupyter/docker-stacks repo into our software directory:

```shell
git clone https://github.com/jupyter/docker-stacks.git
cd docker-stacks
```

Then [build a Python-3.6 image](https://github.com/jupyter/docker-stacks/issues/1208#issuecomment-755907605):

```shell
docker build --rm --force-rm \
    -t jupyter/base-notebook:python-3.6 ./base-notebook \
    --build-arg PYTHON_VERSION=3.6
```

Test:

```shell
docker run --rm -t jupyter/base-notebook:python-3.6 python --version
# Python 3.6.13
```

Push to ghcr.io:

```shell
docker push ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/base-notebook:python-3.6
```

Now we can pull this image during the build process.

### Build egf-notebook

#### Build egf-notebook using the custom base image

Previously, we built on top of a custom base-notebook image with Python v3.6, because EGF packages were developed on it:

```shell
docker build --tag egf-notebook .
```

Then ran as shown above with the locally built image: `egf-notebook`.

#### Build from jupyter/base-notebook

Alternatively, build the EGF image directly from the original base image with the latest Python:
replace the first line (`FROM ...`) in the Dockerfile with `FROM jupyter/base-notebook`.
The path to the Dockerfile can be specified with `--file` (or `-f`) if not in current directory.

#### Build with multiple conda environments

See [Contributed Recipes: Add a Python 3.x environment](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#add-a-python-3-x-environment). However, this approach didn't work as the Python kernel was not visible in JupyterLab.
