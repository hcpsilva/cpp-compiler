project('cpp-compiler', ['cpp', 'c'],
        version : '2.0',
        license : 'GPL-3.0-or-later',
        default_options : [
          'warning_level=3',
          'buildtype=debug',
          'debug=true'])

add_project_arguments('-std=gnu++2b', language: 'cpp')

fs = import('fs')

include_dir = include_directories('include')

fmt_proj = subproject('fmt')
fmt_dep = fmt_proj.get_variable('fmt_dep')

magic_enum_proj = subproject('magic_enum')
magic_enum_dep = magic_enum_proj.get_variable('magic_enum_dep')

subdir('include') # generated configuration file

subdir('src') # sources

# test('basic', exe)
