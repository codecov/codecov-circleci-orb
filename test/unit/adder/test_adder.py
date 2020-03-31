import pytest
from src.adder.adder import Adder

def test_sum_two_plus_two_is_four():
    assert Adder().add(3,1) == 4

def test_sum_two_plus_two_is_not_five():
    assert Adder().add(3,4) != 6
