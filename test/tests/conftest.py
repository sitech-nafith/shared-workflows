import os
import sys

# Make the test/app package importable when pytest runs from the repo root
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
