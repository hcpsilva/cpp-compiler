# list module sources
libutils_sources = files('debug.cc')

# declare the library for the utils module
libutils = library('cpp-compiler-utils',
                    sources : [libutils_sources],
                    include_directories : include_dir,
                    dependencies: [fmt_dep])

libutils_dep = declare_dependency(link_with : libutils)
