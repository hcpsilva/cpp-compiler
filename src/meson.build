# traverse modules
subdir('utils')
subdir('parser')
subdir('semantic')
subdir('driver')

# stage_1 = executable('stage-1', files('stage-1.cc'),
#                      dependencies : [fmt_dep, libparser_dep],
#                      install : true)

stage_2 = executable('stage-2', files('stage-2.cc'),
                     dependencies : libdriver_dep,
                     include_directories : include_dir,
                     install : true)

stage_3 = executable('stage-3', files('stage-3.cc'),
                     dependencies : libdriver_dep,
                     include_directories : include_dir,
                     install : true)

