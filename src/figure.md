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

## Parameters

## Mechanism

To create the figure, we will use Python and the visualisation package `matplotlib` and the NIFTI file I/O package `nibabel`.
These computational demands pose a new challenge in that they are sufficiently specific to this task that finding an appropriate pre-created container may be difficult.
In this circumstance, we have a few potential options:

1. Add `matplotlib` and `nibabel` as dependencies to the Python project and execute the rule within the project.
This is the simplest option, but it leaks dependencies into the workflow project and lose the system-level reproducibility that is provided by containerisation.
Overall though, that may be a reasonable compromise.

1. Use Snakemake's support for [Conda-based package management](https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html#integrated-package-management).
However, this requires working within the Conda ecosystem and does not completely resolve the reproducibility loss.

1. Create a custom Apptainer container.
This is the best approach, but does require some knowledge of creating custom containers and (often) basic Linux system administration.

Here, we will take the opportunity to learn a bit about creating custom Apptainer containers.

### Container

### Logging

### Script

## Resources

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
