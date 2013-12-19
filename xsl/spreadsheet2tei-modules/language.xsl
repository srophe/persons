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
            <xd:p>This stylesheet contains elements for adding @xml:lang tags to elements in a person record.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template uses information from the column name to create a @xml:lang attribute on an element. 
                It determines from the $column-name which language code should be used in the attribute.</xd:p>
        </xd:desc>
        <xd:param name="column-name">Defaults to the name of the context node/current column, but you can override this 
        by specifying something else to use as the $column-name. 
        The column name is expected to contain a two- or three-letter language code preceded by an underscore and followed by a 
        hyphen.</xd:param>
    </xd:doc>
    <xsl:template name="language" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="column-name" select="name()"/>
        <!-- If any other language codes are used in the input spreadsheet, add them below. -->
        <xsl:analyze-string select="$column-name" regex="_(syr|en|ar|de|fr|lat)-">
            <xsl:matching-substring>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="replace(replace(., '_', ''), '-', '')"/>
                    <!-- Adds script code to vocalized names. -->
                    <xsl:if test="matches($column-name, '(-|_)V_')">
                        <xsl:choose>
                            <!-- Source-specific specifications for whether vocalized Syriac is West or East go here. -->
                            <xsl:when test="contains($column-name, 'Barsoum_syr-')">-Syrj</xsl:when>
                            <xsl:when test="contains($column-name, 'Abdisho_YdQ')">-Syrn</xsl:when>
                            <xsl:when test="contains($column-name, 'Abdisho_BO')">-Syrj</xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="matches($column-name, 'GEDSH_en-|GS_en-')">-x-gedsh</xsl:if>
                </xsl:attribute>
            </xsl:matching-substring>
        </xsl:analyze-string>        
    </xsl:template>
</xsl:stylesheet>