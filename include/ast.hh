/** @file ast.hh
 *
 * @copyright (C) 2022 Henrique Silva
 *
 *
 * @author Henrique Silva <hcpsilva@inf.ufrgs.br>
 *
 * @section LICENSE
 *
 * This file is subject to the terms and conditions defined in the file
 * 'LICENSE', which is part of this source code package.
 */

#pragma once

#include "lexic_values.hh"
#include "location.hh"
#include "tree.hh"

namespace hcpsilva {

struct ast_value {
    lexic_value  value;
    yy::location location;
};

using ast_node = tree_node<lexic_value>;

}

namespace fmt {

template <>
struct formatter<hcpsilva::ast_value> {
    template <typename ParseContext>
    constexpr auto parse(ParseContext& ctx)
    {
        return ctx.begin();
    }
};

template <typename FormatContext>
auto format(hcpsilva::ast_value const& value, FormatContext& ctx)
{
    return format_to(ctx.begin(), "{}", &value, value.value);
}
}
