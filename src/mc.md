# Run motion correction


## Outputs

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-2, 5-6
```

## Inputs

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-6
:emphasize-lines: 3-4
```


## Parameters

```{literalinclude} ../workflow/workflow/rules/mot_correct.smk
:caption: `workflow/workflow/rules/mot_correct.smk`
:language: snakemake
:lines: 1-8
:emphasize-lines: 7-8
```

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
