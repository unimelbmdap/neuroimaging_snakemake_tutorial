
import itertools

import matplotlib as mpl
import matplotlib.pyplot as plt

import skimage.util

import nibabel

from snakemake.script import snakemake

mpl.rcParams.update(
    {
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
    figsize=[7.2, 5],
    constrained_layout=True,
    nrows=len(snakemake.params.sub_nums),
    ncols=2,
    width_ratios=[0.3, 0.7],
    sharex="col",
)

for (row_axs, sub_num, sub_anat_path, sub_func_anat_grid_path) in zip(
    axs,
    snakemake.params.sub_nums,
    snakemake.input.anat,
    snakemake.input.func_anat_grid,
    strict=True,
):

    (brain_ax, ts_ax) = row_axs

    anat = nibabel.load(sub_anat_path).get_fdata()
    func_anat_grid = nibabel.load(sub_func_anat_grid_path).get_fdata()

    i_lr = 130

    chk = skimage.util.compare_images(
        image0=skimage.exposure.rescale_intensity(anat[i_lr, :, ::-1].T, out_range=(0, 1)),
        image1=skimage.exposure.rescale_intensity(func_anat_grid[i_lr, :, ::-1].T, out_range=(0, 1)),
        method="checkerboard",
        n_tiles=(16, 16),
    )

    brain_ax.matshow(chk, cmap="grey")
    brain_ax.xaxis.set_visible(False)
    brain_ax.yaxis.set_visible(False)

    brain_ax.set_title(f"Subject: {sub_num}")

    for task in snakemake.params.tasks:

        func = nibabel.load(func_paths[(sub_num, task)]).get_fdata()

        ts_ax.plot(func.mean(axis=(0, 1, 2)), label=task)

    if sub_num == snakemake.params.sub_nums[-1]:
        ts_ax.legend()
        ts_ax.set_xlabel("Volume")
        ts_ax.set_ylabel("Mean BOLD")


plt.savefig(snakemake.output.png)
