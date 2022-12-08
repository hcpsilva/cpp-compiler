/** @file debug.hpp
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
 *
 * @section DESCRIPTION
 *
 * Includes the declaration of some functions that either the lexer
 * itself uses or other public functions to other modules.
 */

#if !defined(_DEBUG_HPP_)
#define _DEBUG_HPP_

#include <stdio.h>

#ifdef VERBOSE
#define V_PRINTF(f_, ...) printf((f_), ##__VA_ARGS__)
#define V_PERROR(f_) perror((f_))
#else
#define V_PRINTF(...) ((void)0)
#define V_PERROR(f_) ((void)0)
#endif

#ifdef DEBUG
#define D_PRINTF(f_, ...) \
    fprintf(stderr, "%s:%d:%s():", __FILE__, __LINE__, __func__); \
    fprintf(stderr, (f_), ##__VA_ARGS__)
#else
#define D_PRINTF(f_, ...) ((void)0)
#endif

#endif // _DEBUG_HPP_
