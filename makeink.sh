#!/bin/bash
cd "$(dirname "$0")"
sudo ln -s "$(pwd)/.bash_aliases" ~/.bash_aliases
echo "Gotowe! Naciśnij Enter, aby zamknąć..."
read
