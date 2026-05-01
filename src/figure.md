# Visualisation

The final step is our example analysis is to create a visualisation that uses data from all participants.
This visualisation is contrived, but is a good demonstration of how Snakemake can be used to manage any arbitrary processing stages in a workflow.

## Outputs

We want to produce a single PNG file containing the visualisation.

We start by creating a new rule (`workflow/rules/figure.smk`) that has this `output` information:

```{literalinclude} ../workflow/workflow/rules/figure.smk
:caption: `workflow/rules/figure.smk`
:language: snakemake
:lines: 1-2, 7-8
```

Note that we don't need any wildcards here.

## Inputs

The visualisation will include, for each participant, an example slice from their anatomical and mean functional images and a depiction of the mean timeseries (over voxels) for the two task types.
We can use the now-familiar approach of `collect`ing paths based on the output of prior rules to specify these inputs:

```{literalinclude} ../workflow/workflow/rules/figure.smk
:caption: `workflow/rules/figure.smk`
:language: snakemake
:lines: 1-8
:emphasize-lines: 3-6
```

## Parameters

We will specify the `SUB_NUMS` and `TASKS` variables as parameters, so that they are available to the processing script:

```{literalinclude} ../workflow/workflow/rules/figure.smk
:caption: `workflow/rules/figure.smk`
:language: snakemake
:lines: 1-11
:emphasize-lines: 9-
```

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

Here, we will take the opportunity to demonstrate the use of custom Apptainer containers.

### Container

Below is an [Apptainer definition file](https://apptainer.org/docs/user/main/definition_files.html) that can be used to build a container with the necessary Python packages.
While it is out of the scope of this tutorial to describe the construction of the definition in detail, hopefully the specification below is readable and gives an indication of how they are created.
We store it within a sub-directory of the base workflow directory called `containers`.

```{literalinclude} ../workflow/containers/py312-matplotlib-nibabel.def
:caption: `workflow/containers/py312-matplotlib-nibabel.def`
:language: singularity
```

The container can then be built by running:

```{code-block} console
$ apptainer build containers/py312-matplotlib-nibabel.sif containers/py312-matplotlib-nibabel.def
```

We then add this location to the register of container locations:

```{literalinclude} ../workflow/workflow/rules/common.smk
:caption: `workflow/rules/common.smk`
:language: snakemake
:emphasize-lines: 7
```

And to the rule:

```{literalinclude} ../workflow/workflow/rules/figure.smk
:caption: `workflow/rules/figure.smk`
:language: snakemake
:lines: 1-13
:emphasize-lines: 12-13
```

### Logging

We won't really need any logging here, so we will skip the `log` directive.

### Script

As described, we will be using the Python package `matplotlib` and the I/O package `nibabel` to create the visualisation.

While we won't go into detail on the Python-specific aspects of creating the visualisation, it is worth considering its interaction with Snakemake.
In particular, how we can convert the `anat`, `func_anat_grid`, and `func` variables that are injected from Snakemake into a more convenient form for further use in the script.

First, it is important to consider what those variables will contain.
Given the value of the `anat` item in the rule's `input` directive (`collect(rules.coreg.output.anat_img, sub_num=SUB_NUMS)`), the `anat` variable will contain a three-item list of strings --- each item will be the location of the coregisted anatomical image for a particular subject, with the order determined by the order of the `SUB_NUMS` variable.
The `func_anat_grid` variable will have a similar structure.

However, it gets a bit trickier with the `func` item.
In the rule, the value of `func` is given as `collect(rules.mot_correct.output.img, sub_num=SUB_NUMS, task=TASKS)`.
That results in the variable available to Python being a six-item list of strings, containing each pairwise combination of subjects and tasks.
It is critical that we know the *order* of these six items.
We can understand the order by noting that each successive argument in the `collect` function call adds another inner loop, so the `snakemake.input.func` variable available in Python is constructed using information from:

0. first subject number and the first task
0. first subject number and the second task
0. second subject number and the first task
0. ...

We can convert this into a more useful representation --- in this case, a dictionary where the key is a tuple of the subject number and the task and the value is the associated path --- in the Python script:


```{literalinclude} ../workflow/workflow/scripts/figure.py
:caption: `workflow/scripts/figure.py`
:lines: 1, 7-19
```

This can then be used in the rest of the script --- which we won't go through in any detail.

:::{note}
To keep things simple, the script hard-codes assumptions and does not do any validation --- generally doesn't follow best practices.
It shouldn't be used as a demonstration of good Python or as a template to use for similar tasks.
:::

```{literalinclude} ../workflow/workflow/scripts/figure.py
:caption: `workflow/scripts/figure.py`
```

## Resources

We don't need anything special for resources, so we will skip the `resources` directive.

## Preparing for execution

We add the new rule file to the `Snakefile` and adjust the output of the `all` rule:

```{literalinclude} ../workflow/workflow/Snakefile
:caption: `workflow/Snakefile`
:language: snakemake
:emphasize-lines: 7, 14
```

Note that we only need to this single rule now, given it depends on output from all of the other rules.

## Executing the workflow

Finally, you can run Snakemake and execute the workflow:

```console
$ uv run snakemake
```

This produces a figure looking something like:

```{figure} _static/group_figure.png

`results/derivatives/group/group_figure.png`
```


