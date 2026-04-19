# Run motion correction

The first step in processing the raw data is to perform motion correction.


## Outputs

We want to produce a motion-corrected NIFTI file, with a similar filename structure to the raw data but with the additional BIDS entity `desc` that has the label `mc`.
We start by creating a new rule (`workflow/rules/mot_correct.smk`) that has this `output` information:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
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
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-4, 9-10
:emphasize-lines: 3-4
```

The motion correction algorithm also needs to know which volume it should use as the reference, to which all the other volumes are registered.
Here, we will designate the first volume in the "stopsignal" task acquisition as the reference ("base") volume.
We can tell Snakemake that this is a required input by adding another entry within the `input` directive:

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
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
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-12
:emphasize-lines: 11-12
```

This provides us with information that we can use within the mechanism to specify the base volume.

## Mechanism

Now we need to think about the rule's mechanism --- how the output files are produced.

### Container

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-8, 11-12
:emphasize-lines: 9-10
```

### Logging

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-8, 11-14
:emphasize-lines: 11-12
```

### Script

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-8, 11-
:emphasize-lines: 13-14
```

## Resources

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:emphasize-lines: 9-10
```

## Preparing for execution

```{literalinclude} ../workflow/workflow/Snakefile_mc
:caption: `workflow/workflow/Snakefile`
:language: snakemake
:emphasize-lines: 4, 9
```

## Executing the workflow

```console
uv run snakemake --dry-run
```


If all looks good, we can go ahead and actually run the workflow:

```console
uv run snakemake
```

Note that it creates a `.afni.log` file.
No good.

Add shadow.
