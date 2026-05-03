# neuroimaging_snakemake_tutorial

This contains the source documents and Snakemake workflow for the website that accompanies the paper ["Orchestrating neuroimaging data processing using the ‘Snakemake’ workflow manager"](https://osf.io/preprints/psyarxiv/fmdvn_v1).

See [https://unimelbmdap.github.io/neuroimaging_snakemake_tutorial/](https://unimelbmdap.github.io/neuroimaging_snakemake_tutorial/) for the built documentation.

## Building the docs

```bash
uv run sphinx-build src output
```

## Running the workflow

### Build the custom container

```bash
cd workflow/containers
apptainer build py312-matplotlib-nibabel.def py312-matplotlib-nibabel.sif
```

### Run the workflow

```bash
cd workflow
uv run snakemake
```
