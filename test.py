from glob import glob
from os import path
from sys import argv
from subprocess import Popen, PIPE, STDOUT

with open('env', 'r') as file:
    crafting_interpreters_dir = file.read()

tests = f'{crafting_interpreters_dir}/test/**/*.lox'
chapters = [
    'chap08_statements'
]

# Check program arguments.
arg_length = len(argv)

if arg_length != 3:
    print(f'Expected three program arguments. Got {arg_length}.')
    exit()

chapter = argv[1]
custom_interpreter = argv[2]

if chapter not in chapters:
    print(f'Unexpected chapter \'{chapter}\'.')
    exit()

if not path.exists(custom_interpreter):
    print(f'Unable to find \'{custom_interpreter}\'.')
    exit()

tests = glob(tests, recursive=True)

# Get test results for validation and training interpreter.
results = {}

with open('test_results.txt', 'w') as file:
    for i, test in enumerate(tests):
        print(f'Running test {i + 1} of {len(tests)} {test}... ', end='')

        with Popen(
            ['java', '-jar', f'{crafting_interpreters_dir}/gen/{chapter}/{chapter}.jar', test], stdin=PIPE,
                stdout=PIPE, stderr=STDOUT, universal_newlines=True)as validation:
            validation_output, _ = validation.communicate()

        with Popen([custom_interpreter, test], stdin=PIPE, stdout=PIPE, stderr=STDOUT, universal_newlines=True) as training:
            training_output, _ = training.communicate()

        if validation_output == None:
                validation_output = ''

        if training_output == None:
                training_output = ''

        lines = []

        passed = validation_output == training_output

        if passed:
            print('[PASS]')
            lines.append('[PASS]')
        else:
            print('[FAIL]')
            lines.append('[FAIL]')

        lines.append(test)

        if not passed:
            lines.extend([
                '[Validation]',
                validation_output,
                '[Training]',
                training_output,
            ])

        lines.append('\n------------------------------------\n\n')

        file.writelines('\n'.join(lines))
