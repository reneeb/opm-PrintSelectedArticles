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

use Kernel::System::Encode;
use Kernel::System::Time;

our $VERSION = 0.02;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(MainObject ConfigObject LogObject LayoutObject ParamObject)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{UserID} = $Param{UserID};

    $Self->{EncodeObject}    = $Param{EncodeObject} || Kernel::System::Encode->new( %{$Self} );
    $Self->{TimeObject}      = $Param{TimeObject}   || Kernel::System::Time->new( %{$Self} );

    $Self->{DBObject} = $Self->{LayoutObject}->{DBObject};

    if ( $Param{TicketObject} ) {
        $Self->{TicketObject} = $Param{TicketObject};
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    #my $Templatename = $Param{TemplateFile} || '';
    my $Templatename = $Self->{ParamObject}->GetParam( Param => 'Action' );

    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};
    return 1 if !$Self->{TicketObject};

    # define if rich text should be used
    my ($TicketID) = $Self->{ParamObject}->GetParam( Param => 'TicketID' );

    return 1 if !$TicketID;

    # add checkboxes
    my $Checkbox = q~
      <input type="checkbox" name="print_checkbox_$QData{"ArticleID"}" value="$QData{"ArticleID"}" />
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
