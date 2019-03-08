#!/bin/bash
# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of Geon's Docker REDHAWK.
#
# Docker REDHAWK is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# Docker REDHAWK is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#
set -e

source ./base-deps-func.sh

install_build_deps

# Get omniEvents
mkdir omniORBpy && pushd omniORBpy
wget http://downloads.sourceforge.net/omniorb/omniORBpy-4.2.3.tar.bz2
tar xf omniORBpy-4.2.3.tar.bz2 --strip 1 && rm -f omniORBpy-4.2.3.tar.bz2

# Compile and install into where the packaged version would normally be.
./configure --prefix=/usr
make && make install

# Remove the build area
popd && rm -rf omniORBpy

remove_build_deps
