rule acquire_anat:
    "Acquire (download) the anatomical images"
    output:
        img="results/sub-{sub_num}/anat/sub-{sub_num}_T1w.nii.gz",
    params:
        remote_url=lambda wildcards, input, output: (
            f"s3://openneuro.org/ds000030/{output.img.removeprefix("results/")}"
        ),
    container:
        CONTAINER_SOURCES["AWS-CLI"]
    log:
        "logs/acquire_anat/acquire_anat_{sub_num}.txt"
    shell:
        """
aws \
s3 \
cp \
--no-sign-request \
--no-progress \
{params.remote_url} \
{output.img} \
> {log} 2>&1
        """
