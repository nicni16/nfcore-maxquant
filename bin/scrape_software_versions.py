#!/usr/bin/env python
from __future__ import print_function
from collections import OrderedDict
import re

regexes = {
    "nf-core/maxquant": ["pipeline.version.txt", r"(\S+)"],
    "Nextflow": ["nextflow.version.txt", r"(\S+)"],
    "SDRF": ["sdrfpipelines.version.txt", r"(\S+)"],
    "Maxquant": ["maxquant.version.txt", r"(\S+)"],
    "Normalyzerde": ["normalizerde.version.txt", r"(\S+)"]
}
results = OrderedDict()
results["nf-core/maxquant"] = '<span style="color:#999999;">N/A</span>'
results["Nextflow"] = '<span style="color:#999999;">N/A</span>'
results["SDRF"] = '<span style="color:#999999;">N/A</span>'
results["Maxquant"] = '<span style="color:#999999;">N/A</span>'
results["Normalyzerde"] = '<span style="color:#999999;">N/A</span>'

# Search each file using its regex
for k, v in regexes.items():
    try:
        with open(v[0]) as x:
            versions = x.read()
            match = re.search(v[1], versions)
            if match:
                results[k] = "v{}".format(match.group(1))
    except IOError:
        results[k] = False

# Remove software set to false in results
for k in list(results):
    if not results[k]:
        del results[k]

# Dump to YAML
print(
    """
id: 'software_versions'
section_name: 'nf-core/maxquant Software Versions'
section_href: 'https://github.com/nf-core/maxquant'
plot_type: 'html'
description: 'are collected at run time from the software output.'
data: |
    <dl class="dl-horizontal">
"""
)
for k, v in results.items():
    print("        <dt>{}</dt><dd><samp>{}</samp></dd>".format(k, v))
print("    </dl>")

# Write out regexes as csv file:
with open("software_versions.csv", "w") as f:
    for k, v in results.items():
        f.write("{}\t{}\n".format(k, v))
