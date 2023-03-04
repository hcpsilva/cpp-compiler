#pragma once

#include <cstddef>
#include <location.hh>
#include <string>
#include <unordered_map>

#include "lexic_values.hh"

namespace hcpsilva {
enum class symbol_kinds {
    VARIABLE,
    ARRAY,
    FUNCTION
};

struct symbol {
    yy::location location;
    symbol_kinds kind;
    types        type;
    size_t       size;
};

using symbol_hash_table = std::unordered_map<std::string, symbol>;

}
