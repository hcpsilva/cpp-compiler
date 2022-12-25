# find flex
lex = find_program('flex', required: true)

liblexic_gen_sources = custom_target('lexic-files',
                                     output : ['scanner.yy.cpp', 'scanner.yy.hpp'],
                                     input : 'scanner.l',
                                     command : [lex,
                                                '--outfile=@OUTPUT0@',
                                                '--header-file=@OUTPUT1@',
                                                '@INPUT@'])
liblexic_gen_headers = liblexic_gen_sources[1]

liblexic_sources = files('tools.cpp')

# declare the library for this module
liblexic = library('cpp-compiler-lexic',
                    sources : [liblexic_gen_sources, liblexic_sources],
                    dependencies: [fmt_dep],
                    include_directories : include_dir)

liblexic_dep = declare_dependency(sources : liblexic_gen_headers,
                                  link_with : liblexic)
