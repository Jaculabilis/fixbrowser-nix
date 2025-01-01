{
  stdenv,
  fetchzip,
  gtk2,
  cairo,
  pango,
  makeWrapper,
  lib,
  symlinkJoin,
  writeShellScriptBin,
}:
let
  libs = [
    cairo
    pango.out
    gtk2
  ];
  src = fetchzip {
    url = "http://www.fixbrowser.org/download/fixbrowser-0.1.zip";
    hash = "sha256-XghMqHtzCkmDtTHv2E5iqdeAZAL6xreEvDagBkeo6uY=";
  };
  unwrapped = stdenv.mkDerivation {
    pname = "fixbrowser";
    version = "0.1.0";
    inherit src;

    nativeBuildInputs = [ makeWrapper ];

    buildPhase = ''
      ./compile.sh
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp fixbrowser $out/bin/
      cp fixproxy $out/bin/
    '';

    postFixup = ''
      patchelf $out/bin/fixbrowser --add-rpath ${lib.makeLibraryPath libs}
    '';
  };
  # fixbrowser assumes cwd is the source dist when looking for certs
  fixbrowser = writeShellScriptBin "fixbrowser" ''
    cd ${src}
    exec ${unwrapped}/bin/fixbrowser
  '';
  fixproxy = writeShellScriptBin "fixproxy" ''
    cd ${src}
    exec ${unwrapped}/bin/fixproxy
  '';
in
symlinkJoin {
  name = "fixbrowser";
  paths = [
    fixbrowser
    fixproxy
  ];
  passthru = {
    inherit unwrapped;
  };
}
