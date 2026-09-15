import os
import re
import shutil

BASH="#!/usr/bin/env bash\n"
HEADER="source ./codecov_envs\n"
FOOTER='env | grep -io "CODECOV_.*=" | tr "=" " " | while read -r val; do echo "export $val=$(eval echo \\\"\$$val\\\")"; done > ./codecov_envs\n'
CLEANUP="rm ./codecov_envs\n"

# Orb-only: empty exports so assignments in later steps survive `env | grep CODECOV_`.
# Merged with assignments found in wrapper step scripts (see _preexport_suffixes).
LEGACY_PREEXPORT_SUFFIXES = [
    'BINARY_LOCATION',
    'CLI_URL',
    'COMMAND',
    'DOWNLOAD_DIR',
    'DOWNLOAD_ONLY',
    'FILENAME',
    'GCOV_ARGS',
    'GCOV_EXECUTABLE',
    'GCOV_IGNORE',
    'GCOV_INCLUDE',
    'PUBLIC_PGP_KEY',
    'SWIFT_PROJECT',
    'WRAPPER_VERSION',
    'YML_PATH',
]

WRAPPER_STEP_SCRIPTS = ('set_defaults.sh', 'download.sh', 'validate.sh')


def package():
    funcs = _get_funcs()
    _copy_all_files(funcs)
    _combine_set_args_and_run(funcs)
    _write_set_codecov_envs()


def _assigned_codecov_vars(script_name):
    path = os.path.join('src', 'scripts', 'scripts', script_name)
    with open(path, 'r') as f:
        text = f.read()
    return set(re.findall(r'^\s*(CODECOV_[A-Z0-9_]+)=', text, re.MULTILINE))


def _wrapper_env_suffixes():
    path = os.path.join('src', 'scripts', 'env')
    if not os.path.isfile(path):
        return set()
    suffixes = set()
    with open(path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('CC_'):
                suffixes.add(line[3:])
    return suffixes


def _preexport_suffixes():
    assigned = set()
    for script in WRAPPER_STEP_SCRIPTS:
        assigned |= _assigned_codecov_vars(script)

    suffixes = set(LEGACY_PREEXPORT_SUFFIXES)
    for var in assigned:
        suffixes.add(var.removeprefix('CODECOV_'))

    wrapper_env = _wrapper_env_suffixes()
    download_assigned = _assigned_codecov_vars('download.sh')
    for var in download_assigned:
        suffix = var.removeprefix('CODECOV_')
        if suffix in wrapper_env and suffix not in suffixes:
            print(
                f'Wrapper env lists CC_{suffix} but orb pre-export list is missing '
                f'CODECOV_{suffix}; update LEGACY_PREEXPORT_SUFFIXES or wrapper scripts.'
            )
            exit(1)

    return sorted(suffixes)


def _write_set_codecov_envs():
    suffixes = _preexport_suffixes()
    lines = [
        BASH.rstrip('\n'),
        '',
        'touch ./codecov_envs',
        'chmod u+x ./codecov_envs',
        'echo "#!/usr/bin/env bash" > ./codecov_envs',
        '',
    ]
    for suffix in suffixes:
        lines.append(f'export CODECOV_{suffix}=')
    lines.extend([
        '',
        'env | grep -i "CODECOV_" | grep -iv "CODECOV_TOKEN" | sed -e \'s/^/export /\' > ./codecov_envs',
        'cat ./codecov_envs',
        '',
    ])
    path = os.path.join('src', 'dist', 'set_codecov_envs.sh')
    with open(path, 'w') as f:
        f.write('\n'.join(lines))
    os.chmod(path, 0o711)
    print(f'Wrote {path} with {len(suffixes)} pre-export vars')

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
