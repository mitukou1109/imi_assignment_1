import numpy as np

_rng = np.random.default_rng()


def apply_noise(x: np.ndarray, prob: float):
    return np.where(_rng.random(x.shape) >= prob, x, _rng.choice([1, -1]))
