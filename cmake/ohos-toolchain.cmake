# ohos-toolchain.cmake — QBDI/QTrace HarmonyOS (OHOS) cross-compile toolchain
#
# Usage:
#   cmake -DCMAKE_TOOLCHAIN_FILE=cmake/ohos-toolchain.cmake \
#         -DOHOS_NDK=/path/to/openharmony/native ..
#
# OHOS_NDK can also be set via environment variable OHOS_SDK_NATIVE,
# or defaults to the DevEco Studio command-line-tools path.
#
# Requirements: OpenHarmony SDK (native/llvm + native/sysroot)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# --- NDK path: -DOHOS_NDK=... > env OHOS_SDK_NATIVE > common default ---
if(NOT DEFINED OHOS_NDK)
  if(DEFINED ENV{OHOS_SDK_NATIVE})
    set(OHOS_NDK "$ENV{OHOS_SDK_NATIVE}")
  else()
    # Common DevEco Studio location (override with -DOHOS_NDK or env)
    set(OHOS_NDK "/opt/openharmony/native")
    if(NOT EXISTS "${OHOS_NDK}")
      message(FATAL_ERROR
        "OpenHarmony NDK not found. Set -DOHOS_NDK=<path to native dir> "
        "or environment variable OHOS_SDK_NATIVE. "
        "The native dir contains llvm/ and sysroot/.")
    endif()
  endif()
endif()

if(NOT EXISTS "${OHOS_NDK}/sysroot")
  message(FATAL_ERROR "Invalid OHOS_NDK='${OHOS_NDK}': sysroot/ not found")
endif()

# --- Host-specific executable suffix (handles .exe on Windows) ---
if(CMAKE_HOST_WIN32)
  set(_TOOL_SUFFIX ".exe")
else()
  set(_TOOL_SUFFIX "")
endif()

set(CMAKE_C_COMPILER   "${OHOS_NDK}/llvm/bin/clang${_TOOL_SUFFIX}")
set(CMAKE_CXX_COMPILER "${OHOS_NDK}/llvm/bin/clang++${_TOOL_SUFFIX}")
set(CMAKE_AR           "${OHOS_NDK}/llvm/bin/llvm-ar${_TOOL_SUFFIX}")
set(CMAKE_RANLIB       "${OHOS_NDK}/llvm/bin/llvm-ranlib${_TOOL_SUFFIX}")
set(CMAKE_STRIP        "${OHOS_NDK}/llvm/bin/llvm-strip${_TOOL_SUFFIX}")

set(CMAKE_SYSROOT "${OHOS_NDK}/sysroot")
set(CMAKE_C_COMPILER_TARGET aarch64-linux-ohos)
set(CMAKE_CXX_COMPILER_TARGET aarch64-linux-ohos)

set(CMAKE_FIND_ROOT_PATH "${OHOS_NDK}/sysroot")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

add_compile_options(-fPIC)

message(STATUS "OHOS toolchain: NDK=${OHOS_NDK}")
message(STATUS "OHOS toolchain: C compiler=${CMAKE_C_COMPILER}")
message(STATUS "OHOS toolchain: sysroot=${CMAKE_SYSROOT}")
