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
:lines: 1-8, 9-12
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
:lines: 1-8, 9-14
:emphasize-lines: 13-
```

### Shell command

Similarly to the first rule, we will directly specify shell commands to run rather than using a script.
First, we use `3dTcat` to combine the separate files into one file (`tcat.nii.gz`).
Then, we use `3dTstat` to average that file and produce our desired output.

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-14, 19-
:emphasize-lines: 15-
```

### Shadowing

There are two important to things to note about the above command that would cause problems if executed within the current state of the rule:

1. The intermediate file `tcat.nii.gz` would remain present.
1. More problematically, each invocation of the rule (i.e., across participants) would be writing to the *same* `tcat.nii.gz` file.

We can resolve both problems by using [*shadowing*](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#shadow-rules).

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:lines: 1-14, 17-
:emphasize-lines: 15-16
```



## Resources

We can provide an indication of the RAM that will be used by a single invocation of the rule by setting the `mem` key as part of the `resources` directive.
Here, we will specify that Snakemake should budget for the job using up to 1 GB of RAM.

```{literalinclude} ../workflow/workflow/rules/tmean.smk
:caption: `workflow/rules/tmean.smk`
:language: snakemake
:emphasize-lines: 15-16
```

## Preparing for execution

As usual, our next step is to add the new rule file to the `Snakefile`:

```{literalinclude} ../workflow/workflow/Snakefile_tmean_start
:caption: `workflow/Snakefile`
:language: snakemake
:emphasize-lines: 5
```

Then we need to tell Snakemake that we want to create the *output* from the motion correction rule, via the `all` rule.
Note that we no longer need to specify the output from the `acquire_func` rule in `all`, because the output from `acquire_func` is needed as an input for `mot_correct`.

```{literalinclude} ../workflow/workflow/Snakefile_tmean
:caption: `workflow/Snakefile`
:language: snakemake
:emphasize-lines: 13
```

## Executing the workflow

Finally, you can run Snakemake and execute the workflow:

```console
$ uv run snakemake
```
