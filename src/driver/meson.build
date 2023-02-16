# list module sources
libdriver_sources = files('driver.cc')

libdriver_direct_dependencies = [libparser_dep, tree_dep]

# declare the library for the driver module
libdriver = library('cpp-compiler-driver',
                    sources : [libdriver_sources],
                    include_directories : include_dir,
                    dependencies : libdriver_direct_dependencies)

libdriver_dep = declare_dependency(link_with : libdriver,
                                   dependencies : libdriver_direct_dependencies)
