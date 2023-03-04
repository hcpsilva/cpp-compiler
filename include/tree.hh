/** @file tree.hh
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
#include <functional>
#include <memory>
#include <optional>
#include <ranges>
#include <vector>

#include <fmt/core.h>
#include <fmt/format.h>

namespace hcpsilva {

template <typename T>
struct tree_node {
    T                             value;
    std::vector<tree_node<T>>     children;
    std::shared_ptr<tree_node<T>> next = nullptr; // a child, but special (i.e. a hack)

    auto add_child(tree_node<T> const& child) -> void;

    auto add_child(tree_node<T>&& child) -> void;

    template <std::same_as<tree_node<T>>... nodes>
    auto add_children(nodes&&... children) -> void
    {
        this->children.reserve(sizeof...(nodes));
        (this->children.push_back(std::forward<nodes>(children)), ...);
    }

    auto append_next(tree_node<T> const& child) -> void;

    auto append_next(tree_node<T>&& child) -> void;

    auto print() const -> void;

    auto print_edges() const -> void;

    auto apply(std::function<void(T const&)>) const -> void;

    auto map(std::function<T(T const&)>) const -> tree_node<T>;

    consteval tree_node() noexcept = default;

    constexpr tree_node(T const& in_value)
        : value(in_value)
        , children()
    {
    }

    constexpr tree_node(tree_node<T> const& in_node) noexcept = default;

    constexpr tree_node(tree_node<T>&& in_node) noexcept = default;

    template <std::same_as<tree_node<T>>... nodes>
    tree_node(T const& value, nodes&&... children) noexcept
        : value(value)
        , children { std::forward<nodes>(children)... }
    {
    }

    template <std::same_as<tree_node<T>>... nodes>
    tree_node(T&& value, nodes&&... children) noexcept
        : value(std::move(value))
        , children { std::forward<nodes>(children)... }
    {
    }

    auto operator=(tree_node<T> const& rhs) -> tree_node<T>& = default;

    auto operator=(tree_node<T>&& rhs) -> tree_node<T>& = default;

    auto operator<=>(tree_node<T> const& rhs) const { return this->value <=> rhs.value; }
};

template <typename T>
auto tree_node<T>::add_child(tree_node<T> const& child) -> void
{
    this->children.emplace_back(child);
}

template <typename T>
auto tree_node<T>::add_child(tree_node<T>&& child) -> void
{
    this->children.emplace_back(std::move(child));
}

template <typename T>
auto tree_node<T>::append_next(tree_node<T> const& child) -> void
{
    if (this->next != nullptr) {
        next->append_next(child);
    } else {
        next = std::make_shared<tree_node<T>>(child);
    }
}

template <typename T>
auto tree_node<T>::append_next(tree_node<T>&& child) -> void
{
    if (this->next != nullptr) {
        next->append_next(std::move(child));
    } else {
        next = std::make_shared<tree_node<T>>(std::move(child));
    }
}

template <typename T>
auto tree_node<T>::print() const -> void
{
    fmt::print("{} [label=\"{}\"]\n", fmt::ptr(this), this->value);

    for (auto const& child : this->children)
        child.print();

    if (this->next != nullptr)
        this->next->print();
}

template <typename T>
auto tree_node<T>::print_edges() const -> void
{
    constexpr auto edge_print = [](tree_node<T> const* from, tree_node<T> const* to) {
        fmt::print("{}, {}\n", fmt::ptr(from), fmt::ptr(to));
    };

    for (auto const& child : this->children) {
        edge_print(this, &child);

        child.print_edges();
    }

    if (this->next != nullptr) {
        edge_print(this, this->next.get());

        this->next->print_edges();
    }
}

template <typename T>
auto tree_node<T>::apply(std::function<void(T const&)> func) const -> void
{
    func(this->value);

    for (auto const& child : this->children)
        child.apply(func);
}

template <typename T>
auto tree_node<T>::map(std::function<T(T const&)> func) const -> tree_node<T>
{
    auto children_set = this->children | std::views::transform(std::bind(&tree_node<T>::map, func));

    return tree_node<T>(func(this->value), children_set);
}

}

template <typename T>
struct fmt::formatter<hcpsilva::tree_node<T>> : formatter<std::string> {
    template <typename FormatContext>
    auto format(hcpsilva::tree_node<T> const& node, FormatContext& ctx) -> decltype(ctx.out())
    {
        return fmt::format_to(ctx.out(), "{}", node.value);
    }
};
