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
    ],
    'chap10_functions': [
        'test/closure/reuse_closure_slot.lox',
        'test/closure/assign_to_shadowed_later.lox',
        'test/closure/close_over_later_variable.lox',
        'test/closure/closed_closure_in_function.lox',
        'test/closure/unused_later_closure.lox',
        'test/closure/shadow_closure_with_local.lox',
        'test/closure/unused_closure.lox',
        'test/closure/close_over_function_parameter.lox',
        'test/closure/close_over_method_parameter.lox',
        'test/closure/open_closure_in_function.lox',
        'test/closure/reference_closure_multiple_times.lox',
        'test/closure/nested_closure.lox',
        'test/closure/assign_to_closure.lox',
        'test/comments/line_at_eof.lox',
        'test/comments/only_line_comment.lox',
        'test/comments/unicode.lox',
        'test/comments/only_line_comment_and_line.lox',
        'test/empty_file.lox',
        'test/limit/too_many_constants.lox',
        'test/limit/no_reuse_constants.lox',
        'test/limit/too_many_upvalues.lox',
        'test/limit/stack_overflow.lox',
        'test/limit/too_many_locals.lox',
        'test/limit/loop_too_large.lox',
        'test/variable/in_nested_block.lox',
        'test/variable/scope_reuse_in_different_blocks.lox',
        'test/variable/local_from_method.lox',
        'test/variable/use_global_in_initializer.lox',
        'test/variable/use_this_as_var.lox',
        'test/variable/redeclare_global.lox',
        'test/variable/use_nil_as_var.lox',
        'test/variable/undefined_global.lox',
        'test/variable/shadow_and_local.lox',
        'test/variable/early_bound.lox',
        'test/variable/duplicate_parameter.lox',
        'test/variable/uninitialized.lox',
        'test/variable/use_false_as_var.lox',
        'test/variable/shadow_global.lox',
        'test/variable/duplicate_local.lox',
        'test/variable/in_middle_of_block.lox',
        'test/variable/shadow_local.lox',
        'test/variable/unreached_undefined.lox',
        'test/variable/collide_with_parameter.lox',
        'test/variable/use_local_in_initializer.lox',
        'test/variable/redefine_global.lox',
        'test/variable/undefined_local.lox',
        'test/nil/literal.lox',
        'test/unexpected_character.lox',
        'test/if/var_in_then.lox',
        'test/if/dangling_else.lox',
        'test/if/truth.lox',
        'test/if/fun_in_else.lox',
        'test/if/class_in_else.lox',
        'test/if/else.lox',
        'test/if/fun_in_then.lox',
        'test/if/class_in_then.lox',
        'test/if/var_in_else.lox',
        'test/if/if.lox',
        'test/assignment/grouping.lox',
        'test/assignment/syntax.lox',
        'test/assignment/global.lox',
        'test/assignment/prefix_operator.lox',
        'test/assignment/associativity.lox',
        'test/assignment/to_this.lox',
        'test/assignment/infix_operator.lox',
        'test/assignment/local.lox',
        'test/assignment/undefined.lox',
        'test/return/after_if.lox',
        'test/return/after_else.lox',
        'test/return/at_top_level.lox',
        'test/return/return_nil_if_no_value.lox',
        'test/return/in_method.lox',
        'test/return/in_function.lox',
        'test/return/after_while.lox',
        'test/function/local_mutual_recursion.lox',
        'test/function/empty_body.lox',
        'test/function/too_many_arguments.lox',
        'test/function/missing_comma_in_parameters.lox',
        'test/function/nested_call_with_arguments.lox',
        'test/function/body_must_be_block.lox',
        'test/function/missing_arguments.lox',
        'test/function/parameters.lox',
        'test/function/local_recursion.lox',
        'test/function/recursion.lox',
        'test/function/print.lox',
        'test/function/too_many_parameters.lox',
        'test/function/mutual_recursion.lox',
        'test/function/extra_arguments.lox',
        'test/scanning/numbers.lox',
        'test/scanning/keywords.lox',
        'test/scanning/punctuators.lox',
        'test/scanning/whitespace.lox',
        'test/scanning/identifiers.lox',
        'test/scanning/strings.lox',
        'test/field/set_on_nil.lox',
        'test/field/get_on_string.lox',
        'test/field/many.lox',
        'test/field/set_on_function.lox',
        'test/field/set_on_bool.lox',
        'test/field/method.lox',
        'test/field/call_nonfunction_field.lox',
        'test/field/get_on_nil.lox',
        'test/field/set_on_class.lox',
        'test/field/set_on_string.lox',
        'test/field/on_instance.lox',
        'test/field/get_on_function.lox',
        'test/field/call_function_field.lox',
        'test/field/set_evaluation_order.lox',
        'test/field/method_binds_this.lox',
        'test/field/set_on_num.lox',
        'test/field/get_on_class.lox',
        'test/field/get_and_set_method.lox',
        'test/field/get_on_bool.lox',
        'test/field/get_on_num.lox',
        'test/field/undefined.lox',
        'test/print/missing_argument.lox',
        'test/number/decimal_point_at_eof.lox',
        'test/number/nan_equality.lox',
        'test/number/literals.lox',
        'test/number/leading_dot.lox',
        'test/number/trailing_dot.lox',
        'test/call/nil.lox',
        'test/call/bool.lox',
        'test/call/num.lox',
        'test/call/object.lox',
        'test/call/string.lox',
        'test/logical_operator/and.lox',
        'test/logical_operator/or.lox',
        'test/logical_operator/and_truth.lox',
        'test/logical_operator/or_truth.lox',
        'test/inheritance/inherit_from_nil.lox',
        'test/inheritance/inherit_from_function.lox',
        'test/inheritance/parenthesized_superclass.lox',
        'test/inheritance/set_fields_from_base_class.lox',
        'test/inheritance/inherit_from_number.lox',
        'test/inheritance/inherit_methods.lox',
        'test/inheritance/constructor.lox',
        'test/super/no_superclass_method.lox',
        'test/super/call_same_method.lox',
        'test/super/no_superclass_call.lox',
        'test/super/no_superclass_bind.lox',
        'test/super/parenthesized.lox',
        'test/super/this_in_superclass_method.lox',
        'test/super/closure.lox',
        'test/super/super_in_top_level_function.lox',
        'test/super/call_other_method.lox',
        'test/super/missing_arguments.lox',
        'test/super/super_in_closure_in_inherited_method.lox',
        'test/super/super_in_inherited_method.lox',
        'test/super/super_without_dot.lox',
        'test/super/indirectly_inherited.lox',
        'test/super/super_at_top_level.lox',
        'test/super/super_without_name.lox',
        'test/super/extra_arguments.lox',
        'test/super/bound_method.lox',
        'test/super/constructor.lox',
        'test/super/reassign_superclass.lox',
        'test/bool/equality.lox',
        'test/bool/not.lox',
        'test/expressions/evaluate.lox',
        'test/expressions/parse.lox',
        'test/for/return_closure.lox',
        'test/for/scope.lox',
        'test/for/var_in_body.lox',
        'test/for/syntax.lox',
        'test/for/return_inside.lox',
        'test/for/statement_initializer.lox',
        'test/for/statement_increment.lox',
        'test/for/statement_condition.lox',
        'test/for/closure_in_body.lox',
        'test/for/class_in_body.lox',
        'test/for/fun_in_body.lox',
        'test/class/empty.lox',
        'test/class/local_inherit_self.lox',
        'test/class/local_inherit_other.lox',
        'test/class/inherited_method.lox',
        'test/class/reference_self.lox',
        'test/class/inherit_self.lox',
        'test/class/local_reference_self.lox',
        'test/this/this_in_method.lox',
        'test/this/this_at_top_level.lox',
        'test/this/closure.lox',
        'test/this/this_in_top_level_function.lox',
        'test/this/nested_closure.lox',
        'test/this/nested_class.lox',
        'test/string/error_after_multiline.lox',
        'test/string/literals.lox',
        'test/string/multiline.lox',
        'test/string/unterminated.lox',
        'test/precedence.lox',
        'test/regression/40.lox',
        'test/regression/394.lox',
        'test/while/return_closure.lox',
        'test/while/var_in_body.lox',
        'test/while/syntax.lox',
        'test/while/return_inside.lox',
        'test/while/closure_in_body.lox',
        'test/while/class_in_body.lox',
        'test/while/fun_in_body.lox',
        'test/method/empty_block.lox',
        'test/method/arity.lox',
        'test/method/refer_to_name.lox',
        'test/method/too_many_arguments.lox',
        'test/method/print_bound_method.lox',
        'test/method/missing_arguments.lox',
        'test/method/not_found.lox',
        'test/method/too_many_parameters.lox',
        'test/method/extra_arguments.lox',
        'test/operator/add_num_nil.lox',
        'test/operator/equals_method.lox',
        'test/operator/equals_class.lox',
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
        'test/operator/not.lox',
        'test/operator/add_nil_nil.lox',
        'test/operator/subtract.lox',
        'test/operator/subtract_nonnum_num.lox',
        'test/operator/not_class.lox',
        'test/operator/greater_or_equal_num_nonnum.lox',
        'test/operator/less_num_nonnum.lox',
        'test/constructor/call_init_explicitly.lox',
        'test/constructor/return_value.lox',
        'test/constructor/init_not_method.lox',
        'test/constructor/missing_arguments.lox',
        'test/constructor/default.lox',
        'test/constructor/arguments.lox',
        'test/constructor/default_arguments.lox',
        'test/constructor/call_init_early_return.lox',
        'test/constructor/extra_arguments.lox',
        'test/constructor/return_in_nested_function.lox',
        'test/constructor/early_return.lox',
        'test/block/empty.lox',
        'test/block/scope.lox',
    ],
    'chap11_resolving': [

        'test/closure/reuse_closure_slot.lox',
        'test/closure/assign_to_shadowed_later.lox',
        'test/closure/close_over_later_variable.lox',
        'test/closure/closed_closure_in_function.lox',
        'test/closure/unused_later_closure.lox',
        'test/closure/shadow_closure_with_local.lox',
        'test/closure/unused_closure.lox',
        'test/closure/close_over_function_parameter.lox',
        'test/closure/close_over_method_parameter.lox',
        'test/closure/open_closure_in_function.lox',
        'test/closure/reference_closure_multiple_times.lox',
        'test/closure/nested_closure.lox',
        'test/closure/assign_to_closure.lox',
        'test/comments/line_at_eof.lox',
        'test/comments/only_line_comment.lox',
        'test/comments/unicode.lox',
        'test/comments/only_line_comment_and_line.lox',
        'test/empty_file.lox',
        'test/limit/too_many_constants.lox',
        'test/limit/no_reuse_constants.lox',
        'test/limit/too_many_upvalues.lox',
        'test/limit/stack_overflow.lox',
        'test/limit/too_many_locals.lox',
        'test/limit/loop_too_large.lox',
        'test/variable/in_nested_block.lox',
        'test/variable/scope_reuse_in_different_blocks.lox',
        'test/variable/local_from_method.lox',
        'test/variable/use_global_in_initializer.lox',
        'test/variable/use_this_as_var.lox',
        'test/variable/redeclare_global.lox',
        'test/variable/use_nil_as_var.lox',
        'test/variable/undefined_global.lox',
        'test/variable/shadow_and_local.lox',
        'test/variable/early_bound.lox',
        'test/variable/duplicate_parameter.lox',
        'test/variable/uninitialized.lox',
        'test/variable/use_false_as_var.lox',
        'test/variable/shadow_global.lox',
        'test/variable/duplicate_local.lox',
        'test/variable/in_middle_of_block.lox',
        'test/variable/shadow_local.lox',
        'test/variable/unreached_undefined.lox',
        'test/variable/collide_with_parameter.lox',
        'test/variable/use_local_in_initializer.lox',
        'test/variable/redefine_global.lox',
        'test/variable/undefined_local.lox',
        'test/nil/literal.lox',
        'test/unexpected_character.lox',
        'test/if/var_in_then.lox',
        'test/if/dangling_else.lox',
        'test/if/truth.lox',
        'test/if/fun_in_else.lox',
        'test/if/class_in_else.lox',
        'test/if/else.lox',
        'test/if/fun_in_then.lox',
        'test/if/class_in_then.lox',
        'test/if/var_in_else.lox',
        'test/if/if.lox',
        'test/assignment/grouping.lox',
        'test/assignment/syntax.lox',
        'test/assignment/global.lox',
        'test/assignment/prefix_operator.lox',
        'test/assignment/associativity.lox',
        'test/assignment/to_this.lox',
        'test/assignment/infix_operator.lox',
        'test/assignment/local.lox',
        'test/assignment/undefined.lox',
        'test/return/after_if.lox',
        'test/return/after_else.lox',
        'test/return/at_top_level.lox',
        'test/return/return_nil_if_no_value.lox',
        'test/return/in_method.lox',
        'test/return/in_function.lox',
        'test/return/after_while.lox',
        'test/function/local_mutual_recursion.lox',
        'test/function/empty_body.lox',
        'test/function/too_many_arguments.lox',
        'test/function/missing_comma_in_parameters.lox',
        'test/function/nested_call_with_arguments.lox',
        'test/function/body_must_be_block.lox',
        'test/function/missing_arguments.lox',
        'test/function/parameters.lox',
        'test/function/local_recursion.lox',
        'test/function/recursion.lox',
        'test/function/print.lox',
        'test/function/too_many_parameters.lox',
        'test/function/mutual_recursion.lox',
        'test/function/extra_arguments.lox',
        'test/scanning/numbers.lox',
        'test/scanning/keywords.lox',
        'test/scanning/punctuators.lox',
        'test/scanning/whitespace.lox',
        'test/scanning/identifiers.lox',
        'test/scanning/strings.lox',
        'test/field/set_on_nil.lox',
        'test/field/get_on_string.lox',
        'test/field/many.lox',
        'test/field/set_on_function.lox',
        'test/field/set_on_bool.lox',
        'test/field/method.lox',
        'test/field/call_nonfunction_field.lox',
        'test/field/get_on_nil.lox',
        'test/field/set_on_class.lox',
        'test/field/set_on_string.lox',
        'test/field/on_instance.lox',
        'test/field/get_on_function.lox',
        'test/field/call_function_field.lox',
        'test/field/set_evaluation_order.lox',
        'test/field/method_binds_this.lox',
        'test/field/set_on_num.lox',
        'test/field/get_on_class.lox',
        'test/field/get_and_set_method.lox',
        'test/field/get_on_bool.lox',
        'test/field/get_on_num.lox',
        'test/field/undefined.lox',
        'test/print/missing_argument.lox',
        'test/number/decimal_point_at_eof.lox',
        'test/number/nan_equality.lox',
        'test/number/literals.lox',
        'test/number/leading_dot.lox',
        'test/number/trailing_dot.lox',
        'test/call/nil.lox',
        'test/call/bool.lox',
        'test/call/num.lox',
        'test/call/object.lox',
        'test/call/string.lox',
        'test/logical_operator/and.lox',
        'test/logical_operator/or.lox',
        'test/logical_operator/and_truth.lox',
        'test/logical_operator/or_truth.lox',
        'test/inheritance/inherit_from_nil.lox',
        'test/inheritance/inherit_from_function.lox',
        'test/inheritance/parenthesized_superclass.lox',
        'test/inheritance/set_fields_from_base_class.lox',
        'test/inheritance/inherit_from_number.lox',
        'test/inheritance/inherit_methods.lox',
        'test/inheritance/constructor.lox',
        'test/super/no_superclass_method.lox',
        'test/super/call_same_method.lox',
        'test/super/no_superclass_call.lox',
        'test/super/no_superclass_bind.lox',
        'test/super/parenthesized.lox',
        'test/super/this_in_superclass_method.lox',
        'test/super/closure.lox',
        'test/super/super_in_top_level_function.lox',
        'test/super/call_other_method.lox',
        'test/super/missing_arguments.lox',
        'test/super/super_in_closure_in_inherited_method.lox',
        'test/super/super_in_inherited_method.lox',
        'test/super/super_without_dot.lox',
        'test/super/indirectly_inherited.lox',
        'test/super/super_at_top_level.lox',
        'test/super/super_without_name.lox',
        'test/super/extra_arguments.lox',
        'test/super/bound_method.lox',
        'test/super/constructor.lox',
        'test/super/reassign_superclass.lox',
        'test/bool/equality.lox',
        'test/bool/not.lox',
        'test/expressions/evaluate.lox',
        'test/expressions/parse.lox',
        'test/for/return_closure.lox',
        'test/for/scope.lox',
        'test/for/var_in_body.lox',
        'test/for/syntax.lox',
        'test/for/return_inside.lox',
        'test/for/statement_initializer.lox',
        'test/for/statement_increment.lox',
        'test/for/statement_condition.lox',
        'test/for/closure_in_body.lox',
        'test/for/class_in_body.lox',
        'test/for/fun_in_body.lox',
        'test/class/empty.lox',
        'test/class/local_inherit_self.lox',
        'test/class/local_inherit_other.lox',
        'test/class/inherited_method.lox',
        'test/class/reference_self.lox',
        'test/class/inherit_self.lox',
        'test/class/local_reference_self.lox',
        'test/this/this_in_method.lox',
        'test/this/this_at_top_level.lox',
        'test/this/closure.lox',
        'test/this/this_in_top_level_function.lox',
        'test/this/nested_closure.lox',
        'test/this/nested_class.lox',
        'test/string/error_after_multiline.lox',
        'test/string/literals.lox',
        'test/string/multiline.lox',
        'test/string/unterminated.lox',
        'test/precedence.lox',
        'test/regression/40.lox',
        'test/regression/394.lox',
        'test/while/return_closure.lox',
        'test/while/var_in_body.lox',
        'test/while/syntax.lox',
        'test/while/return_inside.lox',
        'test/while/closure_in_body.lox',
        'test/while/class_in_body.lox',
        'test/while/fun_in_body.lox',
        'test/method/empty_block.lox',
        'test/method/arity.lox',
        'test/method/refer_to_name.lox',
        'test/method/too_many_arguments.lox',
        'test/method/print_bound_method.lox',
        'test/method/missing_arguments.lox',
        'test/method/not_found.lox',
        'test/method/too_many_parameters.lox',
        'test/method/extra_arguments.lox',
        'test/operator/add_num_nil.lox',
        'test/operator/equals_method.lox',
        'test/operator/equals_class.lox',
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
        'test/operator/not.lox',
        'test/operator/add_nil_nil.lox',
        'test/operator/subtract.lox',
        'test/operator/subtract_nonnum_num.lox',
        'test/operator/not_class.lox',
        'test/operator/greater_or_equal_num_nonnum.lox',
        'test/operator/less_num_nonnum.lox',
        'test/constructor/call_init_explicitly.lox',
        'test/constructor/return_value.lox',
        'test/constructor/init_not_method.lox',
        'test/constructor/missing_arguments.lox',
        'test/constructor/default.lox',
        'test/constructor/arguments.lox',
        'test/constructor/default_arguments.lox',
        'test/constructor/call_init_early_return.lox',
        'test/constructor/extra_arguments.lox',
        'test/constructor/return_in_nested_function.lox',
        'test/constructor/early_return.lox',
        'test/block/empty.lox',
        'test/block/scope.lox',
        '331 expectations'
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
        print(f'{crafting_interpreters_dir}/gen/{chapter}/test.jar')

        with Popen(
            ['java', '-jar', f'{crafting_interpreters_dir}/gen/{chapter}/test.jar', test], stdin=PIPE,
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
