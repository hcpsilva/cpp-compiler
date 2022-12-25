# find flex
lex = find_program('flex', required: true)

liblexer_gen_sources = custom_target('lexer-files',
                                     output : ['scanner.yy.cpp', 'scanner.yy.hpp'],
                                     input : 'scanner.l',
                                     command : [lex,
                                                '--outfile=@OUTPUT0@',
                                                '--header-file=@OUTPUT1@',
                                                '@INPUT@'])
liblexer_gen_headers = liblexer_gen_sources[1]

liblexer_sources = files('tools.cpp')

# declare the library for this module
liblexer = library('cpp-compiler-lexer',
                    sources : [liblexer_gen_sources, liblexer_sources],
                    dependencies: [fmt_dep],
                    include_directories : include_dir)

liblexer_dep = declare_dependency(sources : liblexer_gen_headers,
                                  link_with : liblexer)
