aux_source_directory(. rime_test_src)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/test)
add_executable(rime_test ${rime_test_src})

if(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(RIME_TEST_BUNDLE_IDENTIFIER "")
  set(RIME_TEST_BUNDLE_IDENTIFIER ${RIME_TEST_BUNDLE_IDENTIFIER})

  if (DEFINED RIME_TEST_BUNDLE_IDENTIFIER)
    message (STATUS "Using RIME_TEST_BUNDLE_IDENTIFIER: ${RIME_TEST_BUNDLE_IDENTIFIER}")
    set_xcode_property (rime_test PRODUCT_BUNDLE_IDENTIFIER ${RIME_TEST_BUNDLE_IDENTIFIER} All)
  else()
    message (STATUS "No RIME_TEST_BUNDLE_IDENTIFIER - with -DRIME_TEST_BUNDLE_IDENTIFIER=<rime_test bundle identifier>")
  endif()

  if (DEFINED DEVELOPMENT_TEAM)
    set_xcode_property (rime_test DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} All)
  endif()
endif()

target_link_libraries(rime_test
  ${rime_library}
  ${rime_dict_library}
  ${rime_gears_library}
  ${GTEST_LIBRARIES})
if(BUILD_SHARED_LIBS)
  target_compile_definitions(rime_test PRIVATE RIME_IMPORTS)
endif(BUILD_SHARED_LIBS)

file(GLOB test_data_files ${PROJECT_SOURCE_DIR}/data/test/*.yaml)
file(COPY ${test_data_files} DESTINATION ${EXECUTABLE_OUTPUT_PATH})

set(rime_test_executable ${EXECUTABLE_OUTPUT_PATH}/rime_test${ext})
add_test(rime_test ${rime_test_executable})
