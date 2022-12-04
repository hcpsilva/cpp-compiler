project('cpp-compiler', 'cpp',
  version : '0.1',
  default_options : [
    'warning_level=3',
    'cpp_std=c++20'])

fmt_proj = subproject('fmt')
fmt_dep = fmt_proj.dependency('fmt')

include_dir = include_directories('include')

subdir('src') # sources

cpp_compiler_lib = static_library('etapa1-lib',
  project_sources,
  include_directories : include_dir,
  dependencies : [fmt_dep],
  link_whole : [project_libraries],
  install : true)

cpp_compiler_dep = declare_dependency(
  include_directories : include_dir,
  link_with : cpp_compiler_lib)

cpp_compiler_exec = executable(
  'etapa1', main,
  dependencies : cpp_compiler_dep)

test('basic', exe)
