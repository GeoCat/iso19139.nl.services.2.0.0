<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:geonet="http://www.fao.org/geonetwork"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">
  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Waarschuwingen bij validatie tegen DCAT-AP NL 3</sch:title>

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


  <!-- Function to check that the metadata has a topic category that can be mapped to EuDcatApThemes -->
  <xsl:function name="geonet:hasEuDcatApThemes" as="xs:boolean">
    <xsl:param name="values"  as="node()*" />

    <xsl:variable name="isoTopicToEuDcatApThemes"
                  as="node()*">
      <entry key="http://publications.europa.eu/resource/authority/data-theme/AGRI">
        <inspire>http://inspire.ec.europa.eu/theme/af</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/af</inspire>
        <iso>farming</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/ECON">
        <inspire>http://inspire.ec.europa.eu/theme/cp</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/cp</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/lu</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/lu</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/mr</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/mr</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/pf</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/pf</inspire>
        <iso>economy</iso>
        <iso>planningCadastre</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/EDUC"></entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/ENER">
        <inspire>http://inspire.ec.europa.eu/theme/er</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/er</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/mr</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/mr</inspire>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/ENVI">
        <inspire>http://inspire.ec.europa.eu/theme/hy</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/hy</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/ps</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/ps</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/lc</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/lc</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/am</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/am</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/ac</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/ac</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/br</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/br</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/ef</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/ef</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/hb</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/hb</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/lu</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/lu</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/mr</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/mr</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/nz</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/nz</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/of</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/of</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/sr</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/sr</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/so</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/so</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/sd</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/sd</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/mf</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/mf</inspire>
        <iso>biota</iso>
        <iso>environment</iso>
        <iso>inlandWaters</iso>
        <iso>oceans</iso>
        <iso>climatologyMeteorologyAtmosphere</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/GOVE">
        <inspire>http://inspire.ec.europa.eu/theme/au</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/au</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/us</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/us</inspire>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/HEAL">
        <inspire>http://inspire.ec.europa.eu/theme/hh</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/hh</inspire>
        <iso>health</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/INTR"></entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/JUST"></entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/OP_DATPRO"></entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/REGI">
        <inspire>http://inspire.ec.europa.eu/theme/ad</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/ad</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/rs</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/rs</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/gg</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/gg</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/cp</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/cp</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/gn</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/gn</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/el</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/el</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/ge</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/ge</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/oi</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/oi</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/bu</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/bu</inspire>
        <iso>planningCadastre</iso>
        <iso>boundaries</iso>
        <iso>elevation</iso>
        <iso>imageryBaseMapsEarthCover</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/SOCI">
        <inspire>http://inspire.ec.europa.eu/theme/pd</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/pd</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/su</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/su</inspire>
        <iso>location</iso>
        <iso>society</iso>
        <iso>disaster</iso>
        <iso>intelligenceMilitary</iso>
        <iso>extraTerrestrial</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/TECH">
        <inspire>http://inspire.ec.europa.eu/theme/hy</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/hy</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/ge</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/ge</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/oi</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/oi</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/mf</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/mf</inspire>
        <iso>geoscientificInformation</iso>
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/TRAN">
        <inspire>http://inspire.ec.europa.eu/theme/tn</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/tn</inspire>
        <iso>structure</iso>
        <iso>transportation</iso>
        <iso>utilitiesCommunication</iso>
      </entry>
    </xsl:variable>

    <xsl:variable name="theme"
                  select="$isoTopicToEuDcatApThemes[
            */text() = $values//text()
            or */text() = $values//@xlink:href]/@key"/>

    <xsl:value-of select="count($theme) > 0" />
  </xsl:function>

  <sch:pattern>
    <sch:title>Waarschuwingen bij validatie tegen DCAT-AP NL 3 het DCAT-AP NL 3.0 metadata profiel</sch:title>

    <!-- Service identifier -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/*/gmd:identifier/gmd:MD_Identifier/gmd:code">
      <sch:let name="mdIdentifier" value="./(gco:CharacterString|gmx:Anchor)/text()"/>

      <sch:assert test="$mdIdentifier != ''">Unieke Identifier van de online bron aanbevolen</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification">
      <!-- Check thema with GEMET INSPIRE themes -->
      <sch:let name="nodes">
        <xsl:copy-of select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href ='http://inspire.ec.europa.eu/theme']/gmd:keyword" />
      </sch:let>

      <!-- Thema -->
      <sch:assert test="geonet:hasEuDcatApThemes($nodes)">Een INSPIRE-thema trefwoord wordt aanbevolen</sch:assert>

      <!-- Service identifier present -->
      <sch:assert test="gmd:citation/*/gmd:identifier/gmd:MD_Identifier/gmd:code">Unieke Identifier van de online bron aanbevolen</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>
