# find flex and bison
lex = find_program('flex', required: true)
yacc = find_program('bison', required: true)

yacc_gen_sources = custom_target('yacc-generated-sources',
                                 output : ['parser.cc', 'parser.hh', 'location.hh'],
                                 input : 'parser.yy',
                                 command : [yacc, '-Wall', '-Wcounterexamples',
                                            '--output=@OUTPUT0@',
                                            '--header=@OUTPUT1@',
                                            '@INPUT@'])

lex_gen_sources = custom_target('lex-generated-sources',
                                output : ['scanner.cc', 'FlexLexer.h'],
                                input : 'scanner.ll',
                                command : [lex,
                                           '--outfile=@OUTPUT0@',
                                           '@INPUT@'])

libparser_sources = []

# declare the library for the parser module
libparser = library('cpp-compiler-parser',
                    sources : [yacc_gen_sources,
                               lex_gen_sources,
                               libparser_sources],
                    include_directories : include_dir,
                    dependencies: [fmt_dep, libutils_dep])

libparser_dep = declare_dependency(sources : [yacc_gen_sources[1],
                                              yacc_gen_sources[2],
                                              lex_gen_sources[1]],
                                   link_with : libparser)
