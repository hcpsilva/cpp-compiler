# find flex and bison
lex = find_program('flex', required: true)
yacc = find_program('bison', required: true)

yacc_gen_sources = custom_target('yacc-generated-sources',
                                 build_always : true,
                                 output : ['parser.cc', 'parser.hh', 'location.hh'],
                                 input : 'parser.yy',
                                 command : [yacc, '-Wall',
                                            '--output=@OUTPUT0@',
                                            '--header=@OUTPUT1@',
                                            '@INPUT@'])

lex_gen_sources = custom_target('lex-generated-sources',
                                build_always : true,
                                output : ['scanner.cc', 'scanner.hh'],
                                input : 'scanner.l',
                                command : [lex,
                                           '--outfile=@OUTPUT0@',
                                           '--header-file=@OUTPUT1@',
                                           '@INPUT@'])

libparser_sources = files('scanner-tools.cc')

# declare the library for the parser module
libparser = library('cpp-compiler-parser',
                    sources : [yacc_gen_sources,
                               lex_gen_sources,
                               libparser_sources],
                    include_directories : include_dir,
                    dependencies: [fmt_dep, libutils_dep])

libparser_dep = declare_dependency(sources : [yacc_gen_sources[1],
                                              yacc_gen_sources[2]],
                                   link_with : libparser)
