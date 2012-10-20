package MT::Plugin::OMV::TinyLPO;
my $DESCRIPTION = <<'PERLHEREDOC';
#   TinyLPO - Tiny LPO
#           Original Code by delab - http://de-lab.com/article/mt-searchkeyword-lpo/
#           Programmed by Piroli YUKARINOMIYA
#           Open MagicVox.net - http://www.magicvox.net/
#           @see http://www.magicvox.net/archive/2008/10061124/
#   $Id$
PERLHEREDOC

use strict;
use MT 3;
use MT::Template::Context;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.04'. ($revision ? ".$revision" : '');

### Register a plugin
use base qw( MT::Plugin );
my $plugin = new MT::Plugin({
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Piroli YUKARINOMIYA',
        author_link => "http://www.magicvox.net/?$MYNAME",
        doc_link => "http://www.magicvox.net/archive/2008/10061124/",
        description => <<HTMLHEREDOC,
Original Code by delab - http://de-lab.com/article/mt-searchkeyword-lpo/
HTMLHEREDOC
});
MT->add_plugin( $plugin );

sub instance { $plugin; }



### MTIfTinyLPO
MT::Template::Context->add_container_tag( IfTinyLPO => \&if_tiny_lpo );
sub if_tiny_lpo {
    my ($ctx, $args, $cond) = @_;

    my $charset = {
        'iso-8859-1' => 'ASCII',
        'iso-2022-jp' => 'JIS',
        'utf-8' => 'UTF-8',
        'euc-jp' => 'EUC-JP',
        'shift_jis' => 'SJIS',
    }->{lc MT->instance->config->PublishCharset} || 'UTF-8';

    # Generate PHP codes
    my $php = <<"PHPSOURCECODE";
/************************************************************************
$DESCRIPTION
*/
define ("CHARACTERSET", "$charset");
PHPSOURCECODE

    $php .= <<'PHPSOURCECODE';
function get_domain ($url) {
    return preg_replace ('/^https?:\/\/([^\/]+).+/', '$1', $url);
}

function get_query_keyword () {
    $linkurl = $_SERVER['HTTP_REFERER'];
    $str = '';
    if (strpos (get_domain ($linkurl), ".google.")) {
        $str = eregi_replace (".+[\?&]q=([^&]+).*", "\\1", $linkurl);
        $str = urldecode ($str);
        $str = mb_convert_encoding ($str, CHARACTERSET, "UTF-8");
    }
    elseif (strpos (get_domain ($linkurl), ".yahoo.")) {
        $str = eregi_replace (".+[\?&]p=([^&]+).*", "\\1", $linkurl);
        $str = urldecode ($str);
        $str = mb_convert_encoding ($str, CHARACTERSET, "UTF-8");
    }
    elseif (strpos (get_domain ($linkurl), ".bing.")) {
        $str = eregi_replace (".+[\?&]q=([^&]+).*", "\\1", $linkurl);
        $str = urldecode ($str);
        $str = mb_convert_encoding ($str, CHARACTERSET, "UTF-8");
    }
    elseif (strpos (get_domain ($linkurl), ".goo.")) {
        $str = eregi_replace (".+[\?&]MT=([^&]+).*", "\\1", $linkurl);
        $str = urldecode ($str);
        $str = mb_convert_encoding ($str, CHARACTERSET, "EUC-JP");
    }
    return mb_convert_kana ($str, "s");
}
$tiny_lpo_key = get_query_keyword ();
if ($tiny_lpo_key !== "") {
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
    '<?php echo urlencode ($tiny_lpo_key); ?>';
}

1;