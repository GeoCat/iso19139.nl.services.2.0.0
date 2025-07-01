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


  <!-- Function to check that the metadata has a topic category that can be mapped to EuDcatApThemes -->
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


  <!-- Function to check that the license is a valid one for DCAT-AP NL -->
  <xsl:function name="geonet:isValidLicense" as="xs:boolean">
    <xsl:param name="resourceConstraints"  as="node()*" />

    <!--<xsl:message><xsl:copy-of select="$resourceConstraints/*/gmd:useLimitation" /></xsl:message>-->

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

          <xsl:if test="string($euDcatLicense)"><xsl:value-of select="$euDcatLicense" /></xsl:if>
        </xsl:if>

      </xsl:for-each>

    </xsl:variable>

    <xsl:value-of select="normalize-space($licenses) != ''" />
  </xsl:function>


  <!-- Function to check that the rights are a valid one for DCAT-AP NL -->
  <xsl:function name="geonet:isValidRights" as="xs:boolean">
    <xsl:param name="resourceConstraints"  as="node()*" />

    <xsl:variable name="dcatApAccessTypes" as="node()*">
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">unrestricted</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">licenceUnrestricted</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">restricted</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">private</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/CONFIDENTIAL">confidential</entry>

      <!-- TODO: review with dct:rights -->
      <!--<entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1e</entry>-->

      <!-- Dutch specific -->
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">Geen beperkingen</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Naamsvermelding verplicht,</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/publicdomain/mark/1.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/publicdomain/zero/1.0/deed.nl</entry>

      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by/3.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by/4.0/deed.nl</entry>

      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED" match="start">Gelijk Delen, Naamsvermelding verplicht,</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-sa/3.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-sa/4.0/deed.nl</entry>

      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED" match="start">Niet Commercieel, Naamsvermelding verplicht </entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nc/3.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nc/4.0/deed.nl</entry>

      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED" match="start">Niet Commercieel, Gelijk Delen, Naamsvermelding verplicht,</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nc-sa/3.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nc-sa/4.0/deed.nl</entry>

      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED" match="start">Geen Afgeleide Werken, Naamsvermelding verplicht,</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nd/3.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nd/4.0/deed.nl</entry>

      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED" match="start">Niet Commercieel, Geen Afgeleide Werken, Naamsvermelding verplicht,</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nc-nd/3.0/deed.nl</entry>
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">http://creativecommons.org/licenses/by-nc-nd/4.0/deed.nl</entry>

      <!-- TODO: review other allowed values related to this license -->
      <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">Geo Gedeeld licentie</entry>
    </xsl:variable>


    <xsl:variable name="rightsStatements">

      <xsl:for-each select="distinct-values($resourceConstraints/*[gmd:accessConstraints]/gmd:otherConstraints/(gco:CharacterString|gmx:Anchor/@xlink:href))">
        <xsl:variable name="dcatAccessType"
                      select="$dcatApAccessTypes[(lower-case(.) = lower-case(current()) and not(@match)) or
                                                   (starts-with(lower-case(current()), lower-case(.)) and (@match = 'start'))] "/>

        <xsl:if test="$dcatAccessType">
          <right key="{$dcatAccessType/@key}" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="count($rightsStatements/right) > 0" />
  </xsl:function>

  <sch:pattern>
    <sch:title>Validatie tegen het DCAT-AP NL 3.0 metadata profiel</sch:title>

    <!-- Dataset title -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <sch:let name="mdTitle" value="gco:CharacterString"/>
      <sch:assert test="$mdTitle != ''">Titel van de online bron ontbreekt</sch:assert>
    </sch:rule>

    <!-- Dataset abstract -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:abstract">
      <sch:let name="mdAbstract" value="gco:CharacterString"/>
      <sch:assert test="$mdAbstract != ''">Omschrijving van de inhoud van de online bron ontbreekt</sch:assert>
    </sch:rule>

    <!-- Dataset language -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:language">
      <sch:let name="mdLanguage" value="(*/@codeListValue = 'dut' or */@codeListValue = 'eng')"/>

      <sch:assert test="$mdLanguage">De taal van de online bron moet Nederlands of Engels zijn</sch:assert>
    </sch:rule>

    <!-- Dataset identifier -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code">
      <sch:let name="mdIdentifier" value="./(gco:CharacterString|gmx:Anchor)/text()"/>

      <sch:assert test="$mdIdentifier != ''">Unieke Identifier van de online bron ontbreekt</sch:assert>
    </sch:rule>

    <!-- Dataset contact -->
    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:organisationName">
      <sch:let name="orgName" value="./(gco:CharacterString|gmx:Anchor)/text()"/>

      <sch:assert test="$orgName != ''">Naam van de verantwoordelijke organisatie van de online bron ontbreekt</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
      <sch:let name="email" value="gco:CharacterString"/>

      <sch:let name="isValidEmail" value="xslutil:isValidEmail($email)" />

      <sch:assert test="$isValidEmail = true()">E-mail van de verantwoordelijke organisatie van de online bron ontbreekt of is ongeldig</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage">
      <sch:let name="url" value="gmd:URL"/>

      <sch:let name="isValidUrl" value="($url = '') or starts-with(lower-case($url), 'http://') or starts-with(lower-case($url), 'https://')" />

      <sch:assert test="$isValidUrl = true()">Verantwoordelijke organisatie bron resource URL is ongeldig</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification">
      <!-- Check thema with GEMET INSPIRE themes -->
      <sch:let name="nodes">
        <xsl:copy-of select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href ='http://inspire.ec.europa.eu/theme']/gmd:keyword" />
      </sch:let>

      <!-- Thema -->
      <sch:report test="not(geonet:hasEuDcatApThemes($nodes))">Een INSPIRE-thema trefwoord wordt aanbevolen</sch:report>

      <!-- License -->
      <sch:assert test="geonet:isValidLicense(gmd:resourceConstraints)">Een geldige Creative Commons-licentie voor Overige beperkingen / (Juridische) toegangs restricties is vereist. Zie https://definities.geostandaarden.nl/dcat-ap-nl/nl/</sch:assert>

      <!-- Rights -->
      <sch:assert test="geonet:isValidRights(gmd:resourceConstraints)">Een geldige Creative Commons-licentie voor Overige beperkingen / (Juridische) gebruiksbeperking is vereist. Zie https://definities.geostandaarden.nl/dcat-ap-nl/nl/</sch:assert>

      <!-- Dataset contact -->
      <sch:let name="hasContact" value="count(gmd:pointOfContact) > 0"/>
      <sch:assert test="$hasContact = true()">Informatie die nodig is om contact op te nemen met de verantwoordelijke persoon of organisatie ontbreekt</sch:assert>

     </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:status">
      <sch:let name="status" value="*/@codeListValue"/>

      <sch:assert test="$status != ''">Status van de online bron ontbreekt</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
      <sch:let name="frequency" value="*/@codeListValue"/>

      <sch:assert test="$frequency != ''">Herzieningsfrequentie van de online bron ontbreekt</sch:assert>
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
