# Visualisation

The final step is to create a visualisation that uses data from all participants.

## Outputs

We want to produce a single PNG file containing the visualisation.

We start by creating a new rule (`workflow/rules/figure.smk`) that has this `output` information:

```{literalinclude} ../workflow/workflow/rules/figure.smk
:caption: `workflow/rules/figure.smk`
:language: snakemake
:lines: 1-2, 6-7
```

Note that we don't need any wildcards here.

## Inputs

The coregistration process requires two inputs per participant: their anatomical image and their mean functional image.
We enter these as separate items, with their paths given by the output from the relevant rule.

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-7
:emphasize-lines: 3-5
```

## Parameters

Because we will want to rename an intermediate output during execution of this rule, it is helpful for us to be able to access a path's 'stem' (i.e., the filename without its suffix).
We can use the Snakemake helper function [subpath](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#snakefiles-subpath) to do that; the `strip_suffix` option allows us to remove the `.nii.gz` from the path and the `basename=True` removes the directory information.

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-9
:emphasize-lines: 8-
```

## Mechanism

### Container

We will use the same AFNI container that we have used in previous rules:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-11
:emphasize-lines: 10-
```

### Logging

As usual, we need to specify the file to store logging information (particularly useful for this rule, given the importance of the coregistration process summary that is printed by AFNI):

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-13
:emphasize-lines: 12-
```

### Shell command

We will use the `align_epi_anat.py` AFNI command to run the coregistration:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-13, 19-
:emphasize-lines: 14-
```

:::{note}
We use the `>>` operator, rather than `>`, to redirect to the log file in the second command.
This is because the `>>` appends to an existing file, whereas `>` would overwrite the output from the first command.
:::

### Shadowing

Because this command produces quite a few intermediate outputs, we will again use rule shadowing:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-15, 19-
:emphasize-lines: 14-15
```


## Resources

We will give Snakemake a bit more RAM allowance for this job:

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:lines: 1-17, 19-
:emphasize-lines: 16-17
```

Something about threads.

```{literalinclude} ../workflow/workflow/rules/coreg.smk
:caption: `workflow/rules/coreg.smk`
:language: snakemake
:emphasize-lines: 18
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
