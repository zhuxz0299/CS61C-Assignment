from unittest import TestCase
from framework import AssemblyTest, print_coverage


class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_one(self):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def do_relu(self, values, expected, length=None, code=0):
        t = AssemblyTest(self, "relu.s")
        array0 = t.array(values)
        t.input_array("a0", array0)
        t.input_scalar("a1", len(array0) if length is None else length)
        t.call("relu")
        if code == 0:
            t.check_array(array0, expected)
        t.execute(code=code)

    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute()

    def test_all_nonnegative(self):
        self.do_relu([0, 1, 2, 3], [0, 1, 2, 3])

    def test_all_negative(self):
        self.do_relu([-1, -2, -3, -4], [0, 0, 0, 0])

    def test_single_negative(self):
        self.do_relu([-42], [0])

    def test_single_zero(self):
        self.do_relu([0], [0])

    def test_zero_length(self):
        self.do_relu([], [], length=0, code=78)

    def test_negative_length(self):
        self.do_relu([123], [123], length=-1, code=78)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def do_argmax(self, values, expected=None, length=None, code=0):
        t = AssemblyTest(self, "argmax.s")
        array0 = t.array(values)
        t.input_array("a0", array0)
        t.input_scalar("a1", len(array0) if length is None else length)
        t.call("argmax")
        if code == 0:
            t.check_scalar("a0", expected)
        t.execute(code=code)

    def test_simple(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", len(array0))
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 8)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_single_element(self):
        self.do_argmax([42], 0)

    def test_negative_values_with_tie(self):
        self.do_argmax([-10, -3, -20, -3], 1)

    def test_zero_length(self):
        self.do_argmax([123], length=0, code=77)

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def do_dot(self, values0, values1, length, stride0, stride1, expected=None, code=0):
        t = AssemblyTest(self, "dot.s")
        array0 = t.array(values0)
        array1 = t.array(values1)
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        t.input_scalar("a2", length)
        t.input_scalar("a3", stride0)
        t.input_scalar("a4", stride1)
        t.call("dot")
        if code == 0:
            t.check_scalar("a0", expected)
        t.execute(code=code)

    def test_simple(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1, 2, 3])
        array1 = t.array([4, 5, 6])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", len(array0))
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 32)
        t.execute()

    def test_stride(self):
        self.do_dot([1, 9, 2, 9, 3], [4, 8, 5, 8, 6], 3, 2, 2, 32)

    def test_different_strides(self):
        self.do_dot([1, 9, 2, 9, 3], [4, 5, 6], 3, 2, 1, 32)

    def test_negative_values(self):
        self.do_dot([1, -2, 3], [-4, 5, -6], 3, 1, 1, -32)

    def test_zero_length(self):
        self.do_dot([1], [2], 0, 1, 1, code=75)

    def test_zero_stride(self):
        self.do_dot([1], [2], 1, 0, 1, code=76)

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):

    def do_matmul(self, m0, m0_rows, m0_cols, m1, m1_rows, m1_cols, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        # we need to include (aka import) the dot.s file since it is used by matmul.s
        t.include("dot.s")

        # create arrays for the arguments and to store the result
        array0 = t.array(m0)
        array1 = t.array(m1)
        array_out = t.array([0] * len(result))

        # load address of input matrices and set their dimensions
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_rows)
        t.input_scalar("a2", m0_cols)
        t.input_array("a3", array1)
        t.input_scalar("a4", m1_rows)
        t.input_scalar("a5", m1_cols)
        # load address of output array
        t.input_array("a6", array_out)

        # call the matmul function
        t.call("matmul")

        # check the content of the output array
        if code == 0:
            t.check_array(array_out, result)

        # generate the assembly file and run it through venus, we expect the simulation to exit with code `code`
        t.execute(code=code)

    def test_simple(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150]
        )

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

    def do_read_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "read_matrix.s")
        # load address to the name of the input file into register a0
        t.input_read_filename("a0", "inputs/test_read_matrix/test_input.bin")

        # allocate space to hold the rows and cols output parameters
        rows = t.array([-1])
        cols = t.array([-1])

        # load the addresses to the output parameters into the argument registers
        t.input_array("a1", rows)
        t.input_array("a2", cols)

        # call the read_matrix function
        t.call("read_matrix")

        # check the output from the function
        if code == 0:
            t.check_array(rows, [3])
            t.check_array(cols, [3])
            t.check_array_pointer("a0", [1, 2, 3, 4, 5, 6, 7, 8, 9])

        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)

    def test_simple(self):
        self.do_read_matrix()

    def test_fopen_error(self):
        self.do_read_matrix(fail='fopen', code=90)

    def test_fread_error(self):
        self.do_read_matrix(fail='fread', code=91)

    def test_malloc_error(self):
        self.do_read_matrix(fail='malloc', code=88)

    def test_fclose_error(self):
        self.do_read_matrix(fail='fclose', code=92)

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student.bin"
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        # load input array and other arguments
        matrix = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        t.input_array("a1", matrix)
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 3)
        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        # compare the output file against the reference
        if code == 0:
            t.check_file_output(outfile, "outputs/test_write_matrix/reference.bin")

    def test_simple(self):
        self.do_write_matrix()

    def test_fopen_error(self):
        self.do_write_matrix(fail='fopen', code=93)

    def test_fwrite_error(self):
        self.do_write_matrix(fail='fwrite', code=94)

    def test_fclose_error(self):
        self.do_write_matrix(fail='fclose', code=95)

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        return t

    def test_simple0_input0(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        t.input_scalar("a2", 0)
        # call classify function
        t.call("classify")
        t.check_scalar("a0", 2)
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args)

        # compare the output file and
        t.check_file_output(out_file, ref_file)
        # compare the classification output with `check_stdout`
        t.check_stdout("2")

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")
