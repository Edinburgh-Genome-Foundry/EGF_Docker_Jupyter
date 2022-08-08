FROM jupyter/base-notebook:python-3.9.12
# This actually uses Python v3.9.13
# not using a custom image as that cannot be downloaded without EGF GHCR access
# See details: https://github.com/jupyter/docker-stacks/issues/1763
###############################################################################
# This section is from CUBA:
# The next lines install wkhtmltopdf (for Caravagene)
ENV QT_QPA_PLATFORM offscreen
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
USER root
RUN apt-get update
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin/
RUN ln -nfs /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
# ENV QT_QPA_FONTDIR=/usr/share/fonts
RUN apt-get install -y fontconfig libfontconfig1 libfreetype6 libx11-6 libxext6 libxrender1
RUN apt-get install -y xfonts-base xfonts-75dpi fonts-font-awesome fonts-lato
RUN apt-get install -y xvfb

RUN apt-get install -y graphviz graphviz-dev libgraphviz-dev
# The next line installs NCBI BLAST (for GeneBlocks, DNAWeaver, etc.)
RUN apt-get install -y ncbi-blast+
# The next line enables to build NumberJack (used by GoldenHinges)
RUN apt-get install -y python-dev libxml2-dev zlib1g-dev libgmp-dev
# Ubuntu 20.04 has swig version 4 but we need version 3 to install Numberjack properly:
RUN apt-get remove -y swig
RUN apt-get install -y swig3.0
RUN ln /usr/bin/swig3.0 /usr/bin/swig
# For python-Levenshtein:
RUN apt-get install -y gcc python3-dev
RUN apt-get install -y libxslt1-dev g++
# For PDF reports:
RUN apt-get install -y fonts-inconsolata
###############################################################################
# Numberjack is built from source because pip doesn't install it properly:
USER jovyan
RUN wget https://github.com/Edinburgh-Genome-Foundry/Numberjack/archive/v1.2.0.tar.gz
RUN tar -zxvf v1.2.0.tar.gz
WORKDIR $HOME/Numberjack-1.2.0
RUN python setup.py build -solver Mistral
RUN python setup.py install

# Default cannot find graphviz so path is specified:
RUN pip install pygraphviz==1.5 --install-option="--include-path=/usr/include/graphviz" --install-option="--library-path=/usr/lib/x86_64-linux-gnu/graphviz"
# For proglog:
RUN pip install ipywidgets

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
########################################################################################
# Opencontainer labels
LABEL org.opencontainers.image.title="egf-notebook"
LABEL org.opencontainers.image.description="Docker Jupyter images with (almost) all EGF packages"
LABEL org.opencontainers.image.url="https://github.com/edinburgh-genome-foundry/egf_docker_jupyter"
LABEL org.opencontainers.image.documentation="https://github.com/edinburgh-genome-foundry/egf_docker_jupyter"
LABEL org.opencontainers.image.source="https://github.com/edinburgh-genome-foundry/egf_docker_jupyter"
LABEL org.opencontainers.image.vendor="edinburgh-genome-foundry"
LABEL org.opencontainers.image.authors="Peter Vegh"
LABEL org.opencontainers.image.revision="v0.2.0"
