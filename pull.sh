#!/bin/sh
cd "$(dirname "${0}")"
#
# See
# - https://events.ccc.de/congress/2017/wiki/Static:Crawling
# - https://github.com/mro/34c3/
#

USER_AGENT="https://mro.github.io/34c3"
dir=Fahrplan

# url="https://${dir}.events.ccc.de/congress/2015/${dir}/version"
url="https://${dir}.events.ccc.de/congress/2017/${dir}/version"
dst="${dir}.version"

curl --output "${dir}/schedule.xml" --location https://fahrplan.events.ccc.de/congress/2017/Fahrplan/schedule.xml
{
  echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
  fgrep -v "<?xml version=" "${dir}/schedule.xml"
} | xmllint --output "${dir}"/schedule2.xml --relaxng assets/schedule.rng --format --encode utf-8 -
sed -i -e "s|<url>https://fahrplan.events.ccc.de/congress/2017/Fahrplan/events/|<url>./events/|g" "${dir}"/schedule2.xml

for evt in $(fgrep '<url>' Fahrplan/schedule2.xml | cut -c 14-26)
do 
  dst_evt="./${dir}/${evt}.html"
  url_evt="https://fahrplan.events.ccc.de/congress/2017/${dst_evt}"
  curl --silent --create-dirs --remote-time --time-cond "${dst_evt}" --output "${dst_evt}" "${url_evt}"
done

curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
  url="$(fgrep "URL: " < "${dst}" | cut -d ' ' -f 2)"
  dst="${dir}.tar.gz"

  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    rm -rf "${dir}"
    tar -xzf "${dst}" && mv 34c3 "${dir}"
    sed -i -e "s:/congress/2017/${dir}/:./:g" "${dir}"/*.html
    sed -i -e "s:/congress/2017/${dir}/:../:g" "${dir}"/*/*.html

    {
      echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
      fgrep -v "<?xml version=" "${dir}/schedule.xml"
    } | xmllint --output "${dir}"/schedule2.xml --relaxng assets/schedule.rng --format --encode utf-8 -
    # xsltproc --output "${dir}"/schedule2.html~ assets/schedule2html.xslt "${dir}"/schedule.xml
    # xmllint --output "${dir}"/schedule2.html --format --encode utf-8 "${dir}"/schedule2.html~
    # rm "${dir}"/schedule2.html~

    # add a manifest for offline caching?
    touch "${dir}/index.manifest"
  }
}

for part in everything workshops
do
  dst="${dir}/${part}.schedule.xml"
  url="https://${dir}.events.ccc.de/congress/2017/${dst}"
  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    {
      echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
      fgrep -v "<?xml version=" "${dst}"
    } | xmllint --output "${dir}"/${part}.schedule2.xml --relaxng assets/schedule.sloppy.rng --format --encode utf-8 -
  }
done

# purge images and other binaries with few benefit but large footprint
find . \( -name "*.gif" -o -name "*.jpeg" -o -name "*.jpg" -o -name "*.JPG" -o -name "*.mp4" -o -name "*.odp" -o -name "*.pdf" -o -name "*.png" -o -name "*.PNG" \) -exec rm "{}" \;

git add . && git commit -a -m '🚀'


dir="wiki"

# url="https://events.ccc.de/congress/2015/${dir}/version"
url="https://events.ccc.de/congress/2017/${dir}/version"
dst="${dir}.version"

curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
  url="$(fgrep "URL: " < "${dst}" | cut -d ' ' -f 2)"
  dst="${dir}.tbz"

  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    rm -rf "${dir}"
    tar -xjf "${dst}"
  }
}

sh wiki.sh

git add . && git commit -a -m '🐳'

