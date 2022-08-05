{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, maven ? pkgs.maven, buildMaven ? pkgs.buildMaven, callPackage ? pkgs.buildMaven, makeWrapper ? pkgs.makeWrapper, jre ? pkgs.jre }:
let mvnRepo = (buildMaven ./project-info.json).repo;
in stdenv.mkDerivation rec {
  pname = "maven-test";
  version = "1.0";

  src = ./.;
  buildInputs = [ maven makeWrapper ];

  buildPhase = ''
    mvn --offline -Dmaven.repo.local=${mvnRepo} package;
  '';

  installPhase = ''
    mkdir -p $out/bin

    classpath = $(find ${mvnRepo} -name "*.jar" -printf ':%h/%f');
    install -Dm644 target/${pname}-${version}.jar $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-classpath $out/share/java/${pname}-${version}.jar:''${classpath#:}" \
      --add-flags "Main"
  '';
}
