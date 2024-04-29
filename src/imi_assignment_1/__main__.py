import sys
from datetime import datetime

import matplotlib
import matplotlib.axes
import matplotlib.backend_bases
import matplotlib.gridspec
import matplotlib.pyplot as plt
import numpy as np

from . import transforms
from .data_loader import DataLoader
from .hopfield_network import HopfieldNetwork

noise_probs = [0.2]
attempts = 1000
visualize = False
save_state_history = True

max_steps = 1000
energy_balance_duration = 100
energy_balance_epsilon = 1e0
similarity_epsilon = 1e-3

assert len(sys.argv) > 1, "Specify a directory containing images to load"

data = DataLoader(sys.argv[1])

net = HopfieldNetwork(data.pattern_size())

net.set_weight(data().T @ data() / data.num_patterns())

log_file_basename = datetime.now().strftime("%Y%m%d_%H%M%S")

for i, noise_prob in enumerate(noise_probs):
    result = np.empty(attempts, dtype="U8, u4, f8")
    perfect_recalls = 0

    for j in range(attempts):
        print(f"Attempt {j + 1}")

        original, name = data.random_choice()
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

            def update_figure() -> None:
                net_state_img.set_data(net.get_state().reshape(data.pattern_shape()))
                energy_history_line.set_data(
                    np.arange(len(energy_history)), energy_history
                )
                energy_history_ax.dataLim.update_from_data_xy(
                    list(enumerate(energy_history))
                )
                energy_history_ax.autoscale_view()

            def on_key_press(event: matplotlib.backend_bases.KeyEvent) -> None:
                if event.key == "q":
                    exit()

            fig.canvas.mpl_connect("key_press_event", on_key_press)

        if save_state_history and j == 0:
            state_history = [net.get_state().copy()]

        steps = 0
        while steps < max_steps:
            energy = net()
            if len(energy_history) >= energy_balance_duration:
                latest_energy_history = energy_history[-energy_balance_duration:]
                if (
                    max(latest_energy_history) - min(latest_energy_history)
                    < energy_balance_epsilon
                ):
                    break
            energy_history.append(energy)

            if visualize:
                update_figure()
                plt.pause(0.05)

            if save_state_history and j == 0:
                state_history.append(net.get_state().copy())

            steps += 1

        if visualize:
            plt.show()

        if save_state_history and j == 0:
            max_cols = 10
            nrows = (steps + 1) // max_cols + 1
            ncols = min(steps + 1, max_cols)
            fig, axs = plt.subplots(nrows, ncols, figsize=(ncols, nrows))
            for k, ax in enumerate(axs.flatten()):
                if k < steps + 1:
                    ax.imshow(
                        state_history[k].reshape(data.pattern_shape()), cmap="gray"
                    )
                    ax.set_title(f"$t = {k}$", loc="left", fontsize=8)
                ax.axis("off")
            fig.tight_layout()
            fig.savefig(f"log/{log_file_basename}_{i}.png", bbox_inches="tight")
            plt.close(fig)

        similarity = np.dot(original, net.get_state()) / (original**2).sum()
        result[j] = (name, steps, similarity)
        if abs(similarity - 1) < similarity_epsilon:
            perfect_recalls += 1

        print(f"Similarity: {similarity}")

    similarity_average = result["f2"].mean()
    accuracy = perfect_recalls / attempts

    print(f"Average similarity: {similarity_average}, accuracy: {accuracy}")

    log_header = (
        f"Trained patterns: {data.pattern_names()}, Noise probability: {noise_prob}"
        f"\nAverage similarity: {similarity_average}, accuracy: {accuracy}"
    )

    np.savetxt(
        f"log/{log_file_basename}_{i}.csv",
        result,
        delimiter=",",
        fmt=["%s", "%d", "%.4f"],
        header=log_header,
    )
