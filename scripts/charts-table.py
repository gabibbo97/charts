#!/usr/bin/env python3
from pathlib import Path

CHARTS = {}

for element in Path('charts').iterdir():
  if not element.is_dir():
    continue
  if (element / 'README.md').exists():
    # Skip deprecated
    if (element / 'Chart.yaml').exists():
      # Not elegant but works
      if 'deprecated: true' in open((element / 'Chart.yaml'), 'r').read():
        continue
    CHARTS[element.name] = (element / 'README.md')

for chart_name, readme_path in CHARTS.items():
  print(f'* [{chart_name}]({readme_path})')
