rule acquire_anat:
    "Acquire (download) the anatomical images"
    output:
        nii="results/sub-{sub_num}/anat/sub-{sub_num}_T1w.nii.gz",
    params:
        remote_url=lambda wildcards, input, output: (
            f"s3://openneuro.org/ds000030/{output.nii.removeprefix("results/")}"
        ),
    container:
        "docker://amazon/aws-cli:2.32.21"
    log:
        "logs/acquire_anat/acquire_anat_{sub_num}.txt",
    shell:
        """
aws \
s3 \
cp \
--no-sign-request \
--no-progress \
{params.remote_url} \
{output.nii} \
> {log} 2>&1
        """
