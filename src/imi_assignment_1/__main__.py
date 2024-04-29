import sys

import matplotlib
import matplotlib.axes
import matplotlib.gridspec
import matplotlib.pyplot as plt
import numpy as np

from . import transforms
from .data_loader import DataLoader
from .hopfield_network import HopfieldNetwork

noise_prob = 0.5
max_steps = 1e3
energy_balance_duration = 100
epsilon = 1e0
attempts = 100

visualize = True

assert len(sys.argv) > 1, "Specify a directory containing images to load"

data = DataLoader(sys.argv[1])

net = HopfieldNetwork(data.pattern_size())

net.set_weight(data().T @ data() / data.num_patterns())

for _ in range(attempts):
    original = data.random_choice()
    initial_state = transforms.apply_noise(original, noise_prob)
    net.set_state(initial_state)
    energy_history = []

    if visualize:
        fig, axs = plt.subplots(2, 3)
        bottom_gs: matplotlib.gridspec.GridSpec = axs[1, 0].get_gridspec()
        for ax in axs[1, :]:
            ax.remove()

        initial_state_ax: matplotlib.axes.Axes = axs[0, 0]
        initial_state_ax.imshow(
            initial_state.reshape(data.pattern_shape()), cmap="gray"
        )
        initial_state_ax.set_title("Initial state")
        initial_state_ax.axis("off")

        net_state_ax: matplotlib.axes.Axes = axs[0, 1]
        net_state_img = net_state_ax.imshow(
            net.get_state().reshape(data.pattern_shape()), cmap="gray"
        )
        net_state_ax.set_title("Network state")
        net_state_ax.axis("off")

        net_state_ax: matplotlib.axes.Axes = axs[0, 2]
        net_state_ax.imshow(original.reshape(data.pattern_shape()), cmap="gray")
        net_state_ax.set_title("Original image")
        net_state_ax.axis("off")

        energy_history_ax: matplotlib.axes.Axes = fig.add_subplot(bottom_gs[1, 0:])
        (energy_history_line,) = energy_history_ax.plot(energy_history)
        energy_history_ax.set_xlabel("Time")
        energy_history_ax.set_ylabel("Energy")

        def update_figure():
            net_state_img.set_data(net.get_state().reshape(data.pattern_shape()))
            energy_history_line.set_data(np.arange(len(energy_history)), energy_history)
            energy_history_ax.dataLim.update_from_data_xy(
                list(enumerate(energy_history))
            )
            energy_history_ax.autoscale_view()

    steps = 0
    while steps < max_steps:
        print(f"Step {steps + 1}")
        energy = net()
        if len(energy_history) >= energy_balance_duration:
            latest_energy_history = energy_history[-energy_balance_duration:]
            if max(latest_energy_history) - min(latest_energy_history) < epsilon:
                break
        energy_history.append(energy)
        steps += 1

        if visualize:
            if plt.get_fignums():
                update_figure()
                plt.pause(0.05)
            else:
                exit()

    plt.close("all")
