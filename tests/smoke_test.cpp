#include <catch2/catch_test_macros.hpp>
#include <fmt/core.h>
#include <nlohmann/json.hpp>
#include <yaml-cpp/yaml.h>

#include <string>

TEST_CASE("toolchain dependencies are usable") {
  const auto message = fmt::format("{} {}", "BoltForge", 1);
  const nlohmann::json manifest{{"name", "BoltForge"}, {"schema", 1}};

  YAML::Node node;
  node["name"] = "BoltForge";

  REQUIRE(message == "BoltForge 1");
  REQUIRE(manifest.at("name").get<std::string>() == "BoltForge");
  REQUIRE(node["name"].as<std::string>() == "BoltForge");
}
