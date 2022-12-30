# list module sources
libdriver_sources = files('driver.cc')

# declare the library for the driver module
libdriver = library('cpp-compiler-driver',
                    sources : [libdriver_sources],
                    include_directories : include_dir,
                    dependencies: [fmt_dep, libparser_dep])

libdriver_dep = declare_dependency(link_with : libdriver)
