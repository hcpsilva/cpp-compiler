#pragma once

#include "driver.hh"

hcpsilva::driver driver;

#define yyparse() driver.parse()
