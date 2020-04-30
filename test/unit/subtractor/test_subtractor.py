import pytest
from src.subtractor.subtractor import Subtractor


def test_sum_two_minus_one_is_one():
    assert Subtractor().subtract(2, 1) == 1


def test_sum_two_minus_two_is_not_one():
    assert Subtractor().subtract(2, 2) != 1

def test_four_divided_by_two_is_two():
        assert Subtractor().divide(4, 2) == 2.0
