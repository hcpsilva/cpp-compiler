# find flex
lex = find_program('flex', required: true)

lgen = generator(lex,
  output : '@PLAINNAME@.yy.cpp',
  arguments : ['-o', '@OUTPUT@', '@INPUT@'])

# generate flex source and add other sources
lexer_gen = lgen.process('scanner.l')
lexer_sources = files('tools.cpp')

# declare the library for this module
lexer_lib = static_library('cpp-compiler-lexer',
  lexer_gen, lexer_sources,
  dependencies: [fmt_dep],
  include_directories : include_dir)

# add the lib object to the list of libraries
project_libraries += lexer_lib
