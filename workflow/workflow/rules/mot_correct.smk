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
    resources:
        mem="1GB"
    container:
        "docker://ghcr.io/neurodesk/afni_25.2.03:20250717"
    log:
        "logs/mot_correct/mot_correct_{sub_num}_{task}.txt"
    script:
        "../scripts/mot_correct.py"
