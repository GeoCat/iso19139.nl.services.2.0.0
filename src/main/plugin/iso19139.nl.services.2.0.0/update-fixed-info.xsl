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
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0" exclude-result-prefixes="#all">
  <xsl:import href="../iso19139/update-fixed-info.xsl"/>


  <!-- gml elements to use 3.2 -->
  <xsl:template match="@gml:id" priority="100">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="gml:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]" priority="100">
    <xsl:copy>
      <xsl:attribute name="gml:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gml:*" priority="100">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gml'"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Fix/add hierarchyLevel to service -->
  <xsl:template match="gmd:MD_Metadata" priority="100">
    <xsl:copy>
      <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
      <xsl:apply-templates select="@*"/>

      <gmd:fileIdentifier>
        <gco:CharacterString>
          <xsl:value-of select="/root/env/uuid"/>
        </gco:CharacterString>
      </gmd:fileIdentifier>

      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>

      <xsl:choose>
        <xsl:when test="/root/env/parentUuid!=''">
          <gmd:parentIdentifier>
            <gco:CharacterString>
              <xsl:value-of select="/root/env/parentUuid"/>
            </gco:CharacterString>
          </gmd:parentIdentifier>
        </xsl:when>
        <xsl:when test="gmd:parentIdentifier">
          <xsl:apply-templates select="gmd:parentIdentifier"/>
        </xsl:when>
      </xsl:choose>

      <xsl:if test="not(gmd:hierarchyLevel)">
        <gmd:hierarchyLevel>
          <gmd:MD_ScopeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode"
                            codeListValue="service">
            <xsl:value-of select="java:getCodelistTranslation('gmd:MD_ScopeCode', 'service', string($mainLanguage))"/>
          </gmd:MD_ScopeCode>
        </gmd:hierarchyLevel>
      </xsl:if>

      <xsl:apply-templates select="
        gmd:hierarchyLevel|
        gmd:hierarchyLevelName|
        gmd:contact|
        gmd:dateStamp|
        gmd:metadataStandardName|
        gmd:metadataStandardVersion|
        gmd:dataSetURI"/>

      <!-- Copy existing locales and create an extra one for the default metadata language. -->
      <xsl:if test="$isMultilingual">
        <xsl:apply-templates select="gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]"/>
        <gmd:locale>
          <gmd:PT_Locale id="{$mainLanguageId}">
            <gmd:languageCode>
              <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/"
                                codeListValue="{$mainLanguage}"/>
            </gmd:languageCode>
            <gmd:characterEncoding>
              <gmd:MD_CharacterSetCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_CharacterSetCode"
                                       codeListValue="{$defaultEncoding}"/>
            </gmd:characterEncoding>
          </gmd:PT_Locale>
        </gmd:locale>
      </xsl:if>

      <xsl:apply-templates select="
        gmd:spatialRepresentationInfo|
        gmd:referenceSystemInfo|
        gmd:metadataExtensionInfo|
        gmd:identificationInfo|
        gmd:contentInfo|
        gmd:distributionInfo|
        gmd:dataQualityInfo|
        gmd:portrayalCatalogueInfo|
        gmd:metadataConstraints|
        gmd:applicationSchemaInfo|
        gmd:metadataMaintenance|
        gmd:series|
        gmd:describes|
        gmd:propertyType|
        gmd:featureType|
        gmd:featureAttribute"/>

      <!-- Handle ISO profiles extensions. -->
      <xsl:apply-templates select="
        *[namespace-uri()!='http://www.isotc211.org/2005/gmd' and
          namespace-uri()!='http://www.isotc211.org/2005/srv']"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:hierarchyLevel|gmd:level"
                priority="200">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <gmd:MD_ScopeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode"
                        codeListValue="service">
        <xsl:value-of select="java:getCodelistTranslation('gmd:MD_ScopeCode', 'service', string($mainLanguage))"/>
      </gmd:MD_ScopeCode>
    </xsl:copy>
  </xsl:template>

  <!-- Add codelist labels -->
  <xsl:template match="gmd:LanguageCode[@codeListValue]" priority="220">
    <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>

      <xsl:value-of select="java:getIsoLanguageLabel(@codeListValue, $mainLanguage)" />
    </gmd:LanguageCode>
  </xsl:template>

  <xsl:template match="gmd:*[@codeListValue]"  priority="200">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of
          select="concat('https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>

      <xsl:if test="string(@codeListValue)">
        <xsl:value-of select="java:getCodelistTranslation(name(), string(@codeListValue), string($mainLanguage))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="srv:*[@codeListValue]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of
          select="concat('https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>

      <xsl:if test="string(@codeListValue)">
        <xsl:value-of select="java:getCodelistTranslation(name(), string(@codeListValue), string($mainLanguage))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

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

  <xsl:template
    match="srv:SV_ServiceIdentification|*[contains(@gco:isoType, 'SV_ServiceIdentification')]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:apply-templates select="gmd:citation" />
      <xsl:apply-templates select="gmd:abstract" />
      <xsl:apply-templates select="gmd:purpose" />
      <xsl:apply-templates select="gmd:credit" />
      <xsl:apply-templates select="gmd:status" />
      <xsl:apply-templates select="gmd:pointOfContact" />
      <xsl:apply-templates select="gmd:resourceMaintenance" />
      <xsl:apply-templates select="gmd:graphicOverview" />
      <xsl:apply-templates select="gmd:resourceFormat" />
      <xsl:apply-templates select="gmd:descriptiveKeywords" />
      <xsl:apply-templates select="gmd:resourceSpecificUsage" />

      <!-- Order resource constraints. Related schematron validations depends on the order of the constraints
          - gmd:MD_Constraints
          - gmd:MD_LegalConstraints
          - gmd:MD_SecurityConstraints
      -->
      <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_Constraints]" />
      <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_LegalConstraints]" />
      <xsl:apply-templates select="gmd:resourceConstraints[gmd:MD_SecurityConstraints]" />

      <xsl:apply-templates select="gmd:aggregationInfo" />

      <xsl:apply-templates select="srv:serviceType"/>
      <xsl:apply-templates select="srv:serviceTypeVersion"/>
      <xsl:apply-templates select="srv:accessProperties"/>
      <xsl:apply-templates select="srv:restrictions"/>
      <xsl:apply-templates select="srv:keywords"/>
      <xsl:apply-templates select="srv:extent"/>
      <xsl:apply-templates select="srv:coupledResource"/>
      <xsl:apply-templates select="srv:couplingType"/>

      <!-- Copy url from 1st online resource pointing a service as srv:connectPoint elements -->
      <xsl:choose>
        <xsl:when test="count(//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WMS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WMTS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WFS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WCS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WPS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:SOS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'TMS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:CSW' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OAS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API features' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API tiles' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API styles' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API coverages' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API 3dgeovolumes' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API maps' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:OLS' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:SensorThings' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'W3C:SPARQL' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OASIS:OData' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'landingpage' or
          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'INSPIRE Atom']) > 0">

          <xsl:choose>
            <xsl:when test="srv:containsOperations">

              <!-- Replace connectPoints in all srv:containsOperations -->
              <xsl:for-each select="srv:containsOperations">
                  <xsl:copy>
                    <xsl:copy-of select="@*" />

                    <xsl:for-each select="srv:SV_OperationMetadata">
                      <xsl:copy>
                        <xsl:copy-of select="@*" />

                        <xsl:apply-templates select="srv:operationName" />
                        <xsl:apply-templates select="srv:DCP" />
                        <xsl:apply-templates select="srv:operationDescription" />
                        <xsl:apply-templates select="srv:invocationName" />
                        <xsl:apply-templates select="srv:parameters" />

                        <xsl:variable name="onlineResourceToProcess" select="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WMS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WMTS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WFS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WCS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WPS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:SOS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'TMS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:CSW' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OAS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API features' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API tiles' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API styles' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API coverages' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API 3dgeovolumes' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API maps' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:OLS' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:SensorThings' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'W3C:SPARQL' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OASIS:OData' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'landingpage' or
                          gmd:CI_OnlineResource/gmd:protocol/*/text() = 'INSPIRE Atom'][1]" />

                        <srv:connectPoint>
                          <gmd:CI_OnlineResource>
                            <gmd:linkage>
                              <gmd:URL><xsl:value-of select="$onlineResourceToProcess/gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></gmd:URL>
                            </gmd:linkage>
                          </gmd:CI_OnlineResource>
                        </srv:connectPoint>

                        <xsl:apply-templates select="srv:dependsOn" />
                      </xsl:copy>
                    </xsl:for-each>

                  </xsl:copy>
              </xsl:for-each>

            </xsl:when>

            <xsl:otherwise>
              <srv:containsOperations>
                <srv:SV_OperationMetadata>
                  <srv:operationName>
                    <gco:CharacterString>GetCapabilities</gco:CharacterString>
                  </srv:operationName>

                  <srv:DCP>
                    <srv:DCPList codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#DCPList"
                                 codeListValue="WebServices">WebServices</srv:DCPList>
                  </srv:DCP>

                  <xsl:variable name="onlineResourceToProcess" select="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WMS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WMTS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WFS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WCS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:WPS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:SOS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'TMS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:CSW' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OAS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:API features' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:OLS' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OGC:SensorThings' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'W3C:SPARQL' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'OASIS:OData' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'landingpage' or
                        gmd:CI_OnlineResource/gmd:protocol/*/text() = 'INSPIRE Atom'][1]" />

                  <srv:connectPoint>
                    <gmd:CI_OnlineResource>
                      <gmd:linkage>
                        <gmd:URL><xsl:value-of select="$onlineResourceToProcess/gmd:CI_OnlineResource/gmd:linkage/gmd:URL" /></gmd:URL>
                      </gmd:linkage>
                    </gmd:CI_OnlineResource>
                  </srv:connectPoint>

                </srv:SV_OperationMetadata>
              </srv:containsOperations>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:when>

        <xsl:otherwise>
          <!-- Add empty connectPoint in all srv:containsOperations -->
          <xsl:for-each select="srv:containsOperations">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <xsl:for-each select="srv:SV_OperationMetadata">
                <xsl:copy>
                  <xsl:apply-templates select="srv:operationName" />
                  <xsl:apply-templates select="srv:DCP" />
                  <xsl:apply-templates select="srv:operationDescription" />
                  <xsl:apply-templates select="srv:invocationName" />
                  <xsl:apply-templates select="srv:parameters" />

                  <srv:connectPoint />

                  <xsl:apply-templates select="srv:dependsOn" />
                </xsl:copy>
              </xsl:for-each>
            </xsl:copy>
          </xsl:for-each>

        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="srv:operatesOn"/>
    </xsl:copy>
  </xsl:template>

  <!-- Online resources description: accessPoint, endPoint -->
  <xsl:template match="gmd:onLine/gmd:CI_OnlineResource" priority="200">

    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:variable name="protocol" select="gmd:protocol/*/text()" />
      <xsl:variable name="applicationProfile" select="gmd:applicationProfile/*/text()" />
      <xsl:variable name="separator" select="'\|'"/>

      <xsl:choose>
        <!-- Add request=GetCapabilities if missing -->
        <xsl:when test="geonet:contains-any-of($protocol, ('OGC:WMS', 'OGC:WMTS', 'OGC:WFS', 'OGC:WCS', 'OGC:CSW', 'OGC:WPS', 'OGC:SOS'))">
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

      <!-- gmd:applicationProfile -->
      <xsl:choose>
        <xsl:when test="geonet:contains-any-of($applicationProfile, ('discovery','view','download','transformation','invoke','other'))">
          <gmd:applicationProfile>
              <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType/{$applicationProfile}">
              <xsl:value-of select="$applicationProfile" /></gmx:Anchor>
          </gmd:applicationProfile>
        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="gmd:applicationProfile" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gmd:name" />

      <!-- gmd:description -->
      <xsl:choose>
        <xsl:when test="gmd:description/*/text() = 'accessPoint'">
          <gmd:description>
            <gmx:Anchor
              xlink:href="http://inspire.ec.europa.eu/metadata-codelist/OnLineDescriptionCode/accessPoint">
              accessPoint</gmx:Anchor>
          </gmd:description>
        </xsl:when>

        <xsl:when test="gmd:description/*/text() = 'endPoint'">
          <gmd:description>
            <gmx:Anchor
              xlink:href="http://inspire.ec.europa.eu/metadata-codelist/OnLineDescriptionCode/endPoint">
              endPoint</gmx:Anchor>
          </gmd:description>
        </xsl:when>

        <!-- Empty: check the protocol -->
        <xsl:when test="not(string(gmd:description/*/text()))">
          <xsl:choose>
            <!-- Access points -->
            <xsl:when test="geonet:contains-any-of($protocol, ('OGC:WMS', 'OGC:WMTS', 'OGC:WFS', 'OGC:WCS', 'INSPIRE Atom',
          'landingpage', 'application', 'dataset', 'OGC:WPS', 'OGC:SOS', 'TMS',
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
