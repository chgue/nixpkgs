{ stdenv, fetchFromGitHub, which
, withPython ? true, python
, withPHP71 ? false, php71
, withPHP72 ? true, php72
, withPHP73 ? false, php73
, withPerl ? true, perl
, withPerldevel ? false, perldevel
, withRuby_2_3 ? false, ruby_2_3
, withRuby_2_4 ? false, ruby_2_4
, withRuby ? true, ruby
, withSSL ? true, openssl ? null
, withIPv6 ? true
, withDebug ? false
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "1.8.0";
  name = "unit-${version}";

  src = fetchFromGitHub {
    owner = "nginx";
    repo = "unit";
    rev = "${version}";
    sha256 = "1s5pfyhabnf9p5z2h1fh0wb4hqzkrha5bxahjnikmlkhw59s8zip";
  };

  nativeBuildInputs = [ which ];

  buildInputs = [ ]
    ++ optional withPython python
    ++ optional withPHP71 php71
    ++ optional withPHP72 php72
    ++ optional withPHP73 php73
    ++ optional withPerl perl
    ++ optional withPerldevel perldevel
    ++ optional withRuby_2_3 ruby_2_3
    ++ optional withRuby_2_4 ruby_2_4
    ++ optional withRuby ruby
    ++ optional withSSL openssl;

  # Used patch to enable work with unprivileged user - https://github.com/nginx/unit/issues/228
  patches = [ ./unit-rootless.patch ];

  configureFlags = [
    "--control=unix:/run/unit/control.unit.sock"
    "--pid=/run/unit/unit.pid"
    "--user=unit"
    "--group=unit"
  ] ++ optional withSSL     [ "--openssl" ]
    ++ optional (!withIPv6) [ "--no-ipv6" ]
    ++ optional withDebug   [ "--debug" ];

  postConfigure = ''
    ${optionalString withPython     "./configure python  --module=python    --config=${python}/bin/python-config  --lib-path=${python}/lib"}
    ${optionalString withPHP71      "./configure php     --module=php71     --config=${php71.dev}/bin/php-config  --lib-path=${php71}/lib"}
    ${optionalString withPHP72      "./configure php     --module=php72     --config=${php72.dev}/bin/php-config  --lib-path=${php72}/lib"}
    ${optionalString withPHP73      "./configure php     --module=php73     --config=${php73.dev}/bin/php-config  --lib-path=${php73}/lib"}
    ${optionalString withPerl       "./configure perl    --module=perl      --perl=${perl}/bin/perl"}
    ${optionalString withPerldevel  "./configure perl    --module=perl529   --perl=${perldevel}/bin/perl"}
    ${optionalString withRuby_2_3   "./configure ruby    --module=ruby23    --ruby=${ruby_2_3}/bin/ruby"}
    ${optionalString withRuby_2_4   "./configure ruby    --module=ruby24    --ruby=${ruby_2_4}/bin/ruby"}
    ${optionalString withRuby       "./configure ruby    --module=ruby      --ruby=${ruby}/bin/ruby"}
  '';

  meta = {
    description = "Dynamic web and application server, designed to run applications in multiple languages.";
    homepage    = https://unit.nginx.org/;
    license     = licenses.asl20;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ izorkin ];
  };
}
