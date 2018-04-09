#
OPTION(WITH_ASAN "Turn ON Address sanitizer feature" OFF)
OPTION(STRICT_FLAGS "Turn on a lot of compiler warnings" ON)
OPTION(DEBUG "Add debug info for GDB" OFF)
OPTION(NATIVE_CPU "Strictly bind the binary to current CPU" OFF)
#
INCLUDE(CheckCCompilerFlag)
INCLUDE(CheckCXXCompilerFlag)
SET(CMAKE_INCLUDE_CURRENT_DIR ON)
#
CHECK_CXX_COMPILER_FLAG("-std=gnu++11" COMPILER_SUPPORTS_CXX11)
IF(NOT COMPILER_SUPPORTS_CXX11)
  MESSAGE(FATAL_ERROR "Compiler ${CMAKE_CXX_COMPILER} has no C++11 support.")
ENDIF()
#
IF(WITH_ASAN)
  SET(ASAN_FLAGS "-fsanitize=address")
  SET(CMAKE_REQUIRED_FLAGS ${ASAN_FLAGS})
  CHECK_C_COMPILER_FLAG("" ASAN_C_OK)
  CHECK_CXX_COMPILER_FLAG("" ASAN_CXX_OK)
  IF(ASAN_C_OK AND ASAN_CXX_OK)
    ADD_DEFINITIONS(-fsanitize=address)
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
  ELSE()
    MESSAGE(FATAL_ERROR "ASAN is not supported by ${CMAKE_CXX_COMPILER}")
  ENDIF()
ENDIF(WITH_ASAN)
#
ADD_DEFINITIONS(-std=gnu++11 -pipe)
#
IF((CMAKE_SYSTEM_PROCESSOR MATCHES "i386|i686|x86|AMD64") AND (CMAKE_SIZEOF_VOID_P EQUAL 4))
  SET(ARCH "x86")
ELSEIF((CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64") AND (CMAKE_SIZEOF_VOID_P EQUAL 8))
  SET(ARCH "x86_64")
ELSEIF((CMAKE_SYSTEM_PROCESSOR MATCHES "i386") AND (CMAKE_SIZEOF_VOID_P EQUAL 8) AND (APPLE))
  # Mac is weird like that.
  SET(ARCH "x86_64")
ELSEIF(CMAKE_SYSTEM_PROCESSOR MATCHES "^arm*")
  SET(ARCH "ARM")
ELSEIF(CMAKE_SYSTEM_PROCESSOR MATCHES "sparc")
  SET(ARCH "sparc")
ENDIF()
#
MESSAGE(STATUS "Host system is ${CMAKE_SYSTEM}-${ARCH}")
#
# Debug Release RelWithDebInfo MinSizeRel
IF(CMAKE_BUILD_TYPE STREQUAL "")
  SET(CMAKE_BUILD_TYPE "Release")
ENDIF()
#
IF(CMAKE_BUILD_TYPE STREQUAL "Debug")
  SET(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3 -ggdb3")
ENDIF()
##
IF(NATIVE_CPU)
  ADD_COMPILE_OPTIONS(-march=native -mtune=generic)
ENDIF()
#
IF(STRICT_FLAGS)
  ADD_DEFINITIONS(-Wall -Werror -Wextra -pedantic-errors -Wmissing-declarations)
ENDIF ()
##

#
#
