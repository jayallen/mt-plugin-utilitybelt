# Utility Belt - A plugin for Movable Type.
# Copyright (c) 2008, Arvind Satyanarayan.
# This program is distributed under the terms of the
# GNU General Public License, version 2.

package MT::Plugin::UtilityBelt;

use strict;
use MT 4.0;
use base qw( MT::Plugin );

# Define $DISPLAY_NAME only if different from package ending (i.e. TestPlugin)
our $DISPLAY_NAME = ''; 
our $VERSION = '1.0'; 

our ($plugin, $PLUGIN_MODULE, $PLUGIN_KEY);
MT->add_plugin($plugin = __PACKAGE__->new({
   id          => plugin_module(),
   key         => plugin_key(),
   name        => plugin_name(),
   description => "My first plugin",
   version     => $VERSION,
   author_name => "Arvind Satyanarayan",
   author_link => "http://movalog.com/",
   plugin_link => "[link to plugin's homepage]",
}));
sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        applications => {
            cms => {
                callbacks => {
                    'template_param.header' => '$UtilityBelt::UtilityBelt::header_param',
                    'template_param.footer' => '$UtilityBelt::UtilityBelt::footer_param',
                    'template_output.start_rebuild' => '$UtilityBelt::UtilityBelt::template_output_json',
                    'template_output.rebuilding' => '$UtilityBelt::UtilityBelt::template_output_json',
                    'template_output.rebuilt' => '$UtilityBelt::UtilityBelt::template_output_json'
                } 
            }
        }        
    });
}

sub plugin_name     { return ($DISPLAY_NAME || plugin_module()) }
sub plugin_module   {
    $PLUGIN_MODULE or ($PLUGIN_MODULE = __PACKAGE__) =~ s/^MT::Plugin:://;
    return $PLUGIN_MODULE;
}
sub plugin_key      {
    $PLUGIN_KEY or ($PLUGIN_KEY = lc(plugin_module())) =~ s/\s+//g;
    return $PLUGIN_KEY
}

sub instance { $plugin; }

1;