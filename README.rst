.. README.rst for infix-calculator

infix-calculator
================

A typical command-line infix calculator.

Intended as a hands-on C++ project to get familiar with Flex_ and Bison_.

.. _Flex: https://github.com/westes/flex
.. _Bison: https://www.gnu.org/software/bison/

Features
--------

Can process semicolon-terminated expression input from both stdin and text
files. Supports boolean, integral, and floating point expressions using standard
arithmetic and logical operations, with C-style operator precedence. Allows line
comments within input files and grouping of subexpressions with parentheses.
Variable assignment is supported and some builtin functions are provided, e.g.
logarithmic, exponential, trigonometric, binary min + max.

The calculator parser is built as a separate static or shared library that the
calculator command-line tool links against. PIMPL is used to provide a stable
ABI and prevent leaking Flex + Bison generated names and types into user code.

Below is a sample program that demonstrates some of the available features:

.. code::

   a = 1.5;
   b = sin(1.5) * cos(1.8) + log(a);
   b += exp(a - b);
   # non-assignment expressions write result to output stream
   sqrt(b);

Running the command-line tool on this input should print the following:

.. code::

   <double> 1.98157

Building + Installing
---------------------

Requires CMake_ >=3.16, Flex >=2.6.2, and Bison >=3.5.1. Flex and Bison can
either be installed using your system package manager, e.g. for \*nix systems,
with an alternative being setting either environment or CMake variables with
the directory location of Flex and Bison. On Windows, it is recommended to use
WinFlexBison_, a port of Flex and Bison to Windows, as the original tools were
designed only for distribution for GNU/Linux style systems.

.. _CMake: https://cmake.org/cmake/help/latest/

.. _WinFlexBison: https://github.com/lexxmark/winflexbison

\*nix
~~~~~

Building is easy with the provided ``build.sh`` build script. For usage, type

.. code:: bash

   ./build.sh --help

To build release binaries for this project, simply use the command

.. code:: bash

   ./build.sh -c Release

Simply typing ``./build.sh`` will build unoptimized binaries with debug symbols.

To install to ``/usr/local``, your prefix of choice, use the command

.. code:: bash

   cmake --install build

For a custom installation root, use the ``--prefix`` argument, e.g.

.. code:: bash

   cmake --install build --prefix /path/to/install/location

Windows
~~~~~~~

Building is easy with the provided ``build.bat`` build script. For usage, type

.. code:: shell

   build --help

To build release binaries for this project, simple use the command

.. code:: shell

   build -c Release

Simply typing ``build`` will build unoptimized binaries and the program
database with debugging info. You can specify the target architecture using
the ``-a`` flag, e.g. to build 32-bit release binaries instead of the default
64-bit ones, use

.. code:: shell

   build -a x86 -c Release

Currently, the Visual Studio toolset used will be whichever is the default.

To install to a custom installation root, use the ``--prefix`` argument, e.g.

.. code:: shell

   cmake --install build_windows_x64 --prefix %USERPROFILE%\pdcalc-master

Usage from CMake
----------------

After build + installation, the calculator parser library can be used from
CMake in the normal fashion with CMake's find_package_ command. To locate the
library, use the following in a ``CMakeLists.txt`` or CMake script:

.. _find_package: https://cmake.org/cmake/help/latest/command/find_package.html

.. code:: cmake

   find_package(pdcalc 0.1.0)

If the library is found, one can write programs using the headers, for example:

.. code:: cpp

   /**
    * @file pdcalc_ex.cc
    * @author Derek Huang
    * @brief C++ minimal example using pdcalc
    * @copyright MIT License
    */

   #include <filesystem>

   #include <pdcalc/calc_parser.hh>  // note: no main API header yet

   int main()
   {
     // read input from stdin and write to stdout (returns true on success)
     pdcalc::calc_parser parser;
     return !parser();
   }

Then, when adding the CMake target for this program, one can to specify the
compile + link requirements simply via use of target_link_libraries_ without
needing to manually update the include or link directories for the project or
target. For example:

.. _target_link_libraries: https://cmake.org/cmake/help/latest/command/target_link_libraries.html

.. code:: cmake

   add_executable(pdcalc_ex pdcalc_ex.cc)
   target_link_libraries(pdcalc_ex PRIVATE pdcalc::pdcalc)

On a \*nix system, assuming the build directory is ``build``, one can run the
produced example program as follows:

.. code:: bash

   echo "a = sin(1.9); tan(exp(-a));" | ./build/pdcalc_ex

The following should then be written to standard output:

.. code::

   <double> 0.408923
