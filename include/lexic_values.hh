/** @file lexic_values.hh
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

#include <algorithm>
#include <cctype>
#include <concepts>
#include <ostream>
#include <string>
#include <string_view>
#include <type_traits>
#include <variant>

#include <fmt/core.h>
#include <fmt/format.h>
#include <fmt/std.h>
#include <magic_enum.hpp>

namespace hcpsilva {

enum class keywords {
    IF,
    WHILE,
    INPUT,
    OUTPUT,
    RETURN
};

enum class types {
    INT,
    FLOAT,
    CHAR,
    BOOL
};

enum class operations {
    ATTRIBUTION,
    INITIALIZATION,
    DIVISION,
    MULTIPLICATION,
    REST,
    LESS_THAN,
    GREATER_THAN,
    LESS_EQUAL,
    GREATER_EQUAL,
    EQUAL,
    NOT_EQUAL,
    AND,
    OR,
    NEGATION,
    POSITIVE,
    NEGATIVE,
    INDEX,
    INDEX_SEP
};

using lexic_value = std::variant<std::monostate, types, keywords, operations, int, bool, double, char, std::string>;

template <typename type_to_check, typename... types_to_check_against>
concept type_in = (std::same_as<std::remove_cvref_t<type_to_check>, types_to_check_against> || ...);

template <class T>
concept is_custom_ast_node = type_in<operations, keywords, types>;
}

template <typename T>
    requires std::is_enum_v<T>
struct fmt::formatter<T> : formatter<std::string> {
    template <typename FormatContext>
    auto format(T const& value, FormatContext& ctx) const
    {
        auto name = std::string(magic_enum::enum_name(value));

        // please use ASCII, don't break my code. maybe i'll use an unicode
        // formatting library in the future. until then, just ASCII. that being
        // said, this will break only if you, for some reason, think it's a
        // good idea to add enum members in unicode.
        std::transform(name.begin(), name.end(), name.begin(), [](unsigned char c) { return std::tolower(c); });

        return fmt::formatter<std::string>::format(name, ctx);
    }
};

template <>
struct fmt::formatter<hcpsilva::lexic_value> {
    template <typename ParseContext>
    auto parse(ParseContext& ctx) -> decltype(ctx.begin())
    {
        return ctx.begin();
    }

    template <typename FormatContext>
    auto format(hcpsilva::lexic_value const& val, FormatContext& ctx) const -> decltype(ctx.out())
    {
        auto out = ctx.out();

        std::visit([&](auto const& v) { out = detail::write<char>(out, v); }, val);

        return out;
    }
};

template <>
struct fmt::formatter<hcpsilva::operations> : formatter<std::string> {
    template <typename FormatContext>
    auto format(hcpsilva::operations const& op, FormatContext& ctx)
    {
        std::string op_name;

        switch (op) {
        case hcpsilva::operations::ATTRIBUTION:
            op_name = "=";
            break;
        case hcpsilva::operations::INITIALIZATION:
            op_name = "<=";
            break;
        case hcpsilva::operations::DIVISION:
            op_name = "/";
            break;
        case hcpsilva::operations::MULTIPLICATION:
            op_name = "*";
            break;
        case hcpsilva::operations::POSITIVE:
            op_name = "+";
            break;
        case hcpsilva::operations::NEGATIVE:
            op_name = "-";
            break;
        case hcpsilva::operations::NEGATION:
            op_name = "!";
            break;
        case hcpsilva::operations::REST:
            op_name = "%";
            break;
        case hcpsilva::operations::LESS_THAN:
            op_name = "<";
            break;
        case hcpsilva::operations::LESS_EQUAL:
            op_name = "<=";
            break;
        case hcpsilva::operations::GREATER_THAN:
            op_name = ">";
            break;
        case hcpsilva::operations::GREATER_EQUAL:
            op_name = ">=";
            break;
        case hcpsilva::operations::EQUAL:
            op_name = "==";
            break;
        case hcpsilva::operations::NOT_EQUAL:
            op_name = "!=";
            break;
        case hcpsilva::operations::AND:
            op_name = "&&";
            break;
        case hcpsilva::operations::OR:
            op_name = "||";
            break;
        case hcpsilva::operations::INDEX:
            op_name = "[]";
            break;
        case hcpsilva::operations::INDEX_SEP:
            op_name = "^";
            break;
        default:
            op_name = std::string(magic_enum::enum_name(op));
        }

        return fmt::formatter<std::string>::format(op_name, ctx);
    }
};
