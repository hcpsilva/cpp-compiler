# etapa1

project('cpp-compiler', ['cpp', 'c'],
        version : '1.0',
        license : 'GPL-3.0-or-later',
        default_options : [
          'warning_level=3',
          'cpp_std=gnu++20'])

fs = import('fs')

fmt_proj = subproject('fmt')
fmt_dep = fmt_proj.get_variable('fmt_dep')

main = files('main.cpp')

include_dir = include_directories('include')

subdir('include') # config file

subdir('src') # sources

cpp_compiler = executable('etapa1', main,
                          include_directories : include_dir,
                          dependencies : [fmt_dep, liblexic_dep],
                          install : true)

# test('basic', exe)
