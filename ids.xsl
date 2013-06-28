<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    
    <xd:doc>
        <xd:desc>
            <xd:p>Cycles through all the columns provided in the <xd:ref name="sourced-columns" type="parameter">sourced-columns param</xd:ref>, 
                assigning each a number that will be used as the part of an @xml:id that should be different for columns from different sources. 
                Vocalized and non-vocalized versions of full-names from the same source are given "a" and "b" suffixes.</xd:p>
        </xd:desc>
        <xd:param name="sourced-columns">All columns representing distinct sources (including vocalized/non-vocalized versions of columns from the same source)</xd:param>
        <xd:param name="count">A counter to cycle through all the columns in <xd:ref name="sourced-columns" type="parameter">sourced-columns</xd:ref></xd:param>
        <xd:param name="same-source-adjustment">Contains a number adjusting for the fact that vocalized and non-vocalized versions of names from the same source have the same number (but an added suffix).</xd:param>
        <xd:param name="next-column-name">Gets the name of the next column to be processed out of the group of columns in <xd:ref name="sourced-columns" type="parameter">sourced-columns</xd:ref></xd:param>
    </xd:doc>
    <xsl:template name="ids-base">
        <xsl:param name="sourced-columns"/>
        <xsl:param name="count"/>
        <xsl:param name="same-source-adjustment"/>
        <xsl:param name="next-column-name" select="name($sourced-columns/*[$count])"/>
        <xsl:if test="$next-column-name">
            <xsl:element name="{$next-column-name}">
                <xsl:value-of select="$count - $same-source-adjustment"/>
                <xsl:choose>
                    <xsl:when test="matches($next-column-name, '(_|-)NV_')">a</xsl:when>
                    <xsl:when test="matches($next-column-name, '(_|-)V_')">b</xsl:when>
                </xsl:choose>
            </xsl:element>
            <xsl:call-template name="ids-base">
                <xsl:with-param name="sourced-columns" select="$sourced-columns"/>
                <xsl:with-param name="count" select="$count + 1"/>
                <xsl:with-param name="same-source-adjustment">
                    <xsl:choose>
                        <!-- This test assumes non-vocalized and vocalized columns coming from the same source do not have any intervening columns containing full names from a different source -->
                        <xsl:when test="matches(replace($next-column-name, '(_|-)NV_|(_|-)V_', ''), replace(name($sourced-columns/*[$count + 1]), '(_|-)NV_|(_|-)V_', ''))"><xsl:value-of select="$same-source-adjustment + 1"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="$same-source-adjustment"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template creates a sequence of @xml:id attribute values for bibl elements, in the format "bib10-5", 
                in which "10" is the record ID of the person record and "5" is a numerical value corresponding to the source 
                and derived from <xd:ref name="ids-base" type="parameter">ids-base</xd:ref>. However, whereas 
                <xd:ref name="ids-base" type="parameter">ids-base</xd:ref> includes "a" or "b" to distinguish vocalized and 
                non-vocalized versions of content, bib-ids removes the "a" or "b". The @xml:id values are contained inside 
                nodes which are named the same as their corresponding <xd:ref name="sourced-columns" type="parameter">sourced-columns param</xd:ref>.</xd:p>
        </xd:desc>
        <xd:param name="sourced-columns">All columns representing distinct sources (including vocalized/non-vocalized versions of columns from the same source)</xd:param>
        <xd:param name="record-id">The record ID of the person record</xd:param>
        <xd:param name="ids-base">A sequence containing the part of the IDs that are distinct for columns coming from different sources</xd:param>
    </xd:doc>
    <xsl:template name="bib-ids">
        <xsl:param name="sourced-columns"/>
        <xsl:param name="record-id"/>
        <xsl:param name="ids-base"/>
        <xsl:for-each select="$sourced-columns/*">
            <xsl:variable name="name" select="name()"/>
            <xsl:element name="{name()}">
                <xsl:value-of
                    select="concat('bib', $record-id, '-', replace($ids-base/*[contains(name(), $name)], 'a|b', ''))"
                />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>