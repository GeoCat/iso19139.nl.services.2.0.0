<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                version="2.0">
  <xsl:import href="../iso19139/update-fixed-info.xsl"/>


  <!-- Dutch profile uses gco:Date instead of gco:DateTime -->
  <xsl:template match="gmd:dateStamp" priority="99">
    <xsl:choose>
      <xsl:when test="/root/env/changeDate">
        <xsl:copy copy-namespaces="no">
          <gco:Date>
            <xsl:value-of select="tokenize(/root/env/changeDate,'T')[1]" />
          </gco:Date>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."  copy-namespaces="no"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="srv:operatesOn|gmd:featureCatalogueCitation" priority="99">
    <xsl:copy-of select="."  copy-namespaces="no"/>
  </xsl:template>


  <!-- Online resources description: accessPoint, endPoint -->
  <xsl:template match="gmd:onLine/gmd:CI_OnlineResource" priority="200">

    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:variable name="protocol" select="gmd:protocol/*/text()" />

      <xsl:choose>
        <!-- Add request=GetCapabilities if missing -->
        <xsl:when test="geonet:contains-any-of($protocol, ('OGC:WMS', 'OGC:WMTS', 'OGC:WFS', 'OGC:WCS'))">
          <xsl:variable name="url" select="gmd:linkage/gmd:URL" />
          <xsl:variable name="paramRequest" select="'request=GetCapabilities'" />

          <xsl:choose>
            <xsl:when test="not(contains(lower-case($url), lower-case($paramRequest)))">
              <xsl:choose>
                <xsl:when test="ends-with($url, '?')">
                  <gmd:linkage>
                    <gmd:URL><xsl:value-of select="concat($url, $paramRequest)" /></gmd:URL>
                  </gmd:linkage>
                </xsl:when>
                <xsl:when test="contains($url, '?')">
                  <gmd:linkage>
                    <gmd:URL><xsl:value-of select="concat($url, '&amp;', $paramRequest)" /></gmd:URL>
                  </gmd:linkage>
                </xsl:when>
                <xsl:otherwise>
                  <gmd:linkage>
                    <gmd:URL><xsl:value-of select="concat($url, '?', $paramRequest)" /></gmd:URL>
                  </gmd:linkage>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="gmd:linkage" />
            </xsl:otherwise>
          </xsl:choose>

        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:linkage" />
        </xsl:otherwise>
      </xsl:choose>


      <xsl:apply-templates select="gmd:protocol" />
      <xsl:apply-templates select="gmd:applicationProfile" />
      <xsl:apply-templates select="gmd:name" />

      <!-- gmd:description -->
      <xsl:choose>
        <!-- Access points -->
        <xsl:when test="geonet:contains-any-of($protocol, ('OGC:WMS', 'OGC:WMTS', 'OGC:WFS', 'OGC:WCS', 'INSPIRE Atom',
          'landingpage', 'application', 'dataset', 'OGC:WPS', 'OGC:SOS',
          'OGC:SensorThings', 'OAS', 'W3C:SPARQL', 'OASIS:OData', 'OGC:CSW',
          'OGC:WCTS', 'OGC:WFS-G', 'OGC:SPS', 'OGC:SAS', 'OGC:WNS', 'OGC:ODS', 'OGC:OGS', 'OGC:OUS', 'OGC:OPS', 'OGC:ORS', 'UKST'))">

          <gmd:description>
            <gmx:Anchor
              xlink:href="http://inspire.ec.europa.eu/metadata-codelist/OnLineDescriptionCode/accessPoint">
              accessPoint</gmx:Anchor>
          </gmd:description>
        </xsl:when>

        <!-- End points -->
        <xsl:when test="geonet:contains-any-of($protocol, ('gml', 'geojson', 'gpkg', 'tiff', 'kml', 'csv', 'zip',
          'wmc', 'json', 'jsonld', 'rdf-xml', 'xml', 'png', 'gif', 'jp2', 'mapbox-vector-tile', 'UKMT'))">
          <gmd:description>
            <gmx:Anchor
              xlink:href="http://inspire.ec.europa.eu/metadata-codelist/OnLineDescriptionCode/endPoint">
              endPoint</gmx:Anchor>
          </gmd:description>
        </xsl:when>

        <!-- Other cases: copy current gmd:description element -->
        <xsl:otherwise>
          <xsl:apply-templates select="gmd:description" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gmd:function" />
    </xsl:copy>
  </xsl:template>

  <!-- Search for any of the searchStrings provided -->
  <xsl:function name="geonet:contains-any-of" as="xs:boolean">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="searchStrings" as="xs:string*"/>

    <xsl:sequence
      select="
      some $searchString in $searchStrings
      satisfies contains($arg,$searchString)
      "
    />
  </xsl:function>

  <xsl:function name="geonet:ends-with-any-of" as="xs:boolean">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="searchStrings" as="xs:string*"/>

    <xsl:sequence
      select="
      some $searchString in $searchStrings
      satisfies ends-with($arg,$searchString)
      "
    />
  </xsl:function>


</xsl:stylesheet>
