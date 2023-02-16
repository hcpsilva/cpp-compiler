/*
 * Função principal para realização da E3.
 * Não modifique este arquivo.
 */

#include "driver.hh"

auto main(void) -> int
{
    hcpsilva::driver driver;

    int ret = driver.parse();

    if (ret == 0)
        driver.print_ast();

    return ret;
}
