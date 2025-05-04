import os

def package():
    rows = []
    with open('src/scripts/env', 'r') as f:
        for row in f:
            filtered_row = _filter_row(row)
            if filtered_row:
                rows.append(filtered_row)
        f.readline()

    with open('src/scripts/dist/env.sh', 'w+') as f:
        for row in rows:
            f.write(f'echo "export {row}=${row}" >> "$BASH_ENV"\n')

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
