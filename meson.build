# etapa2

project('cpp-compiler', ['cpp', 'c'],
        version : '2.0',
        license : 'GPL-3.0-or-later',
        default_options : [
          'warning_level=3',
          'cpp_std=gnu++20'])

fs = import('fs')

include_dir = include_directories('include')

fmt_proj = subproject('fmt')
fmt_dep = fmt_proj.get_variable('fmt_dep')

subdir('include') # generated configuration file

subdir('src') # sources

# test('basic', exe)
