# Coregistration

The next step is to coregister the anatomical and functional images.

## Outputs

We want to produce a single NIFTI file per participant that is their anatomical image in alignment with the mean functional image.
We will give the `desc` entity the label `coreg`.

We start by creating a new rule (`workflow/rules/coreg.smk`) that has this `output` information:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-2, 6-7
```

For subsequent visualisation, it is also useful to have a copy of the mean functional image after it has been resampled into the grid of the coregistered anatomical image.
We add that file as an additional output of the rule:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-2, 6-8
:emphasize-lines: 5
```

## Inputs

The coregistration process requires two inputs per participant: their anatomical image and their mean functional image.
We enter these as separate items, with their paths given by the output from the relevant rule.

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-8
:emphasize-lines: 3-5
```

## Parameters

Because we will want to rename an intermediate output during execution of this rule, it is helpful for us to be able to access a path's 'stem' (i.e., the filename without its suffix).
We can use the Snakemake helper function [subpath](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#snakefiles-subpath) to do that; the `strip_suffix` option allows us to remove the `.nii.gz` from the path and the `basename=True` removes the directory information.

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-10
:emphasize-lines: 9-
```

## Mechanism

### Container

We will use the same AFNI container that we have used in previous rules:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-12
:emphasize-lines: 11-
```

### Logging

As usual, we need to specify the file to store logging information (particularly useful for this rule, given the importance of the coregistration process summary that is printed by AFNI):

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-14
:emphasize-lines: 13-
```

### Shell command

We will use the `align_epi_anat.py` AFNI command to run the coregistration and resample the mean functional image:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-14, 20-
:emphasize-lines: 15-
```

### Shadowing

Because this command produces quite a few intermediate outputs, we will again use rule shadowing:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-16, 20-
:emphasize-lines: 15-16
```

## Resources

We will give Snakemake a bit more RAM allowance for this job:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-18, 20-
:emphasize-lines: 17-18
```

We will also allow it to use two cores when executing each job using the `threads` directive:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:emphasize-lines: 19
```

## Preparing for execution

As usual, our next step is to add the new rule file to the `Snakefile` and adjust the output of the `all` rule:

```{literalinclude} ../workflow/workflow/Snakefile_coreg
:caption: `workflow/Snakefile`
:language: snakemake
:emphasize-lines: 6, 13
```

Note that we only need to expand this single rule now, given it depends on output from all of the other rules.

## Executing the workflow

Finally, you can run Snakemake and execute the workflow:

```console
$ uv run snakemake
```
