import subprocess

from snakemake.script import snakemake

# open the log file for writing
with open(snakemake.log[0], "w") as log_handle:

    cmd = [
        "3dvolreg",
        "-base", snakemake.params.base,
        "-prefix", snakemake.output.img,
        snakemake.input.img,
    ]

    # keep a record of the command in the log file
    print(" ".join(cmd), file=log_handle, flush=True)

    # run the command
    subprocess.run(cmd, stdout=log_handle, stderr=log_handle, check=True)
