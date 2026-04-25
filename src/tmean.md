# Run temporal averaging

The next step is to average together, over time, all the motion-corrected functional images.

## Outputs

We want to produce a single NIFTI file per participant that has a single volume --- the temporal average of all the motion-corrected data.
We will give the `desc` entity the label `tmean`.


We start by creating a new rule (`workflow/rules/tmean.smk`) that has this `output` information:

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-2, 9-10
```

## Inputs

Each output file requires *two* input files --- one motion-corrected image for each of the two tasks.
The `mot_correct` rule was applied separately to participants and tasks, so we cannot simply refer to the output of the rule.
Instead, we can use the `collect` helper function (from Snakemake) to produce a sequence of inputs based on a rule's output.

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-8, 9-10
:emphasize-lines: 3-8
```

We need to use an input function here as we want to use the active subject number with the fixed set of tasks.
Note that `imgs` here in the input is now a sequence rather than just a single string as it has been previously.

## Parameters

We don't need any particular parameters for this rule, so we can skip the `params` directive.

## Mechanism

### Container

We will use the same AFNI container that we used in the motion correction rule:

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-8, 9-11
:emphasize-lines: 11-12
```

:::{note}
Given the repetition of this URL across rules, it would be worth considering specifying it as a [config variable](https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html#standard-configuration) instead.
:::

### Logging

As usual, we need to specify the file to store logging information:

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-8, 9-12
:emphasize-lines: 12-
```

### Shell command

Similarly to the first rule, we will directly specify shell commands to run rather than using a script.
First, we use `3dTcat` to combine the separate files into one file (`tcat.nii.gz`).
Then, we use `3dTstat` to average that file and produce our desired output.

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-8, 9-12, 15-
:emphasize-lines: 13-
```

### Shadowing

There are two important to things to note about the above command that would cause problems if executed within the current state of the rule:

1. The intermediate file `tcat.nii.gz` would remain present.
1. More problematically, each invocation of the rule (i.e., across participants) would be writing to the *same* `tcat.nii.gz` file.

We can resolve both problems by using [*shadowing*](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#shadow-rules).




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
This path can then be referenced in the rule instead of the URL (i.e., `container: "containers/afni.sif"`).
:::
