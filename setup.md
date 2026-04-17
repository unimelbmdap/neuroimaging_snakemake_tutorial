# Preparation

## Install required software

### Apptainer

We will be using the Apptainer software to execute computational jobs in containers.
It can be installed by following [the instructions from Apptainer](https://apptainer.org/docs/admin/main/installation#).

To check that Apptainer has been installed, you can ask it to print its version information:

```{code-block} console
$ apptainer --version
```

Here, we are using this version of Apptainer:

```{code-block} none
apptainer version 1.4.5
```

### Python project manager (uv)

The uv software allows for management of the Python project, and can be installed following [the instructions from uv](https://docs.astral.sh/uv/getting-started/installation/).

To check that uv has been installed, you can ask uv to print its version information:

```{code-block} console
uv --version
```

Here, we are using this version of uv:

```{code-block} none
uv 0.11.7 (x86_64-unknown-linux-gnu)
```

## Initialise project

First, set your working directory to the base directory of your project.
It is best if this directory is empty at this point.

You can check what directory you are currently in by running:
```{code-block} console
echo $PWD
```

First, we initialise the Python project.
We will use the `--bare` option to just create a minimal project configuration, consisting only of a basic `pyproject.toml` file.

```{code-block} console
$ uv init --bare
```

We then add our key dependency, Snakemake:

```{code-block} console
$ uv add snakemake
```

This will create a `uv.lock` file, which records the version of Snakemake that is used and the versions of its dependencies.
This allows others to reproduce the Python environment that was used in the project.


<!--
We then make a few directories that will contain the project files:

```{code-block} console
$ mkdir workflow
$ mkdir workflow/rules
$ mkdir workflow/scripts
$ mkdir results
$ mkdir logs
$ mkdir profiles
$ mkdir profiles/default
```

-->

<!--use `tree -F`-->
<!--
At this point, the contents of the project directory should be:


```{code-block} none
./
├── logs/
├── profiles/
│   └── default/
├── pyproject.toml
├── results/
├── uv.lock
└── workflow/
    ├── rules/
    └── scripts/
```
-->

## Set default Snakemake command-line arguments

First, make the directory that will contain the command-line argument configuration file: 

```{code-block} console
mkdir --parents workflow/profiles/default
```

Then, specify the configuration in YAML format in the `config.yaml` file:

```{literalinclude} workflow/profiles/default/config.yaml
:caption: `workflow/profiles/default/config.yaml`
:language: yaml
```


:::{note}
You may want to set the value of the `cores` key to a number rather than `all`, to limit how many cores Snakemake can use at a time.
:::
