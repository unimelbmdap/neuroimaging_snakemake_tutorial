rule figure:
    "Create a visualisation of the participant data"
    input:
        anat=collect(rules.acquire_anat.output.img, sub_num=SUB_NUMS),
        func=collect(rules.tmean.output.img, sub_num=SUB_NUMS),
    output:
        png="results/group/group_figure.png",
    container:
        CONTAINER_SOURCES["AFNI"]
    log:
        "logs/figure/figure.txt"
    resources:
        mem="1GB",
    shell:
        """
        """
