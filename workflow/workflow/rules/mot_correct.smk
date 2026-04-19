rule mot_correct:
    "Runs motion correction"
    input:
        img=rules.acquire_func.output.img,
        base=lambda wildcards: rules.acquire_func.output.img.format(
            sub_num=wildcards.sub_num,
            task="stopsignal",
        ),
    output:
        img="results/sub-{sub_num}/func/sub-{sub_num}_task-{task}_desc-mc_bold.nii.gz",
    params:
        base_volume=0,
    container:
        "docker://ghcr.io/neurodesk/afni_26.0.07:20260128",
    log:
        "logs/mot_correct/mot_correct_{sub_num}_{task}.txt"
    resources:
        mem="1GB"
    script:
        "../scripts/mot_correct.py"
