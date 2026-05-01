# Summary

In this worked example, we have used Snakemake to construct and implement a reproducible and transparent workflow for a simulated data analysis.

## Running the workflow from scratch

We have followed an incremental approach in which we implemented each workflow step in turn --- gradually building up the complete workflow, with the opportunity to examine the construction and operation of each successive rule in relative isolation.
After following this sort of strategy, a useful final step is to re-create all the output from scratch.
Thankfully, this is what specifying the workflow in Snakemake makes easy!

One option is to run Snakemake with the `--forceall` argument, which ignores any existing output from the rules.
However, we recommend just running Snakemake with a clear `results` directory --- just in case there are any unexpected dependencies on files existing in `results` outside of the workflow.
For example:

```{code-block} console
$ mv results results_backup
$ mkdir results
$ uv run snakemake
```

A good additional check is to look for any lines that begin with `results/` in the output of the command:
```{code-block} console
$ uv run snakemake --list-untracked
```
These lines show files that are present in `results` but are not associated with the Snakemake workflow.


## Visualising the workflow

It is useful to be able to visualise the flow of files between rules in the workflow.
This can be achieved by using the `--rulegraph` argument to `snakemake`, which produces output in [Graphviz](https://graphviz.org/) format.
This output can then be passed to the `dot` application (see [Graphviz](https://graphviz.org/download/) for installation instructions) and rendered as a file such as a PNG or SVG:

```{code-block} console
$ uv run snakemake --rulegraph | dot -Tsvg -o rulegraph.svg
```

```{figure} _static/rulegraph.svg
```

There is also the `--dag` option, similar to the above --- however, it can produce crowded output and tends to be less useful than the rulegraph for realistic workflows.
However, it does produce a nice visualisation here:

```{code-block} console
$ uv run snakemake --dag | dot -Tsvg -o dag.svg
```

```{figure} _static/dag.svg
```

These visualisations are a great way of debugging and validating the connectivity between rules.
