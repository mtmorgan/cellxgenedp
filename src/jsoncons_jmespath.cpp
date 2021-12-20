#include "cpp11/declarations.hpp"

#include <jsoncons/config/version.hpp>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jmespath/jmespath.hpp>

using namespace jsoncons; // for convenience

[[cpp11::register]]
std::string cpp_version()
{
    versioning_info v = version();
    return
        std::to_string(v.major) + '.' +
        std::to_string(v.minor) + '.' +
        std::to_string(v.patch);
}

[[cpp11::register]]
std::string cpp_jmespath(std::string data, std::string path)
{
    json j = json::parse(data);
    json result = jmespath::search(j, path);
    return result.as<std::string>();
}
