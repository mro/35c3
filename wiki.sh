#!/bin/sh
cd "$(dirname "${0}")"
#
# See
# - https://events.ccc.de/congress/2017/wiki/Static:Crawling
# - https://github.com/mro/34c3/
#

USER_AGENT="https://mro.github.io/34c3"

dir=wiki

rm -rf "${dir}"

for page in Static:Main_Page Static:Crawling Static:Assemblies Static:Lightning_Talks Static:Projects "Static:Self-organized_Sessions" Static:Design Lightning:Datenreichtum_beim_Denkmalamt:_Aus_PDF_wird_RDF Session:We_Fix_the_Net
do
  url="https://events.ccc.de/congress/2017/${dir}/${page}"
  dst="${dir}/${page}/index.html"
  curl --create-dirs --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    echo postproc
  }
done

for css in "mediawiki.legacy.commonPrint%2Cshared%7Cmediawiki.skinning.interface%7Cmediawiki.ui.button%7Cskins.vector.styles"
do
  url="https://events.ccc.de/congress/2017/wiki/load.php?debug=false&amp;lang=en&amp;modules=${css}*&amp;only=styles&amp;skin=vector&amp;*"
  dst="${dir}/${css}.css"
  curl --create-dirs --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    echo postproc
  }
  sed -i -e "s|https://events.ccc.de/|/|g" "${dir}"/*/*.html
  sed -i -e "s|/congress/2017/${dir}/|../|g" "${dir}"/*/*.html

  sed -i -e "s|${url}|../${css}.css|g" "${dir}"/*/*.html
done

sed -i -e 's|This page has been accessed [0-9,]* times\.|This page has been accessed foo times.|g' "${dir}"/*/*.html
sed -i -e 's|mw\.config\.set.."wgBackendResponseTime":[0-9]*..;|mw.config.set({"wgBackendResponseTime":-123});|g' "${dir}"/*/*.html
sed -i -e 's|Real time usage: [0-9.]* seconds|Real time usage: foo seconds|g' "${dir}"/*/*.html
sed -i -e 's|CPU time usage: [0-9.]* seconds|CPU time usage: bar seconds|g' "${dir}"/*/*.html
sed -i -e 's|and timestamp [0-9]* and revision id [0-9]*|and timestamp foo and revision bar|g' "${dir}"/*/*.html
sed -i -e 's|Preprocessor visited node count: [0-9]+/[0-9]+|Preprocessor visited node count: foo/bar|g' "${dir}"/*/*.html
sed -i -e 's|Preprocessor generated node count: [0-9]+/[0-9]+|Preprocessor generated node count: foo/bar|g' "${dir}"/*/*.html
sed -i -e 's|Post.+expand include size: [0-9]+/[0-9]+ bytes|Post-expand include size: foo/bar bytes|g' "${dir}"/*/*.html
sed -i -e 's|Template argument size: [0-9]+/[0-9]+ bytes|Template argument size: foo/bar bytes|g' "${dir}"/*/*.html
sed -i -e 's|Highest expansion depth: [0-9]+/[0-9]+|Highest expansion depth: foo/bar|g' "${dir}"/*/*.html
sed -i -e 's|Expensive parser function count: [0-9]+/[0-9]+|Expensive parser function count: foo/bar|g' "${dir}"/*/*.html

