package UtilityBelt;

use strict;
use MT::Util qw( encode_html );

sub header_param {
    my ($cb, $app, $param, $tmpl) = @_; 
    my $plugin = MT::Plugin::UtilityBelt->instance;
    
    my $html_head = $tmpl->getElementsByName('html_head')->[0];
    
    my $header_include = $tmpl->createElement('include', 
                        { name => File::Spec->catdir($plugin->path,'tmpl','header-include.tmpl') });
    $tmpl->insertAfter($header_include, $html_head);
}

sub footer_param {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT::Plugin::UtilityBelt->instance;
    
    require MT::Blog;
    require MT::Template;
    require MT::CMS::Blog;
    my %args;
    $app->build_blog_selector(\%args);
    foreach my $b (@{$args{top_blog_loop}}) {
        my $blog = MT::Blog->load($b->{top_blog_id});
        MT::CMS::Blog::_create_build_order( $app, $blog, $b );
        
        my @templates = MT::Template->load({ blog_id => $blog->id, type => 'index' },
                                           { sort => 'name', direction => 'ascend' });
        foreach my $tmpl (@templates) {
            push @{$b->{index_loop}}, $tmpl->column_values;
        }
    } 
    
    my $mt_beta = $tmpl->getElementsByName('mt_beta')->[0];
    
    $args{name} = File::Spec->catdir($plugin->path,'tmpl','utility-belt.tmpl');
    my $utility_belt = $tmpl->createElement('include', \%args);
                        
    $tmpl->insertBefore($utility_belt, $mt_beta);
}

sub template_output_json {
    my ($eh, $app, $tmpl_str, $param, $tmpl) = @_;
    
    return unless $app->param('json');
    
    foreach my $key (keys %$param) {
        delete $param->{$key} if ref $param->{$key} && ref $param->{$key} ne 'HASH';
    }
    
    my ($rebuilding, $rebuilt);
    if($param->{is_individual}) {
        $rebuilding = $app->translate("Publishing [_1] [_2]...",
                                                            encode_html($param->{build_type_name}),
                                                                encode_html($param->{indiv_range}));
    } elsif($param->{dynamic}) {
        $rebuilding = $app->translate("Publishing [_1] dynamic links...", 
                                                            encode_html($param->{build_type_name}));
    } elsif($param->{archives}) {
        $rebuilding = $app->translate("Publishing [_1] archives...", 
                                                            encode_html($param->{build_type_name}));
                                                            
        $rebuilt = $app->translate("Your [_1] archives have been published.",
                                                            encode_html($param->{type}));
    } else {
        $rebuilding = $app->translate("Publishing [_1] templates...", encode_html($param->{build_type_name}));
        $rebuilt = $app->translate("Your [_1] templates have been published.", encode_html($param->{type}));
    }
    
    if($param->{all}) {
        $rebuilt = $app->translate("The files for [_1] have been published.",
                                                            encode_html($param->{blog_name}));
    }
    $param->{rebuilding_label} = $rebuilding;
    $param->{rebuilt_label} = $rebuilt;
    $param->{tmpl_name} = $tmpl->{__file};
    $param->{tmpl_id} = $app->param('tmpl_id');
    $param->{single_template} = $app->param('single_template');
    
    require JSON;
    $$tmpl_str = JSON::objToJson($param);
}

1;