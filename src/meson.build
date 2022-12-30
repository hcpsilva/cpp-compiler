# traverse modules
subdir('utils')
subdir('parser')
subdir('driver')

# stage_1 = executable('stage-1', files('stage-1.cc'),
#                      dependencies : [fmt_dep, libparser_dep],
#                      install : true)

stage_2 = executable('stage-2', files('stage-2.cc'),
                     dependencies : [fmt_dep, libparser_dep, libdriver_dep],
                     include_directories : include_dir,
                     install : true)

