#!/bin/sh
cd "$(dirname "${0}")"
#
# See
# - https://events.ccc.de/congress/${year}/wiki/Static:Crawling
# - https://github.com/mro/35c3/
#

USER_AGENT="https://mro.github.io/35c3"

dir=wiki
year=2018

rm -rf "${dir}"

for page in \
  Static:Main_Page \
  Static:Crawling \
  Static:Assemblies \
  Static:Lightning_Talks \
  Static:Projects \
  "Static:Self-organized_Sessions" \
  Static:Design
do
  url="https://events.ccc.de/congress/${year}/${dir}/${page}"
  dst="${dir}/${page}/index.html"
  curl --silent --create-dirs --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    echo "postproc ${url}"
  }
done

for css in \
  "mediawiki.legacy.commonPrint%2Cshared%7Cmediawiki.skinning.interface%7Cmediawiki.ui.button%7Cskins.vector.styles"
do
  url="https://events.ccc.de/congress/${year}/wiki/load.php?debug=false&amp;lang=en&amp;modules=${css}*&amp;only=styles&amp;skin=vector&amp;*"
  dst="${dir}/${css}.css"
  curl --silent --create-dirs --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    echo "postproc ${url}"
  }
  sed -i -e "s|https://events.ccc.de/|/|g" "${dir}"/*/*.html
  sed -i -e "s|/congress/${year}/${dir}/|../|g" "${dir}"/*/*.html

  sed -i -e "s|${url}|../${css}.css|g" "${dir}"/*/*.html
done

sed --in-place --regexp-extended \
  -e 's|/index\.php/|/|g' \
  -e 's|[^-]+ - -total|foo% bar - -total|g' \
  -e 's|[^-]+ - Template:|foo% bar - Template:|g' \
  -e 's|<script>.+window\.RLQ=window\.RLQ[^<]+|<script>/* script purged */|g' \
  -e 's|and timestamp [0-9]+ and revision id [0-9]*|and timestamp foo and revision bar|g' \
  -e 's|Cached time:\s+[0-9]+|Cached time: foo|g' \
  -e 's|CPU time usage: [0-9.]+ seconds|CPU time usage: bar seconds|g' \
  -e 's|Expensive parser function count: [0-9]+/[0-9]+|Expensive parser function count: foo/bar|g' \
  -e 's|Highest expansion depth: [0-9]+/[0-9]+|Highest expansion depth: foo/bar|g' \
  -e 's|mw\.config\.set.."wgBackendResponseTime":[0-9]*..;|mw.config.set({"wgBackendResponseTime":-123});|g' \
  -e 's|Post‐expand include size:\s+[0-9]+/[0-9]+ bytes|Post‐expand include size: foo/bar bytes|g' \
  -e 's|Post.+expand include size: [0-9]+/[0-9]+ bytes|Post-expand include size: foo/bar bytes|g' \
  -e 's|Preprocessor generated node count: [0-9]+/[0-9]+|Preprocessor generated node count: foo/bar|g' \
  -e 's|Preprocessor generated node count:\s+[0-9]+/[0-9]+|Preprocessor generated node count: foo/bar|g' \
  -e 's|Preprocessor visited node count: [0-9]+/[0-9]+|Preprocessor visited node count: foo/bar|g' \
  -e 's|Preprocessor visited node count:\s+[0-9]+/[0-9]+|Preprocessor visited node count: foo/bar|g' \
  -e 's|Real time usage: [0-9.]* seconds|Real time usage: foo seconds|g' \
  -e 's|Template argument size: [0-9]+/[0-9]+ bytes|Template argument size: foo/bar bytes|g' \
  -e 's|Template argument size:\s+[0-9]+/[0-9]+ bytes|Template argument size: foo/bar bytes|g' \
  -e 's|This page has been accessed [0-9,]* times\.|This page has been accessed foo times.|g' \
"${dir}"/*/*.html

