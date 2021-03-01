FROM jupyter/minimal-notebook
USER jovyan

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
