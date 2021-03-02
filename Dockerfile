FROM ghcr.io/edinburgh-genome-foundry/egf_docker_jupyter/base-notebook@sha256:205ebe88f56a77bfe5c8c901f86ad59befe26e8e7f80de63ceae4824871f5838


############################
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
RUN apt-get install -y python-dev swig libxml2-dev zlib1g-dev libgmp-dev
# For python-Levenshtein:
RUN apt-get install -y gcc python3-dev
# Numberjack is veeery slow to install,
# It has its own Docker line so changes in other lines don't reinstall it:
USER jovyan
RUN pip install Numberjack
# Default cannot find graphviz so path is specified:
RUN pip install pygraphviz==1.5 --install-option="--include-path=/usr/include/graphviz" --install-option="--library-path=/usr/lib/x86_64-linux-gnu/graphviz"
############################

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# First import downloads the datasets:
RUN python -c "import tatapov"
