<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:syriaca="http://syriaca.org">
    
    <!-- FORMAT OF COMMENTS -->
    <!-- ??? Indicates an issue that needs resolving. -->
    <!-- ALL CAPS is a section header. -->
    <!-- !!! Shows items that may need to be changed/customized when running this template on a new spreadsheet. -->
    <!-- lower case comments explain the code -->
    
    <!-- FILE OUTPUT PROCESSING -->
    <!-- specifies how the output file will look -->
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml"/>
    
    
    <xsl:template match="/root">
        <xsl:result-document href="../xml/ektobe-for-ner.xml" format="xml">
            <!-- adds the xml-model instruction with the link to the Syriaca.org validator -->
            <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="row">
                <person>
                    <xsl:if test="Syriaca_ID[matches(.,'[0-9]+')]">
                        <xsl:attribute name="ref">http://syriaca.org/person/<xsl:value-of select="Syriaca_ID"/></xsl:attribute>
                    </xsl:if>
                    <xsl:analyze-string select="Noms_" regex="(.*)\((.*)\)\s*$">
                        <xsl:matching-substring>
                            <persName xml:lang="fr"><xsl:value-of select="normalize-space(regex-group(1))"/></persName>
                            <floruit xml:lang="fr"><xsl:value-of select="regex-group(2)"/></floruit>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring><persName xml:lang="fr"><xsl:value-of select="normalize-space(.)"/></persName></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    <xsl:for-each select="tokenize(Formes_usuelles,',')">
                        <xsl:for-each select="tokenize(.,';')">
                            <xsl:analyze-string select="." regex="([̈\s܀-݊]+)|([A-Za-zÀ-žḀ-ỿ\-'\s]+)|([\s؀-ۿ]+)">
                                <xsl:matching-substring>
                                    <xsl:variable name="syr-name" select="normalize-space(regex-group(1))"/>
                                    <xsl:variable name="fr-name" select="normalize-space(regex-group(2))"/>
                                    <xsl:variable name="ar-name" select="normalize-space(regex-group(3))"/>
                                    <xsl:if test="$syr-name"><persName xml:lang="syr"><xsl:value-of select="$syr-name"/></persName></xsl:if>
                                    <xsl:if test="$fr-name"><persName xml:lang="fr"><xsl:value-of select="$fr-name"/></persName></xsl:if>
                                    <xsl:if test="$ar-name"><persName xml:lang="ar"><xsl:value-of select="$ar-name"/></persName></xsl:if>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:if test=".">
                                        <persName type="other" xml:lang="fr"><xsl:value-of select="normalize-space(.)"/></persName>
                                    </xsl:if>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:for-each>
                    </xsl:for-each>
                    <xsl:if test="Rôles">
                        <note type="eKtobe-roles"><xsl:value-of select="Rôles"/></note>
                    </xsl:if>
                    <xsl:if test="Remarks_for_SYRIACA!=''">
                        <note type="eKtobe-notes-for-syriaca"><xsl:value-of select="Remarks_for_SYRIACA"/></note>
                    </xsl:if>
                    <xsl:if test="Remarks_for_eKtobe!=''">
                        <note type="syriaca-notes-for-eKtobe"><xsl:value-of select="Remarks_for_eKtobe"/></note>
                    </xsl:if>
                </person>
            </xsl:for-each>
            </TEI>
        </xsl:result-document>
    </xsl:template>
    
    
</xsl:stylesheet>