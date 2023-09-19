cmake_minimum_required(VERSION 3.10)
project(pegasus)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
set(PEGASUS_THIRDPARTY_DIR ${CMAKE_CURRENT_LIST_DIR}/thirdparty)

add_compile_options(-fPIC)
add_compile_options(-D_GLIBCXX_USE_CXX11_ABI=0)

add_subdirectory(thirdparty/Gemini-SEAL/ EXCLUDE_FROM_ALL)
add_library(Gemini-SEAL::seal ALIAS seal)

set(PEGASUS_USE_EIGEN_STR "Build Eigen for Pegasus")
option(PEGASUS_USE_EIGEN ${PEGASUS_USE_EIGEN_STR} ON)

# Download and configure
if (PEGASUS_USE_EIGEN)
  message(STATUS "Setting up Eigen ...")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    OUTPUT_QUIET
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${PEGASUS_THIRDPARTY_DIR}/eigen)
  if(result)
    message(WARNING "Failed to download Eigen (${result}); disabling `PEGASUS_USE_EIGEN`")
  endif()
  set(INSTALL_EIGEN OFF CACHE BOOL "" FORCE)
  mark_as_advanced(INSTALL_EIGEN)
  endif()

if (PEGASUS_USE_EIGEN)
  execute_process(COMMAND ${CMAKE_COMMAND} --build .
    OUTPUT_QUIET
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${PEGASUS_THIRDPARTY_DIR}/eigen)
  if(result)
    message(WARNING "Failed to build Eigen (${result}); disabling `PEGASUS_USE_EIGEN`")
  endif()

  # add_subdirectory(${PEGASUS_THIRDPARTY_DIR}/eigen/src EXCLUDE_FROM_ALL)
  set(EIGEN_INCLUDE_DIR ${PEGASUS_THIRDPARTY_DIR}/eigen/src)
endif()

find_package(GMP)
if(GMP_FOUND)
  add_definitions(-DGEMINI_USE_GMP)
endif(GMP_FOUND)

find_package(OpenMP)
if (OPENMP_FOUND)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
  set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif(OPENMP_FOUND)

# Pegasus
add_library(pegasus OBJECT)
add_library(Pegasus::pegasus ALIAS pegasus)
add_subdirectory(pegasus)
# SEAL
target_link_libraries(pegasus PUBLIC Gemini-SEAL::seal)
# RapidJSON
target_include_directories(pegasus PRIVATE ${PEGASUS_THIRDPARTY_DIR}/rapidjson/include)
# Eigen
if (PEGASUS_USE_EIGEN)
  target_include_directories(pegasus PUBLIC ${EIGEN_INCLUDE_DIR})
endif()
# GMP
if (GMP_FOUND)
  target_include_directories(pegasus PUBLIC ${GMP_INCLUDE_DIRS})
  target_link_libraries(pegasus PUBLIC ${GMP_LIBRARIES})
endif(GMP_FOUND)
# Base64
target_include_directories(pegasus PRIVATE ${PEGASUS_THIRDPARTY_DIR})

# Examples
add_subdirectory(examples)
