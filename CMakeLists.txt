cmake_minimum_required(VERSION 3.22)

project(fcitx5-mozc)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if (WIN32)
    if (NOT DEFINED Python3_EXECUTABLE OR Python3_EXECUTABLE MATCHES "WindowsApps")
        find_program(_MOZC_PYTHON3_EXECUTABLE
            NAMES python3 python
            HINTS
                "$ENV{LOCALAPPDATA}/Python/bin"
                "$ENV{LocalAppData}/Python/bin"
            NO_DEFAULT_PATH
        )
        if (_MOZC_PYTHON3_EXECUTABLE)
            set(Python3_EXECUTABLE "${_MOZC_PYTHON3_EXECUTABLE}" CACHE FILEPATH "Python3 interpreter" FORCE)
        endif()
    endif()
endif()
find_package(Python3 REQUIRED COMPONENTS Interpreter)

option(BUILD_MOZC_ADDON "Build Mozc Fcitx5 Addon" ON)

include(GNUInstallDirs)
set(CMAKE_CXX_STANDARD 20)
if (NOT WIN32)
    add_compile_options(-fPIC)
endif()

set(MOZC_SRC_DIR "${PROJECT_SOURCE_DIR}/mozc/src")

if (NOT DEFINED MOZC_TARGET)
    add_subdirectory(abseil-cpp)
    # Not installing as we'll regenerate libabsl.a

    set(protobuf_INSTALL OFF)
    set(protobuf_BUILD_TESTS OFF)
    if (WIN32)
        # Windows uses pre-generated .pb.cc files (see cmake/protobuf.cmake),
        # so it never needs the protoc binary or libprotoc.
        set(protobuf_BUILD_PROTOC_BINARIES OFF)
        set(protobuf_BUILD_LIBPROTOC OFF)
    endif()
    set(protobuf_BUILD_LIBUPB OFF) # No binary for iOS.

    add_subdirectory("protobuf")
    install(TARGETS utf8_validity DESTINATION "${CMAKE_INSTALL_LIBDIR}")
    install(TARGETS libprotobuf DESTINATION "${CMAKE_INSTALL_LIBDIR}")

    include(cmake/protobuf.cmake)
    include(cmake/base.cmake)
    include(cmake/composer.cmake)
    include(cmake/config.cmake)
    include(cmake/converter.cmake)
    include(cmake/data_manager.cmake)
    include(cmake/dictionary.cmake)
    include(cmake/engine.cmake)
    include(cmake/prediction.cmake)
    include(cmake/rewriter.cmake)
    include(cmake/session.cmake)
    include(cmake/storage.cmake)
    include(cmake/transliteration.cmake)

    include(cmake/mozc-static.cmake)
    set(MOZC_TARGET
        libprotobuf
        mozc-static
        absl::flags_parse
        absl::log_flags
    )

    # Force data generation before binary build
    add_dependencies(gen
        gen_config_file_stream_data
        gen_pos_matcher_code
        gen_pos_matcher_impl_inc
        gen_version_def
        gen_pos_cost_map
    )
endif()

if (BUILD_MOZC_ADDON AND NOT WIN32)
    find_package(Gettext REQUIRED)
    find_package(Fcitx5Core 5.1.12 REQUIRED)
    find_package(Fcitx5Module REQUIRED COMPONENTS Clipboard)

    include("${FCITX_INSTALL_CMAKECONFIG_DIR}/Fcitx5Utils/Fcitx5CompilerSettings.cmake")
    add_subdirectory(src/unix/fcitx5)
elseif (BUILD_MOZC_ADDON AND WIN32)
    message(STATUS "Skipping BUILD_MOZC_ADDON on Windows")
endif()
