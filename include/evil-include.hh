#pragma once

#include "driver.hh"

using namespace hcpsilva;

driver driver;

#define yyparse() driver.parse()
#define yylex_destroy() ((void)0)
