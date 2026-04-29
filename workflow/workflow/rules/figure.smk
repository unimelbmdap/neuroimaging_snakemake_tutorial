rule figure:
    "Create a visualisation of the participant data"
    input:
        anat=collect(rules.coreg.output.anat_img, sub_num=SUB_NUMS),
        func_anat_grid=collect(rules.coreg.output.func_img, sub_num=SUB_NUMS),
        func=collect(
            rules.mot_correct.output.img,
            sub_num=SUB_NUMS,
            task=TASKS,
        ),
    output:
        png="results/derivatives/group/group_figure.png",
    params:
        sub_nums=SUB_NUMS,
        tasks=TASKS,
    container:
        CONTAINER_SOURCES["PY312-MATPLOTLIB-SKIMAGE-NIBABEL"]
    log:
        "logs/figure_log.txt"
    script:
        "../scripts/figure.py"
