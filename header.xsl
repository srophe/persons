<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    
    <xd:doc>
        <xd:desc>
            <!-- Correct link to manual? -->
            <xd:p>Creates a TEI header, according to the specifications of the Syriaca TEI Manual.</xd:p>
        </xd:desc>
        <xd:param name="record-id">The record ID of the person record</xd:param>
        <xd:param name="record-title">The value to be used as the title of the record</xd:param>
    </xd:doc>
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="record-title">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(../Calculated_Name))">
                    <xsl:value-of select="../Calculated_Name"/>
                </xsl:when>
                <xsl:otherwise>Person <xsl:value-of select="$record-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title xml:lang="en"><xsl:value-of select="$record-title"/></title>
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The Andrew W. Mellon Foundation</funder>
                    <funder>The National Endowment for the Humanities</funder>
                    <funder>The International Balzan Prize Foundation</funder>
                    <principal>
                        <name ref="http://syriaca.org/editors.xml#dmichelson">David A. Michelson</name>
                    </principal>
                    <!-- Need to adapt this to reflect the following:
                    List Thomas and Nathan as "creator" on Abdisho records.
                    List Jamey, Nathan and Dave as "creator" on non-Abdisho persons. 
                    General-Eds: DM, Nathan, Thomas?-->
                    <editor role="general-editor">
                       <name ref="http://syriaca.org/editors.xml#dmichelson">David A. Michelson</name>
                    </editor>
                    <editor role="general-editor">
                        <name ref="http://syriaca.org/editors.xml#ngibson">Nathan P. Gibson</name>
                    </editor>
                    <editor role="general-editor">
                        <name type="person" ref="http://syriaca.org/editors.xml#tcarlson">Thomas A. Carlson</name>
                    </editor>
                    <editor role="creator">
                        <name ref="http://syriaca.org/editors.xml#dmichelson">David A. Michelson</name>
                    </editor>
                    <editor role="creator">
                        <name ref="http://syriaca.org/editors.xml#jwalters">James E. Walters</name>
                    </editor>
                    <editor role="creator">
                        <name type="person" ref="http://syriaca.org/editors.xml#tcarlson">Thomas A. Carlson</name>
                    </editor>
                    <editor role="creator">
                        <name ref="http://syriaca.org/editors.xml#ngibson">Nathan P. Gibson</name>
                    </editor>
                    <respStmt>
                       <resp>Editing, document design, proofreading, data entry by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#dmichelson">David A. Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Editing, proofreading, data entry by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#jnsaint-laurent">Jeanne-Nicole Saint-Laurent</name>
                    </respStmt>
                    <respStmt>
                        <resp>English name entry, matching with viaf.org records by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#jwalters">James E. Walters</name>
                    </respStmt>
                    <respStmt>
                        <resp>Matching with viaf.org records, data entry, data transformation, conversion to XML by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#ngibson">Nathan P. Gibson</name>
                    </respStmt>
                    <respStmt>
                        <resp>editing, Syriac name entry, disambiguation research by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#tcarlson">Thomas A. Carlson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Syriac name entry by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#raydin">Robert Aydin</name>
                    </respStmt>
                    <respStmt>
                        <resp>Arabic name entry by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#pkirlles">Philemon Kirlles</name>
                    </respStmt>
                    <respStmt>
                        <resp>Arabic name entry by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#jkaado">Jad Kaado</name>
                    </respStmt>
                    <respStmt>
                        <resp>Normalization, matching with viaf.org records by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#avawter">Alex Vawter</name>
                    </respStmt>
                    <respStmt>
                        <resp>Date entry by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#rsingh-bischofberger">Ralf Singh-Bischofberger</name>
                    </respStmt>
                    <respStmt>
                        <resp>Project managament, english text entry, and proofreading by</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#cjohnson">Christopher Johnson</name>
                    </respStmt>
                    <respStmt>
                        <resp>English text entry and proofreading by</resp>
                        <name type="org" ref="http://syriaca.org/editors.xml#uasyriacresearchgroup">the Syriac Research Group, University of Alabama</name>
                    </respStmt>
                    <!-- Should anybody from VIAF or ISAW be added here? -->
                </titleStmt>
                <editionStmt>
                    <edition n="1.0"/>
                </editionStmt>
                <publicationStmt>
                    <authority>Syriaca.org: The Syriac Reference Portal</authority>
                    <idno type="URI">http://syriaca.org/person/<xsl:value-of select="$record-id"
                        />/source</idno>
                    <availability>
                        <licence target="http://creativecommons.org/licenses/by/3.0/"> Distributed
                            under a Creative Commons Attribution 3.0 Unported License </licence>
                    </availability>
                    <!-- Is this the publication date for the entire data set or this record? Is the date is was converted to XML good enough? -->
                    <date>
                        <xsl:value-of select="current-date()"/>
                    </date>
                </publicationStmt>
                <sourceDesc>
                    <p>Born digital.</p>
                </sourceDesc>
            </fileDesc>
            <encodingDesc>
                <p>This record created following the Syriaca.org guidelines. Documentation available at: <ptr target="http://syriaca.org/documentation"/>.</p>
                <p>Headwords or names without source attributes may not be attested in extant sources. They are included only to aid the reader for the purpose of disambiguation. These names have been created according to the Syriac.org guidelines for headwords: <ptr target="http://syriaca.org/documentation/headwords"/>.</p>
                <editorialDecl>
                    <interpretation>
                        <p>Approximate dates described in terms of centuries or partial centuries
                            have been interpreted as in the following example: 
                            "4th cent." - notBefore="300" notAfter="399". 
                            "Early 4th cent." - notBefore="300" notAfter="349". 
                            "Late 4th cent." - notBefore="350" notAfter="399".
                            "Mid-4th cent." - notBefore="325" notAfter="374". 
                            Etc.</p>
                    </interpretation>
                    <!-- Are there other editorial decisions we need to record here? -->
                </editorialDecl>
                <classDecl>
                    <taxonomy>
                        <category xml:id="syriaca-headword">
                            <catDesc>The name used by Syriaca.org for document titles, citation, and disambiguation. 
                                While headwords are usually created from primary source citations, those without source attributes may not be attested in extant sources. 
                                They are included only to aid the reader for the purpose of disambiguation. 
                                These names have been created according to the Syriac.org guidelines for headwords: <ptr target="http://syriaca.org/documentation/headwords"/>.</catDesc>
                        </category>
                    </taxonomy>
                </classDecl>
            </encodingDesc>
            <profileDesc>
                <langUsage>
                    <language ident="syr">Unvocalized Syriac of any variety or period</language>
                    <language ident="syr-Syrj">Vocalized West Syriac</language>
                    <language ident="syr-Syrn">Vocalized East Syriac</language>
                    <language ident="en">English</language>
                    <language ident="en-x-gedsh">Names or terms Romanized into English according to the standards 
                        adopted by the Gorgias Encyclopedic Dictionary of the Syriac Heritage</language>
                    <language ident="ar">Arabic</language>
                    <language ident="fr">French</language>
                    <language ident="de">German</language>
                    <language ident="la">Latin</language>
                </langUsage>
            </profileDesc>
            <revisionDesc>
                <change who="http://syriaca.org/editors.xml#ngibson" n="1.0">
                    <xsl:attribute name="when" select="current-date()"/> CREATED: person </change>
                <xsl:if test="string-length(normalize-space(For_Post-Publication_Review))">
                    <change type="planned">
                        <xsl:value-of select="For_Post-Publication_Review"/>
                    </change>
                </xsl:if>
            </revisionDesc>
        </teiHeader>
    </xsl:template>
</xsl:stylesheet>