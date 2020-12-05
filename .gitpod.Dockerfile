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

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py > get-poetry.py && \
    python get-poetry.py --version ${POETRY_VERSION}

RUN rm -f get-poetry.py

RUN sudo groupadd -g 1002 poetry && \
    sudo useradd -u 1001 -g poetry -d /home/poetry -M poetry

RUN sudo mkdir /home/poetry && \
    sudo mv /home/gitpod/.poetry /home/poetry/.poetry

ENV PATH=$PATH:/home/poetry/.poetry/bin

RUN sudo chown -R poetry:poetry /home/poetry

COPY poetry.lock pyproject.toml ./

RUN poetry config virtualenvs.create false \
 && poetry install --no-interaction --no-ansi --no-dev


#RUN git clone https://github.com/facebook/rocksdb.git
#RUN cd rocksdb && make build && cd build && cmake ..
#RUN export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:`pwd`/../include
#RUN export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:`pwd`
#RUN export LIBRARY_PATH=${LIBRARY_PATH}:`pwd`
