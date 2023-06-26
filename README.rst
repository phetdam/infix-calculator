.. README.rst for infix-calculator

infix-calculator
================

A typical command-line infix calculator.

Intended as a hands-on project to get familiar with Flex_ and Bison_.

.. _Flex: https://github.com/westes/flex
.. _Bison: https://www.gnu.org/software/bison/

Features
--------

Can process input from both stdin and from files. Supports boolean, integral,
and floating point expressions using standard arithmetic and logcal operations,
with C-style operator precedence. Allows line comments within input files and
expression grouping with parentheses.

Maybe in the future I will be able to support name assignment.

Building from source
--------------------

Requires CMake_ >=3.16.

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

TBD. For now, please follow the instructions in the top-level ``CMakeLists.txt``.

.. _CMake: https://cmake.org/cmake/help/latest/
