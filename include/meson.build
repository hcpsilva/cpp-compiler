# setup includes configuration file
conf_inc = configuration_data()

# set the options
conf_inc.set_quoted('VERSION_STR', meson.project_version())
conf_inc.set('VERBOSE', get_option('verbose'))
conf_inc.set('DEBUG', get_option('buildtype') in ['debug', 'debugoptimized'])

# create configuration file
configure_file(
  input : 'cpp-compiler-config.hpp.in',
  output : '@BASENAME@',
  configuration : conf_inc
)
