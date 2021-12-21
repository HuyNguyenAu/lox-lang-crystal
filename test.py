from glob import glob
from os import path
from sys import argv
from subprocess import Popen, PIPE, STDOUT

with open('env', 'r') as file:
    crafting_interpreters_dir = file.read()

chapters = {
    'chap08_statements': [
        'test/comments/line_at_eof.lox',
        'test/comments/only_line_comment.lox',
        'test/comments/unicode.lox',
        'test/comments/only_line_comment_and_line.lox',
        'test/empty_file.lox',
        'test/variable/in_nested_block.lox',
        'test/variable/scope_reuse_in_different_blocks.lox',
        'test/variable/use_global_in_initializer.lox',
        'test/variable/use_this_as_var.lox',
        'test/variable/redeclare_global.lox',
        'test/variable/use_nil_as_var.lox',
        'test/variable/undefined_global.lox',
        'test/variable/shadow_and_local.lox',
        'test/variable/uninitialized.lox',
        'test/variable/use_false_as_var.lox',
        'test/variable/shadow_global.lox',
        'test/variable/in_middle_of_block.lox',
        'test/variable/shadow_local.lox',
        'test/variable/redefine_global.lox',
        'test/variable/undefined_local.lox',
        'test/nil/literal.lox',
        'test/assignment/grouping.lox',
        'test/assignment/syntax.lox',
        'test/assignment/global.lox',
        'test/assignment/prefix_operator.lox',
        'test/assignment/associativity.lox',
        'test/assignment/infix_operator.lox',
        'test/assignment/local.lox',
        'test/assignment/undefined.lox',
        'test/print/missing_argument.lox',
        'test/number/literals.lox',
        'test/number/leading_dot.lox',
        'test/bool/equality.lox',
        'test/bool/not.lox',
        'test/string/error_after_multiline.lox',
        'test/string/literals.lox',
        'test/string/multiline.lox',
        'test/string/unterminated.lox',
        'test/precedence.lox',
        'test/operator/add_num_nil.lox',
        'test/operator/subtract_num_nonnum.lox',
        'test/operator/multiply.lox',
        'test/operator/negate.lox',
        'test/operator/divide_nonnum_num.lox',
        'test/operator/comparison.lox',
        'test/operator/greater_num_nonnum.lox',
        'test/operator/less_or_equal_nonnum_num.lox',
        'test/operator/multiply_nonnum_num.lox',
        'test/operator/not_equals.lox',
        'test/operator/add_bool_num.lox',
        'test/operator/negate_nonnum.lox',
        'test/operator/add.lox',
        'test/operator/greater_or_equal_nonnum_num.lox',
        'test/operator/equals.lox',
        'test/operator/less_nonnum_num.lox',
        'test/operator/add_bool_string.lox',
        'test/operator/divide.lox',
        'test/operator/add_string_nil.lox',
        'test/operator/add_bool_nil.lox',
        'test/operator/divide_num_nonnum.lox',
        'test/operator/multiply_num_nonnum.lox',
        'test/operator/less_or_equal_num_nonnum.lox',
        'test/operator/greater_nonnum_num.lox',
        'test/operator/add_nil_nil.lox',
        'test/operator/subtract.lox',
        'test/operator/subtract_nonnum_num.lox',
        'test/operator/greater_or_equal_num_nonnum.lox',
        'test/operator/less_num_nonnum.lox',
        'test/block/scope.lox',
    ]
}

# Check program arguments.
arg_length = len(argv)

if arg_length != 3:
    print(f'Expected three program arguments. Got {arg_length}.')
    exit()

chapter = argv[1]
custom_interpreter = argv[2]

if chapter not in chapters.keys():
    print(f'Unexpected chapter \'{chapter}\'.')
    exit()

if not path.exists(custom_interpreter):
    print(f'Unable to find \'{custom_interpreter}\'.')
    exit()

tests = [f'{crafting_interpreters_dir}/{test}' for test in chapters[chapter]]

# Get test results for validation and training interpreter.
results = {}

with open('test_results.txt', 'w') as file:
    passed_tests = 0
    failed_tests = 0

    for i, test in enumerate(tests):
        print(f'Running test {i + 1} of {len(tests)} {test}... ', end='')

        with Popen(
            ['java', '-jar', f'{crafting_interpreters_dir}/gen/{chapter}/{chapter}.jar', test], stdin=PIPE,
                stdout=PIPE, stderr=STDOUT, universal_newlines=True)as validation:
            validation_output, _ = validation.communicate()

        with Popen([custom_interpreter, test], stdin=PIPE, stdout=PIPE, stderr=STDOUT, universal_newlines=True) as training:
            training_output, _ = training.communicate()

        validation_output = validation_output.strip()
        training_output = training_output.strip()
        
        if validation_output == None:
            validation_output = ''

        if training_output == None:
            training_output = ''

        lines = []

        passed = validation_output == training_output

        if passed:
            passed_tests += 1
            print('[PASS]')
            lines.append('[PASS]')
        else:
            failed_tests += 1
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

    file.write(f'Passed {passed_tests}. Failed {failed_tests}.')
    print(f'Passed {passed_tests}. Failed {failed_tests}.')
