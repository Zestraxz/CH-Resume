"""Example Python unit test. Delete once you have real ones.

Run with: `pytest`
"""

from __future__ import annotations


def test_sanity() -> None:
    assert 1 + 1 == 2


def test_example_fixture(example_record: dict[str, str]) -> None:
    assert example_record["id"] == "test-1"
    assert example_record["name"] == "Example"


def test_arrange_act_assert() -> None:
    # Arrange
    input_list = [3, 1, 2]

    # Act
    result = sorted(input_list)

    # Assert
    assert result == [1, 2, 3]
    assert input_list == [3, 1, 2]  # original unchanged
