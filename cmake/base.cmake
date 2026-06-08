# Generate config_file_stream_data.inc
set(config_file_stream_data_inc "${PROJECT_BINARY_DIR}/base/config_file_stream_data.inc")

set(keymap_files
    atok.tsv
    chromeos.tsv
    kotoeri.tsv
    mobile.tsv
    ms-ime.tsv
    overlay_henkan_muhenkan_to_ime_on_off.tsv
)

list(TRANSFORM keymap_files PREPEND "keymap/")

set(composition_table
    12keys-halfwidthascii.tsv
    12keys-hiragana.tsv
    12keys-hiragana_intuitive.tsv
    50keys-hiragana.tsv
    flick-halfwidthascii.tsv
    flick-halfwidthascii_ios.tsv
    flick-hiragana.tsv
    flick-hiragana_intuitive.tsv
    flick-number.tsv
    godan-hiragana.tsv
    hiragana-romanji.tsv
    kana.tsv
    notouch-hiragana.tsv
    qwerty_mobile-halfwidthascii.tsv
    qwerty_mobile-hiragana.tsv
    romanji-hiragana.tsv
    toggle_flick-halfwidthascii.tsv
    toggle_flick-halfwidthascii_ios.tsv
    toggle_flick-hiragana.tsv
    toggle_flick-hiragana_intuitive.tsv
    toggle_flick-number.tsv
)

list(TRANSFORM composition_table PREPEND "preedit/")

add_custom_command(
    OUTPUT "${config_file_stream_data_inc}"
    COMMAND "${Python3_EXECUTABLE}" "${MOZC_SRC_DIR}/base/gen_config_file_stream_data.py" --output "${config_file_stream_data_inc}" ${composition_table} ${keymap_files}
    WORKING_DIRECTORY "${MOZC_SRC_DIR}/data"
    COMMENT "Generating config_file_stream_data.inc"
)

add_custom_target(gen_config_file_stream_data DEPENDS "${config_file_stream_data_inc}")

# Generate version_def.h
set(version_def_h "${PROJECT_BINARY_DIR}/base/version_def.h")
set(_mozc_target_platform "Linux")
if (WIN32)
    set(_mozc_target_platform "Windows")
elseif (APPLE)
    set(_mozc_target_platform "Mac")
endif()

add_custom_command(
    OUTPUT "${version_def_h}"
    COMMAND "${CMAKE_COMMAND}" -E env PYTHONPATH="${MOZC_SRC_DIR}"
        "${Python3_EXECUTABLE}" "${MOZC_SRC_DIR}/build_tools/mozc_version.py"
        --template_path "${MOZC_SRC_DIR}/version.bzl"
        --target_platform="${_mozc_target_platform}"
        --output "${PROJECT_BINARY_DIR}/base/mozc_version.txt"
    COMMAND "${CMAKE_COMMAND}" -E env PYTHONPATH="${MOZC_SRC_DIR}"
        "${Python3_EXECUTABLE}" "${MOZC_SRC_DIR}/build_tools/replace_version.py"
        --version_file "${PROJECT_BINARY_DIR}/base/mozc_version.txt"
        --branding Mozc
        --input "${MOZC_SRC_DIR}/base/version_def_template.h"
        --output "${version_def_h}"
    WORKING_DIRECTORY "${MOZC_SRC_DIR}"
    COMMENT "Generating version_def.h"
)

add_custom_target(gen_version_def DEPENDS "${version_def_h}")

# Build mozc_base
set(MOZC_BASE_SRCS
    clock.cc
    config_file_stream.cc
    container/serialized_string_array.cc
    encryptor.cc
    environ.cc
    file_stream.cc
    file_util.cc
    hash.cc
    init_mozc.cc
    log_file.cc
    mmap.cc
    number_util.cc
    password_manager.cc
    process_mutex.cc
    random.cc
    singleton.cc
    stopwatch.cc
    strings/internal/double_array.cc
    strings/internal/japanese_rules.cc
    strings/internal/utf8_internal.cc
    strings/japanese.cc
    strings/unicode.cc
    system_util.cc
    text_normalizer.cc
    unverified_aes256.cc
    unverified_sha1.cc
    util.cc
    version.cc
    vlog.cc
)
list(TRANSFORM MOZC_BASE_SRCS PREPEND "${MOZC_SRC_DIR}/base/")

if (NOT WIN32)
    list(APPEND MOZC_BASE_SRCS
        "${PROJECT_SOURCE_DIR}/src/process.cc"
    )
endif()

if (WIN32)
    list(APPEND MOZC_BASE_SRCS
        "${MOZC_SRC_DIR}/base/win32/wide_char.cc"
    )
endif()

if (APPLE)
    list(APPEND MOZC_BASE_SRCS
        "${PROJECT_SOURCE_DIR}/src/mac_util.mm"
    )
endif()
