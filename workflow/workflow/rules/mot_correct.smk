rule mot_correct:
    "Runs motion correction"
    input:
        img=rules.acquire_func.output.nii,
        base=lambda wildcards: expand(
            rules.acquire_func.output.nii,
            sub_num=wildcards.sub_num,
            task="stopsignal",
        )[0],
    output:
        img="results/sub-{sub_num}/func/sub-{sub_num}_task-{task}_mc.nii.gz",
    params:
        base=lambda wildcards, input: input.base + "[0]",
    resources:
        mem="1GB"
    shadow: "copy-minimal"
    container:
        "docker://ghcr.io/neurodesk/afni_25.2.03:20250717"
    log:
        "logs/mot_correct/mot_correct_{sub_num}_{task}.txt"
    script:
        "../scripts/mot_correct.py"
