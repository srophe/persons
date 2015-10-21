<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" />
    <xsl:template match="/report" xpath-default-namespace="http://www.oxygenxml.com/ns/report">
        <xsl:variable name="all-authors" select="//author"/>
        <xsl:variable name="all-author-names" as="xs:string*">
            <xsl:for-each select="$all-authors">
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($all-author-names)">
            <xsl:variable name="author-name" select="."/>
            <author>
                <!-- elements version -->
                <!--<xsl:for-each select="$all-authors[.=$author-name]">
                    <source><xsl:value-of select="@source"/></source>
                </xsl:for-each>-->
                <!-- attributes version -->
                <xsl:attribute name="source">
                        <xsl:for-each select="$all-authors[.=$author-name]">
                            <xsl:value-of select="concat(@source,' ')"/>
                        </xsl:for-each>
                    </xsl:attribute>
                <!--<persName>-->
                    <xsl:attribute name="xml:lang" select="'fr'"/>
                    <xsl:value-of select="$author-name"/>
                <!--</persName>-->
            </author>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>