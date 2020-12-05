FROM gitpod/workspace-full:latest

ENV POETRY_VERSION=1.1.4

RUN sudo apt-get update -y --fix-missing \
    && sudo apt-get install -y \
       build-essential \
       curl \
       libgflags-dev \
       libsnappy-dev \
       zlib1g-dev \
       libbz2-dev \
       liblz4-dev

ENV LD_LIBRARY_PATH=/usr/local/lib \
    PORTABLE=1

RUN cd /tmp \
    && sudo mkdir -p /usr/local/lib/pkgconfig \
    && curl -sL rocksdb.tar.gz https://github.com/facebook/rocksdb/archive/v6.13.3.tar.gz > rocksdb.tar.gz \
    && tar fvxz rocksdb.tar.gz \
    && cd rocksdb-6.13.3 \
    && sudo make shared_lib \
    && sudo make install-shared

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py > get-poetry.py && \
    python get-poetry.py --version ${POETRY_VERSION}

RUN rm -f get-poetry.py

RUN sudo groupadd -g 1002 poetry && \
    sudo useradd -u 1001 -g poetry -d /home/poetry -M poetry

RUN sudo mkdir /home/poetry && \
    sudo mv /home/gitpod/.poetry /home/poetry/.poetry

ENV PATH=$PATH:/home/poetry/.poetry/bin

COPY poetry.lock pyproject.toml ./

RUN poetry config virtualenvs.create false \
 && poetry install --no-interaction --no-ansi --no-dev
