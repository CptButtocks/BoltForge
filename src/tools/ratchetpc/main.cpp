#include <CLI/CLI.hpp>
#include <fmt/core.h>
#include <spdlog/spdlog.h>

#include <iostream>
#include <string>

#ifndef BOLTFORGE_VERSION
#define BOLTFORGE_VERSION "0.0.0"
#endif

int main(int argc, char** argv) {
  CLI::App app{"BoltForge native PC tooling"};
  app.set_version_flag("--version", fmt::format("ratchetpc {}", BOLTFORGE_VERSION));

  if (argc == 1) {
    std::cout << app.help();
    return 0;
  }

  spdlog::set_level(spdlog::level::warn);
  CLI11_PARSE(app, argc, argv);
  return 0;
}
