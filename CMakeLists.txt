cmake_minimum_required(VERSION 3.25)

project(
  BoltForge
  VERSION 0.1.0
  DESCRIPTION "Native PC tooling and runtime research for PS2 Ratchet & Clank games"
  LANGUAGES CXX
)

include(CTest)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(CLI11 CONFIG REQUIRED)
find_package(Catch2 CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(yaml-cpp CONFIG REQUIRED)

add_executable(ratchetpc src/tools/ratchetpc/main.cpp)
target_compile_definitions(ratchetpc PRIVATE BOLTFORGE_VERSION="${PROJECT_VERSION}")
target_link_libraries(
  ratchetpc
  PRIVATE
    CLI11::CLI11
    fmt::fmt
    spdlog::spdlog
)

if(BUILD_TESTING)
  add_executable(boltforge_smoke_tests tests/smoke_test.cpp)
  target_link_libraries(
    boltforge_smoke_tests
    PRIVATE
      Catch2::Catch2WithMain
      fmt::fmt
      nlohmann_json::nlohmann_json
      yaml-cpp::yaml-cpp
  )
  add_test(NAME boltforge.smoke COMMAND boltforge_smoke_tests)
endif()
