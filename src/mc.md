# Motion correction

The first step in processing the raw data is to perform motion correction.

## Outputs

We want to produce a motion-corrected NIFTI file, with a similar filename structure to the raw data but with the additional BIDS entity `desc` that has the label `mc`.

We start by creating a new rule (`workflow/rules/mot_correct.smk`) that has this `output` information:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-2, 9-10
```

## Inputs

Unlike the previous step, motion correction requires an input to be specified (the raw data).
While we could specify the path directly, a better approach is to instead reference the output of the rule that produced the input.
We can do that by referring to `rules.{rule_name}.output.{output_id}`, where `rule_name` is the name that we have given to the rule (here, `acquire_func`) and `output_id` is the name that we have given to the output of interest (here, `img`).

:::{note}
A good heuristic is to aim to only ever specify the full file path (containing wildcards) *once* within a workflow - and refer to this specification in other rules that require knowledge of the path.
:::

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-4, 9-10
:emphasize-lines: 3-4
```

The motion correction algorithm also needs to know which volume it should use as the reference, to which all the other volumes are registered.
Here, we will designate the first volume in the "stopsignal" task acquisition as the reference ("base") volume.
We can tell Snakemake that this is a required input by adding another entry within the `input` directive:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-10
:emphasize-lines: 5-8
```

Note that this needs to be an *input function*, because we want to use the active subject number wildcard value with a fixed `task` wildcard value.
We use the standard Python string formatting function (`format`) to insert the desired values into the `sub_num` and `task` wildcards from the `img` entry in the `output` directive of the `acquire_func` rule.

## Parameters

In the previous section, we mentioned that the base for the motion correction algorithm was the first volume in the image file (which contains many volumes).
We can specify this volume information as a parameter:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-12
:emphasize-lines: 11-12
```

This provides us with information that we can use within the mechanism to specify the base volume.

## Mechanism

Now we need to think about the rule's mechanism --- how the output files are produced.

### Container

We will be using [AFNI](https://afni.nimh.nih.gov/) to perform the motion correction, so we need to find a container that provides AFNI.
A great resource for neuroimaging-related containers is the [NeuroDesk package respository](https://github.com/orgs/neurodesk/packages).
If we go to that site and search for 'AFNI', there is an `afni_26.0.07` package that we can use.
Clicking on the link shows that a Docker container is available at `ghcr.io/neurodesk/afni_26.0.07:20260128`.
That gives us all the information we need to specify the container for the rule, which we add to `common.smk`:

```{literalinclude} ../workflow/workflow/rules/common.smk
:caption: `workflow/rules/common.smk`
:language: snakemake
:lines: 1-6, 8
:emphasize-lines: 6
```

and then to the `mot_correct.smk` rule:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-14
:emphasize-lines: 13-14
```

:::{note}
The AFNI container is quite large (~8 GB) and so can take quite a while to download.
Unfortunately, there is no progress indicator while it is downloading.
It is cached though, so it only needs to be downloaded once.
:::

### Logging

As usual, we need to specify the file to store logging information:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-16
:emphasize-lines: 15-16
```

### Script

In the previous rule, we directly specified a shell command.
Although the command we need to run to do the motion correction is not very complex, we will instead use a Python script to execute the rule.
This is implemented using the `script` directive, which has a value that is the path to the Python file relative to the location of the rule.
By convention, scripts are stored in `workflow/scripts/`; given that this rule is in `workflow/rules/`, the relative path begins with `../scripts/`.

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-16, 19-20
:emphasize-lines: 17-18
```

Before looking at the Python script, it is worth thinking about the command that the script will need to execute.
For motion correction, we will use the `3dvolreg` command with `base` and `prefix` named parameters and the input as positional arguments.

We can start the script by importing a special Snakemake object that is inserted by Snakemake at runtime and contains useful information for constructing the command:

```{literalinclude} ../workflow/workflow/scripts/mot_correct.py
:caption: `workflow/scripts/mot_correct.py`
:language: python
:lines: 3
```

The `snakemake` object has a `log` attribute, which contains the information from the `log` directive in the rule.
We start by opening this log file to be able to write to it during execution:

```{literalinclude} ../workflow/workflow/scripts/mot_correct.py
:caption: `workflow/scripts/mot_correct.py`
:language: python
:lines: 3-6
:emphasize-lines: 3-4
```

Now we can build the command, using the `snakemake` object to obtain the necessary information for the command arguments:

:::{note}
In AFNI, the volume within a file is referenced using square brackets after the path.
:::

```{literalinclude} ../workflow/workflow/scripts/mot_correct.py
:caption: `workflow/scripts/mot_correct.py`
:language: python
:lines: 3-13
:emphasize-lines: 6-
```

It is helpful for record-keeping and debugging to store the command that was executed.
We can do that by printing the command to the log file:

```{literalinclude} ../workflow/workflow/scripts/mot_correct.py
:caption: `workflow/scripts/mot_correct.py`
:language: python
:lines: 3-16
:emphasize-lines: 13-
```

Finally, we execute the command using the `run` function from the built-in Python `subprocess` package --- providing the log file handle so that any content from standard output or standard error is stored within the log file:

```{literalinclude} ../workflow/workflow/scripts/mot_correct.py
:caption: `workflow/scripts/mot_correct.py`
:language: python
:emphasize-lines: 1, 18-
```

## Resources

We can provide an indication of the RAM that will be used by a single invocation of the rule by setting the `mem` key as part of the `resources` directive.
Here, we will specify that Snakemake should budget for the job using up to 1 GB of RAM.

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/rules/mot_correct.smk`
:language: snakemake
:emphasize-lines: 17-18
```

## Preparing for execution

As usual, our next step is to add the new rule file to the `Snakefile`:

```{literalinclude} ../workflow/workflow/Snakefile_mc_start
:caption: `workflow/Snakefile`
:language: snakemake
:lines: 1-4, 8-
:emphasize-lines: 4
```

Then we need to tell Snakemake that we want to create the *output* from the motion correction rule, via the `all` rule.
Note that we no longer need to specify the output from the `acquire_func` rule in `all`, because the output from `acquire_func` is needed as an input for `mot_correct`.

```{literalinclude} ../workflow/workflow/Snakefile_mc
:caption: `workflow/Snakefile`
:language: snakemake
:lines: 1-4, 8-
:emphasize-lines: 9
```

If you do a test invocation of Snakemake, you will find that Snakemake gives an error:

```{code-block} console
$ uv run snakemake --dry-run
```

```{code-block} none
:class: console-output
AmbiguousRuleException:
Rules mot_correct and acquire_func are ambiguous for the file results/sub-10159/func/sub-10159_task-taskswitch_desc-mc_bold.nii.gz.
Consider starting rule output with a unique prefix, constrain your wildcards, or use the ruleorder directive.
Wildcards:
        mot_correct: sub_num=10159,task=taskswitch
        acquire_func: sub_num=10159,task=taskswitch_desc-mc
Expected input files:
        mot_correct: results/sub-10159/func/sub-10159_task-taskswitch_bold.nii.gz results/sub-10159/func/sub-10159_task-stopsignal_bold.nii.gz
        acquire_func:
Expected output files:
        mot_correct: results/sub-10159/func/sub-10159_task-taskswitch_desc-mc_bold.nii.gz
        acquire_func: results/sub-10159/func/sub-10159_task-taskswitch_desc-mc_bold.nii.gz
```

The error is caused by Snakemake getting confused about how to resolve the wildcard values.
From the `mot_correct` rule, it correctly infers the wildcards (`task=taskswitch`).
However, the `task` wildcard is inferred incorrectly in the `acquire_func` rule (`task=taskswitch_desc-mc`).

The solution is to provide a constraint on the potential wildcard values, using the [`wildcard_constraints`](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#wildcards) directive; i.e., we tell Snakemake that the `task` wildcard can only possibly resolve to `taskswitch` or `stopsignal`.
Given the `task` wildcard applies over multiple rules, we specify this constraint within the `Snakefile`:

```{literalinclude} ../workflow/workflow/Snakefile_mc
:caption: `workflow/Snakefile`
:language: snakemake
:emphasize-lines: 6-7
```

If you now run Snakemake again, it should correctly resolve the wildcards:

```console
$ uv run snakemake --dry-run
```

## Executing the workflow

Finally, you can run Snakemake and execute the workflow:

```console
$ uv run snakemake
```

Note that it will not need to re-run the `acquire_anat` and `acquire_func` rules --- it knows that the output from those rules is already present, so it only needs to run the `mot_correct` rule to produce all the inputs to the `all` rule.

:::{note}
Snakemake can sometimes fail at this point due to being unable to download the AFNI container.
Downloading from the package repository can become throttled and time out.

An alternative approach is to manually acquire the container:

```{code-block} console
$ mkdir containers
$ apptainer pull containers/afni.sif docker://ghcr.io/neurodesk/afni_26.0.07:20260128
```

This downloads the container into the path `containers/afni.sif`.
This path can then be referenced in the `common.smk` rule instead of the URL (i.e., the value of the `AFNI` key in the `CONTAINER_SOURCES` dictionary becomes `"containers/afni.sif"`).
:::
