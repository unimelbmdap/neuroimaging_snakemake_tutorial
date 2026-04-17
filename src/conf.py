project = "Orchestrating neuroimaging data processing using the 'Snakemake' workflow manager"
copyright = "2026, MDAP"
author = "MDAP"
version = "0.1"
release = version

extensions = [
    "myst_parser",
    "sphinx_copybutton",
]

# myst_nb
nb_execution_timeout = -1
nb_execution_mode = "cache"
nb_execution_cache_path = ".myst_nb_cache"

myst_render_markdown_format = "myst"

myst_enable_extensions = [
    "amsmath",
    "colon_fence",
    "deflist",
    "dollarmath",
    "html_image",
    "attrs_block",
]

copybutton_exclude = ".linenos, .gp"

templates_path = ["_templates"]
exclude_patterns = []
source_suffix = [".md"]

maximum_signature_line_length = 88

html_theme = "furo"
html_static_path = ["_static"]

html_show_copyright = False
html_show_sphinx = False
html_show_sourcelink = False

html_theme_options = {
    "sidebar_hide_name": False,
}

html_title = project
html_last_updated_fmt = ""
#html_search = False
#html_sidebars = {
#    "**": [
#        "sidebar/scroll-start.html",
#        "sidebar/navigation.html",
#        "sidebar/scroll-end.html",
#    ],
#}

def setup(app):
    app.add_css_file("theme_hide.css")
    app.add_css_file("code_boxes.css")
