import os
import re
import shutil

BASH="#!/usr/bin/env bash\n"
HEADER="source ./codecov_envs\n"
FOOTER='env | grep -io "CODECOV_.*=" | tr "=" " " | while read -r val; do echo "export $val=\\\"$(eval echo \\\"\$$val\\\")\\\""; done; > ./codecov_envs\n'

def package():
    funcs = _get_funcs()
    _copy_all_files(funcs)

def _get_funcs():
    with open('src/scripts/scripts/set_funcs.sh', 'r') as f:
        funcs=f.read()
    return funcs

def _copy_all_files(funcs):
    files = []
    file_matcher = r'.*\/(\w+\.sh)'

    original_dir = os.path.join('src', 'scripts', 'scripts')
    new_dir = os.path.join('src', 'dist')

    with open('src/scripts/scripts/run.sh', 'r') as f:
        for line in f:
            if not line.strip().endswith('.sh'):
                continue
            match = re.search(file_matcher, line)
            if match is None:
                continue

            filename = match.groups()[0].strip()
            old_file = os.path.join(original_dir, filename)
            new_file = os.path.join(new_dir, filename)
            shutil.copyfile(old_file, new_file)
            os.chmod(new_file, 0o711)

            # Update contents
            contents = [HEADER, funcs]
            codecov_vars_set = set()
            with open(new_file, 'r') as f:
                contents.append(f.read())
            contents.append(FOOTER)

            contents = ''.join(contents).replace(BASH, "")
            contents = BASH + contents

            if len(''.join(contents)) >= 8191:
                print(f'Due to Windows limitations, script {new_file} must be less than 8192 chars')
                exit(1)

            with open(new_file, 'w') as f:
                f.write(''.join(contents))

            print(f'Copied {old_file} to {new_file} ({len(contents)} chars)')


def _filter_row(row):
    exclude_rows = set([
        'CC_AUTO_LOAD_PARAMS_FROM',
        'CC_BINARY_LOCATION',
        'CC_CLI_URL',
        'CC_DOWNLOAD_ONLY',
        'CC_GCOV_ARGS',
        'CC_GCOV_EXECUTABLE',
        'CC_GCOV_IGNORE',
        'CC_GCOV_INCLUDE',
        'CC_PUBLIC_PGP_KEY',
        'CC_SWIFT_PROJECT',
    ])

    row = row.strip()
    if row in exclude_rows:
        return None
    return row


if __name__=="__main__":
    package()
