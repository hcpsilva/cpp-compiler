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

project_libraries = []

main = files('main.cpp')

include_dir = include_directories('include')

subdir('include') # config file

subdir('src') # sources

cpp_compiler_lib = static_library('etapa1-lib', [],
  include_directories : include_dir,
  dependencies : [fmt_dep, lexer_header_dep],
  link_whole : [project_libraries],
  install : true)

cpp_compiler_dep = declare_dependency(
  include_directories : include_dir,
  link_with : cpp_compiler_lib)

cpp_compiler_exec = executable('etapa1', main,
  dependencies : [cpp_compiler_dep, fmt_dep])

# test('basic', exe)
