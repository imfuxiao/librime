set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

set(rime_console_deps
  ${rime_library}
  ${rime_dict_library}
  ${rime_gears_library}
  ${rime_levers_library}
  ${rime_plugins_library})


set(rime_api_console_src "rime_api_console.cc")
add_executable(rime_api_console ${rime_api_console_src})
target_link_libraries(rime_api_console ${rime_console_deps})

if(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(RIME_API_CCONSOLE_BUNDLE_IDENTIFIER "")
  set(RIME_API_CCONSOLE_BUNDLE_IDENTIFIER ${RIME_API_CCONSOLE_BUNDLE_IDENTIFIER})

  if (DEFINED RIME_API_CCONSOLE_BUNDLE_IDENTIFIER)
    message (STATUS "Using RIME_API_CCONSOLE_BUNDLE_IDENTIFIER: ${RIME_API_CCONSOLE_BUNDLE_IDENTIFIER}")
    set_xcode_property (rime_api_console PRODUCT_BUNDLE_IDENTIFIER ${RIME_API_CCONSOLE_BUNDLE_IDENTIFIER} All)
  else()
    message (STATUS "No RIME_API_CCONSOLE_BUNDLE_IDENTIFIER - with -DRIME_API_CCONSOLE_BUNDLE_IDENTIFIER=<rime_api_console bundle identifier>")
  endif()

  if (DEFINED DEVELOPMENT_TEAM)
    set_xcode_property (rime_api_console DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} All)
  endif()
endif()

set(rime_patch_src "rime_patch.cc")
add_executable(rime_patch ${rime_patch_src})
target_link_libraries(rime_patch
  ${rime_library}
  ${rime_levers_library})

if(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(RIME_PATCH_BUNDLE_IDENTIFIER "")
  set(RIME_PATCH_BUNDLE_IDENTIFIER ${RIME_PATCH_BUNDLE_IDENTIFIER})

  if (DEFINED RIME_PATCH_BUNDLE_IDENTIFIER)
    message (STATUS "Using RIME_PATCH_BUNDLE_IDENTIFIER: ${RIME_PATCH_BUNDLE_IDENTIFIER}")
    set_xcode_property (rime_patch PRODUCT_BUNDLE_IDENTIFIER ${RIME_PATCH_BUNDLE_IDENTIFIER} All)
  else()
    message (STATUS "No RIME_API_CCONSOLE_BUNDLE_IDENTIFIER - with -DRIME_PATCH_BUNDLE_IDENTIFIER=<rime_patch bundle identifier>")
  endif()

  if (DEFINED DEVELOPMENT_TEAM)
    set_xcode_property (rime_patch DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} All)
  endif()
endif()

# msvc doesn't export all symbols
if(NOT (WIN32 AND BUILD_SHARED_LIBS))

set(rime_console_src "rime_console.cc")
add_executable(rime_console ${rime_console_src})
target_compile_definitions(rime_console PRIVATE RIME_IMPORTS)
target_link_libraries(rime_console ${rime_console_deps})

if(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(RIME_CONSOLE_BUNDLE_IDENTIFIER "")
  set(RIME_CONSOLE_BUNDLE_IDENTIFIER ${RIME_CONSOLE_BUNDLE_IDENTIFIER})

  if (DEFINED RIME_CONSOLE_BUNDLE_IDENTIFIER)
    message (STATUS "Using RIME_CONSOLE_BUNDLE_IDENTIFIER: ${RIME_CONSOLE_BUNDLE_IDENTIFIER}")
    set_xcode_property (rime_console PRODUCT_BUNDLE_IDENTIFIER ${RIME_CONSOLE_BUNDLE_IDENTIFIER} All)
  else()
    message (STATUS "No RIME_CONSOLE_BUNDLE_IDENTIFIER - with -DRIME_CONSOLE_BUNDLE_IDENTIFIER=<rime_console bundle identifier>")
  endif()

  if (DEFINED DEVELOPMENT_TEAM)
    set_xcode_property (rime_console DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} All)
  endif()
endif()

set(rime_dict_manager_src "rime_dict_manager.cc")
add_executable(rime_dict_manager ${rime_dict_manager_src})
target_link_libraries(rime_dict_manager
  ${rime_library}
  ${rime_dict_library}
  ${rime_levers_library})

if(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER "")
  set(RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER ${RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER})

  if (DEFINED RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER)
    message (STATUS "Using RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER: ${RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER}")
    set_xcode_property (rime_dict_manager PRODUCT_BUNDLE_IDENTIFIER ${RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER} All)
  else()
    message (STATUS "No RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER - with -DRIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER=<rime_dict_manager bundle identifier>")
  endif()

  if (DEFINED DEVELOPMENT_TEAM)
    set_xcode_property (rime_dict_manager DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} All)
  endif()
endif()

set(rime_deployer_src "rime_deployer.cc")
add_executable(rime_deployer ${rime_deployer_src})
target_compile_definitions(rime_deployer PRIVATE RIME_IMPORTS)
target_link_libraries(rime_deployer
  ${rime_library}
  ${rime_dict_library}
  ${rime_levers_library})

set(rime_table_decompiler_src 
  "rime_table_decompiler.cc"
  ${CMAKE_SOURCE_DIR}/src/rime/dict/table.cc
  ${CMAKE_SOURCE_DIR}/src/rime/dict/mapped_file.cc
  ${CMAKE_SOURCE_DIR}/src/rime/dict/string_table.cc
  ${CMAKE_SOURCE_DIR}/src/rime/dict/vocabulary.cc
  )
add_executable(rime_table_decompiler ${rime_table_decompiler_src})
target_link_libraries(rime_table_decompiler
  ${rime_library}
  ${rime_dict_library})
if(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(RIME_DEPLOYER_BUNDLE_IDENTIFIER "")
  set(RIME_DEPLOYER_BUNDLE_IDENTIFIER ${RIME_DEPLOYER_BUNDLE_IDENTIFIER})

  if (DEFINED RIME_DEPLOYER_BUNDLE_IDENTIFIER)
    message (STATUS "Using RIME_DEPLOYER_BUNDLE_IDENTIFIER: ${RIME_DEPLOYER_BUNDLE_IDENTIFIER}")
    set_xcode_property (rime_deployer PRODUCT_BUNDLE_IDENTIFIER ${RIME_DEPLOYER_BUNDLE_IDENTIFIER} All)
  else()
    message (STATUS "No RIME_DEPLOYER_BUNDLE_IDENTIFIER - with -DRIME_DEPLOYER_BUNDLE_IDENTIFIER=<rime_deployer bundle identifier>")
  endif()

  if (DEFINED DEVELOPMENT_TEAM)
    set_xcode_property (rime_deployer DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} All)
  endif()
endif()

install(TARGETS rime_deployer DESTINATION ${BIN_INSTALL_DIR})
install(TARGETS rime_dict_manager DESTINATION ${BIN_INSTALL_DIR})
install(TARGETS rime_table_decompiler DESTINATION ${BIN_INSTALL_DIR})

install(TARGETS rime_patch DESTINATION ${BIN_INSTALL_DIR})

file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/default.yaml
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/symbols.yaml
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/essay.txt
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/luna_pinyin.dict.yaml
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/luna_pinyin.schema.yaml
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/cangjie5.dict.yaml
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
file(COPY ${PROJECT_SOURCE_DIR}/data/minimal/cangjie5.schema.yaml
     DESTINATION ${EXECUTABLE_OUTPUT_PATH})
