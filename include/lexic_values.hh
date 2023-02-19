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

enum class keyword {
    IF,
    WHILE,
    INPUT,
    OUTPUT,
    RETURN
};

enum class type {
    INT,
    FLOAT,
    CHAR,
    BOOL
};

enum class operation {
    ATTRIBUTION,
    INITIALIZATION,
    CALL,
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

using lexic_value = std::variant<std::monostate, type, keyword, operation, int, bool, double, char, std::string>;

template <typename type_to_check, typename... types_to_check_against>
concept type_in = (std::same_as<std::remove_cvref_t<type_to_check>, types_to_check_against> || ...);

template <class T>
concept is_custom_ast_node = type_in<operation, keyword, type>;
}

template <typename T>
    requires std::is_enum_v<T>
struct fmt::formatter<T> : formatter<std::string> {
    template <typename FormatContext>
    auto format(T const& value, FormatContext& ctx) const
    {
        return fmt::formatter<std::string>::format(std::string(magic_enum::enum_name(value)), ctx);
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
