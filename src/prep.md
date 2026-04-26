# Study configuration

First, create a directory that will contain the Snakemake rules:

```{code-block} console
$ mkdir --parents workflow/rules/
```

We will create a Snakemake rule that only contains some study information; this information is not directly used, but will be then available for other rules.
For our purposes, we specify the subject numbers and task descriptors that we are interested in processing.
We do so using regular Python syntax:

```{literalinclude} ../workflow/workflow/rules/common.smk
:caption: `workflow/rules/common.smk`
:language: snakemake
:lines: 1-2
```

We then make this information available to Snakemake by using the `include` directive in the main Snakemake file (`Snakefile`):

```{literalinclude} ../workflow/workflow/Snakefile
:caption: `workflow/Snakefile`
:language: snakemake
```

We can then run Snakemake, just to check that everything is OK:

```{code-block} console
$ uv run snakemake
```

The output should then be something like:

```{code-block} none
:class: console-output
Using workflow specific profile profiles/default for setting default command line arguments.
Assuming unrestricted shared filesystem usage.
host: ...
Building DAG of jobs...
Nothing to be done (all requested files are present and up to date).
```

As expected, Snakemake does not execute any jobs because we haven't asked it to generate any output files yet.
