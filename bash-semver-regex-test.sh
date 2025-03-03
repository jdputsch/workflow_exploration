#!/usr/bin/env bash

valid_strings=( \
    '0.0.0' \
    '0.10.0' \
    'v1.0.0' \
    '0.0.0-foo' \
    '0.0.0-foo-bar-baz' \
    '1.2.3-4' \
    '2.7.2+asdf' \
    '1.2.3-a.b.c.10.d.5' \
    '2.7.2-foo+bar' \
    '1.2.3-alpha.10.beta' \
    '1.2.3-alpha.10.beta+build.unicorn.rainbow' \
    '99999.99999.99999' \
    '0.0.4' \
    '1.2.3' \
    '10.20.30' \
    '1.1.2-prerelease+meta' \
    '1.1.2+meta' \
    '1.1.2+meta-valid' \
    '1.0.0-alpha' \
    '1.0.0-beta' \
    '1.0.0-alpha.beta' \
    '1.0.0-alpha.beta.1' \
    '1.0.0-alpha.1' \
    '1.0.0-alpha0.valid' \
    '1.0.0-alpha.va1id' \
    '1.0.0-alpha.0valid' \
    '1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay' \
    '1.0.0-rc.1+build.1' \
    '2.0.0-rc.1+build.123' \
    '1.2.3-beta' \
    '10.2.3-DEV-SNAPSHOT' \
    '1.2.3-SNAPSHOT-123' \
    '1.0.0' \
    '2.0.0' \
    '1.1.7' \
    '2.0.0+build.1848' \
    '2.0.1-alpha.1227' \
    '1.0.0-alpha+beta' \
    '1.2.3----RC-SNAPSHOT.12.9.1--.12+788' \
    '1.2.3----R-S.12.9.1--.12+meta' \
    '1.2.3----RC-SNAPSHOT.12.9.1--.12' \
    '1.0.0+0.build.1-rc.10000aaa-kk-0.1' \
    '1.0.0-0A.is.legal' \
)

invalid_strings=( \
    '1' \
    '1.2' \
    '1.2.3-0123' \
    '1.2.3-0123.0123' \
    '1.1.2+.123' \
    '+invalid' \
    '-invalid' \
    '-invalid+invalid' \
    '-invalid.01' \
    'alpha' \
    'alpha.beta' \
    'alpha.beta.1' \
    'alpha.1' \
    'alpha+beta' \
    'alpha_beta' \
    'alpha.' \
    'alpha..' \
    'beta' \
    '1.0.0-alpha_beta' \
    '-alpha.' \
    '1.0.0-alpha..' \
    '1.0.0-alpha..1' \
    '1.0.0-alpha...1' \
    '1.0.0-alpha....1' \
    '1.0.0-alpha.....1' \
    '1.0.0-alpha......1' \
    '1.0.0-alpha.......1' \
    '01.1.1' \
    '1.01.1' \
    '1.1.01' \
    '1.2' \
    '1.2.3.DEV' \
    '1.2-SNAPSHOT' \
    '1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788' \
    '1.2-RC-SNAPSHOT' \
    '-1.0.3-gamma+b7718' \
    '+justmeta' \
    '9.8.7+meta+meta' \
    '9.8.7-whatever+meta+meta' \
    '99999999999999999999999.999999999999999999.99999999999999999----RC-SNAPSHOT.12.09.1--------------------------------..12' \
    '1.0.0-beta@beta' \
)

# some semver regexes for inspiration
#
# from Node's semver-regex package (https://www.npmjs.com/package/semver-regex)
# /(?<=^v?|\sv?)(?:(?:0|[1-9]\d{0,9}?)\.){2}(?:0|[1-9]\d{0,9})(?:-(?:--+)?(?:0|[1-9]\d*|\d*[a-z]+\d*)){0,100}(?=$| |\+|\.)(?:(?<=-\S+)(?:\.(?:--?|[\da-z-]*[a-z-]\d*|0|[1-9]\d*)){1,100}?)?(?!\.)(?:\+(?:[\da-z]\.?-?){1,100}?(?!\w))?(?!\+)/gi;
#
# from regex101.com: https://regex101.com/library/t8Aawu
# /(?<Semantic>(?<Major>[0-9]+)\.(?<Minor>[0-9]+)(?:\.(?=[0-9]))?(?<Maintenance>[0-9]+)?(?:\.(?=[0-9]))?(?<Patch>[0-9]+)?)(?<Label>(?:(?:\.|\-|\+)?\w+)+)?/gm
#
# Bash script (https://gist.github.com/rverst/1f0b97da3cbeb7d93f4986df6e8e5695)
# ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$

semver_regex="^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$"

function chsv_check_version() {
  if [[ $1 =~ $semver_regex ]]; then
    echo "$1"
  else
    echo ""
  fi
}

function chsv_check_version_ex() {
  if [[ $1 =~ ^v.+$ ]]; then
    chsv_check_version "${1:1}"
  else
    chsv_check_version "${1}"
  fi
}

for i in "${valid_strings[@]}"; do
    if [[ $(chsv_check_version "$i") == "" ]]; then
        echo "ERROR: $i"
    fi
done

for i in "${invalid_strings[@]}"; do
    if [[ $(chsv_check_version_ex "$i") -ne "" ]]; then
        echo "ERROR: $i"
    fi
done