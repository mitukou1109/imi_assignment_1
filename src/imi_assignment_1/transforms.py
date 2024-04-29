import numpy as np

_rng = np.random.default_rng()


def apply_noise(x: np.ndarray, prob: float) -> np.ndarray:
    return np.where(_rng.random(x.shape) >= prob, x, _rng.choice([1, -1], size=x.shape))
