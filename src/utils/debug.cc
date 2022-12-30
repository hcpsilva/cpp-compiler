#include "utils.hh"
#include "build-configurations.hh"

#include <cstdio>

#include "fmt/core.h"

namespace hcpsilva
{

template<typename... types>
auto log(std::string const& format, types... arguments) -> void
{
#ifdef VERBOSE
    fmt::print(format, arguments...);
#else
    return;
#endif
}

template<typename... types>
auto debug(std::string const& format, types... arguments) -> void
{
#ifdef DEBUG
    fmt::print(stderr, "{}:{}:{}(): ", __FILE__, __LINE__, __func__);
    fmt::print(stderr, format, arguments...);
#else
    return;
#endif
}

}

