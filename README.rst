.. README.rst for infix-calculator

infix-calculator
================

A typical command-line infix calculator.

Intended as a hands-on project to get familiar with Flex_ and Bison_.

.. _Flex: https://github.com/westes/flex
.. _Bison: https://www.gnu.org/software/bison/

Features
--------

Can process semicolon-terminated expression input from both stdin and text
files. Supports boolean, integral, and floating point expressions using standard
arithmetic and logical operations, with C-style operator precedence. Allows line
comments within input files and grouping of subexpressions with parentheses.

Maybe in the future I will be able to support name assignment.

Building from source
--------------------

Requires CMake_ >=3.16.

.. _CMake: https://cmake.org/cmake/help/latest/

\*nix
~~~~~

Building is easy with the provided ``build.sh`` build script. For usage, type

.. code:: bash

   ./build.sh --help

To build release binaries for this project, simply use the command

.. code:: bash

   ./build.sh -c Release

Simply typing ``./build.sh`` will build unoptimized binaries with debug symbols.

Windows
~~~~~~~

Building is easy with the provided ``build.bat`` build script. For usage, type

.. code:: shell

   build --help

To build release binaries for this project, simple use the command

.. code:: shell

   build -c Release

Simply typing ``build`` will build unoptimized binaries and generate the
program database with debugging info. You can specify the target architecture
using the ``-a`` flag, e.g. to build 64-bit release binaries instead of the
default 32-bit ones, use

.. code:: shell

   build -a x64 -c Release

Currently, the Visual Studio toolset used will be whichever is the default.
