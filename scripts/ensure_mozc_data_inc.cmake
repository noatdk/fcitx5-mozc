if (DEFINED MOZC_DATA_INC AND EXISTS "${MOZC_DATA_INC}")
    return()
endif()

if (NOT DEFINED MOZC_DATA_INC)
    message(FATAL_ERROR "MOZC_DATA_INC is required")
endif()

if (NOT DEFINED MOZC_DATA_INC_URL)
    set(MOZC_DATA_INC_URL
        "https://github.com/fcitx-contrib/fcitx5-mozc/releases/download/latest/mozc_data.inc"
    )
endif()

get_filename_component(_mozc_data_dir "${MOZC_DATA_INC}" DIRECTORY)
file(MAKE_DIRECTORY "${_mozc_data_dir}")

message(STATUS "Downloading mozc_data.inc from ${MOZC_DATA_INC_URL}")
file(DOWNLOAD
    "${MOZC_DATA_INC_URL}"
    "${MOZC_DATA_INC}"
    STATUS _download_status
    SHOW_PROGRESS
)

list(GET _download_status 0 _download_code)
if (NOT _download_code EQUAL 0)
    list(GET _download_status 1 _download_message)
    file(REMOVE "${MOZC_DATA_INC}")
    message(FATAL_ERROR
        "Failed to download mozc_data.inc: ${_download_message}"
    )
endif()
