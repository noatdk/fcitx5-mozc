add_library(mozc-static STATIC
    ${GENERATED_PROTO_SRCS}
    ${MOZC_BASE_SRCS}
    ${MOZC_COMPOSER_SRCS}
    ${MOZC_CONFIG_SRCS}
    ${MOZC_CONVERTER_SRCS}
    ${MOZC_DATA_MANAGER_SRCS}
    ${MOZC_DICTIONARY_SRCS}
    ${MOZC_ENGINE_SRCS}
    ${MOZC_PREDICTION_SRCS}
    ${MOZC_REWRITER_SRCS}
    ${MOZC_SESSION_SRCS}
    ${MOZC_STORAGE_SRCS}
    ${MOZC_TRANSLITERATION_SRCS}
    ${MOZC_USAGE_STATS_SRCS}
)

set_source_files_properties(
    "${MOZC_SRC_DIR}/base/hash.cc"
    "${MOZC_SRC_DIR}/base/strings/internal/utf8_internal.cc"
    "${MOZC_SRC_DIR}/base/util.cc"
    PROPERTIES COMPILE_OPTIONS "/J"
)

target_include_directories(mozc-static PRIVATE
    "${MOZC_SRC_DIR}"
    "${PROJECT_SOURCE_DIR}/abseil-cpp"
    "${PROJECT_SOURCE_DIR}/protobuf/src"
    "${PROJECT_BINARY_DIR}"
)

if (WIN32)
    target_include_directories(mozc-static PRIVATE
        "${wil_SOURCE_DIR}/include"
    )
endif()

target_compile_definitions(mozc-static PRIVATE
    -DMOZC_DATASET_MAGIC_NUMBER_LENGTH=7
)

if (WIN32)
    target_compile_definitions(mozc-static PRIVATE
        UNICODE
        _UNICODE
        WIN32_LEAN_AND_MEAN
        NOMINMAX
    )

    if (MSVC)
        set(_MOZC_UNSIGNED_CHAR_SRCS
            ${MOZC_BASE_SRCS}
            ${MOZC_COMPOSER_SRCS}
            ${MOZC_CONFIG_SRCS}
            ${MOZC_CONVERTER_SRCS}
            ${MOZC_DATA_MANAGER_SRCS}
            ${MOZC_DICTIONARY_SRCS}
            ${MOZC_ENGINE_SRCS}
            ${MOZC_PREDICTION_SRCS}
            ${MOZC_REWRITER_SRCS}
            ${MOZC_SESSION_SRCS}
            ${MOZC_STORAGE_SRCS}
            ${MOZC_TRANSLITERATION_SRCS}
            ${MOZC_USAGE_STATS_SRCS}
        )
        list(FILTER _MOZC_UNSIGNED_CHAR_SRCS EXCLUDE REGEX "/base/win32/")
        list(FILTER _MOZC_UNSIGNED_CHAR_SRCS EXCLUDE REGEX "/config/stats_config_util\\.cc$")
        set_source_files_properties(
            ${_MOZC_UNSIGNED_CHAR_SRCS}
            PROPERTIES COMPILE_OPTIONS "/J"
        )
    endif()

    target_link_libraries(mozc-static PUBLIC
        aux_ulib
    )
endif()

# fcitx5-mozc references session_handler.h.
target_compile_definitions(mozc-static PUBLIC
    -DMOZC_DISABLE_SESSION_WATCHDOG
)

add_dependencies(mozc-static gen)

install(TARGETS mozc-static DESTINATION "${CMAKE_INSTALL_LIBDIR}")
