# Study configuration


Our goal in this section is to specify some information about the study that we will be processing.

First, ensure that you are in the base directory of your project --- this is where you ran `uv init` and should contain, at this point, at least a `pyproject.toml`, a `uv.lock` file, and a `workflow` directory.

Then, create a directory that will contain the Snakemake rules:

```{code-block} console
$ mkdir --parents workflow/rules/
```

We will create a Snakemake rule that only contains some study information.
This information is not used directly, but it will be then available for other rules.
For our purposes, we specify the subject numbers and task descriptors that we are interested in processing.
We do so using regular Python syntax:

```{literalinclude} ../workflow/workflow/rules/common.smk
:caption: `workflow/rules/common.smk`
:language: snakemake
:lines: 1-2
```

:::{note}
We specify the variable names in upper case as a signal that they are constants.
This is a particularly important signal because these variables are available in the global namespace --- i.e., just as `SUB_NUMS` and not something like `common.SUB_NUMS` that might be expected from ordinary Python.
:::

We then make this information available to Snakemake by using the `include` directive in the main Snakemake file (`Snakefile`) --- which we will create and edit to include the following:

```{literalinclude} ../workflow/workflow/Snakefile_common
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
