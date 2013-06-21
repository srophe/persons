<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xsl:template name="language" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="column-name" select="name()"/>
        <!-- If any other language codes are used in the input spreadsheet, add them below. -->
        <xsl:analyze-string select="name()" regex="_(syr|en|ar|de|fr|lat)-">
            <xsl:matching-substring>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="replace(replace(., '_', ''), '-', '')"/>
                    <!-- Adds script code to vocalized names. -->
                    <xsl:if test="matches($column-name, '(-|_)V_')">
                        <xsl:choose>
                            <xsl:when test="contains($column-name, 'Barsoum_syr-')">-Syrj</xsl:when>
                            <xsl:when test="contains($column-name, 'Abdisho')">-Syrn</xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="matches($column-name, 'GEDSH_en-|GS_en-')">-x-gedsh</xsl:if>
                </xsl:attribute>
            </xsl:matching-substring>
        </xsl:analyze-string>        
    </xsl:template>
</xsl:stylesheet>