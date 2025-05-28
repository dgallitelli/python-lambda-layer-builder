#!/bin/sh
echo "⏳️ Starting dependency installation..."
echo "🧹️ Removing old .venv and src/python"
rm -rf .venv src/python
echo "⏳️ Creating Python3 virtual environment..."
# Create a virtualenv using Python 3.12
python3 -m venv .venv
. .venv/bin/activate
echo "🚀️ Virtual environment activated"
# Install in the virtual env
echo "⏳️ Upgrading pip..."
pip install pip --quiet --upgrade
echo "⏳️ Installing requirements from src/requirements.txt..."
pip install -r src/requirements.txt --quiet --upgrade
# Delete content of src/python and copy .venv/lib to src/python/lib
echo "🧹️ Cleaning src/python directory..."
rm -rf src/python/*
mkdir -p src/python/lib
echo "⏳️ Copying virtual environment libraries to src/python/lib..."
cp -r .venv/lib/* src/python/lib/
echo "✅️ Dependency installation complete!"
