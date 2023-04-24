cmake_minimum_required(VERSION 3.16)

# major, minor, patch versions
set(PDCALC_MAJOR_VERSION 0)
set(PDCALC_MINOR_VERSION 1)
set(PDCALC_PATCH_VERSION 0)

project(
    PROJECT pdcalc
    VERSION
        ${PDCALC_MAJOR_VERSION}.${PDCALC_MINOR_VERSION}.${PDCALC_PATCH_VERSION}
    DESCRIPTION "An infix calculator written with flex + bison"
    HOMEPAGE_URL https://github.com/phetdam/infix-calculator
    # TODO: maybe this will be a C-only project
    LANGUAGES C CXX
)

# enforce our C/C++ standards
set(CMAKE_C_STANDARD C11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# TODO: actually add things
