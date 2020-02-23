#!/usr/bin/env python3
import sys
import yaml
import re
from pathlib import Path

def get_values_file(file):
  with open(file, 'r') as values_file:
    return values_file.read()

values_text = get_values_file(sys.argv[1])
values = yaml.safe_load(values_text)

def flattened(original):
  new_dict = {}
  for k, v in original.items():
    if isinstance(v, dict):
      inside = flattened(v)
      new_dict.update({ f'{k}.{k2}':v2 for k2,v2 in inside.items() })
    elif isinstance(v, list):
      i = 0
      for elem in v:
        if isinstance(elem, dict):
          inside = flattened(elem)
          new_dict.update({ f'{k}[{i}].{k2}':v2 for k2,v2 in inside.items() })
        else:
          new_dict.update({f'{k}[{i}]':elem})
        i += 1
    else:
      new_dict.update({k:v})
  return new_dict

values = flattened(values)

def get_default(value):
  if isinstance(value, str) and '\n' in value:
    return '<CONFIG>'
  else:
    return value

values = { k: get_default(v) for k,v in values.items() }

def try_decription(key):
  # Known patterns
  patterns = {
    r'replicaCount': 'Number of replicas to deploy',
    r'image\.?.*\.repository': 'Repository for the container image',
    r'image\.?.*\.pullPolicy': 'Pull policy for the container image',
    r'service\.type': 'The type of the service that will be created',
    r'service\.port': 'The port of the service that will be created',
    r'serviceAccount\.create': 'Create automatically a service account',
    r'serviceAccount\.name': 'The service account name',
    r'ingress\.enabled': 'Expose the service with an ingress resource',
    r'ingress\.hosts\[[0-9]+\]\.host': 'Hostname for this ingress',
  }
  for pattern, description in patterns.items():
    if re.match(pattern, key):
      return description
  return None

def remap_value(value):
  if value == True:
    return 'true'
  if value == False:
    return 'false'
  return value

for k,v in values.items():
  description = try_decription(k)
  value = remap_value(v)
  if description == None:
    print(f"|`{k}`|  | `{value}` |")
  else:
    print(f"|`{k}`| {description} | `{value}` |")