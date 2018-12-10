#!/bin/sh
cd "$(dirname "${0}")"
#
# See
# - https://events.ccc.de/congress/2018/wiki/Static:Crawling
# - https://code.mro.name/mro/35c3/
#

USER_AGENT="https://mro.github.io/35c3"
dir=Fahrplan
year=2018

# url="https://${dir}.events.ccc.de/congress/2015/${dir}/version"
url="https://${dir}.events.ccc.de/congress/${year}/${dir}/version"
dst="${dir}.version"

{
  curl --output "${dir}/schedule.xml" --location "https://fahrplan.events.ccc.de/congress/${year}/${dir}/schedule.xml"
  {
    echo '<?xml-stylesheet type="text/xsl" href="../assets/schedule2html.xslt"?>'
    fgrep -v "<?xml version=" "${dir}/schedule.xml"
  } | xmllint --output "${dir}"/schedule2.xml --relaxng assets/schedule.rng --format --encode utf-8 -
  sed -i -e "s|<url>https://fahrplan.events.ccc.de/congress/${year}/Fahrplan/events/|<url>./events/|g" "${dir}"/schedule2.xml
}

for evt in $(fgrep '<url>' Fahrplan/schedule2.xml | cut -c 16-26 | sort)
do 
  dst_evt="${dir}/${evt}.html"
  url_evt="https://fahrplan.events.ccc.de/congress/${year}/${dst_evt}"
	echo "${url_evt}"
  curl --silent --max-time 3 --create-dirs --location --remote-time --time-cond "${dst_evt}" --output "${dst_evt}" "${url_evt}"
done

{	
  curl --output "${dir}/schedule.json" --location "https://fahrplan.events.ccc.de/congress/${year}/${dir}/schedule.json"
  ruby -ryaml -e "puts YAML::dump(YAML::load(STDIN.read))" < "${dir}/schedule.json" > "${dir}/schedule.yaml"
}

curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
  url="$(fgrep "URL: " < "${dst}" | cut -d ' ' -f 2)"
  dst="${dir}.tar.gz"

  curl --silent --location --remote-time --output "${dst}" --time-cond "${dst}" --user-agent "${USER_AGENT}" "${url}" && {
    rm -rf "${dir}"
    tar -xzf "${dst}" && mv 35c3 "${dir}"
    sed -i -e "s:/congress/${year}/${dir}/:./:g" "${dir}"/*.html
    sed -i -e "s:/congress/${year}/${dir}/:../:g" "${dir}"/*/*.html

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
  url="https://${dir}.events.ccc.de/congress/${year}/${dst}"
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
url="https://events.ccc.de/congress/${year}/${dir}/version"
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

