rule coreg:
    "Coregisters the anatomical to the mean functional"
    input:
        anat=rules.acquire_anat.output.img,
        func=rules.tmean.output.img,
    output:
        anat_img="results/sub-{sub_num}/anat/sub-{sub_num}_desc-coreg_T1w.nii.gz",
        func_img="results/sub-{sub_num}/func/sub-{sub_num}_desc-tmean_grid-anat_bold.nii.gz",
    params:
        anat_stem=subpath(input.anat, strip_suffix=".nii.gz", basename=True),
    container:
        CONTAINER_SOURCES["AFNI"]
    log:
        "logs/coreg/coreg_{sub_num}.txt"
    shadow:
        "shallow"
    resources:
        mem="4GB",
    threads: 2
    shell:
        """
# run the coregistration
align_epi_anat.py \
-anat {input.anat} -epi {input.func} \
-epi_base 0 -giant_move \
> {log} 2>&1
# convert the resulting files into NIFTI format
3dcopy \
{params.anat_stem}_al+orig \
{output.anat_img} \
>> {log} 2>&1
# save a copy of the functional in the anatomical grid
3dresample \
-inset {input.func} \
-master {output.anat_img} \
-prefix {output.func_img} \
>> {log} 2>&1
        """
