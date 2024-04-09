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
Some simple builtin functions are available, e.g. trigonometric functions,
binary min + max functions.

The calculator parser is built as a separate static or shared library that the
calculator command-line tool links against. PIMPL is used to provide a stable
ABI and prevent leaking Flex + Bison generated names and types into user code.

Building from source
--------------------

Requires CMake_ >=3.16, Flex >=2.6.2, and Bison >=3.5.1. Flex and Bison can
either be installed using your system package manager, e.g. for \*nix systems,
with an alternative being setting either environment or CMake variables with
the directory location of Flex and Bison. For the latter,
``PDCALC_FLEX_BISON_DIR`` can simply be set if both Flex and Bison are in the
same directory, e.g. when pointing to the location of a WinFlexBison_ release
on Windows. If located in different directories, ``PDCALC_FLEX_DIR`` and
``PDCALC_BISON_DIR`` can be set appropriately.

.. _CMake: https://cmake.org/cmake/help/latest/

.. _WinFlexBison: https://github.com/lexxmark/winflexbison

\*nix
~~~~~

Building is easy with the provided ``build.sh`` build script. For usage, type

.. code:: shell

   ./build.sh --help

To build release binaries for this project, simply use the command

.. code:: shell

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

Simply typing ``build`` will build unoptimized binaries and the program
database with debugging info. You can specify the target architecture using
the ``-a`` flag, e.g. to build 64-bit release binaries instead of the default
32-bit ones, use

.. code:: shell

   build -a x64 -c Release

Currently, the Visual Studio toolset used will be whichever is the default.
