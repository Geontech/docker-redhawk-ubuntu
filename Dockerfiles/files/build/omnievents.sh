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
mkdir omniEvents && pushd omniEvents
wget https://github.com/RedhawkSDR/omniEvents/archive/2.7.1.tar.gz
tar xf 2.7.1.tar.gz --strip 1 && rm -f 2.7.1.tar.gz

# Compile and install into where the packaged version would normally be.
./reconf
./configure --prefix=/usr
make && make install

# Remove the build area
popd && rm -rf omniEvents

remove_build_deps
