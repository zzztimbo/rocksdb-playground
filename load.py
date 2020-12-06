import random
import uuid

import numpy as np
import pandas as pd
import rocksdb

from loguru import logger

def _random_embedding():
    return np.array([random.uniform(-1, 1) for _ in range(128)])


def _write_feather_with_random_embeddings():
    upc_df = pd.read_csv("distinct_upc_numbers_2020_09_23.csv")
    logger.debug(upc_df)
    logger.debug(_random_embedding())
    logger.debug(_random_embedding().shape)
    upc_df["embedding"] = upc_df.apply(lambda x: _random_embedding(), axis=1)
    upc_df.to_feather("upc_embeddings.feather")


def _read_feather_with_embeddings():
    _df = pd.read_feather('upc_embeddings.feather')
    return _df


def _load_rocksdb_with_embeddings(_db, _size):
    for _ in range(_size):
        _db.put(str.encode(str(uuid.uuid1())), _random_embedding().tobytes())


def _import_df_2_rocksdb(_db, _df):
    for index, row in _df.iterrows():
        upc_number = row['upc_number']
        embedding = row['embedding']

        _db.put(str.encode(str(upc_number)), embedding.tobytes())


if __name__ == "__main__":
    _db = rocksdb.DB("test.db", rocksdb.Options(create_if_missing=True))
    # _df = _read_feather_with_embeddings()

    _load_rocksdb_with_embeddings(_db, 100000)
    # _import_df_2_rocksdb(_db, _df)

    # 1154613188
    # logger.debug(np.frombuffer(_db.get(str.encode("999221"))))

    it = _db.iterkeys()
    it.seek_to_first()
    all_keys = list(it)
    # # logger.debug(all_keys)
    logger.debug(len((all_keys)))

    logger.debug(all_keys[234])

    # logger.debug(np.frombuffer(_db.get(b'90e107c6-fddf-11ea-ae53-acde48001122')))
