#!/bin/sh

## release.sh
#
# Copyright: (C) 2020 Henrique Silva
#
# Author: Henrique Silva <hcpsilva@inf.ufrgs.br>
#
# License: GNU General Public License version 3, or any later version
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
## Commentary:
#
# Creates a .tar.gz aggregate of all the project files in the directory
# from where it was called.
#
## Code:

root=$(dirname $(dirname $(readlink -f "$0")))

pushd $root

version=$(awk '/VERSION :=/ {print $3}' Makefile)
sed -i.bak 's/RELEASE ?=/RELEASE := true/g' Makefile

make clean

for src_file in $(find . -mindepth 2 -regex '.*\.[chl]\(pp\)?'); do
    link=$(basename "$src_file")
    ln -s $(readlink -f "$src_file" "$link")
done

tar --exclude="${version}.tgz" \
    --exclude-vcs-ignores \
    --exclude-vcs \
    --exclude-backups \
    -czf "$version.tgz" .

mv Makefile.bak Makefile

popd

## release.sh ends here
