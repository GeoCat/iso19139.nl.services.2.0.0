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
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>
  <xsl:include href="../../../iso19139/layout/utility-fn.xsl"/>

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/(gmd:MD_Metadata|*[@gco:isoType = 'gmd:MD_Metadata'])"/>

  <xsl:variable name="schema"
                select="/root/info/record/datainfo/schemaid"/>

  <xsl:variable name="metadataUuid"
                select="/root/info/record/datainfo/uuid"/>

  <xsl:variable name="langId" select="gn-fn-iso19139:getLangId($metadata, $language)"/>

  <xsl:variable name="schemaStrings"
                select="/root/schemas/*[name() = $schema]/strings"/>

  <xsl:variable name="nodeUrl"
                select="/root/gui/nodeUrl"/>

  <!-- Load the editor configuration to be able
to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Required for utility-fn.xsl -->
  <xsl:variable name="editorConfig"
                select="document('../../layout/config-editor.xml')"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>

  <xsl:template mode="getOverviews" match="gmd:MD_Metadata|*[@gco:isoType = 'gmd:MD_Metadata']">
    <section class="gn-md-side-overview">
      <h2>
        <i class="fa fa-fw fa-image"></i>
        <span>
          <xsl:value-of select="$schemaStrings/overviews"/>
        </span>
      </h2>

      <xsl:variable name="imgOnError" as="xs:string?"
                    select="if (count(gmd:identificationInfo/*/gmd:graphicOverview/*) > 1)
                            then 'this.onerror=null; this.parentElement.style.display=''none'';'
                            else 'this.onerror=null; $(''.gn-md-side-overview'').hide();'"/>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:graphicOverview/*">
        <div>
          <img data-gn-img-modal="md"
               class="gn-img-thumbnail"
               alt="{$schemaStrings/overview}"
               src="{gmd:fileName/*}"
               onerror="{$imgOnError}" />

          <xsl:for-each select="gmd:fileDescription">
            <div class="gn-img-thumbnail-caption" style="display: block;">
              <xsl:call-template name="localised">
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
            </div>
          </xsl:for-each>
        </div>
      </xsl:for-each>
    </section>
  </xsl:template>

  <xsl:template mode="getExtent" match="gmd:MD_Metadata|*[@gco:isoType = 'gmd:MD_Metadata']">
    <xsl:if test=".//gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement[gmd:EX_GeographicBoundingBox or gmd:EX_BoundingPolygon]">
      <section class="gn-md-side-extent">
        <h2>
          <i class="fa fa-fw fa-map-marker"></i>
          <span>
            <xsl:value-of select="$schemaStrings/spatialExtent"/>
          </span>
        </h2>

        <xsl:choose>
          <xsl:when test=".//gmd:EX_BoundingPolygon">
            <xsl:copy-of select="gn-fn-render:extent($metadataUuid)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="gn-fn-render:bboxes(.//gmd:EX_GeographicBoundingBox)"/>
          </xsl:otherwise>
        </xsl:choose>
      </section>
    </xsl:if>
  </xsl:template>

  <!-- Render coordinates of bbox and an images of the geometry
using the region API -->
  <xsl:function name="gn-fn-render:bbox">
    <xsl:param name="west" as="xs:double"/>
    <xsl:param name="south" as="xs:double"/>
    <xsl:param name="east" as="xs:double"/>
    <xsl:param name="north" as="xs:double"/>

    <xsl:variable name="isPoint"
                  select="$west = $east and $south = $north"
                  as="xs:boolean"/>

    <xsl:variable name="boxGeometry"
                  select="if ($isPoint)
                          then concat('POINT(', $east, '%20', $south, ')')
                          else concat('POLYGON((',
                            $east, '%20', $south, ',',
                            $east, '%20', $north, ',',
                            $west, '%20', $north, ',',
                            $west, '%20', $south, ',',
                            $east, '%20', $south, '))')"/>
    <xsl:variable name="numberFormat" select="'0.00'"/>

    <div class="thumbnail extent">
      <div class="input-group coord coord-north">
        <input type="text" class="form-control"
               aria-label="{$schemaStrings/north}"
               value="{format-number($north, $numberFormat)}" readonly=""/>
        <span class="input-group-addon">N</span>
      </div>
      <div class="input-group coord coord-south">
        <input type="text" class="form-control"
               aria-label="{$schemaStrings/south}"
               value="{format-number($south, $numberFormat)}" readonly=""/>
        <span class="input-group-addon">S</span>
      </div>
      <div class="input-group coord coord-east">
        <input type="text" class="form-control"
               aria-label="{$schemaStrings/east}"
               value="{format-number($east, $numberFormat)}" readonly=""/>
        <span class="input-group-addon">E</span>
      </div>
      <div class="input-group coord coord-west">
        <input type="text" class="form-control"
               aria-label="{$schemaStrings/west}"
               value="{format-number($west, $numberFormat)}" readonly=""/>
        <span class="input-group-addon">W</span>
      </div>
      <xsl:copy-of select="gn-fn-render:geometry($boxGeometry)"/>
    </div>
  </xsl:function>


  <!-- Use region API to display an image -->
  <xsl:function name="gn-fn-render:geometry">
    <xsl:param name="geometry" as="xs:string"/>

    <xsl:if test="$geometry">
      <img class="gn-img-extent"
           alt="{$schemaStrings/thumbnail}"
           src="{$nodeUrl}api/regions/geom.png?geomsrs=EPSG:4326&amp;geom={$geometry}"/>
    </xsl:if>

  </xsl:function>

  <xsl:function name="gn-fn-render:bboxes">
    <xsl:param name="boundingBoxes" as="node()*"/>

    <xsl:variable name="coordinates" as="node()*">
      <xsl:for-each select="$boundingBoxes[*:eastBoundLongitude/*:Decimal castable as xs:double
                                           and *:southBoundLatitude/*:Decimal castable as xs:double
                                           and *:westBoundLongitude/*:Decimal castable as xs:double
                                           and *:northBoundLatitude/*:Decimal castable as xs:double]">
        <coords east="{xs:double(*:eastBoundLongitude/*:Decimal)}"
                south="{xs:double(*:southBoundLatitude/*:Decimal)}"
                west="{xs:double(*:westBoundLongitude/*:Decimal)}"
                north="{xs:double(*:northBoundLatitude/*:Decimal)}"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="points"
                  select="$coordinates[@east = @west and @south = @north]"/>

    <xsl:variable name="boxes"
                  select="$coordinates[@east != @west and @south != @north]"/>

    <xsl:variable name="geometryCollection"
                  select="concat('GEOMETRYCOLLECTION(',
                              string-join($points/concat('POINT(', @east, '%20', @south, ')'), ','),
                              if (count($points) > 0 and count($boxes) > 0) then ',' else '',
                              string-join($boxes/concat('POLYGON((',
                                @east, '%20', @south, ',',
                                @east, '%20', @north, ',',
                                @west, '%20', @north, ',',
                                @west, '%20', @south, ',',
                                @east, '%20', @south, '))'), ','),
                             ')')"/>
    <xsl:variable name="numberFormat" select="'0.00'"/>

    <div class="thumbnail extent">
      <xsl:copy-of select="gn-fn-render:geometry($geometryCollection)"/>
    </div>
  </xsl:function>

  <!-- Use region API to display metadata extent -->
  <xsl:function name="gn-fn-render:extent">
    <xsl:param name="uuid" as="xs:string"/>
    <xsl:if test="$uuid">
      <img class="gn-img-extent"
           alt="{$schemaStrings/thumbnail}"
           src="{$nodeUrl}api/records/{$uuid}/extents.png"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="gn-fn-render:extent">
    <xsl:param name="uuid" as="xs:string"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:if test="$uuid">
      <img class="gn-img-extent"
           alt="{$schemaStrings/thumbnail}"
           src="{$nodeUrl}api/records/{$uuid}/extents/{$index}.png"/>
    </xsl:if>

  </xsl:function>

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
      <hvd>http://data.europa.eu/bna/c_4ac557e7</hvd> <!-- Government expenditure and revenue -->
    </entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/HEAL">
      <inspire>http://inspire.ec.europa.eu/theme/hh</inspire>
      <inspire>http://www.eionet.europa.eu/gemet/nl/inspire-theme/hh</inspire>
      <iso>health</iso>
      <hvd>http://data.europa.eu/bna/c_424bb0b4</hvd> <!-- Current healthcare expenditure -->
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
      <iso>location</iso>
      <iso>society</iso>
      <iso>disaster</iso>
      <iso>intelligenceMilitary</iso>
      <iso>extraTerrestrial</iso>
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
      <iso>structure</iso>
      <iso>transportation</iso>
      <iso>utilitiesCommunication</iso>
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

  <!-- Used for metadata that does not have ISO topic categories (for example, service metadata) and does not have also INSPIRE GEMET Themes keywords -->
  <xsl:variable name="fallbackDcatApThemes" as="node()*">
    <entry key="http://publications.europa.eu/resource/authority/data-theme/GOVE" />
  </xsl:variable>

  <xsl:variable name="dcatApThemesTranslations">
    <entry key="http://publications.europa.eu/resource/authority/data-theme/AGRI">Landbouw, visserij, bosbouw en voeding</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/ECON">Economie en financiën</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/EDUC">Onderwijs, cultuur en sport</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/ENER">Energie</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/ENVI">Milieu</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/GOVE">Overheid en publieke sector</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/HEAL">Gezondheid</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/INTR">Internationale vraagstukken</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/JUST">Justitie, rechtsstelsel en openbare veiligheid</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/OP_DATPRO">Voorlopige gegevens</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/REGI">Regio's en steden</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/SOCI">Bevolking en samenleving</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/TECH">Wetenschap en technologie</entry>
    <entry key="http://publications.europa.eu/resource/authority/data-theme/TRAN">Vervoer</entry>
  </xsl:variable>

  <xsl:variable name="dcatApAccessTypes" as="node()*">
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">unrestricted</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">licenceUnrestricted</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/RESTRICTED">restricted</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">private</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/CONFIDENTIAL">confidential</entry>

    <!-- TODO: review with dct:rights -->
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1a</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1b</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1c</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1d</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1e</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1f</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1g</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1h</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1a</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1b</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1c</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1d</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1e</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1f</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1g</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/INSPIRE_Directive_Article13_1h</entry>

    <!-- Dutch specific -->
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">Geen beperkingen</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Naamsvermelding verplicht,</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/publicdomain/mark/1.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/publicdomain/zero/1.0/deed.nl</entry>

    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by/3.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by/4.0/deed.nl</entry>

    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Gelijk Delen, Naamsvermelding verplicht,</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-sa/3.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-sa/4.0/deed.nl</entry>

    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Niet Commercieel, Naamsvermelding verplicht </entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nc/3.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nc/4.0/deed.nl</entry>

    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Niet Commercieel, Gelijk Delen, Naamsvermelding verplicht,</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nc-sa/3.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nc-sa/4.0/deed.nl</entry>

    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Geen Afgeleide Werken, Naamsvermelding verplicht,</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nd/3.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nd/4.0/deed.nl</entry>

    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC" match="start">Niet Commercieel, Geen Afgeleide Werken, Naamsvermelding verplicht,</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nc-nd/3.0/deed.nl</entry>
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">http://creativecommons.org/licenses/by-nc-nd/4.0/deed.nl</entry>

    <!-- TODO: review other allowed values related to this license -->
    <entry key="http://publications.europa.eu/resource/authority/access-right/PUBLIC">Geo Gedeeld licentie</entry>
  </xsl:variable>

  <xsl:variable name="isMappingResourceConstraintsToEuVocabulary"
                as="xs:boolean"
                select="true()"/>

  <xsl:variable name="euLicenses"
                select="document('../../../iso19139.nl.geografie.2.0.0/formatter/dcat-ap-nl-3/vocabularies/licences-skos.rdf')"/>

  <xsl:variable name="isoStatusToDublinCore"
                as="node()*">
    <entry key="completed">Compleet</entry>
    <entry key="deprecated">DEPRECATED</entry>
    <entry key="underDevelopment">In ontwikkeling</entry>
    <entry key="obsolete">Niet relevant</entry>
    <!--<entry key="">OP_DATPRO</entry>-->
    <entry key="withdrawn">WITHDRAWN</entry>
  </xsl:variable>

  <xsl:variable name="isoContactRoleToDcatCommonNames"
                as="node()*">
    <entry key="dct:creator" as="foaf">originator</entry>
    <entry key="dct:creator" as="foaf">author</entry>
    <!-- Add this? -->
    <!--<entry key="dct:creator" as="foaf">originator</entry>-->
    <entry key="dct:publisher" as="foaf">publisher</entry>
    <entry key="dcat:contactPoint" as="vcard">pointOfContact</entry>
    <!-- Add this? -->
    <!--<entry key="dcat:contactPoint" as="vcard">owner</entry>-->
    <!--<entry key="dct:rightsHolder" as="foaf">owner</entry>--> <!-- TODO: Check if dcat or only in profile -->
    <!-- Others are prov:qualifiedAttribution -->
  </xsl:variable>

  <xsl:variable name="isoDateTypeToDcatCommonNames"
                as="node()*">
    <entry key="dct:modified">creation</entry>
    <entry key="dct:issued">publication</entry>
    <entry key="dct:modified">revision</entry>
  </xsl:variable>

  <xsl:variable name="isoFrequencyToDublinCore"
                as="node()*">
    <entry key="continual">Continu</entry>
    <entry key="daily">Dagelijks</entry>
    <entry key="weekly">Wekelijks</entry>
    <entry key="fortnightly">2-wekelijks</entry>
    <entry key="monthly">Maandelijks</entry>
    <entry key="quarterly">1 x per kwartaal</entry>
    <entry key="biannually">1 x per half jaar</entry>
    <entry key="annually">Jaarlijks</entry>
    <entry key="irregular">Onregelmatig</entry>
    <entry key="unknown">Onbekend</entry>
    <!--
    <entry key="asNeeded"></entry>
    <entry key="notPlanned"></entry>
    -->
  </xsl:variable>

  <xsl:variable name="languageMap">
    <entry key="dut">Nederlands</entry>
    <entry key="eng">Engels</entry>
  </xsl:variable>

  <!-- HTML -->
  <xsl:template match="/" priority="100">

    <xsl:variable name="useConstraints"
                  as="node()*">
      <xsl:copy-of select="$metadata/gmd:identificationInfo/*/gmd:resourceConstraints/*[gmd:useConstraints]/gmd:otherConstraints"/>
      <xsl:copy-of select="$metadata/gmd:identificationInfo/*/gmd:resourceConstraints/*[gmd:accessConstraints]/gmd:otherConstraints"/>
      <!-- TODO: review to use useLimitation -->
      <!--<xsl:copy-of select="../../mri:resourceConstraints/*[mco:useConstraints]/mco:useLimitation"/>-->
      <!-- TODO: review to use accessConstraints -->
      <!--<xsl:copy-of select="../../mri:resourceConstraints/*[mco:accessConstraints]/mco:otherConstraints"/>
      <xsl:copy-of select="../../mri:resourceConstraints/*[mco:accessConstraints]/mco:useLimitation"/>-->
    </xsl:variable>

    <!--<xsl:message>
      useConstraints: <xsl:copy-of select="$useConstraints" />
    </xsl:message>-->

    <xsl:variable name="licenses" as="node()*">
      <xsl:for-each select="$useConstraints">
        <!--<xsl:message>LICENSES $useConstraints</xsl:message>-->
        <xsl:variable name="httpUriInAnchorOrText"
                      select="(gmx:Anchor/@xlink:href[starts-with(., 'http')]
                                  |gco:CharacterString[starts-with(., 'http')])[1]"/>

        <!--<xsl:message>
          httpUriInAnchorOrText: <xsl:value-of select="$httpUriInAnchorOrText" />
          $isMappingResourceConstraintsToEuVocabulary: <xsl:value-of select="$isMappingResourceConstraintsToEuVocabulary" />
        </xsl:message>-->

        <xsl:choose>
          <xsl:when test="$httpUriInAnchorOrText != '' and $isMappingResourceConstraintsToEuVocabulary = true()">
            <xsl:variable name="licenseUriWithoutHttp"
                          select="replace($httpUriInAnchorOrText,'https?://','')"/>
            <!--<xsl:message>
              $licenseUriWithoutHttp: <xsl:value-of select="$licenseUriWithoutHttp" />
            </xsl:message>-->

            <xsl:variable name="euDcatLicense"
                          select="$euLicenses/rdf:RDF/skos:Concept[
                                                  matches(skos:exactMatch/@rdf:resource,
                                                          concat('https?://', $licenseUriWithoutHttp, '/?'))
                                                  or matches(@rdf:about,
                                                          concat('https?://', $licenseUriWithoutHttp, '/?'))]"/>

            <!--<xsl:message>
              euLicenses: <xsl:copy-of select="$euLicenses" />
              euDcatLicense: <xsl:copy-of select="$euDcatLicense" />
            </xsl:message>-->

            <xsl:if test="$euDcatLicense/@rdf:about != ''">
              <license><xsl:value-of select="$euDcatLicense/@rdf:about" /></license>
            </xsl:if>
          </xsl:when>

        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <div class="container-fluid gn-metadata-view gn-schema-{$schema}">
      <article class="gn-md-view gn-metadata-display">
        <div class="row">
          <div class="col-md-9">
            <h1><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString/text()"/></h1>

            <tabset id="detail-tabset" type="tabs" justified="false">
              <tab
                heading="Service"
              >
                <div>
                  <table class="table table-striped">
                    <tbody>
                      <tr>
                        <th>Titel</th>
                        <td>
                          <xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString/text()"/>
                        </td>
                      </tr>

                      <tr>
                        <th>Beschrijving</th>
                        <td>
                          <xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:abstract/gco:CharacterString/text()"/>
                        </td>
                      </tr>

                      <tr>
                        <th>Taal</th>
                        <td>
                          <xsl:value-of select="if (string($metadata/gmd:language/*/@codeListValue))
                                          then $languageMap/entry[@key = $metadata/gmd:language/*/@codeListValue]
                                          else $metadata/gmd:language/*/text()"/>
                        </td>
                      </tr>

                      <tr>
                        <th>Unieke identifier</th>
                        <td>
                          <xsl:value-of select="$metadata/gmd:fileIdentifier/*/text()"/>
                        </td>
                      </tr>

                      <xsl:variable name="issuedDateTypes" select="$isoDateTypeToDcatCommonNames[@key='dct:issued']" />

                      <!-- issued dates -->
                      <xsl:variable name="issuedDates">
                        <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:date">
                          <xsl:sort select="." order="descending" />

                          <xsl:variable name="dateType"
                                        as="xs:string?"
                                        select="*/gmd:dateType/*/@codeListValue"/>
                          <xsl:variable name="dcatElementName"
                                        as="xs:string?"
                                        select="$issuedDateTypes[. = $dateType]/@key"/>
                          <xsl:if test="string($dcatElementName)">
                            <date><xsl:value-of select="*/gmd:date/*/text()" /></date>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>

                      <xsl:if test="count($issuedDates/*) > 0">
                        <tr>
                          <th>Datum van de bron (aangemaakt) </th>
                          <td>
                            <xsl:value-of select="$issuedDates/*[1]"/>
                          </td>
                        </tr>
                      </xsl:if>

                      <!-- modified dates -->
                      <xsl:variable name="modifiedDateTypes" select="$isoDateTypeToDcatCommonNames[@key='dct:modified']" />

                      <xsl:variable name="modifiedDates">
                        <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:date">
                          <xsl:sort select="." order="descending" />
                          <xsl:variable name="dateType"
                                        as="xs:string?"
                                        select="*/gmd:dateType/*/@codeListValue"/>
                          <xsl:variable name="dcatElementName"
                                        as="xs:string?"
                                        select="$modifiedDateTypes[. = $dateType]/@key"/>
                          <xsl:if test="string($dcatElementName)">
                            <date><xsl:value-of select="*/gmd:date/*/text()" /></date>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>

                      <xsl:if test="count($modifiedDates/*) > 0">
                        <tr>
                          <th>Datum van de bron (laatste wijziging) </th>
                          <td>
                            <xsl:value-of select="$modifiedDates/*[1]"/>
                          </td>
                        </tr>
                      </xsl:if>

                      <xsl:if test="count($metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(gmd:thesaurusName)]/gmd:keyword[string(gco:CharacterString/text())]) +
                                    count($metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*[gmd:thesaurusName/*/gmd:title/*/text() != 'GEMET - INSPIRE themes, version 1.0']/gmd:keyword[string(gco:CharacterString/text())]) > 0">
                        <tr>
                          <th>Trefwoorden</th>
                          <td>
                            <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(gmd:thesaurusName) or
                                                        gmd:thesaurusName/*/gmd:title/*/text() != 'GEMET - INSPIRE themes, version 1.0']/gmd:keyword[string((gco:CharacterString|gmx:Anchor)/text())]">
                              <xsl:variable name="keywordValue" select="(gco:CharacterString|gmx:Anchor)/text()" />
                              <a
                                href=""
                                title="{{{{ 'clickToFilterOn' | translate }}}} {{{{'{replace($keywordValue, '''', '\\''')}' | capitalize}}}}"
                                aria-label="{{{{ 'clickToFilterOn' | translate }}}} {{{{'{replace($keywordValue, '''', '\\''')}' | capitalize}}}}"
                                data-ng-click="filterBy('tag.default', '{replace($keywordValue, '''', '\\''')}')"
                              >
                                <xsl:variable name="firstChar" select="substring($keywordValue,1,1)"/>

                                <xsl:value-of select="translate($firstChar,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/><xsl:value-of select="substring-after($keywordValue,$firstChar)"/>
                              </a>
                              <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                          </td>
                        </tr>
                      </xsl:if>

                        <xsl:variable name="hvdCategoryThesaurusKey"
                                      select="('http://data.europa.eu/bna/asd487ae75', 'http://publications.europa.eu/resource/dataset/high-value-dataset-category')"/>

                      <xsl:variable name="themes">
                        <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*[gmd:thesaurusName/*/gmd:title/*/text() = 'GEMET - INSPIRE themes, version 1.0']/gmd:keyword">
                          <xsl:variable name="gemetValue" select="gmx:Anchor/@xlink:href" />
                          <xsl:variable name="gemetTheme" select="$isoTopicToEuDcatApThemes[inspire = $gemetValue]/@key" />

                          <xsl:for-each select="$gemetTheme">
                            <xsl:variable name="translation" select="$dcatApThemesTranslations/entry[@key = current()]" />
                            <theme><xsl:value-of select="if (string($translation)) then $translation else ." /></theme>
                          </xsl:for-each>
                        </xsl:for-each>

                        <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*[gmd:thesaurusName/*/gmd:title/*/@xlink:href = $hvdCategoryThesaurusKey]/gmd:keyword">
                          <xsl:variable name="hvdValue" select="gmx:Anchor/@xlink:href" />
                          <xsl:variable name="hvdTheme" select="$isoTopicToEuDcatApThemes[hvd = $hvdValue]/@key" />

                          <xsl:for-each select="$hvdTheme">
                            <xsl:variable name="translation" select="$dcatApThemesTranslations/entry[@key = current()]" />
                            <theme><xsl:value-of select="if (string($translation)) then $translation else ." /></theme>
                          </xsl:for-each>
                        </xsl:for-each>
                      </xsl:variable>

                      <xsl:choose>
                        <xsl:when test="count($themes/*) > 0">
                          <tr>
                            <th>Thema</th>
                            <td>
                              <xsl:for-each-group select="$themes/theme" group-by=".">
                                <xsl:value-of select="current-grouping-key()" /><xsl:if test="position() != last()">, </xsl:if>
                              </xsl:for-each-group>
                            </td>
                          </tr>
                        </xsl:when>
                        <xsl:otherwise>
                          <tr>
                            <th>Thema</th>
                            <td>
                              <xsl:for-each select="$fallbackDcatApThemes/@key">
                                <xsl:variable name="translation" select="$dcatApThemesTranslations/entry[@key = current()]" />
                                <xsl:value-of select="if (string($translation)) then $translation else ." /><xsl:if test="position() != last()">, </xsl:if>
                              </xsl:for-each>
                            </td>
                          </tr>
                        </xsl:otherwise>
                      </xsl:choose>

                      <tr>
                        <th>Toegangsrechten</th>
                        <td>
                          <!-- Check if there are non PUBLIC constraints -->
                          <xsl:variable name="rightsStatementsNonPublic">
                            <xsl:for-each select="distinct-values($metadata/gmd:identificationInfo/*/gmd:resourceConstraints/*[gmd:accessConstraints]/gmd:otherConstraints/(gco:CharacterString|gmx:Anchor/@xlink:href))">
                              <xsl:variable name="dcatAccessType"
                                            select="$dcatApAccessTypes[(lower-case(.) = lower-case(current()) and not(@match)) or
                                                   (starts-with(lower-case(current()), lower-case(.)) and (@match = 'start'))] "/>

                              <xsl:if test="$dcatAccessType/@key != 'http://publications.europa.eu/resource/authority/access-right/PUBLIC'">
                                <right key="{$dcatAccessType/@key}" />
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:variable>

                          <!-- If there are non PUBLIC constraints, use the first one, otherwise use PUBLIC -->
                          <xsl:choose>
                            <xsl:when test="count($rightsStatementsNonPublic/right) > 0">
                              Beperkt
                            </xsl:when>
                            <xsl:otherwise>
                              Publiek
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                      </tr>

                      <xsl:if test="count($licenses) > 0">
                        <tr>
                          <th>Licenties</th>
                          <td>
                            <xsl:choose>
                              <xsl:when test="starts-with($licenses[1], 'http')">
                                <a href="{$licenses[1]}" target="_blank"><xsl:value-of select="$licenses[1]" /></a>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="$licenses[1]" />
                              </xsl:otherwise>
                            </xsl:choose>
                          </td>
                        </tr>
                      </xsl:if>

                      <xsl:if test="count($metadata/gmd:dataQualityInfo/*/gmd:report/*/gmd:result[*/gmd:pass/*/text() = 'true']) > 0">
                        <tr>
                          <th>Conformiteit met specificatie</th>
                          <td>
                            <ul style="padding-left: 1em;">
                              <xsl:for-each
                                      select="$metadata/gmd:dataQualityInfo/*/gmd:report/*/gmd:result[*/gmd:pass/*/text() = 'true']/*/gmd:specification">
                                <xsl:variable name="specificationTitle" select="*/gmd:title/*/text()"/>
                                <xsl:variable name="specificationHref"
                                              select="*/gmd:title/*/@xlink:href"/>
                                <li>
                                  <a href="{$specificationHref}" target="_blank">
                                    <xsl:value-of select="$specificationTitle"/>
                                  </a>
                                </li>
                              </xsl:for-each>
                            </ul>
                          </td>
                        </tr>
                      </xsl:if>

                      <xsl:variable name="endpointDescriptionUrlExpression"
                                    as="xs:string"
                                    select="'GetCapabilities|WSDL'"/>
                      <xsl:variable name="endpointDescriptionProtocolsExpression"
                                    as="xs:string"
                                    select="'OpenAPI|Swagger|GetCapabilities|WSDL|Description'"/>

                      <xsl:if test="$metadata/gmd:identificationInfo/*/srv:containsOperations/*/srv:connectPoint[gmd:CI_OnlineResource/gmd:linkage/gmd:URL != '']">
                        <tr>
                          <th>Service URL</th>
                          <td>
                            <xsl:for-each
                              select="$metadata/gmd:identificationInfo/*/srv:containsOperations/*/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage[matches(gmd:protocol/(gco:CharacterString|gmd:Anchor)/text(), $endpointDescriptionProtocolsExpression, 'i')
                                        or matches(gmd:URL/text(), $endpointDescriptionUrlExpression, 'i')
                                        or gmd:function/*/@codeListValue = 'information']/gmd:URL">
                              <xsl:if test="position() = 1">
                                <xsl:variable name="endpointUrl" select="if (contains(., '?')) then substring-before(., '?') else ."/>
                                <p style="word-break: break-all;">
                                  <a href="{$endpointUrl}" target="_blank" title="={$endpointUrl}">
                                    <xsl:value-of select="$endpointUrl"/>
                                  </a>
                                </p>
                              </xsl:if>
                            </xsl:for-each>
                          </td>
                        </tr>

                        <tr>
                          <th>Service URL beschrijving</th>
                          <td>
                            <xsl:for-each
                              select="$metadata/gmd:identificationInfo/*/srv:containsOperations/*/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage[matches(gmd:protocol/(gco:CharacterString|gmd:Anchor)/text(), $endpointDescriptionProtocolsExpression, 'i')
                                        or matches(gmd:URL/text(), $endpointDescriptionUrlExpression, 'i')
                                        or gmd:function/*/@codeListValue = 'information']/gmd:URL">
                              <xsl:if test="position() = 1">
                                <p style="word-break: break-all;">
                                  <a href="{.}" target="_blank" title="={.}">
                                    <xsl:value-of select="."/>
                                  </a>
                                </p>
                              </xsl:if>
                            </xsl:for-each>
                          </td>
                        </tr>
                      </xsl:if>

                      <xsl:if test="$metadata/gmd:identificationInfo/*/srv:operatesOn">
                        <tr>
                          <th>Gerelateerde dataset</th>
                          <td>
                            <xsl:for-each
                                    select="$metadata/gmd:identificationInfo/*/srv:operatesOn">
                              <p style="word-break: break-all;">
                                <a href="{@xlink:href}" target="_blank" title="={@xlink:href}">
                                  <xsl:value-of select="@xlink:href"/>
                                </a>
                              </p>
                            </xsl:for-each>
                          </td>
                        </tr>
                      </xsl:if>

                      <xsl:if test="count($metadata/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[string(*/gmd:linkage/*/text()) and
                                            */gmd:protocol/gmx:Anchor/@xlink:href='https://www.w3.org/TR/vocab-dcat-2/#Property:resource_landing_page']) > 0">

                        <tr>
                          <th>Landingspagina</th>
                          <td>
                            <xsl:for-each select="$metadata/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[string(*/gmd:linkage/*/text()) and
                                            */gmd:protocol/gmx:Anchor/@xlink:href='https://www.w3.org/TR/vocab-dcat-2/#Property:resource_landing_page']">
                              <a href="{*/gmd:linkage/*/text()}" target="_blank" ><xsl:value-of select="*/gmd:linkage/*/text()" /></a>
                            </xsl:for-each>
                          </td>
                        </tr>
                      </xsl:if>

                    </tbody>

                  </table>
                </div>
              </tab>
              <tab
                heading="Contact gegevens"
              >
                <!-- Obtain default iso contact mappings to DCAT contacts -->
                <xsl:variable name="contactsMapping">
                  <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact">
                    <xsl:variable name="role"
                                  as="xs:string?"
                                  select="*/gmd:role/*/@codeListValue"/>

                    <xsl:variable name="dcatElementConfig"
                                  as="node()?"
                                  select="$isoContactRoleToDcatCommonNames[. = $role]"/>

                    <xsl:if test="$dcatElementConfig">
                      <xsl:copy-of select="$dcatElementConfig" />
                    </xsl:if>
                    <!--<xsl:message>dcatElementConfig: <xsl:copy-of select="$dcatElementConfig" /></xsl:message>-->
                  </xsl:for-each>
                </xsl:variable>

                <table class="table table-striped">
                  <tbody>
                    <tr>
                      <th>Aanmaker</th>
                      <td>
                        <xsl:choose>
                          <xsl:when test="$contactsMapping/entry[@key='dct:creator']">
                            <xsl:variable name="mappingRole" select="$contactsMapping/entry[@key='dct:creator']" />

                            <xsl:variable name="rolesForCreator" select="$isoContactRoleToDcatCommonNames[@key = 'dct:creator']/text()" />

                            <xsl:variable name="contactsToProcess"
                                          select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = $rolesForCreator]" />

                            <!-- Sorted contacts to process with rolesForCreator ordering -->
                            <xsl:variable name="contactsToProcessSorted">
                              <xsl:for-each select="$rolesForCreator">
                                <xsl:variable name="creatorRole" select="." />

                                <xsl:if test="count($contactsToProcess[gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = $creatorRole]) > 0">

                                  <xsl:copy-of select="$contactsToProcess[gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = $creatorRole]" />
                                </xsl:if>
                              </xsl:for-each>
                            </xsl:variable>

                            <xsl:for-each select="$contactsToProcessSorted/*[1]">
                              <xsl:variable name="role"
                                            as="xs:string?"
                                            select="*/gmd:role/*/@codeListValue"/>

                              <xsl:if test="$role = $mappingRole">
                                <p><xsl:value-of select="*/gmd:organisationName/*/text()" /></p>
                                <p><i class="fa fa-fw fa-envelope"></i><a href="mailto:{*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()}"><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()" /></a></p>
                                <xsl:if test="string(*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)">
                                  <p><i class="fa fa-fw fa-link"></i><a href="{*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL}"><xsl:value-of select="*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL" /></a></p>
                                </xsl:if>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:message>otherwise dct:creator</xsl:message>
                            <xsl:variable name="dcatElementConfig">
                              <value name="dct:creator" as="{$isoContactRoleToDcatCommonNames/entry[@key = 'dct:creator']/@as}"/>
                            </xsl:variable>

                            <p><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:organisationName/*/text()" /></p>
                            <p><i class="fa fa-fw fa-envelope"></i> <a href="mailto:{$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()}"><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()" /></a></p>
                            <xsl:if test="string($metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)">
                              <p><i class="fa fa-fw fa-link"></i><a href="{$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL}"><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL" /></a></p>
                            </xsl:if>
                          </xsl:otherwise>
                        </xsl:choose>
                      </td>
                    </tr>

                    <tr>
                      <th>Publiceerder</th>
                      <td>
                        <xsl:choose>
                          <xsl:when test="$contactsMapping/entry[@key='dct:publisher']">
                            <xsl:message>if: dct:publisher</xsl:message>
                            <xsl:variable name="mappingRole" select="$contactsMapping/entry[@key='dct:publisher']" />
                            <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact">
                              <xsl:variable name="role"
                                            as="xs:string?"
                                            select="*/gmd:role/*/@codeListValue"/>

                              <xsl:if test="$role = $mappingRole">
                                <p><xsl:value-of select="*/gmd:organisationName/*/text()" /></p>
                                <p><i class="fa fa-fw fa-envelope"></i><a href="mailto:{*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()}"><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()" /></a></p>
                                <xsl:if test="string(*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)">
                                  <p><i class="fa fa-fw fa-link"></i><a href="{*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL}"><xsl:value-of select="*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL" /></a></p>
                                </xsl:if>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:message>otherwise dct:publisher</xsl:message>
                            <xsl:variable name="dcatElementConfig">
                              <value name="dct:creator" as="{$isoContactRoleToDcatCommonNames/entry[@key = 'dct:publisher']/@as}"/>
                            </xsl:variable>

                            <p><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:organisationName/*/text()" /></p>
                            <p><i class="fa fa-fw fa-envelope"></i> <a href="mailto:{$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()}"><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()" /></a></p>
                            <xsl:if test="string($metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)">
                              <p><i class="fa fa-fw fa-link"></i><a href="{$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL}"><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL" /></a></p>
                            </xsl:if>
                          </xsl:otherwise>
                        </xsl:choose>
                      </td>
                    </tr>

                    <tr>
                      <th>Contactpunt</th>
                      <td>
                        <xsl:choose>
                          <xsl:when test="$contactsMapping/entry[@key='dct:contactPoint']">
                            <xsl:message>if: dct:contactPoint</xsl:message>
                            <xsl:variable name="mappingRole" select="$contactsMapping/entry[@key='dct:contactPoint']" />
                            <xsl:for-each select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact">
                              <xsl:variable name="role"
                                            as="xs:string?"
                                            select="*/gmd:role/*/@codeListValue"/>

                              <xsl:if test="$role = $mappingRole">
                                <p><xsl:value-of select="*/gmd:organisationName/*/text()" /></p>
                                <p><i class="fa fa-fw fa-envelope"></i><a href="mailto:{*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()}"><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()" /></a></p>
                                <xsl:if test="string(*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)">
                                  <p><i class="fa fa-fw fa-link"></i><a href="{*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL}"><xsl:value-of select="*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL" /></a></p>
                                </xsl:if>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:message>otherwise dct:publisher</xsl:message>
                            <xsl:variable name="dcatElementConfig">
                              <value name="dct:creator" as="{$isoContactRoleToDcatCommonNames/entry[@key = 'dct:publisher']/@as}"/>
                            </xsl:variable>

                            <p><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:organisationName/*/text()" /></p>
                            <p><i class="fa fa-fw fa-envelope"></i> <a href="mailto:{$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()}"><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*/text()" /></a></p>
                            <xsl:if test="string($metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL)">
                              <p><i class="fa fa-fw fa-link"></i><a href="{$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL}"><xsl:value-of select="$metadata/gmd:identificationInfo/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/gmd:URL" /></a></p>
                            </xsl:if>
                          </xsl:otherwise>
                        </xsl:choose>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </tab>
            </tabset>
          </div>

          <div class="gn-md-side gn-md-side-advanced col-md-3">
          <xsl:apply-templates mode="getOverviews" select="$metadata"/>
          <xsl:apply-templates mode="getExtent" select="$metadata"/>

          </div>
        </div>
      </article>
    </div>
  </xsl:template>

</xsl:stylesheet>
