# --
# Kernel/Output/HTML/OutputFilterPrintSelectedArticles.pm
# Copyright (C) 2014 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterPrintSelectedArticles;

use strict;
use warnings;

use List::Util qw(first);

our $VERSION = 0.03;

our @ObjectDependencies = qw(
    Kernel::System::Web::Request
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get template name
    #my $Templatename = $Param{TemplateFile} || '';
    my $Templatename = $ParamObject->GetParam( Param => 'Action' );

    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    # define if rich text should be used
    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );

    return 1 if !$TicketID;

    # add checkboxes
    my $Checkbox = q~
      <input type="checkbox" name="print_checkbox_[% Data.ArticleID | html %]" value="[% Data.ArticleID | html %]" />
    ~;

    ${ $Param{Data} } =~ s{(<td class=".*? NonTextContent">)}{$1$Checkbox};

    # check for checked articles on click
    my $JS = q~
    $('input[name^="print_checkbox"]').each( function() {
        $(this).bind( 'click', function(e) {
            var print_link  = $('a[target="print"]');        
            var link_target = print_link.attr( 'href' );
            var link_add    = ';ArticleID=' + $(this).val();

            if ( $(this).is(':checked') ) {
                link_target += link_add;
            }
            else {
                link_target = link_target.replace( link_add, "" );
            }

            print_link.attr( 'href', link_target);

            e.stopImmediatePropagation();
        });
    });
    ~;

    ${ $Param{Data} } =~ s{(Core.Agent.TicketZoom.Init\(.*?;)}{$1$JS};

    return ${ $Param{Data} };
}

1;
