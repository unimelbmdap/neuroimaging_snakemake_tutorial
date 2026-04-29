import itertools

import matplotlib as mpl
import matplotlib.pyplot as plt

import skimage.util

import nibabel

from snakemake.script import snakemake


mpl.rcParams.update(
    {
        "font.sans-serif": ["Liberation Sans"],
        "font.size": 8,
        "axes.spines.right": False,
        "axes.spines.top": False,
        "axes.labelpad": 8,
    },
)

func_paths = {
    (sub_num, task): path
    for ((sub_num, task), path) in zip(
        itertools.product(snakemake.params.sub_nums, snakemake.params.tasks),
        snakemake.input.func,
        strict=True,
    )
}

(fig, axs) = plt.subplots(
    figsize=[7.2, 4.5],
    constrained_layout=True,
    nrows=len(snakemake.params.sub_nums),
    ncols=3,
    width_ratios=[0.25, 0.25, 0.5],
    sharex="col",
)

for (row_axs, sub_num, sub_anat_path, sub_func_anat_grid_path) in zip(
    axs,
    snakemake.params.sub_nums,
    snakemake.input.anat,
    snakemake.input.func_anat_grid,
    strict=True,
):

    (anat_ax, func_ax, ts_ax) = row_axs

    anat = nibabel.load(sub_anat_path).get_fdata()
    func_anat_grid = nibabel.load(sub_func_anat_grid_path).get_fdata()

    i_lr = 130

    anat_ax.matshow(anat[i_lr, :, ::-1].T, cmap="grey")
    anat_ax.xaxis.set_visible(False)
    anat_ax.yaxis.set_visible(False)
    anat_ax.set_title(f"Subject: {sub_num}")

    func_ax.matshow(func_anat_grid[i_lr, :, ::-1].T, cmap="grey")
    func_ax.xaxis.set_visible(False)
    func_ax.yaxis.set_visible(False)

    for task in snakemake.params.tasks:

        func = nibabel.load(func_paths[(sub_num, task)]).get_fdata()

        ts_ax.plot(func.mean(axis=(0, 1, 2)), label=task, alpha=0.7)

    if sub_num == snakemake.params.sub_nums[-1]:
        ts_ax.legend(fontsize="small", frameon=False)
        ts_ax.set_xlabel("Volume")
        ts_ax.set_ylabel("Mean BOLD")

plt.savefig(snakemake.output.png, dpi=200)
