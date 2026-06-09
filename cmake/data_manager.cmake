set(MOZC_DATA_MANAGER_SRCS
    data_manager.cc
    dataset_reader.cc
    oss/oss_data_manager.cc
    serialized_dictionary.cc
)
list(TRANSFORM MOZC_DATA_MANAGER_SRCS PREPEND "${MOZC_SRC_DIR}/data_manager/")

set(_mozc_data_manager_oss_dir "${PROJECT_BINARY_DIR}/data_manager/oss")
file(MAKE_DIRECTORY "${_mozc_data_manager_oss_dir}")

set(_mozc_oss_pos_list_token_array_data
    "${_mozc_data_manager_oss_dir}/user_pos_token_array.data"
)
set(_mozc_oss_pos_list_string_array_data
    "${_mozc_data_manager_oss_dir}/user_pos_string_array.data"
)
set(_mozc_oss_pos_list_data "${_mozc_data_manager_oss_dir}/pos_list.data")
set(_mozc_oss_pos_list_inc "${_mozc_data_manager_oss_dir}/pos_list.inc")
set(_mozc_oss_mozc_data_inc "${_mozc_data_manager_oss_dir}/mozc_data.inc")

add_custom_command(
    OUTPUT
        "${_mozc_oss_pos_list_token_array_data}"
        "${_mozc_oss_pos_list_string_array_data}"
        "${_mozc_oss_pos_list_data}"
    COMMAND "${CMAKE_COMMAND}" -E env PYTHONPATH="${MOZC_SRC_DIR}"
        "${Python3_EXECUTABLE}" "${MOZC_SRC_DIR}/dictionary/gen_user_pos_data.py"
        --id_file="${MOZC_SRC_DIR}/data/dictionary_oss/id.def"
        --special_pos_file="${MOZC_SRC_DIR}/data/rules/special_pos.def"
        --cforms_file="${MOZC_SRC_DIR}/data/rules/cforms.def"
        --user_pos_file="${MOZC_SRC_DIR}/data/rules/user_pos.def"
        --output_token_array="${_mozc_oss_pos_list_token_array_data}"
        --output_string_array="${_mozc_oss_pos_list_string_array_data}"
        --output_pos_list="${_mozc_oss_pos_list_data}"
    DEPENDS
        "${MOZC_SRC_DIR}/dictionary/gen_user_pos_data.py"
        "${MOZC_SRC_DIR}/build_tools/serialized_string_array_builder.py"
        "${MOZC_SRC_DIR}/dictionary/pos_util.py"
        "${MOZC_SRC_DIR}/data/rules/cforms.def"
        "${MOZC_SRC_DIR}/data/dictionary_oss/id.def"
        "${MOZC_SRC_DIR}/data/rules/special_pos.def"
        "${MOZC_SRC_DIR}/data/rules/user_pos.def"
    WORKING_DIRECTORY "${MOZC_SRC_DIR}"
    COMMENT "Generating pos_list.data"
)

add_custom_command(
    OUTPUT "${_mozc_oss_pos_list_inc}"
    COMMAND "${CMAKE_COMMAND}" -E env PYTHONPATH="${MOZC_SRC_DIR}"
        "${Python3_EXECUTABLE}" "${MOZC_SRC_DIR}/build_tools/embed_file.py"
        --input="${_mozc_oss_pos_list_data}"
        --name=kPosArray
        --output="${_mozc_oss_pos_list_inc}"
    DEPENDS
        "${MOZC_SRC_DIR}/build_tools/embed_file.py"
        "${_mozc_oss_pos_list_data}"
    WORKING_DIRECTORY "${MOZC_SRC_DIR}"
    COMMENT "Generating pos_list.inc"
)

add_custom_target(gen_pos_list_inc DEPENDS "${_mozc_oss_pos_list_inc}")
add_dependencies(gen gen_pos_list_inc)

add_custom_command(
    OUTPUT "${_mozc_oss_mozc_data_inc}"
    COMMAND "${CMAKE_COMMAND}"
        -DMOZC_DATA_INC="${_mozc_oss_mozc_data_inc}"
        -P "${PROJECT_SOURCE_DIR}/scripts/ensure_mozc_data_inc.cmake"
    DEPENDS
        "${PROJECT_SOURCE_DIR}/scripts/ensure_mozc_data_inc.cmake"
    COMMENT "Ensuring mozc_data.inc is available"
)

add_custom_target(gen_mozc_data_inc DEPENDS "${_mozc_oss_mozc_data_inc}")
add_dependencies(gen gen_mozc_data_inc)
