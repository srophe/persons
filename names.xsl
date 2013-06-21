<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
      
    
    <xsl:template name="names" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name-ids"/>
        <xsl:param name="name-links"/>
        <xsl:param name="bib-ids"/>
        <xsl:param name="sort"/>
        <!-- Selects any non-empty fields ending with "_Full" or "-Full" (i.e., full names) -->
        <xsl:for-each
            select="*[matches(name(),'(_|-)Full') and string-length(normalize-space(node()))]">
            <persName>
                <!-- Adds xml:id attribute. -->
                <xsl:call-template name="perName-id">
                    <xsl:with-param name="name-ids" select="$name-ids"/>
                    <xsl:with-param name="name-links" select="$name-links"/>
                </xsl:call-template>
                <!-- Adds language attributes. -->
                <xsl:call-template name="language"/>
                <!-- Adds source attributes. -->
                <xsl:call-template name="source">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                </xsl:call-template>
                <!-- Shows which name forms are authorized. -->
                <!-- Need to test whether this properly overrides GEDSH with GS as headword. -->
                <xsl:if
                    test="contains(name(),'GS_en') or (contains(name(),'GEDSH') and not(string-length(normalize-space(*[contains(name(), 'GS_en')])))) or contains(name(),'Authorized_syr')">
                    <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                </xsl:if>
                <!--A variable to hold the first part of the column name, which must be the same for all name columns from that source. 
                                            E.g., "Barsoum_en" for the columns "Barsoum_en", "Barsoum_en-Given", etc.-->
                <xsl:variable name="group" select="replace(name(), '(_|-)Full', '')"/>
                <!-- Adds name parts -->
                <xsl:call-template name="name-parts">
                    <xsl:with-param name="name" select="."/>
                    <xsl:with-param name="count" select="1"/>
                    <xsl:with-param name="all-name-parts"
                        select="following-sibling::*[contains(name(), $group)]"/>
                    <xsl:with-param name="sort" select="$sort"/>
                </xsl:call-template>
            </persName>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="perName-id" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name-ids"/>
        <xsl:param name="name-links"/>
        <xsl:param name="current-column-name" select="name()"/>
        
        <xsl:attribute name="xml:id" select="$name-ids/*[contains(name(), $current-column-name)]"/>
        <!-- Gets all other name links whose column names start with the same word (e.g., "Barsoum", "Abdisho").
        Requires that names that should be parallel have column names starting with same word (before underscore)
        and that names that should not be parallel do not.-->
        <!-- Is it OK that vocalized and non-vocalized names from different editions are parallel to each other or should I weed these out? -->
        <xsl:if test="exists($name-links/*[matches(substring-before($current-column-name, '_'), substring-before(name(), '_')) and not(contains(name(), $current-column-name))])">
            <xsl:attribute name="corresp" select="$name-links/*[matches(substring-before($current-column-name, '_'), substring-before(name(), '_')) and not(contains(name(), $current-column-name))]"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Cycles through the fields containing the individual parts of a name, creating and populating the appropriate TEI name fields.
                Name fields using this template should end in one of the following:
                <xd:ul>
                    <xd:li>_Given</xd:li>
                    <xd:li>_Family</xd:li>
                    <xd:li>_Titles</xd:li>
                    <xd:li>_Office</xd:li>
                    <xd:li>_Saint_Title</xd:li>
                    <xd:li>_Numeric_Title</xd:li>
                    <xd:li>_Terms_of_Address</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="group">Field name without the name part on the end (e.g., "GEDSH" is group for "GEDSH_en-Given"). Used to make sure this template loop doesn't proceed to a different set of fields.</xd:param>
        <xd:param name="same-group">Boolean to test whether the next element is in the same group/fieldset.</xd:param>
        <xd:param name="next-element-name">The name of the next element being processed, which is the element immediately following in the source XML.</xd:param>
        <xd:param name="next-element">Content of the next element being processed, which is the element immediately following in the source XML.</xd:param>
        <xd:param name="count">A counter to use for determining the next element to process.</xd:param>
        <xd:param name="sort">Contains the name of the TEI name part element that should be used first in alphabetical lists.</xd:param>
    </xd:doc>
    <xsl:template name="name-parts" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name"/>
        <xsl:param name="count"/>
        <xsl:param name="all-name-parts"/>
        <xsl:param name="sort"/>
        <xsl:param name="next-column" select="$all-name-parts[$count]"/>
        <xsl:param name="next-column-name" select="name($all-name-parts[$count])"/>
        <xsl:choose>
            <xsl:when test="count($all-name-parts)">
                <xsl:variable name="name-element-name">
                    <xsl:choose>
                        <xsl:when test="matches($next-column-name,'(_|-)Given')">forename</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Family')">addName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Titles') or matches($next-column-name,'(_|-)Saint_Title') or matches($next-column-name,'(_|-)Terms_of_Address')">addName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Office')">roleName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Numeric_Title')">genName</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <!-- Might be able to machine-generate title types based on content (e.g., "bishop," "III", etc.) -->
                <xsl:variable name="name-element-type">
                    <xsl:choose>
                        <xsl:when test="matches($next-column-name,'(_|-)Family')">family</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Titles')">untagged-title</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Saint_Title')">saint-title</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Terms_of_Address')">terms-of-address</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Office')">office</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Numeric_Title')">numeric-title</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($next-column, ', ') or contains($next-column, '، ')">
                        <xsl:call-template name="name-parts">
                            <xsl:with-param name="name">
                                <xsl:call-template name="name-part-comma-separated">
                                    <xsl:with-param name="name" select="$name"/>
                                    <xsl:with-param name="count" select="1"/>
                                    <!-- The token for splitting comma-separated values doesn't work well for commas inside parentheses. (See SRP 224) -->
                                    <xsl:with-param name="all-name-parts" select="tokenize($next-column, ',\s|،\s')"/>
                                    <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                    <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:with-param>
                            <xsl:with-param name="count" select="$count + 1"/>
                            <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                            <xsl:with-param name="sort" select="$sort"/>
                        </xsl:call-template>                    
                    </xsl:when>
                    <xsl:when test="string-length($next-column-name)">
                        <xsl:choose>
                            <xsl:when test="string-length($name-element-name) and string-length(normalize-space($next-column))">
                                <xsl:analyze-string select="$name" regex="{functx:escape-for-regex($next-column)}" flags="i">
                                    <xsl:matching-substring>
                                        <xsl:call-template name="name-part-element">
                                            <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                            <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                            <xsl:with-param name="sort" select="$sort"/>
                                        </xsl:call-template>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:call-template name="name-parts">
                                            <xsl:with-param name="name" select="."/>
                                            <xsl:with-param name="count" select="$count + 1"/>
                                            <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                                            <xsl:with-param name="sort" select="$sort"/>
                                        </xsl:call-template>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="name-parts">
                                    <xsl:with-param name="name" select="$name"/>
                                    <xsl:with-param name="count" select="$count + 1"/>
                                    <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="name-part-comma-separated" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name"/>
        <xsl:param name="count"/>
        <xsl:param name="all-name-parts"/>
        <xsl:param name="name-element-name"/>
        <xsl:param name="name-element-type"/>
        <xsl:param name="next-column" select="$all-name-parts[$count]"/>
        <xsl:param name="sort"/>
        <xsl:choose>
            <xsl:when test="count($all-name-parts) >= $count">
                <xsl:choose>
                    <xsl:when test="string-length($name-element-name) and string-length(normalize-space($next-column))">
                        <xsl:analyze-string select="$name" regex="{functx:escape-for-regex($next-column)}" flags="i">
                            <xsl:matching-substring>
                                <xsl:call-template name="name-part-element">
                                    <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                    <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:call-template name="name-part-comma-separated">
                                    <xsl:with-param name="name" select="."/>
                                    <xsl:with-param name="count" select="$count + 1"/>
                                    <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                                    <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                    <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="name-part-comma-separated">
                            <xsl:with-param name="name" select="$name"/>
                            <xsl:with-param name="count" select="$count + 1"/>
                            <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                            <xsl:with-param name="name-element-name" select="$name-element-name"/>
                            <xsl:with-param name="name-element-type" select="$name-element-type"/>
                            <xsl:with-param name="sort" select="$sort"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="name-part-element" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name-element-name"/>
        <xsl:param name="name-element-type"/>
        <xsl:param name="sort"/>
        <xsl:element name="{$name-element-name}">
            <xsl:if test="string-length($name-element-type)">
                <xsl:attribute name="type" select="$name-element-type"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space($sort))">
                <xsl:attribute name="sort">
                    <xsl:choose>
                        <xsl:when test="($name-element-name = 'forename') and ($sort = 'given')">1</xsl:when>
                        <xsl:when test="($name-element-name = 'addName')">
                            <xsl:choose>
                                <xsl:when test="($name-element-type = 'family') and ($sort = 'family')">1</xsl:when>
                                <xsl:when test="$sort = 'titles'">1</xsl:when>
                                <xsl:otherwise>2</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>2</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="."/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>