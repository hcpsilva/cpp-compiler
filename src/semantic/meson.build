# list module sources
libsemantic_sources = files('ast.cc')

libsemantic_direct_dependencies = [fmt_dep, libparser_dep, magic_enum_dep]

# declare the library for the utils module
libsemantic = library('cpp-compiler-semantic',
                      sources : [libsemantic_sources],
                      include_directories : include_dir,
                      dependencies: libsemantic_direct_dependencies)

libsemantic_dep = declare_dependency(link_with : libsemantic,
                                     dependencies : libsemantic_direct_dependencies)
