package MT::Plugin::OMV::TinyLPO;
my $DESCRIPTION = <<'PERLHEREDOC';
#   TinyLPO - Tiny LPO
#           Original Code by delab - http://de-lab.com/article/mt-searchkeyword-lpo/
#           Programmed by Piroli YUKARINOMIYA
#           Open MagicVox.net - http://www.magicvox.net/
#           @see http://www.magicvox.net/
PERLHEREDOC

use strict;
use MT::Template::Context;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'TinyLPO';
$VERSION = '0.01 DEVEL';

### Register a plugin
use base qw( MT::Plugin );
my $plugin = new MT::Plugin({
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Piroli YUKARINOMIYA',
        author_link => "http://www.magicvox.net/?$MYNAME",
        doc_link => "http://www.magicvox.net/?$MYNAME",
        description => <<HTMLHEREDOC,
Original Code by delab - http://de-lab.com/article/mt-searchkeyword-lpo/
HTMLHEREDOC
});
MT->add_plugin( $plugin );

sub instance { $plugin; }



### MTIfTinyLPO
MT::Template::Context->add_container_tag( IfTinyLPO => \&if_tiny_lpo );
sub if_tiny_lpo {
    my ( $ctx, $args, $cond ) = @_;

    # Generate PHP codes
    my $php = <<"PHPSOURCECODE";
/************************************************************************
$DESCRIPTION
*/
PHPSOURCECODE

    $php .= <<'PHPSOURCECODE';
define( "CHARACTERSET", "UTF-8" );
function get_query_keyword() {
    $linkurl = $_SERVER['HTTP_REFERER'];
    if( strpos( $linkurl, ".google." )) {
        $str = eregi_replace( ".+[\?&]q=([^&]+).*", "\\1", $linkurl );
        $str = urldecode( $str );
        $str = mb_convert_encoding( $str, CHARACTERSET, "UTF-8" );
    } elseif( strpos( $linkurl, ".goo." )) {
        $str = eregi_replace( ".+[\?&]MT=([^&]+).*", "\\1", $linkurl );
        $str = urldecode( $str );
        $str = mb_convert_encoding( $str, CHARACTERSET, "EUC-JP" );
    } elseif( strpos( $linkurl, ".yahoo." )) {
        $str = eregi_replace( ".+[\?&]p=([^&]+).*", "\\1", $linkurl );
        $str = urldecode( $str );
        $str = mb_convert_encoding( $str, CHARACTERSET, "EUC-JP" );
    } elseif( strpos( $linkurl, ".msn." )) {
        $str = eregi_replace( ".+[\?&]q=([^&]+).*", "\\1", $linkurl );
        $str = urldecode( $str );
        $str = mb_convert_encoding( $str, CHARACTERSET, "UTF-8" );
    }
    return mb_convert_kana( $str, "s" );
}
$tiny_lpo_key = get_query_keyword();
if( $tiny_lpo_key != "" ) {
PHPSOURCECODE

    my $builder = $ctx->stash ('builder');
    my $tokens = $ctx->stash ('tokens');
    defined (my $out = $builder->build ($ctx, $tokens, $cond))
        or return $ctx->error ($builder->errstr);

    "<?php\n${php}?>$out<?php } ?>";
}

### $MTSearchEngineQuery$
MT::Template::Context->add_tag( SearchEngineQuery => \&search_engine_query );
sub search_engine_query {
    '<?php echo $tiny_lpo_key; ?>';
}

1;