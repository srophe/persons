<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 27, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> nathan</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This variable contains a list of roles the stylesheet can use to automatically create roleName elements 
                and state elements. Each element name in the variable corresponds to the @type attribute that should be 
            assigned to the roleName or state, while the content of each element is the text to be automatically matched 
            (not case-sensitive). (Should element content also be used in some machine-readable way, such as @syriaca-tags?)
            </xd:p>
            <xd:p>Since the @roleName type will reflect the first match in the list below, the list should be prioritized.</xd:p>
            <xd:p>This variable can be replaced or pointed to an xml document containing this info.</xd:p>
            <xd:p>This list needs more development.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="roles">
        <office>bishop</office>
        <office>priest</office>
        <saint>saint</saint>
        <saint>martyr</saint>
    </xsl:variable>
    
    <!-- This doesn't work yet. -->
    <xsl:template name="state">
        <xsl:param name="all-titles"/>
        <xsl:param name="bib-ids"/>
        <xsl:for-each select="$all-titles">
            <xsl:variable name="column-name" select="name()"/>
            <xsl:variable name="column" select="."/>
            <xsl:choose>
                <xsl:when test="exists($roles/*[matches($column, node())]) and matches(., ',\s')">
                    <xsl:for-each select="tokenize(., ',\s')">
                        <xsl:variable name="subcolumn" select="."/>
                        <xsl:if test="exists($roles/*[matches($subcolumn, node())])">
                            <xsl:call-template name="state-element">
                                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                <xsl:with-param name="column" select="."/>
                                <xsl:with-param name="column-name" select="$column-name"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="exists($roles/*[matches($column, node())])">
                    <xsl:call-template name="state-element">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="column" select="node()"/>
                        <xsl:with-param name="column-name" select="$column-name"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="state-element" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <xsl:param name="column"/>
        <xsl:param name="column-name"/>
        <state>
            <xsl:attribute name="type" select="name($roles/*[matches($column, node(), 'i')][1])"/>
            <xsl:attribute name="role" select="$roles/*[matches($column, node(), 'i')][1]"/>
            <!-- Should we include GEDSH reign as @when? -->
            <xsl:call-template name="source">
                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                <xsl:with-param name="column-name" select="$column-name"/>
            </xsl:call-template>
            <xsl:call-template name="language">
                <xsl:with-param name="column-name" select="$column-name"/>
            </xsl:call-template>
            <desc><xsl:value-of select="$column"/></desc>
        </state>
    </xsl:template>
</xsl:stylesheet>