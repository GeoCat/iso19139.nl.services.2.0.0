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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:include href="layout-custom-fields.xsl"/>
  <xsl:include href="utility-tpl.xsl"/>

  <!-- Use custom schema codelists -->
  <xsl:template mode="mode-iso19139" priority="500" match="*[*/@codeList and $schema='iso19139.nl.services.2.0.0']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="elementName" select="name()"/>
    <xsl:variable name="labelConfig">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <element>
            <label><xsl:value-of select="$overrideLabel"/></label>
          </element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="$labelConfig/*"/>
      <xsl:with-param name="value" select="*/@codeListValue"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-iso19139:getCodeListType(name())"/>
      <xsl:with-param name="name"
                      select="if ($isEditing) then concat(*/gn:element/@ref, '_codeListValue') else ''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="listOfValues"
                      select="gn-fn-metadata:getCodeListValues($schema, name(*[@codeListValue]), $codelists, .)"/>
      <xsl:with-param name="isFirst"
                      select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
    </xsl:call-template>

  </xsl:template>

  <!-- Visit all XML tree recursively -->
  <xsl:template mode="mode-iso19139.nl.services.2.0.0" match="*|@*">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="mode-iso19139"
                match="srv:operatesOn[(1 or @gn:addedObj = 'true') and $isFlatMode]"
                priority="4001">

    <xsl:variable name="name"
                  select="name()"/>
    <xsl:variable name="xpath"
                  select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType"
                  select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="isEmbeddedMode"
                  select="@gn:addedObj = 'true'"/>
    <xsl:variable name="isFirstOfItsKind"
                  select="preceding-sibling::*[1]/name() != $name"/>
    <xsl:variable name="values">
      <xsl:if test="not($isEmbeddedMode) or ($isEmbeddedMode and $isFirstOfItsKind)">
        <header>
          <col>
            <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'xlink:href', $labels, '', $isoType, $xpath)/label"/>
          </col>
        </header>
      </xsl:if>
      <xsl:for-each select="(.|following-sibling::*[name() = $name])">
        <row>
          <col type="text" name="{concat('_', gn:element/@ref, '_xlinkCOLONhref')}">
            <value><xsl:value-of select="@xlink:href"/></value>
          </col>
          <col remove="true">
            <xsl:copy-of select="gn:element"/>
          </col>
        </row>
      </xsl:for-each>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$isEmbeddedMode and not($isFirstOfItsKind)">
        <xsl:call-template name="render-table">
          <xsl:with-param name="values" select="$values"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>

        <xsl:call-template name="render-boxed-element">
          <xsl:with-param name="label"
                          select="gn-fn-metadata:getLabel($schema, $name, $labels, $name, $isoType, $xpath)/label"/>
          <xsl:with-param name="cls" select="local-name()"/>
          <xsl:with-param name="subTreeSnippet">

            <xsl:call-template name="render-table">
              <xsl:with-param name="values" select="$values"/>
            </xsl:call-template>

          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="mode-iso19139"
                match="srv:operatesOn[
                        preceding-sibling::*[1]/name() = name() and
                        not(@gn:addedObj) and
                        $isFlatMode]"
                priority="4001"/>

</xsl:stylesheet>
