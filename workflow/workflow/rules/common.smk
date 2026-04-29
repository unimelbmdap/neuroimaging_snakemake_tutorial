SUB_NUMS = ["10159", "10171", "10189"]
TASKS = ["taskswitch", "stopsignal"]

CONTAINER_SOURCES = {
    "AWS-CLI": "docker://amazon/aws-cli:2.32.21",
    "AFNI": "docker://ghcr.io/neurodesk/afni_26.0.07:20260128",
    "PY312-MATPLOTLIB-SKIMAGE-NIBABEL": "containers/py312-matplotlib-skimage-nibabel.sif",
}
