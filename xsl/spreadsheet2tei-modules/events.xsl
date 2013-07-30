<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 2, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nathan Gibson</xd:p>
            <xd:p>This stylesheet contains templates for processing birth, death, floruit, event and other date-related elements 
            for person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Cycles through types of events to create only a single <gi>birth</gi> or <gi>death</gi> event.</xd:p>
        </xd:desc>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
        <xd:param name="event-columns">The various columns which have dates for events.</xd:param>
    </xd:doc>
    <xsl:template name="personal-events">
        <xsl:param name="bib-ids"/>
        <xsl:param name="event-columns"/>
        
        <!-- Create a birth element if the data exists for one -->
        <xsl:if test="$event-columns[contains(name(),'DOB') and string-length(normalize-space(node()))]">
            <xsl:for-each select="$event-columns[contains(name(),'DOB') and string-length(normalize-space(node()))][1]"> <!-- wrapping it in for-each is an awful hack to make the context work in the called template -->
            <xsl:call-template name="event-element">
                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                <xsl:with-param name="column-name" select="name(.)"/>
            </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Create a death element if the data exists for one -->
        <xsl:if test="$event-columns[contains(name(),'DOD') and string-length(normalize-space(node()))]">
            <xsl:for-each select="$event-columns[contains(name(),'DOD') and string-length(normalize-space(node()))][1]"> <!-- wrapping it in for-each is an awful hack to make the context work in the called template -->
                <xsl:call-template name="event-element">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                    <xsl:with-param name="column-name" select="name(.)"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Create a floruit element if the data exists for one -->
        <xsl:if test="$event-columns[contains(name(),'Floruit') and string-length(normalize-space(node()))]">
            <xsl:for-each select="$event-columns[contains(name(),'Floruit') and string-length(normalize-space(node()))][1]"> <!-- wrapping it in for-each is an awful hack to make the context work in the called template -->
                <xsl:call-template name="event-element">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                    <xsl:with-param name="column-name" select="name(.)"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        
        <!-- <xsl:for-each 
            select="$event-columns[ends-with(name(),'Floruit')]">
            <xsl:call-template name="event-element">
                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                <xsl:with-param name="column-name" select="name(.)"/>
            </xsl:call-template>
        </xsl:for-each> -->
        <!-- Tests whether there are any columns with content that will be put into event elements (e.g., "Event"). 
                                        If so, creates a listEvent parent element to contain them. 
                                        Add to the if test and to the for-each the descriptors of any columns that should be put into event elements. -->
        <xsl:if test="exists(*[contains(name(), 'Event') and string-length(normalize-space(node()))])">
            <listEvent>
                <xsl:for-each 
                    select="$event-columns[ends-with(name(),'Event')]">
                    <xsl:call-template name="event-element">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="column-name" select="name(.)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </listEvent>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a birth, death, floruit, event, etc. element using the current column/context node as human-readable content and 
            using machine-readable dates from other columns whose names include the current column's name. (E.g., the GEDSH_DOB 
            column contains human-readable content, whereas GEDSH_DOB_Standard, GEDSH_DOB_Not_Before, and GEDSH_DOB_Not_After are 
            machine-readable columns. If this template is called on GEDSH_DOB, the content of the created element will be the content of
            GEDSH_DOB, while GEDSH_DOB_Standard, GEDSH_DOB_Not_Before, and GEDSH_DOB_Not_After will be automatically detected and 
            their contents added as machine-readable attributes.)</xd:p>
        </xd:desc>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
        <xd:param name="column-name">The name of the column being processed (must be specified when template is called).</xd:param>
        <xd:param name="element-name">The name of the TEI element to be created, determined from the $column-name.</xd:param>
    </xd:doc>
    <xsl:template name="event-element" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <xsl:param name="column-name" select="name()"/>
        <xsl:param name="element-name">
            <!-- Names of date-related elements to be created go here. -->
            <xsl:choose>
                <xsl:when test="contains($column-name, 'Floruit')">floruit</xsl:when>
                <xsl:when test="contains($column-name, 'DOB')">birth</xsl:when>
                <xsl:when test="contains($column-name, 'DOD')">death</xsl:when>
                <xsl:when test="contains($column-name, 'Event')">event</xsl:when>
            </xsl:choose>
        </xsl:param>
        
        <!-- If the current column has content or a related column has content, adds the element with the name specified by $element-name. -->
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
                    <xsl:with-param name="column-name" select="name(.)"/>
                </xsl:call-template>
                
                <!-- Adds custom type and, if relevant, human-readable date as content of element
                Any additional custom types should go here.-->
                <xsl:choose>
                    <xsl:when test="contains(name(), 'Event')">
                        <xsl:attribute name="type" select="'event'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>This template cycles through date columns, adding machine-readable date attributes to an element, based on 
                text strings contained in the source XML element's name.
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