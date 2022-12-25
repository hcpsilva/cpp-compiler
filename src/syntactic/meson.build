# find bison
yacc = find_program('bison', required: true)

libsyntactic_gen_sources = custom_target(
  'syntactic-gen-files',
  output : ['parser.tab.cpp', 'parser.tab.hpp'],
  input : 'parser.y',
  command : [yacc,
             '--output=@OUTPUT0@',
             '--header=@OUTPUT1@',
             '--color=yes',
             '-Wall',
             '@INPUT@'])

libsyntactic_gen_headers = libsyntactic_gen_sources[1]

libsyntactic_sources = []

# declare the library for this module
libsyntactic = library('cpp-compiler-syntactic',
                       sources : [libsyntactic_gen_sources, libsyntactic_sources],
                       dependencies: [fmt_dep, liblexic_dep],
                       include_directories : include_dir)

libsyntactic_dep = declare_dependency(sources : libsyntactic_gen_headers,
                                      link_with : libsyntactic)
