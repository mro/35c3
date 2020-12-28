#!/bin/sh
cd "$(dirname "${0}")" || exit 1
#
# See
# - https://events.ccc.de/${evt}/2018/wiki/Static:Crawling
# - https://code.mro.name/mro/35c3/
#

USER_AGENT="https://code.mro.name/mro/c3"
dir=Fahrplan
evt=congress
evt=rc3
year=2020

# url="https://${dir}.events.ccc.de/${evt}/2015/${dir}/version"
url="https://${dir}.events.ccc.de/${evt}/${year}/${dir}/version"
dst="${dir}.version"

{
  curl --output "${dir}/schedule.xml" --location "https://fahrplan.events.ccc.de/${evt}/${year}/${dir}/schedule.xml"
  {
    echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
    grep -vF "<?xml version=" "${dir}/schedule.xml"
  } | xmllint --output "${dir}"/schedule2.xml --relaxng assets/schedule.rng --format --encode utf-8 -
  sed -i -e "s|<url>https://fahrplan.events.ccc.de/${evt}/${year}/Fahrplan/events/|<url>./events/|g" "${dir}"/schedule2.xml
}

for evt in $(grep -F '<url>' Fahrplan/schedule2.xml | grep -hoE '[0-9]+' | sort -n)
do 
  dst_evt="${dir}/events/${evt}.html"
  url_evt="https://fahrplan.events.ccc.de/${evt}/${year}/${dst_evt}"
	echo "${url_evt}"
  curl --silent --max-time 3 --create-dirs --location --remote-time --time-cond "${dst_evt}" --output "${dst_evt}" "${url_evt}"
done

{	
  curl --output "${dir}/schedule.json" --location "https://fahrplan.events.ccc.de/${evt}/${year}/${dir}/schedule.json"
  ruby -ryaml -e "puts YAML::dump(YAML::load(STDIN.read))" < "${dir}/schedule.json" > "${dir}/schedule.yaml"
}

curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
  url="$(grep -F "URL: " < "${dst}" | cut -d ' ' -f 2)"
  dst="${dir}.tar.gz"

  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    rm -rf "${dir}"
    tar -xzf "${dst}" && mv 35c3 "${dir}"
    sed -i -e "s:/${evt}/${year}/${dir}/:./:g" "${dir}"/*.html
    sed -i -e "s:/${evt}/${year}/${dir}/:../:g" "${dir}"/*/*.html

    {
      echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
      grep -vF "<?xml version=" "${dir}/schedule.xml"
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
  url="https://${dir}.events.ccc.de/${evt}/${year}/${dst}"
  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    {
      echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
      grep -vF "<?xml version=" "${dst}"
    } | xmllint --output "${dir}"/${part}.schedule2.xml --relaxng assets/schedule.sloppy.rng --format --encode utf-8 -
  }
done

# purge images and other binaries with few benefit but large footprint
find . \( -name "*.gif" -o -name "*.jpeg" -o -name "*.jpg" -o -name "*.JPG" -o -name "*.mp4" -o -name "*.odp" -o -name "*.pdf" -o -name "*.png" -o -name "*.PNG" \) -exec rm "{}" \;

git add . && git commit -a -m '🚀'


dir="wiki"

# url="https://events.ccc.de/${evt}/2015/${dir}/version"
url="https://events.ccc.de/${evt}/${year}/${dir}/version"
dst="${dir}.version"

curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
  url="$(grep -F "URL: " < "${dst}" | cut -d ' ' -f 2)"
  dst="${dir}.tbz"

  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    rm -rf "${dir}"
    tar -xjf "${dst}"
  }
}

sh wiki.sh

git add . && git commit -a -m '🐳'

