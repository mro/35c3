<?xml version="1.0" encoding="UTF-8"?>
<!--

 @@LICENSE

 http://www.w3.org/TR/xslt/
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl"
  version="1.0">

  <xsl:output
    method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="/schedule">
    <xsl:variable name="event_base_url">
      <xsl:choose>
        <xsl:when test="'31c3' = conference/acronym">https://events.ccc.de/congress/2014</xsl:when>
        <xsl:when test="'32c3' = conference/acronym">https://events.ccc.de/congress/2015</xsl:when>
        <xsl:when test="'33c3' = conference/acronym">https://events.ccc.de/congress/2016</xsl:when>
        <xsl:when test="'34c3' = conference/acronym">..</xsl:when>
        <xsl:otherwise>foo</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <html xmlns="http://www.w3.org/1999/xhtml" manifest="index.manifest">
      <head>
        <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
        <!-- https://developer.apple.com/library/IOS/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html#//apple_ref/doc/uid/TP40006509-SW26 -->
        <!-- http://maddesigns.de/meta-viewport-1817.html -->
        <!-- meta name="viewport" content="width=device-width"/ -->
        <!-- http://www.quirksmode.org/blog/archives/2013/10/initialscale1_m.html -->
        <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
        <!-- meta name="viewport" content="width=400"/ -->
			<!--		
        <link href="../assets/Chaosknoten.svg" rel="shortcut icon" type="image/svg"/>
        <link href="../assets/Chaosknoten.svg" rel="apple-touch-icon" type="image/svg"/>
      -->
				<link rel="apple-touch-icon" href="../assets/tuwat-250x250.png"/>
				<link rel="apple-touch-startup-image" href="../assets/tuwat-250x250.png"/>
        <link href="../assets/style.css" rel="stylesheet" type="text/css"/>
        <title><xsl:value-of select="conference/acronym"/></title>
        <style type="text/css">
/*&lt;![CDATA[*/<![CDATA[
@media screen and (max-width: 376px) {
  /* http://maddesigns.de/meta-viewport-1817.html */
  html {
    font-size: 100%;
  }
}
@media screen and (max-width: 321px) {
  /* http://maddesigns.de/meta-viewport-1817.html */
  html {
    font-size: 90%;
  }
}
  ]]>/*]]&gt;*/
        </style>
<script type="text/javascript">
//&lt;![CDATA[*/<![CDATA[
function makeICalUri(elem,uid,locatio,dtstart,duration,summary,abstrac,persons,url) {
//   var speaker = "";
//   if(false) {
//     for(i = 0; i < persons.length; i++) {
//       if( 0 < speaker.length )
//         speaker += ", ";
//       speaker += persons.item(i).textContent;
//     }
//     if( 0 < speaker.length )
//       speaker += ": ";
//   }
  // http://stackoverflow.com/questions/15439922/datauri-for-ical-does-not-work-on-android-or-iphone
  var icalstr = "BEGIN:VCALENDAR\r\n\
VERSION:2.0\r\n\
PRODID:-//purl.mro.name/32c3//NONSGML v1.0//EN\r\n\
BEGIN:VEVENT\r\n\
SUMMARY:" + summary + "\r\n\
LOCATION:" + locatio + "\r\n\
DTSTART:" + /* @todo: not timezone safe! */ dtstart.replace(/[-:]/g,'').substring(0, 4+2+2+1+2+2+2) + "\r\n\
DURATION:" + "PT" + duration.substring(0,2) + "H" + duration.substring(3,5) + "M" + "\r\n\
URL;VALUE=URI:" + url + "\r\n\
UID:" + uid + "\r\n\
DESCRIPTION:" + abstrac + "\r\n\
UID:" + uid + "\r\n";
  // UID duplicate to frame shaky DESCRIPTION linefeed encoding.
  for(i = 0; i < persons.length; i++)
    icalstr += "ATTENDEE;PARTSTAT=ACCEPTED;ROLE=CHAIR;CN=\"" + persons.item(i).textContent + "\":invalid:nomail" + "\r\n";
icalstr += "END:VEVENT\r\n\
END:VCALENDAR\r\n";
// DTEND:" + "20160101T010100" + "\r\n\
// DESCRIPTION:description\r\n\
  elem.download = uid + '.ics';
  elem.href = "data:text/calendar," + encodeURIComponent(icalstr);
}

var baseUrl = (document.location + '').replace(/#.*$/,'');

]]>//]]&gt;
</script>
      </head>
      <body>
        <p><a href="..">..</a></p>
        <div id="schedule">
        <h1><xsl:value-of select="conference/acronym"/></h1>
        <p><xsl:value-of select="version"/></p>
        <ul class="days">
          <xsl:for-each select="day">
            <li><a href="#day_{@index}">Dec <xsl:value-of select="substring(@date,9,2)"/><sup>th</sup> (Day <xsl:value-of select="@index"/>)</a></li>
          </xsl:for-each>
        </ul>
        <xsl:for-each select="day">
          <h2 id="day_{@index}">Dec <xsl:value-of select="substring(@date,9,2)"/><sup>th</sup> (Day <xsl:value-of select="@index"/>)</h2>
            <xsl:for-each select="room">
              <h3><xsl:value-of select="@name"/></h3>
              <ul class="event_list">
              <xsl:for-each select="event">
                <xsl:sort select="date"/>
                <xsl:variable name="ev_id" select="concat('event_', @id)"/>
                <li>
                  <div style="display:none">
                    <span id="{$ev_id}_location"><xsl:value-of select="../@name"/></span>
                    <span id="{$ev_id}_dtstart"><xsl:value-of select="date"/></span>
                    <span id="{$ev_id}_duration"><xsl:value-of select="duration"/></span>
                    <span id="{$ev_id}_abstract"><xsl:value-of select="abstract"/></span>
                    <span id="{$ev_id}_description"><xsl:value-of select="description"/></span>
                    <div id="{$ev_id}_attendee">
                      <xsl:for-each select="persons/person">
                        <span><xsl:value-of select="."/></span>
                      </xsl:for-each>
                    </div>
                  </div>
                  <a title="iCal URL" class="ical" id="{$ev_id}_ical" href="">📅</a><xsl:text> </xsl:text>
                  <a title="{date}" class="dtstart" id="{$ev_id}" href="#{$ev_id}"><xsl:value-of select="substring(date,12,5)"/></a><xsl:text> </xsl:text>
                  <a title="Video URL" class="video" href="https://media.ccc.de/v/{slug}#video">📹</a><xsl:text> </xsl:text>
                  <a class="text" id="{$ev_id}_title" href="{$event_base_url}/Fahrplan/events/{@id}.html"><xsl:value-of select="title"/></a>
<script type="text/javascript">
  var ev_id = '<xsl:value-of select="$ev_id"/>';
  // console.log(ev_id + ' ' + document.getElementById(ev_id + '_dtstart').textContent);
  makeICalUri(
    document.getElementById(ev_id + '_ical'),
    ev_id,
    document.getElementById(ev_id + '_location').textContent,
    document.getElementById(ev_id + '_dtstart').textContent,
    document.getElementById(ev_id + '_duration').textContent,
    document.getElementById(ev_id + '_title').textContent,
    document.getElementById(ev_id + '_abstract').textContent,
    document.getElementById(ev_id + '_attendee').children,
    baseUrl + '#' + ev_id
  );
</script>
                </li>
              </xsl:for-each>
              </ul>
            </xsl:for-each>
        </xsl:for-each>
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
