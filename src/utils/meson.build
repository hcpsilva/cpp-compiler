# list module sources
libutils_sources = files('debug.cc')

libutils_direct_dependencies = [fmt_dep, magic_enum_dep]

# declare the library for the utils module
libutils = library('cpp-compiler-utils',
                   sources : [libutils_sources],
                   include_directories : include_dir,
                   dependencies: libutils_direct_dependencies)

libutils_dep = declare_dependency(link_with : libutils,
                                  dependencies : libutils_direct_dependencies)
