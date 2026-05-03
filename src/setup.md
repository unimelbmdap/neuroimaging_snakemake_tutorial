# Preparation

Following along with this worked example will require typing commands into a console and using a text editor.

The console commands are displayed with a `$` prefix and assume the use of a Bash shell --- they may require minor modifications on other shells.
You are free to use whichever text editor you prefer, such as vim, emacs, nano, or VSCode.

This guide has been written using the Linux platform.
However, it is likely to work on Mac platforms without modification.
It may be able to run natively on Windows with some modification, but we recommend using the [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) to instead use Linux within Windows.

:::{note}
It will also require about 10 GB of disk space.
:::

## Install required software

Following the example will require two critical software applications to be available: Apptainer and uv.

### Apptainer

We will be using the Apptainer software to execute computational jobs in containers.
It can be installed by following [the instructions from Apptainer](https://apptainer.org/docs/admin/main/installation#).

To check that Apptainer has been installed, you can ask it to print its version information:

```{code-block} console
$ apptainer --version
```

Here, we are using this version of Apptainer:

```{code-block} none
:class: console-output
apptainer version 1.4.5
```

### Python project manager (uv)

The uv software allows for management of the Python project, and can be installed following [the instructions from uv](https://docs.astral.sh/uv/getting-started/installation/).

To check that uv has been installed, you can ask uv to print its version information:

```{code-block} console
$ uv --version
```

Here, we are using this version of uv:

```{code-block} none
:class: console-output
uv 0.11.7 (x86_64-unknown-linux-gnu)
```

## Initialise project

The first step is to decide a storage location that will be the base directory of the project.
It is best if this directory is empty at this point.

Begin by changing to this directory using the `cd` command.
You can check what directory you are currently in by running:
```{code-block} console
$ echo $PWD
```

First, we initialise the Python project.
We will use the `--bare` option to just create a minimal project configuration, consisting only of a basic `pyproject.toml` file.

```{code-block} console
$ uv init --bare
```

We then add our key dependency, Snakemake:

```{code-block} console
$ uv add snakemake=='9.9.0'
```

This will create a `uv.lock` file, which records the version of Snakemake that is used and the versions of its dependencies.
This allows others to reproduce the Python environment that was used in the project.

:::{note}
We have pinned Snakemake to a specific version to prevent conflicts between this guide and future updates to Snakemake.
:::

## Set default Snakemake command-line arguments

There are some command-line arguments that we will always use when we execute Snakemake.
To avoid having to specify them each time, and to provide some additional documentation for how we are running Snakemake, we can create a [profile](https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles).

First, make the directory that will contain the command-line argument configuration file: 

```{code-block} console
$ mkdir --parents workflow/profiles/default
```

Then, specify the configuration in YAML format in the `config.yaml` file:

```{literalinclude} ../workflow/profiles/default/config.yaml
:caption: `workflow/profiles/default/config.yaml`
:language: yaml
```

:::{note}
You may want to set the value of the `cores` key to a number rather than `all`, to limit how many cores Snakemake can use at a time.
:::
