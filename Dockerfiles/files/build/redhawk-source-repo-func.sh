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

function install_repo() {
    if ! [ -d redhawk ]; then
        git clone --recursive -b ${RH_VERSION} git://github.com/RedhawkSDR/redhawk.git
        pushd redhawk
    fi
}

function remove_repo () {
    popd
    if [ -d redhawk ]; then
        rm -rf redhawk
    fi
}

function patch_cf() {
    # Patch Resource_impl.h
    cat<<EOF | tee ./Resource_impl-h.patch
diff --git a/redhawk/src/base/include/ossie/Resource_impl.h b/redhawk/src/base/include/ossie/Resource_impl.h
index 3a62e6f..dca67bc 100644
--- a/redhawk/src/base/include/ossie/Resource_impl.h
+++ b/redhawk/src/base/include/ossie/Resource_impl.h
@@ -24,6 +24,7 @@

 #include <string>
 #include <map>
+#include <boost/scoped_ptr.hpp>
 #include "Logging_impl.h"
 #include "Port_impl.h"
 #include "LifeCycle_impl.h"
EOF
    patch ./redhawk/src/base/include/ossie/Resource_impl.h Resource_impl-h.patch

    # Patch shm/Allocator.cpp
    cat<<EOF | tee ./Allocator-cpp.patch
diff --git a/redhawk/src/base/framework/shm/Allocator.cpp b/redhawk/src/base/framework/shm/Allocator.cpp
index f467de0..0c83edb 100644
--- a/redhawk/src/base/framework/shm/Allocator.cpp
+++ b/redhawk/src/base/framework/shm/Allocator.cpp
@@ -26,6 +26,7 @@
 #include <ossie/BufferManager.h>

 #include <boost/thread.hpp>
+#include <boost/scoped_ptr.hpp>

 #include "Block.h"

EOF
    patch ./redhawk/src/base/framework/shm/Allocator.cpp Allocator-cpp.patch

    # Patch ComponentHost/Makefile.am
    cat<<EOF | tee ./CH-Makefile-am.patch
diff --git a/redhawk/src/control/sdr/ComponentHost/Makefile.am b/redhawk/src/control/sdr/ComponentHost/Makefile.am
index 91bd9a6..b5bc24b 100644
--- a/redhawk/src/control/sdr/ComponentHost/Makefile.am
+++ b/redhawk/src/control/sdr/ComponentHost/Makefile.am
@@ -27,7 +27,7 @@ dist_xml_DATA = ComponentHost.scd.xml ComponentHost.prf.xml ComponentHost.spd.xm
 ComponentHost_SOURCES = ComponentHost.cpp ModuleLoader.cpp main.cpp

 ComponentHost_LDADD = \$(top_builddir)/base/framework/libossiecf.la \$(top_builddir)/base/framework/idl/libossieidl.la
-ComponentHost_LDADD += \$(BOOST_LDFLAGS) \$(BOOST_THREAD_LIB) \$(BOOST_REGEX_LIB) \$(BOOST_SYSTEM_LIB)
+ComponentHost_LDADD += \$(BOOST_LDFLAGS) \$(BOOST_THREAD_LIB) \$(BOOST_REGEX_LIB) \$(BOOST_SYSTEM_LIB) \$(BOOST_FILESYSTEM_LIB) -lomniORB4 -lomnithread -ldl
 ComponentHost_CPPFLAGS = -I\$(top_srcdir)/base/include \$(BOOST_CPPFLAGS)
 ComponentHost_CXXFLAGS = -Wall

EOF
    patch ./redhawk/src/control/sdr/ComponentHost/Makefile.am CH-Makefile-am.patch

    # Patch svc_fn_error_cpp Makefile.am
    cat<<EOF | tee ./svc_fn_error_cpp-Makefile-am.patch
diff --git a/redhawk/src/testing/sdr/dom/components/svc_fn_error_cpp/cpp/Makefile.am b/redhawk/src/testing/sdr/dom/components/svc_fn_error_cpp/cpp/Makefile.am
index 50213e7..c1845b7 100644
--- a/redhawk/src/testing/sdr/dom/components/svc_fn_error_cpp/cpp/Makefile.am
+++ b/redhawk/src/testing/sdr/dom/components/svc_fn_error_cpp/cpp/Makefile.am
@@ -28,7 +28,7 @@ noinst_PROGRAMS = svc_fn_error_cpp
 # you wish to manually control these options.
 include \$(srcdir)/Makefile.am.ide
 svc_fn_error_cpp_SOURCES = \$(redhawk_SOURCES_auto)
-svc_fn_error_cpp_LDADD = \$(CFDIR)/framework/libossiecf.la \$(CFDIR)/framework/idl/libossieidl.la \$(SOFTPKG_LIBS) \$(PROJECTDEPS_LIBS) \$(BOOST_LDFLAGS) \$(BOOST_THREAD_LIB) \$(BOOST_REGEX_LIB) \$(BOOST_SYSTEM_LIB) \$(INTERFACEDEPS_LIBS) \$(redhawk_LDADD_auto)
+svc_fn_error_cpp_LDADD = \$(CFDIR)/framework/libossiecf.la \$(CFDIR)/framework/idl/libossieidl.la \$(SOFTPKG_LIBS) \$(PROJECTDEPS_LIBS) \$(BOOST_LDFLAGS) \$(BOOST_THREAD_LIB) \$(BOOST_REGEX_LIB) \$(BOOST_SYSTEM_LIB) \$(INTERFACEDEPS_LIBS) \$(redhawk_LDADD_auto) -lomniORB4 -lomnithread
 svc_fn_error_cpp_CXXFLAGS = -Wall \$(SOFTPKG_CFLAGS) \$(PROJECTDEPS_CFLAGS) \$(BOOST_CPPFLAGS) \$(INTERFACEDEPS_CFLAGS) \$(redhawk_INCLUDES_auto)
 svc_fn_error_cpp_LDFLAGS = -Wall \$(redhawk_LDFLAGS_auto)

EOF
    patch ./redhawk/src/testing/sdr/dom/components/svc_fn_error_cpp/cpp/Makefile.am svc_fn_error_cpp-Makefile-am.patch

    # Patch codegen
    cat<<EOF | tee ./utils.py.patch
diff --git a/redhawk-codegen/redhawk/codegen/utils.py b/redhawk-codegen/redhawk/codegen/utils.py
index 9ec6432..b99bb7e 100644
--- a/redhawk-codegen/redhawk/codegen/utils.py
+++ b/redhawk-codegen/redhawk/codegen/utils.py
@@ -55,7 +55,7 @@ def fileMD5(filename):
     # secure; the "usedforsecurity" flag assures the library that it's not used
     # in that way, since in this case it's just a hash for tracking when a file
     # has changed. 
-    m = md5(usedforsecurity=False)
+    m = md5()
     for line in open(filename, 'r'):
         m.update(line)
     return m.hexdigest()
EOF
    patch ./redhawk-codegen/redhawk/codegen/utils.py utils.py.patch
}
