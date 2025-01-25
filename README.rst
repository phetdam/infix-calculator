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

Building from source
--------------------

Requires CMake_ >=3.16, Flex >=2.6.2, and Bison >=3.5.1. Flex and Bison can
either be installed using your system package manager, e.g. for \*nix systems,
with an alternative being setting either environment or CMake variables with
the directory locations of Flex and Bison, e.g. ``FLEX_ROOT`` and
``BISON_ROOT``. On Windows, it is recommended to use WinFlexBison_ to get a
Flex and Bison release.

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
