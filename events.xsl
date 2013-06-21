<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    
    <xsl:template name="events" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <xsl:param name="column-name" select="name()"/>
        <xsl:param name="element-name">
            <xsl:choose>
                <xsl:when test="contains($column-name, 'Floruit')">floruit</xsl:when>
                <xsl:when test="contains($column-name, 'DOB')">birth</xsl:when>
                <xsl:when test="contains($column-name, 'DOD')">death</xsl:when>
                <xsl:when test="contains($column-name, 'Reign')">event</xsl:when>
            </xsl:choose>
        </xsl:param>
        
        <xsl:if test="string-length(normalize-space(.)) or exists(following-sibling::*[contains(name(), $column-name) and string-length(normalize-space(node()))]) or exists(preceding-sibling::*[contains(name(), $column-name) and string-length(normalize-space(node()))])">
            <xsl:element name="{$element-name}">
                <!-- Adds machine-readable attributes to date. -->
                <xsl:call-template name="date-attributes">
                    <xsl:with-param name="date-type" select="replace(replace(name(), '_Begin', ''), '_End', '')"/>
                    <xsl:with-param name="next-element-name" select="name()"/>
                    <xsl:with-param name="next-element" select="node()"/>
                    <xsl:with-param name="count" select="0"/>
                </xsl:call-template>
        
                <!-- Adds source attributes. -->
                <xsl:call-template name="source">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                    <xsl:with-param name="column-name" select="substring-before(name(.), '-')"/>
                </xsl:call-template>
                
                <!-- Adds custom type and, if relevant, human-readable date as content of element
                Any additional custom types should go here.-->
                <xsl:choose>
                    <xsl:when test="contains(name(), 'Reign')">
                        <!-- Is "incumbency" or "term-of-office" better for this? -->
                        <xsl:attribute name="type" select="'reign'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>This template adds machine-readable date attributes to an element, based on text strings contained in the source XML element's name.
                <xd:ul>
                    <xd:li>_Begin_Standard --> @from</xd:li>
                    <xd:li>_End_Standard --> @to</xd:li>
                    <xd:li>_Standard --> @when</xd:li>
                    <xd:li>_Not_Before --> @notBefore</xd:li>
                    <xd:li>_Not_After --> @notAfter</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="date-type">Uses the name of the human-readable field, except in fields that have "_Begin" and "_End",
            which it replaces so that @from and @to attributes can be added to the same element. Fields should be named in such a way that machine-readable fields contain the name of the field that has human-readable date data. If the template is called and the <xd:ref name="next-element-name" type="parameter">next element name</xd:ref> does not contain this date-type, the template will be exited.</xd:param>
        <xd:param name="next-element-name">The name of the next element to be processed. This is used in combination with the <xd:ref name="count" type="parameter">count param</xd:ref> to cycle through the set of fields used to create an element with dates.</xd:param>
        <xd:param name="next-element">The content of the next element to be processed. This is used in combination with the <xd:ref name="count" type="parameter">count param</xd:ref> to cycle through the set of fields used to create an element with dates.</xd:param>
        <xd:param name="count">A counter to facilitate cycling through fields recursively.</xd:param>
    </xd:doc>
    <xsl:template name="date-attributes" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="date-type"/>
        <xsl:param name="next-element-name"/>
        <xsl:param name="next-element"/>
        <xsl:param name="count"/>
        <!-- Tests whether the beginning of the field name matches the name of the human-readable field. 
        For this to work, machine-readable date fields need to start with the field name of the corresponding human-readable field.
        For example, GEDSH_en-DOB and GEDSH_en-DOB_Standard -->
        <!-- What should be done if a _Begin field or an _End field have notBefore/notAfter attributes? -->
        <xsl:if test="contains($next-element-name, $date-type)">
            <xsl:if test="string-length(normalize-space($next-element))">
                <xsl:choose>
                    <xsl:when test="contains($next-element-name, '_Begin_Standard')">
                        <xsl:attribute name="from" select="$next-element"/>
                    </xsl:when>
                    <xsl:when test="contains($next-element-name, '_End_Standard')">
                        <xsl:attribute name="to" select="$next-element"/>
                    </xsl:when>
                    <xsl:when test="contains($next-element-name, '_Standard')">
                        <xsl:attribute name="when" select="$next-element"/>
                    </xsl:when>
                    <xsl:when test="contains($next-element-name, '_Not_Before')">
                        <xsl:attribute name="notBefore" select="$next-element"/>
                    </xsl:when>
                    <xsl:when test="contains($next-element-name, '_Not_After')">
                        <xsl:attribute name="notAfter" select="$next-element"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <xsl:call-template name="date-attributes">
                <xsl:with-param name="date-type" select="$date-type"/>
                <xsl:with-param name="next-element-name" select="name(following-sibling::*[$count + 1])"/>
                <xsl:with-param name="next-element" select="following-sibling::*[$count + 1]"/>
                <xsl:with-param name="count" select="$count + 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>