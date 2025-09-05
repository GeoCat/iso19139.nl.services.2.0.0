<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">
  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">DCAT-AP NL 3 </sch:title>

  <sch:ns uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
  <sch:ns uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
  <sch:ns uri="http://www.isotc211.org/2005/gmx" prefix="gmx"/>
  <sch:ns uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
  <sch:ns uri="http://www.opengis.net/gml" prefix="gml"/>
  <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  <sch:ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
  <sch:ns uri="http://www.w3.org/2004/02/skos/core#" prefix="skos"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="xslutil" uri="java:org.fao.geonet.schema.iso19139nl.util.XslUtil" />

  <sch:let name="lowercase" value="'abcdefghijklmnopqrstuvwxyz'"/>
  <sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>


  <!-- Function to check that the license is a valid one for DCAT-AP NL -->
  <xsl:function name="geonet:isValidLicense" as="xs:boolean">
    <xsl:param name="resourceConstraints"  as="node()*" />

    <xsl:variable name="euLicenses"
                  select="document('../../iso19139.nl.geografie.2.0.0/formatter/dcat-ap-nl-3/vocabularies/licences-skos.rdf')"/>

    <xsl:variable name="licenses">
      <xsl:for-each select="$resourceConstraints/*/gmd:otherConstraints">

        <xsl:variable name="httpUriInAnchorOrText"
          select="(gmx:Anchor/@xlink:href[starts-with(., 'http')]
          |gco:CharacterString[starts-with(., 'http')])[1]"/>


        <xsl:if test="$httpUriInAnchorOrText != ''">
          <xsl:variable name="licenseUriWithoutHttp"
            select="replace($httpUriInAnchorOrText,'https?://','')"/>

          <xsl:variable name="euDcatLicense"
            select="$euLicenses/rdf:RDF/skos:Concept[
            matches(skos:exactMatch/@rdf:resource,
            concat('https?://', $licenseUriWithoutHttp, '/?'))
            or matches(@rdf:about,
            concat('https?://', $licenseUriWithoutHttp, '/?'))]"/>

          <xsl:if test="count($euDcatLicense) = 1">
            <xsl:if test="string($euDcatLicense/skos:prefLabel[@xml:lang = 'nl'])"><xsl:value-of select="$euDcatLicense/skos:prefLabel[@xml:lang = 'nl']" /></xsl:if>
          </xsl:if>
        </xsl:if>

      </xsl:for-each>

    </xsl:variable>

    <xsl:value-of select="normalize-space($licenses) != ''" />
  </xsl:function>

  <sch:pattern>
    <sch:title>Validatie tegen het DCAT-AP NL 3.0 metadata profiel</sch:title>

    <!-- Service title -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <sch:let name="mdTitle" value="gco:CharacterString"/>
      <sch:assert test="$mdTitle != ''">Titel van de service ontbreekt</sch:assert>
    </sch:rule>

    <!-- Service abstract -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:abstract">
      <sch:let name="mdAbstract" value="gco:CharacterString"/>
      <sch:assert test="$mdAbstract != ''">Omschrijving van de inhoud van de service ontbreekt</sch:assert>
    </sch:rule>

    <!-- Service contact -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:organisationName">
      <sch:let name="orgName" value="./(gco:CharacterString|gmx:Anchor)/text()"/>

      <sch:assert test="$orgName != ''">Naam van de verantwoordelijke organisatie van de service ontbreekt</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
      <sch:let name="email" value="gco:CharacterString"/>

      <sch:let name="isValidEmail" value="xslutil:isValidEmail($email)" />

      <sch:assert test="$isValidEmail = true()">E-mail van de verantwoordelijke organisatie van de service ontbreekt of is ongeldig</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage">
      <sch:let name="url" value="gmd:URL"/>

      <sch:let name="isValidUrl" value="($url = '') or starts-with(lower-case($url), 'http://') or starts-with(lower-case($url), 'https://')" />

      <sch:assert test="$isValidUrl = true()">Verantwoordelijke organisatie bron resource URL is ongeldig</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification">
      <!-- Service title present -->
      <sch:assert test="gmd:citation/*/gmd:title">Titel van de service ontbreekt</sch:assert>

      <!-- Service abstract present -->
      <sch:assert test="gmd:abstract">Omschrijving van de inhoud van de service ontbreekt</sch:assert>
      
      <!-- License -->
      <sch:assert test="geonet:isValidLicense(gmd:resourceConstraints)">Een geldige Creative Commons-licentie voor Overige beperkingen / (Juridische) toegangs restricties is vereist. Zie https://definities.geostandaarden.nl/dcat-ap-nl/nl/</sch:assert>

      <!-- Service contact present -->
      <sch:let name="hasContact" value="count(gmd:pointOfContact) > 0"/>
      <sch:assert test="$hasContact = true()">Informatie die nodig is om contact op te nemen met de verantwoordelijke persoon of organisatie ontbreekt</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
      <sch:let name="frequency" value="*/@codeListValue"/>

      <sch:assert test="$frequency != ''">Herzieningsfrequentie van de service ontbreekt</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata">
      <sch:assert test="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">De online bron moet ten minste één online resource bevatten met een geldige protocol waarde: OGC:WMS, OGC:WMTS, OGC:WFS, OGC:WCS, OGC:WPS, OGC:SOS, TMS, OGC:CSW, OAS, OGC:API features, OGC:API tiles, OGC:API styles, OGC:API 3dgeovolumes, OGC:API maps, OGC:OLS, OGC:SensorThings, W3C:SPARQL, OASIS:OData, landingpage, INSPIRE Atom</sch:assert>

    </sch:rule>
    <sch:rule context="//gmd:MD_Metadata/gmd:distributionInfo">
      <!-- Endpoint URL and description: check at least 1 online resource: in Dutch schemas are stored automatically in srv:connectPoint,
      used for these DCAT-AP NL elements. See update-fixed-info.xsl -->
      <sch:let name="validDistributions" value="*/gmd:transferOptions/*/gmd:onLine[
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
      gmd:CI_OnlineResource/gmd:protocol/*/text() = 'INSPIRE Atom']"/>

      <sch:assert test="count($validDistributions) > 0">De online bron moet ten minste één online resource bevatten met een geldige protocol waarde: OGC:WMS, OGC:WMTS, OGC:WFS, OGC:WCS, OGC:WPS, OGC:SOS, TMS, OGC:CSW, OAS, OGC:API features, OGC:API tiles, OGC:API styles, OGC:API 3dgeovolumes, OGC:API maps, OGC:OLS, OGC:SensorThings, W3C:SPARQL, OASIS:OData, landingpage, INSPIRE Atom</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>
