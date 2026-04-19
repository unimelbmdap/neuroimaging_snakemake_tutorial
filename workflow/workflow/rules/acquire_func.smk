use rule acquire_anat as acquire_func with:
    output:
        img="results/sub-{sub_num}/func/sub-{sub_num}_task-{task}_bold.nii.gz",
    log:
        "logs/acquire_func/acquire_func_{sub_num}_{task}.txt",
