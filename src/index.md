# Snakemake in neuroimaging: a worked example

```{toctree}
:hidden:
setup.md
prep.md
acquire.md
mc.md
tmean.md
coreg.md
figure.md
```

This is a detailed worked example of how the workflow manager [Snakemake](https://snakemake.readthedocs.io) can be used to specify and execute workflows for processing and analysing neuroimaging data.

The accompanying manuscript [Orchestrating neuroimaging data processing using the 'Snakemake' workflow manager](https://osf.io/preprints/psyarxiv/fmdvn_v1) describes the motivation and advantages for using Snakemake and provides a conceptual overview of its operation.
We recommend reading the manuscript prior to working through this tutorial.
In the manuscript, we describe a simple example workflow that processes [publicly-available data](https://doi.org/10.18112/openneuro.ds000030.v1.0.0) from an fMRI study by Poldrack et al. (2016).
In this website, we extend this example by:
* Providing stepwise instructions that show how a workflow can be built incrementally.
* Adding additional workflow stages that highlight the flexibility and capacity of Snakemake as a whole-workflow manager.


Please report any issues or raise any questions via [email](mailto:damien.mannion@unimelb.edu.au) or the [issue tracker](https://github.com/unimelbmdap/neuroimaging_snakemake_tutorial) in the repository.

If you find this useful, please consider letting us know via [email](mailto:damien.mannion@unimelb.edu.au) and by citing the accompanying paper:

> Mannion, D.J., Quiroga, M.M., Paul, J.M., & Garrido, M.I. (2026) Orchestrating neuroimaging data processing using the 'Snakemake' workflow manager. *PsyArXiv*. [https://doi.org/10.31234/osf.io/fmdvn_v1](https://doi.org/10.31234/osf.io/fmdvn_v1)

## Contents

[Preparation](setup.md)
: Describes the steps required to set up the necessary software and initialise the project.

[Configuration](prep.md)
: Prepares configuration details for the example analysis.

[Data acquisition](acquire.md)
: Implements an initial workflow step that downloads the raw data from the example dataset.

[Motion correct](mc.md)
: Implements a 'motion correction' step in the pre-processing of fMRI BOLD images.

[Temporal averaging](tmean.md)
: Implements a 'temporal averaging' step to summarise fMRI BOLD images.

[Coregistration](coreg.md)
: Coregisters the anatomical and functional images.

[Visualisation](figure.md)
: Produces an example visualisation of the processed data.
