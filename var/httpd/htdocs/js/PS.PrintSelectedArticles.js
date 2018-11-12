// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var PS = PS || {};

/**
 * @namespace
 * @exports TargetNS as PS.PrintSelectedArticles
 * @description
 *      This namespace contains the special module functions for the time tracking add on
 */
PS.PrintSelectedArticles = (function (TargetNS) {
    
    $('#ArticleTable > tbody > tr').each( function() {
        var ArticleID     = $(this).find('input.ArticleID').val();
        var ArticleNumber = $(this).find('input.SortData').val();

        var IsLoaded = Core.Config.Get('PrintSelectedArticlesLoaded_' + ArticleID );

        if ( IsLoaded ) {
            return;
        }

        var Checkbox = $('<input type="checkbox" name="print_checkbox_' + ArticleID + '" value="' + ArticleID + '" />');

        $(this).find('td.UnreadArticles').append( Checkbox );

        Checkbox.on( 'click', function(e) {
            var print_link  = $('a[target="print"]');        
            var link_target = print_link.attr( 'href' );
            var link_add    = ';PrintArticle=' + ArticleID + '__' + ArticleNumber;

            if ( $(this).is(':checked') ) {
                link_target += link_add;
            }
            else {
                link_target = link_target.replace( link_add, "" );
            }

            print_link.attr( 'href', link_target);

            e.stopImmediatePropagation();
        });

        Core.Config.Set('PrintSelectedArticlesLoaded_' + ArticleID, 1);
    });

    return TargetNS;
}(PS.PrintSelectedArticles || {}));

