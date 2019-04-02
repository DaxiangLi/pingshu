#!/usr/bin/python3

"""
Convert YAML file to JSON file or convert JSON file to YAML file, also support
to load a YAML file and dump it out in case it looks ugly

Note we use oyaml which is a drop-in replacement for PyYAML which preserves
dict ordering. And you have to install PyYAML first, then have a try, e.g.
    $ git clone https://github.com/wimglenn/oyaml.git /tmp/oyaml
    $ export PYTHONPATH=/tmp/oyaml:$PYTHONPATH

"""

import sys
import getopt
import json
import collections
import oyaml as yaml


def to_json(txt, indent=4):
    # XXX: yaml.load() support to load both JSON and YAML
    obj = yaml.load(txt)
    out = json.dumps(obj, indent=indent)
    return out


def to_yaml(txt, indent=2):
    # XXX: yaml.load() support to load both JSON and YAML
    obj = yaml.load(txt)
    out = yaml.dump(obj, default_flow_style=False, indent=indent)
    return out.rstrip('\n')


def new_argv(argv0, rargv):
    argv = []
    argv.append(argv0)
    argv.extend(rargv)
    return argv


def usage(argv0):
    sys.stderr.write('Usage: %s [-t indent] [-o outfile] <subcmd> '
                     '<yaml or json file>\n' % argv0)
    sys.stderr.write('subcmd:\n')
    sys.stderr.write('\ttojson | j : convert yaml to json OR\n')
    sys.stderr.write('\t             load json then dump out\n')
    sys.stderr.write('\ttoyaml | y : convert json to yaml OR\n')
    sys.stderr.write('\t             load yaml then dump out\n')
    sys.stderr.write('e.g.\n')
    sys.stderr.write('       %s tojson foo1.yaml\n' % argv0)
    sys.stderr.write('       %s toyaml foo2.json\n' % argv0)
    sys.stderr.write('       %s toyaml foo3.yaml\n' % argv0)
    sys.stderr.write('       %s -t 8 -o foo2.json tojson foo1.yaml\n' % argv0)
    sys.stderr.write('       %s -t 2 -o foo1.yaml toyaml foo2.json\n' % argv0)
    sys.stderr.write('       %s -t 2 -o foo3.yaml toyaml foo1.yaml\n' % argv0)


def main(argc, argv):
    indent = 4
    output_file = None

    options, rargv = getopt.getopt(argv[1:],
                                   ':t:o:h',
                                   ['indent=', 'output=', 'help'])
    for opt, arg in options:
        if opt in ('-t', '--indent'):
            indent = int(arg)
        elif opt in ('-o', '--output'):
            output_file = arg
        else:
            usage(argv[0])
            return 1

    argv = new_argv(argv[0], rargv)
    argc = len(argv)
    if argc != 3:
        usage(argv[0])
        return 1

    subcmd = argv[1]
    yaml_file = argv[2]
    txt = None
    with open(yaml_file, 'r') as file_handler:
        txt = ''.join(file_handler.readlines())

    if subcmd in ['tojson', 'j']:
        out = to_json(txt, indent)
    elif subcmd in ['toyaml', 'y']:
        out = to_yaml(txt, indent)
    else:
        usage(argv[0])
        return 1

    if output_file is None:
        print(out)
    else:
        with open(output_file, 'w') as file_handler:
            file_handler.write('%s\n' % out)

    return 0


if __name__ == '__main__':
    sys.exit(main(len(sys.argv), sys.argv))
