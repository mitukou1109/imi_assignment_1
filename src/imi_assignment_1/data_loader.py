import glob
import os

import numpy as np
import PIL.Image


class DataLoader:
    def __init__(self, dir: str) -> None:
        self._data: np.ndarray = None
        self._pattern_shape: tuple = None
        self._pattern_names: list[str] = []
        self._rng = np.random.default_rng()

        for img_file in [
            f for f in glob.glob(os.path.join(dir, "*")) if os.path.isfile(f)
        ]:
            img = np.array(PIL.Image.open(img_file).convert("1"), dtype=np.int8) * 2 - 1
            self._pattern_names.append(os.path.splitext(os.path.basename(img_file))[0])
            if self._data is None:
                self._data = img.ravel()[np.newaxis]
                self._pattern_shape = img.shape
            else:
                self._data = np.vstack([self._data, img.ravel()])

    def __call__(self) -> np.ndarray:
        return self._data

    def __getitem__(self, key: int | slice | str) -> np.ndarray:
        if isinstance(key, str):
            return self._data[self._pattern_names.index(key)]
        else:
            return self._data[key]

    def random_choice(self) -> tuple[np.ndarray, str]:
        index = self._rng.integers(self.num_patterns())
        return self._data[index], self._pattern_names[index]

    def num_patterns(self) -> int:
        return self._data.shape[0]

    def pattern_size(self) -> int:
        return self._data.shape[1]

    def pattern_shape(self) -> tuple:
        return self._pattern_shape

    def pattern_names(self) -> list[str]:
        return self._pattern_names
