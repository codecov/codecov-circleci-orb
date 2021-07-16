import unittest

from src.subtractor.subtractor import Subtractor


class TestSubtractorMethods(unittest.TestCase):
    def test_sum_two_minus_one_is_one(self):
        self.assertEqual(Subtractor().subtract(2, 1), 1)

    def test_sum_two_minus_two_is_not_one(self):
        self.assertNotEqual(Subtractor().subtract(2, 2), 1)

    def test_four_divided_by_two_is_two(self):
        self.assertEqual(Subtractor().divide(4, 2), 2.0)
