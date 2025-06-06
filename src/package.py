import os
import re
import shutil

BASH="#!/usr/bin/env bash\n"
HEADER="source ./codecov_envs\n"
FOOTER='env | grep -io "CODECOV_.*=" | tr "=" " " | while read -r val; do echo "export $val=$(eval echo \\\"\$$val\\\")"; done > ./codecov_envs\n'
CLEANUP="rm ./codecov_envs\n"

def package():
    funcs = _get_funcs()
    _copy_all_files(funcs)
    _combine_set_args_and_run(funcs)

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
            contents = []
            codecov_vars_set = set()
            with open(new_file, 'r') as f:
                for line in f:
                    script_match = re.search(r'\S+\.sh', line)
                    if not script_match:
                        contents.append(line)
                        continue

                    script_path = script_match.group()
                    with open(os.path.join(original_dir, script_path), 'r') as f:
                        contents.append(f.read())

            if filename not in ['run_command.sh', 'set_args.sh']:
                contents.insert(0, HEADER)
                contents.insert(1, funcs)
                contents.append(FOOTER)
                contents = ''.join(contents).replace(BASH, "")
                contents = BASH + contents
            else:
                contents = ''.join(contents).replace(BASH, "")

            if len(''.join(contents)) >= 8191:
                print(f'Due to Windows limitations, script {new_file} must be less than 8192 chars')
                exit(1)

            with open(new_file, 'w') as f:
                f.write(''.join(contents))

            print(f'Copied {old_file} to {new_file} ({len(contents)} chars)')

def _combine_set_args_and_run(funcs):
    contents = [BASH, HEADER, funcs.replace(BASH, "")]
    with open('src/dist/set_args.sh', 'r') as f:
        for line in f:
            contents.append(line)
    with open('src/dist/run_command.sh', 'r') as f:
        for line in f:
            contents.append(line)

    contents.append(CLEANUP)
    contents = ''.join(contents)

    if len(contents) >= 8191:
        print(f'Due to Windows limitations, script {new_file} must be less than 8192 chars')
        exit(1)

    with open('src/dist/run_command.sh', 'w') as f:
        f.write(contents)

    print(f'Combined set_args.sh and run_command.sh into run_command.sh ({len(contents)} chars)')


if __name__=="__main__":
    package()
