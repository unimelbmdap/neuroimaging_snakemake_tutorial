# Data acquisition

The first step in our processing pipeline is to acquire a local copy of the raw data.
The raw data for this study is stored on [OpenNeuro](https://openneuro.org/datasets/ds000030/versions/1.0.0).
If we browse to that website and go to the 'Download' tab, we can see that the data can be downloaded via the [Amazon S3](https://en.wikipedia.org/wiki/Amazon_S3) storage infrastructure.

Our task now is to write Snakemake rules that will use the [AWS CLI](https://aws.amazon.com/cli/) to download the anatomical and functional image data of interest for each of our participants.
We could potentially aim to download everything in the one rule, but the differences between the file structure of anatomical and functional images makes it simpler to have separate rules.


:::{note}
Ideally, the [S3 storage plugin](https://github.com/snakemake/snakemake-storage-plugin-s3) would allow access to the raw data as required, rather than specifically being downloaded as a first step.
However, it currently [doesn't support the public data access](https://github.com/snakemake/snakemake-storage-plugin-s3/issues/59) that is required for this raw data.
:::

## Rule for anatomical image acquisition

We will first tackle the rule to acquire the anatomical images.

### Outputs

The first step is to think about the outputs that the rule will produce.
Given our list of subject numbers, we expect that the workflow will generate the following output files:

```{code-block} none
results/sub-10159/anat/sub-10159_T1w.nii.gz
results/sub-10171/anat/sub-10171_T1w.nii.gz
results/sub-10189/anat/sub-10189_T1w.nii.gz
```

When creating the rule, we want to abstract away aspects of the output that are specific to a particular subject.
We do that by replacing those characters with a *wildcard* for `sub_num`:

```{code-block} none
results/sub-{sub_num}/anat/sub-{sub_num}_T1w.nii.gz
```

As you can see, each of the required output files can be created by plugging in a particular value for `sub_num`.

We can now start to create the rule, called `acquire_anat`, that specifies a single output that we refer to as `nii` and that contains the `sub_num` wildcard:

```{literalinclude} ../workflow/workflow/rules/acquire_anat.smk
:caption: `workflow/workflow/rules/acquire_anat.smk`
:language: snakemake
:lines: 1-4
```


### Inputs

The next step when creating a rule is to think about the *inputs* that are required to produce the output.
Here, we don't actually need any inputs --- so we can omit an `input` section from the rule.

### Parameters

Now we can think about any parameters that are required for the operation of the rule.
For our purposes, it is useful to build the OpenNeuro URL as a parameter that can then be used by the downloading mechanism.
In particular, we just need to combine the study data location (the S3 URL `s3://openneuro.org/ds000030/`) with the relative location of an output image (without the `results/` prefix).

Because we need the output path *after* the `sub_num` wildcard has been replaced with a specific value, we specify this parameter as a function.
Here, we use an anonymous (lambda) function and use the provided `output` argument:

```{literalinclude} ../workflow/workflow/rules/acquire_anat.smk
:caption: `workflow/workflow/rules/acquire_anat.smk`
:language: snakemake
:lines: 1-8
:emphasize-lines: 5-8
```

### Mechanism

Now we need to think about the rule's mechanism --- how the output files are produced.

#### Container

As outlined above, we want to use the AWS CLI to download the data from OpenNeuro.
We could try to install this software locally, which can then be used when running Snakemake.
However, a more reproducible approach is to use a container that, well, contains the AWS CLI in addition to the supporting operating system and dependencies.

If we search the internet for an AWS CLI container, we can see that one is hosted by Amazon on the [Docker Hub](https://hub.docker.com/r/amazon/aws-cli/).
From that site, we can see its location identifier is something like `amazon/aws-cli:2.32.21` (the latest version number will vary over time).
We can provide this information in the rule, along with the `docker://` protocol prefix, to specify that the rule should execute its job within this container:

```{literalinclude} ../workflow/workflow/rules/acquire_anat.smk
:caption: `workflow/workflow/rules/acquire_anat.smk`
:language: snakemake
:lines: 1-10
:emphasize-lines: 9-10
```

#### Logging

Because multiple jobs can be running simultaneously, and potentially on different computers, we do not easily have a way of monitoring any output that gets printed to the terminal as a rule executes.
Instead, we can redirect any such output to a log file.
Here, we specify the location of this log file:

```{literalinclude} ../workflow/workflow/rules/acquire_anat.smk
:caption: `workflow/workflow/rules/acquire_anat.smk`
:language: snakemake
:lines: 1-12
:emphasize-lines: 11-12
```

Note that this doesn't actually *do* any logging or any redirection of terminal output --- it just specifies the location of the log file, which can then be used by other components in the rule (as we will see).


#### Command

Now we need to specify the AWS CLI command that will download the data.
We use the `shell` directive in the rule to specify the command to execute, using wildcards for the remote URL and the output path (and the log path):

```{literalinclude} ../workflow/workflow/rules/acquire_anat.smk
:caption: `workflow/workflow/rules/acquire_anat.smk`
:language: snakemake
:emphasize-lines: 13-
```

The details on the construction of this command is out of the scope of this tutorial.
However, it is worth noting that interactive exploration of a containerised command is aided by having a local copy of the container --- obtained using the `apptainer pull` command.
For example, `apptainer pull "docker://amazon/aws-cli:2.32.21"` will download the container into a local file named `aws-cli_2.32.21.sif`.
An interactive console running inside the container can then be obtained by `apptainer shell aws-cli_2.32.21.sif`.
You could then run something like `aws s3 cp help` to see the command-line options.

A potentially cryptic aspect of the command is the final `> {log} 2>&1` statement.
That can be read as "redirect (`>`) to the file (`{log}`), both standard error (`2`) and (`>&`) standard output (`1`)".
It is just some arcane syntax that puts any printed output from the command into the log file rather than to the screen.

### Resources

We also need to consider the resources that are required by the rule.
Here, there is nothing special required --- so we omit any resource-related directives.

## Rule for functional image acquisition

Now that we have a complete rule for the anatomical image acquisition, we can turn to the rule for the functional image acquisition.

We can first note that the process for acquiring functional images is pretty much the same as for anatomical images --- just with different paths.
We could start by copying the `acquire_anat.smk` file that we just created.
However, this puts the same information in multiple places and becomes prone to inconsistencies.

Instead, we can use [rule inheritance](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#snakefiles-rule-inheritance) to ask Snakemake to use everything from the `acquire_anat` rule except for what we explicitly override.
We do this via:

```{literalinclude} ../workflow/workflow/rules/acquire_func.smk
:caption: `workflow/workflow/rules/acquire_func.smk`
:language: snakemake
:lines: 1
```

### Outputs

As with the anatomical acquisition rule, we can start by thinking about all the output that will be produced by the rule.

```{code-block} none
results/sub-10159/func/sub-10159_task-stopsignal_bold.nii.gz
results/sub-10159/func/sub-10159_task-taskswitch_bold.nii.gz
results/sub-10171/func/sub-10171_task-stopsignal_bold.nii.gz
results/sub-10171/func/sub-10171_task-taskswitch_bold.nii.gz
results/sub-10189/func/sub-10189_task-stopsignal_bold.nii.gz
results/sub-10189/func/sub-10189_task-taskswitch_bold.nii.gz
```

We can see that, in addition to the `sub_num` wildcard that was required for the anatomical rule, there is also a `task` wildcard.
We can thus specify the rule output as:

```{literalinclude} ../workflow/workflow/rules/acquire_func.smk
:caption: `workflow/workflow/rules/acquire_func.smk`
:language: snakemake
:lines: 1-3
:emphasize-lines: 2-3
```

### Mechanism

#### Logging

We need to override the path for the log file:

```{literalinclude} ../workflow/workflow/rules/acquire_func.smk
:caption: `workflow/workflow/rules/acquire_func.smk`
:language: snakemake
:emphasize-lines: 4-
```


## Preparing for execution

At this point, we have specified the procedure for *how* the raw data files can be downloaded.
Now, we need to tell Snakemake *which* output files we want the workflow to produce.

First, we need to include our newly-created rules within the `Snakefile`:

```{literalinclude} ../workflow/workflow/Snakefile_acquire
:caption: `workflow/workflow/Snakefile`
:language: snakemake
:lines: 1-3
:emphasize-lines: 2-3
```

Now we need to describe a special rule, called `all` by convention.
The input to this rule is the set of output files that are to be produced by the workflow.
As such, they cannot contain any wildcards.

At this point, we want the output to be the anatomical images for each of the subject numbers of interest and the functional images for each pairwise combination of the subject numbers of interest and the tasks of interest.
We can use the [`expand` helper function](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#the-expand-function) to insert these values into the rule output paths:


```{literalinclude} ../workflow/workflow/Snakefile_acquire
:caption: `workflow/workflow/Snakefile`
:language: snakemake
:emphasize-lines: 5-
```

## Executing the workflow

We now have everything in order to actually run the workflow!

However, before doing so it is typically useful to do a 'dry run'.
This shows us what Snakemake is planning to do, but does not actually execute the jobs.
We can do a dry run via:

```console
uv run snakemake --dry-run
```

This will produce a bunch of output.
If we start at the top, it will look something like:

```none
Using workflow specific profile profiles/default for setting default command line arguments.
host: djmhomepc
Building DAG of jobs...
Singularity image docker://amazon/aws-cli:2.32.21 will be pulled.
Job stats:
job             count
------------  -------
acquire_anat        3
acquire_func        6
all                 1
total              10
```

We can see that it has picked up our command line arguments profile, and that it has recognised that it needs to pull the container in order to run the rules.
It also shows that it needs to run the `acquire_anat` rule 3 times and the `acquire_func` rule 6 times --- which matches our expectation on the number of output files that will be produced.

We can also look at the details for specific jobs, such as an anatomical data acquisition:

```none
rule acquire_anat:
    output: results/sub-10159/anat/sub-10159_T1w.nii.gz
    jobid: 1
    reason: Missing output files: results/sub-10159/anat/sub-10159_T1w.nii.gz
    wildcards: sub_num=10159
    resources: tmpdir=<TBD>
Shell command: 
aws s3 cp --no-sign-request --only-show-errors s3://openneuro.org/ds000030/sub-10159/anat/sub-10159_T1w.nii.gz results/sub-10159/anat/sub-10159_T1w.nii.gz
```

Note that Snakemake states its reason for running the job - here, because the required output file is not present.
It also shows the wildcard value that it will use, and the shell command that is constructed.

The description for a functional acquisition job is similar:

```none
rule acquire_func:
    output: results/sub-10171/func/sub-10171_task-stopsignal_bold.nii.gz
    jobid: 7
    reason: Missing output files: results/sub-10171/func/sub-10171_task-stopsignal_bold.nii.gz
    wildcards: sub_num=10171, task=stopsignal
    resources: tmpdir=<TBD>
Shell command: 
aws s3 cp --no-sign-request --only-show-errors s3://openneuro.org/ds000030/sub-10171/func/sub-10171_task-stopsignal_bold.nii.gz results/sub-10171/func/sub-10171_task-stopsignal_bold.nii.gz
```

If all looks good, we can go ahead and actually run the workflow:

```console
uv run snakemake
```

Snakemake will print its progress to the screen.
When it completes, the required output files will be found in the `results/` directory.
