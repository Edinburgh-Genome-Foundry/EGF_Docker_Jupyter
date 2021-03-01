FROM jupyter/base-notebook:python-3.6
USER jovyan

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
