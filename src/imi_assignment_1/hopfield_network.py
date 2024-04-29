import numpy as np


class HopfieldNetwork:
    def __init__(self, num_neurons: int) -> None:
        self._num_neurons = num_neurons
        self._weight = np.zeros((num_neurons, num_neurons))
        self._state = np.zeros(num_neurons)
        self._threshold = np.zeros(num_neurons)
        self._rng = np.random.default_rng()

    def __call__(self) -> float:
        index = self._rng.integers(self._num_neurons)
        self._state[index] = np.sign(
            np.dot(self._weight[index], self._state) - self._threshold[index]
        )
        return -np.dot(self._weight @ self._state, self._state) / 2 + np.dot(
            self._threshold, self._state
        )

    def set_weight(self, weight: np.ndarray) -> None:
        self._weight = weight.copy()
        np.fill_diagonal(self._weight, 0)

    def set_threshold(self, threshold: np.ndarray) -> None:
        self._threshold = threshold

    def set_state(self, state: np.ndarray) -> None:
        self._state = state.copy()

    def get_state(self) -> np.ndarray:
        return self._state

    def get_threshold(self) -> np.ndarray:
        return self._threshold
