import unittest

from src.adder.adder import Adder


class TestAdderMethods(unittest.TestCase):
    def test_sum_two_plus_two_is_four(self):
        self.assertEqual(Adder().add(3, 1), 4)

    def test_sum_two_plus_two_is_not_five(self):
        self.assertNotEqual(Adder().add(3, 4), 6)
