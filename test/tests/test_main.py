from app.main import add, greet


def test_greet():
    assert greet("World") == "Hello, World"


def test_add():
    assert add(1, 2) == 3


def test_add_negatives():
    assert add(-1, -1) == -2
