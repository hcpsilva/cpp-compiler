# find flex
lex = find_program('flex', required: true)

lexer_gen = custom_target('lexer-files',
                          output : ['scanner.yy.cpp', 'scanner.yy.hpp'],
                          input : 'scanner.l',
                          command : [lex,
                                     '--outfile=@OUTPUT0@',
                                     '--header-file=@OUTPUT1@',
                                     '@INPUT@'])

lexer_sources = files('tools.cpp')

# declare the library for this module
lexer_lib = static_library('cpp-compiler-lexer',
                           lexer_gen[0], lexer_sources,
                           dependencies: [fmt_dep],
                           include_directories : include_dir)

lexer_header_dep = declare_dependency(sources : [lexer_gen[1]],
                                      link_with : [lexer_lib])

# add the lib object to the list of libraries
project_libraries += lexer_lib
