# find flex
lex = find_program('flex', required: true)

lgen = generator(flex,
  output : '@PLAINNAME@.yy.c',
  arguments : ['-o', '@OUTPUT@', '@INPUT@'])

# generate flex source
lexer_sources = lgen.process('scanner.l')

# list all cpp sources of the solver module
lexer_sources += files('tools.c')
# and the headers of the module
lexer_headers = files('scanner.hpp', 'tools.hpp', 'tokens.h')

# add those to their respective lists
project_sources += lexer_sources
project_headers += lexer_headers

# declare the library for this module
lexer_lib = static_library(
  'cpp-compiler-lexer', lexer_sources,
  include_directories : inc)

# add the lib object to the list of libraries
project_libraries += lexer_lib
