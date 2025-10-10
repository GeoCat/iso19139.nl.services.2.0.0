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
        <hvd>http://data.europa.eu/bna/c_642643e6</hvd> <!-- Agricultural parcels -->
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
        <hvd>http://data.europa.eu/bna/c_04bf94a3</hvd> <!-- Poverty -->
        <hvd>http://data.europa.eu/bna/c_20cd11bb</hvd> <!-- EU International trade in goods statistics ... -->
        <hvd>http://data.europa.eu/bna/c_23385471</hvd> <!-- Potential labour force -->
        <hvd>http://data.europa.eu/bna/c_2aed31f9</hvd> <!-- Industrial producer price index breakdowns by activity -->
        <hvd>http://data.europa.eu/bna/c_317b9493</hvd> <!-- Population, Fertility, Mortality -->
        <hvd>http://data.europa.eu/bna/c_34abf8c1</hvd> <!-- Industrial production -->
        <hvd>http://data.europa.eu/bna/c_424bb0b4</hvd> <!-- Current healthcare expenditure -->
        <hvd>http://data.europa.eu/bna/c_4ac557e7</hvd> <!-- Government expenditure and revenue -->
        <hvd>http://data.europa.eu/bna/c_59627af3</hvd> <!-- National accounts – key indicators on households -->
        <hvd>http://data.europa.eu/bna/c_92874eb2</hvd> <!-- Environmental accounts and statistics -->
        <hvd>http://data.europa.eu/bna/c_95da87c7</hvd> <!-- National accounts – key indicators on corporations -->
        <hvd>http://data.europa.eu/bna/c_a2c6dcd8</hvd> <!-- Employment -->
        <hvd>http://data.europa.eu/bna/c_a49ec591</hvd> <!-- Volume of sales by activity -->
        <hvd>http://data.europa.eu/bna/c_a8b937c4</hvd> <!-- Inequality -->
        <hvd>http://data.europa.eu/bna/c_b72b721f</hvd> <!-- National accounts – GDP main aggregates -->
        <hvd>http://data.europa.eu/bna/c_c0022235</hvd> <!-- Harmonised Indices of consumer prices -->
        <hvd>http://data.europa.eu/bna/c_dd8f4797</hvd> <!-- Consolidated government gross debt -->
        <hvd>http://data.europa.eu/bna/c_fd4e881c</hvd> <!-- Unemployment -->
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/EDUC"></entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/ENER">
        <inspire>http://inspire.ec.europa.eu/theme/er</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/er</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/mr</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/mr</inspire>
        <iso>economy</iso>
        <hvd>http://data.europa.eu/bna/c_b7de66cd</hvd> <!-- Energy resources -->
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
        <iso>geoscientificInformation</iso>
        <iso>imageryBaseMapsEarthCover</iso>
        <iso>planningCadastre</iso>
        <hvd>http://data.europa.eu/bna/c_164e0bf5</hvd> <!-- Meteorological -->
        <hvd>http://data.europa.eu/bna/c_13e3cf16</hvd> <!-- NWP model data -->
        <hvd>http://data.europa.eu/bna/c_36807466</hvd> <!-- Climate data: validated observations -->
        <hvd>http://data.europa.eu/bna/c_3af3368c</hvd> <!-- Observations data measured by weather stations -->
        <hvd>http://data.europa.eu/bna/c_be47b010</hvd> <!-- Weather alerts -->
        <hvd>http://data.europa.eu/bna/c_d13a4420</hvd> <!-- Radar data -->
        <hvd>http://data.europa.eu/bna/c_92874eb2</hvd> <!-- Environmental accounts and statistics -->
        <hvd>http://data.europa.eu/bna/c_dd313021</hvd> <!-- Earth observation and environment -->
        <hvd>http://data.europa.eu/bna/c_63b37dd4</hvd> <!-- Air -->
        <hvd>http://data.europa.eu/bna/c_af646f5b</hvd> <!-- Area management / restriction / regulation zones ... -->
        <hvd>http://data.europa.eu/bna/c_c873f344</hvd> <!-- Bio-geographical regions -->
        <hvd>http://data.europa.eu/bna/c_59e64dd4</hvd> <!-- Climate -->
        <hvd>http://data.europa.eu/bna/c_315692ad</hvd> <!-- Elevation -->
        <hvd>http://data.europa.eu/bna/c_4ba9548e</hvd> <!-- Emissions -->
        <hvd>http://data.europa.eu/bna/c_b7de66cd</hvd> <!-- Energy resources -->
        <hvd>http://data.europa.eu/bna/c_7b8fbb64</hvd> <!-- Environmental monitoring facilities -->
        <hvd>http://data.europa.eu/bna/c_e3f55603</hvd> <!-- Geology -->
        <hvd>http://data.europa.eu/bna/c_c3919aec</hvd> <!-- Habitats and biotopes -->
        <hvd>http://data.europa.eu/bna/c_4d63300b</hvd> <!-- Horizontal legislation -->
        <hvd>http://data.europa.eu/bna/c_06b1eec4</hvd> <!-- Hydrography -->
        <hvd>http://data.europa.eu/bna/c_b21e1296</hvd> <!-- Land cover -->
        <hvd>http://data.europa.eu/bna/c_ad9ae929</hvd> <!-- Land use -->
        <hvd>http://data.europa.eu/bna/c_4dd389c5</hvd> <!-- Mineral resources -->
        <hvd>http://data.europa.eu/bna/c_63be22bd</hvd> <!-- Natural risk zones -->
        <hvd>http://data.europa.eu/bna/c_b7f6a4f3</hvd> <!-- Nature preservation and biodiversity -->
        <hvd>http://data.europa.eu/bna/c_e4358335</hvd> <!-- Noise -->
        <hvd>http://data.europa.eu/bna/c_b40e6d46</hvd> <!-- Oceanographic geographical features -->
        <hvd>http://data.europa.eu/bna/c_91185a85</hvd> <!-- Orthoimagery -->
        <hvd>http://data.europa.eu/bna/c_59c93ba5</hvd> <!-- Production and industrial facilities -->
        <hvd>http://data.europa.eu/bna/c_83aa10a6</hvd> <!-- Protected sites -->
        <hvd>http://data.europa.eu/bna/c_f399050e</hvd> <!-- Sea regions -->
        <hvd>http://data.europa.eu/bna/c_87a129d9</hvd> <!-- Soil -->
        <hvd>http://data.europa.eu/bna/c_793164b6</hvd> <!-- Species distribution -->
        <hvd>http://data.europa.eu/bna/c_38933a65</hvd> <!-- Waste -->
        <hvd>http://data.europa.eu/bna/c_43f88346</hvd> <!-- Water -->
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/GOVE">
        <inspire>http://inspire.ec.europa.eu/theme/au</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/au</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/us</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/us</inspire>
        <iso>boundaries</iso>
        <iso>utilitiesCommunication</iso>
        <hvd>http://data.europa.eu/bna/c_4ac557e7</hvd> <!-- Government expenditure and revenue -->
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/HEAL">
        <inspire>http://inspire.ec.europa.eu/theme/hh</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/hh</inspire>
        <iso>health</iso>
        <hvd>http://data.europa.eu/bna/c_424bb0b4</hvd> <!-- Current healthcare expenditure -->
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/INTR"></entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/JUST">
        <iso>intelligenceMilitary</iso>
      </entry>
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
        <iso>elevation</iso>
        <iso>imageryBaseMapsEarthCover</iso>
        <iso>geoscientificInformation</iso>
        <iso>location</iso>
        <iso>structure</iso>
        <hvd>http://data.europa.eu/bna/c_ac64a52d</hvd> <!-- Geospatial -->
        <hvd>http://data.europa.eu/bna/c_60182062</hvd> <!-- Buildings -->
        <hvd>http://data.europa.eu/bna/c_642643e6</hvd> <!-- Agricultural parcels -->
        <hvd>http://data.europa.eu/bna/c_6a3f6896</hvd> <!-- Cadastral parcels -->
        <hvd>http://data.europa.eu/bna/c_6c2bb82d</hvd> <!-- Geographical names -->
        <hvd>http://data.europa.eu/bna/c_9427236f</hvd> <!-- Administrative units -->
        <hvd>http://data.europa.eu/bna/c_c3de25e4</hvd> <!-- Addresses -->
        <hvd>http://data.europa.eu/bna/c_fbd2fc3f</hvd> <!-- Reference parcels -->
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/SOCI">
        <inspire>http://inspire.ec.europa.eu/theme/pd</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/pd</inspire>
        <inspire>http://inspire.ec.europa.eu/theme/su</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/su</inspire>
        <iso>society</iso>
        <iso>boundaries</iso>
        <hvd>http://data.europa.eu/bna/c_e1da4e07</hvd> <!-- Statistics -->
        <hvd>http://data.europa.eu/bna/c_04bf94a3</hvd> <!-- Poverty -->
        <hvd>http://data.europa.eu/bna/c_20cd11bb</hvd> <!-- EU International trade in goods statistics ... -->
        <hvd>http://data.europa.eu/bna/c_23385471</hvd> <!-- Potential labour force -->
        <hvd>http://data.europa.eu/bna/c_2aed31f9</hvd> <!-- Industrial producer price index breakdowns by activity -->
        <hvd>http://data.europa.eu/bna/c_317b9493</hvd> <!-- Population, Fertility, Mortality -->
        <hvd>http://data.europa.eu/bna/c_34abf8c1</hvd> <!-- Industrial production -->
        <hvd>http://data.europa.eu/bna/c_424bb0b4</hvd> <!-- Current healthcare expenditure -->
        <hvd>http://data.europa.eu/bna/c_4ac557e7</hvd> <!-- Government expenditure and revenue -->
        <hvd>http://data.europa.eu/bna/c_4acb6bf3</hvd> <!-- Mortality -->
        <hvd>http://data.europa.eu/bna/c_59627af3</hvd> <!-- National accounts – key indicators on households -->
        <hvd>http://data.europa.eu/bna/c_6a7250c1</hvd> <!-- Fertility -->
        <hvd>http://data.europa.eu/bna/c_92874eb2</hvd> <!-- Environmental accounts and statistics -->
        <hvd>http://data.europa.eu/bna/c_95da87c7</hvd> <!-- National accounts – key indicators on corporations -->
        <hvd>http://data.europa.eu/bna/c_a2c6dcd8</hvd> <!-- Employment -->
        <hvd>http://data.europa.eu/bna/c_a3767648</hvd> <!-- Tourism flows in Europe -->
        <hvd>http://data.europa.eu/bna/c_a49ec591</hvd> <!-- Volume of sales by activity -->
        <hvd>http://data.europa.eu/bna/c_a8b937c4</hvd> <!-- Inequality -->
        <hvd>http://data.europa.eu/bna/c_b72b721f</hvd> <!-- National accounts – GDP main aggregates -->
        <hvd>http://data.europa.eu/bna/c_c0022235</hvd> <!-- Harmonised Indices of consumer prices -->
        <hvd>http://data.europa.eu/bna/c_dd8f4797</hvd> <!-- Consolidated government gross debt -->
        <hvd>http://data.europa.eu/bna/c_f2b50efd</hvd> <!-- Population -->
        <hvd>http://data.europa.eu/bna/c_fd4e881c</hvd> <!-- Unemployment -->
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
        <hvd>http://data.europa.eu/bna/c_91185a85</hvd> <!-- Orthoimagery -->
      </entry>
      <entry key="http://publications.europa.eu/resource/authority/data-theme/TRAN">
        <inspire>http://inspire.ec.europa.eu/theme/tn</inspire>
        <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/tn</inspire>
        <iso>transportation</iso>
        <hvd>http://data.europa.eu/bna/c_b79e35eb</hvd> <!-- Mobility -->
        <hvd>http://data.europa.eu/bna/c_4b74ea13</hvd> <!-- Transport networks -->
        <hvd>http://data.europa.eu/bna/c_b151a0ba</hvd> <!-- Inland waterways datasets -->
        <hvd>http://data.europa.eu/bna/c_03ba8d92</hvd> <!-- Regular lock and bridge operating times -->
        <hvd>http://data.europa.eu/bna/c_1226dc1a</hvd> <!-- Bank of waterway at mean water level -->
        <hvd>http://data.europa.eu/bna/c_1e787364</hvd> <!-- Reference data for water level gauges relevant to navigation -->
        <hvd>http://data.europa.eu/bna/c_2037ada4</hvd> <!-- Navigation rules and recommendations -->
        <hvd>http://data.europa.eu/bna/c_25f43866</hvd> <!-- Rates of waterway infrastructure charges -->
        <hvd>http://data.europa.eu/bna/c_298ffb73</hvd> <!-- Links to the external xml-files with operation times of restricting structures -->
        <hvd>http://data.europa.eu/bna/c_3e8e3bf7</hvd> <!-- Location and characteristics of ports and transhipment sites -->
        <hvd>http://data.europa.eu/bna/c_407951ff</hvd> <!-- Location of ports and transhipment sites -->
        <hvd>http://data.europa.eu/bna/c_593bc53d</hvd> <!-- Short term changes of aids to navigation -->
        <hvd>http://data.europa.eu/bna/c_664c9e5a</hvd> <!-- Boundaries of the fairway/navigation channel -->
        <hvd>http://data.europa.eu/bna/c_66b946cb</hvd> <!-- Short term changes of lock and bridge operating times -->
        <hvd>http://data.europa.eu/bna/c_7e19ef26</hvd> <!-- Other physical limitations on waterways -->
        <hvd>http://data.europa.eu/bna/c_883d0205</hvd> <!-- Contours of locks and dams -->
        <hvd>http://data.europa.eu/bna/c_99bc517f</hvd> <!-- Isolated dangers in the fairway/navigation channel under and above water -->
        <hvd>http://data.europa.eu/bna/c_9cbe4435</hvd> <!-- List of navigation aids and traffic signs -->
        <hvd>http://data.europa.eu/bna/c_b121e2f6</hvd> <!-- Temporary obstructions in the fairway -->
        <hvd>http://data.europa.eu/bna/c_b24028d7</hvd> <!-- Official aids-to-navigation (e.g. buoys, beacons, lights, notice marks) -->
        <hvd>http://data.europa.eu/bna/c_bc8941d9</hvd> <!-- Shoreline construction -->
        <hvd>http://data.europa.eu/bna/c_c19af83a</hvd> <!-- Waterway axis with kilometres indication -->
        <hvd>http://data.europa.eu/bna/c_e50004c6</hvd> <!-- State of the rivers, canals, locks and bridges -->
        <hvd>http://data.europa.eu/bna/c_e5f69a04</hvd> <!-- Present and future water levels at gauges -->
        <hvd>http://data.europa.eu/bna/c_f6886b00</hvd> <!-- Restrictions caused by flood and ice -->
        <hvd>http://data.europa.eu/bna/c_f76b01e6</hvd> <!-- Fairway characteristics -->
        <hvd>http://data.europa.eu/bna/c_fa2a1c3a</hvd> <!-- Long-time obstructions in the fairway and reliability -->
        <hvd>http://data.europa.eu/bna/c_fef208ab</hvd> <!-- Water depths contours in the navigation channel -->
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

      <sch:assert test="$mdIdentifier != ''">Unieke Identifier van de service ontbreekt</sch:assert>
    </sch:rule>

    <sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification">
      <!-- Check thema with GEMET INSPIRE themes -->
      <sch:let name="nodes">
        <xsl:copy-of select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href = 'http://inspire.ec.europa.eu/theme' or
                                                                     gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmx:Anchor/@xlink:href = 'http://www.eionet.europa.eu/gemet/inspire_themes']/gmd:keyword" />
      </sch:let>

      <!-- Thema -->
      <sch:assert test="geonet:hasEuDcatApThemes($nodes)">Een INSPIRE-thema trefwoord wordt aanbevolen</sch:assert>

      <!-- Service identifier present -->
      <sch:assert test="gmd:citation/*/gmd:identifier/gmd:MD_Identifier/gmd:code">Unieke Identifier van de service ontbreekt</sch:assert>

      <!-- Keywords -->
      <sch:assert test="gmd:descriptiveKeywords/*/gmd:keyword[gmx:Anchor/@xlink:href != '' or gco:CharacterString != '']">Trefwoorden voor datasets worden aanbevolen</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>
