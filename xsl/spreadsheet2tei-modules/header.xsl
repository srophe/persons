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
            <xd:p>This stylesheet contains template(s) for creating the header element, with its children, for 
            person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <!-- Correct link to manual? -->
            <xd:p>Creates a TEI header, according to the specifications of the TEI Header Manual for Syriaca.org.</xd:p>
        </xd:desc>
        <xd:param name="record-id">The record ID of the person record</xd:param>
        <xd:param name="bib-ids">A sequence of @xml:id attribute values for bibl elements, contained as the content of elements 
            which have as names the column name of a column coming from that source. For example, $bib-ids may contain the following: 
            &lt;GEDSH_en-Full&gt;bibl1-1&lt;/GEDSH_en-Full&gt;</xd:param>
    </xd:doc>
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="bib-ids"/>
        
        <xsl:variable name="english-headword">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(GS_en-Full)) != 0"><xsl:value-of select="GS_en-Full"/></xsl:when>
                <xsl:when test="string-length(normalize-space(GEDSH_en-Full)) != 0"><xsl:value-of select="GEDSH_en-Full"/></xsl:when>
                <xsl:otherwise>Person <xsl:value-of select="$record-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="syriac-headword">
            <xsl:choose>
                <xsl:when test="compare(Authorized_syr-Source,'Other') = 0"><xsl:value-of select="Authorized_syr-NV_Full"/></xsl:when>
                <xsl:when test="compare(Authorized_syr-Source,'Abdisho') = 0"><xsl:value-of select="Abdisho_YdQ_syr-NV_Full"/></xsl:when>
                <xsl:when test="compare(Authorized_syr-Source,'Barsoum') = 0"><xsl:value-of select="Barsoum_syr-NV_Full"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="record-title">
            <xsl:value-of select="$english-headword"/>
            <xsl:if test="string-length($syriac-headword)"> — <foreign xml:lang="syr"><xsl:value-of select="$syriac-headword"/></foreign></xsl:if>
        </xsl:variable>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title level="a" xml:lang="en"><xsl:copy-of select="$record-title"/></title>
                    <title level="m" xml:lang="en">The Syriac Prosopography</title>
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The Andrew W. Mellon Foundation</funder>
                    <funder>The National Endowment for the Humanities</funder>
                    <funder>The International Balzan Prize Foundation</funder>
                    <principal>David A. Michelson</principal>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P. Gibson</editor>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A. Carlson</editor>
                    <xsl:if test=" number($record-id) &lt; 839 and (string-length(normalize-space(GEDSH_en-Full)) != 0 or string-length(normalize-space(Barsoum_en-Full)) != 0 or string-length(normalize-space(Barsoum_syr-NV_Full)) != 0)">
                        <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#jwalters">James E. Walters</editor>
                    </xsl:if>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A. Carlson</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P. Gibson</editor>
                    <respStmt>
                        <resp>Editing, document design, proofreading, data entry by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Matching with viaf.org records, data entry, data transformation, conversion to XML by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P. Gibson</name>
                    </respStmt>
                    <xsl:if test="number($record-id) &lt; 839 and (string-length(normalize-space(GEDSH_en-Full)) != 0 or string-length(normalize-space(Barsoum_en-Full)) != 0 or string-length(normalize-space(Barsoum_syr-NV_Full)) != 0)">
                        <respStmt>
                            <resp>GEDSH and Barsoum English name entry, matching with viaf.org records by</resp>
                            <name type="person" ref="http://syriaca.org/documentation/editors.xml#jwalters">James E. Walters</name>
                        </respStmt>
                    </xsl:if>
                    <respStmt>
                        <resp>Editing, <xsl:if test="string-length(normalize-space(Abdisho_YdQ_syr-NV_Full)) != 0 or (number($record-id) &gt; 305 and string-length(normalize-space(Barsoum_syr-NV_Full)) != 0)">Syriac name entry, </xsl:if>
                            <xsl:if test="Barsoum_Ar_Entered = 'TAC'">Arabic name entry, </xsl:if>disambiguation research, conversion to XML by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A. Carlson</name>
                    </respStmt>
                    <xsl:if test="number($record-id) &lt; 306 and string-length(normalize-space(Barsoum_syr-NV_Full)) != 0">
                        <respStmt>
                            <resp>Syriac name entry by</resp>
                            <name type="person" ref="http://syriaca.org/documentation/editors.xml#raydin">Robert Aydin</name>
                        </respStmt>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space(Barsoum_ar-Full)) != 0">
                        <xsl:choose>
                            <xsl:when test="Barsoum_Ar_Entered = 'JK'">
                                <respStmt>
                                    <resp>Arabic name entry by</resp>
                                    <name type="person" ref="http://syriaca.org/documentation/editors.xml#jkaado">Jad Kaado</name>
                                </respStmt>
                            </xsl:when>
                            <xsl:when test="string-length(normalize-space(Barsoum_Ar_Entered)) = 0">
                                <respStmt>
                                    <resp>Arabic name entry by</resp>
                                    <name type="person" ref="http://syriaca.org/documentation/editors.xml#pkirlles">Philemon Kirlles</name>
                                </respStmt>            
                            </xsl:when>
                            <!-- TAC case covered above -->
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space(GEDSH_en-Full)) != 0">
                        <respStmt>
                            <resp>Normalization of GEDSH dates and entry matching with viaf.org records by</resp>
                            <name type="person" ref="http://syriaca.org/documentation/editors.xml#avawter">Alex Vawter</name>
                        </respStmt>    
                    </xsl:if>
                    <xsl:if test="number($record-id) &lt; 839 and (string-length(normalize-space(GEDSH_en-Full)) != 0 or string-length(normalize-space(Barsoum_en-Full)) != 0)">
                        <respStmt>
                            <resp>Editorial oversight for GEDSH and Barsoum English text entry, and proofreading by</resp>
                            <name type="person" ref="http://syriaca.org/documentation/editors.xml#cjohnson">Christopher Johnson</name>
                        </respStmt>
                        <respStmt>
                            <resp>GEDSH and Barsoum English text entry and proofreading by</resp>
                            <name type="org" ref="http://syriaca.org/documentation/editors.xml#uasyriacresearchgroup">the Syriac Research Group, University of Alabama</name>
                        </respStmt>    
                    </xsl:if>
                    
                    <!-- Should anybody from VIAF or ISAW be added here? -->
                        
                </titleStmt>
                <editionStmt>
                    <edition n="1.0"/>
                </editionStmt>
                <publicationStmt>
                    <authority>Syriaca.org: The Syriac Reference Portal</authority>
                    <idno type="URI">http://syriaca.org/person/<xsl:value-of select="$record-id"/>/tei</idno>
                    <availability>
                        <licence target="http://creativecommons.org/licenses/by/3.0/">
                            <p>Distributed under a Creative Commons Attribution 3.0 Unported License.</p>
                            <xsl:if test="*[matches(name(),'Barsoum_syr|Barsoum_ar') and string-length(normalize-space(node()))]">
                                <p>This entry incorporates copyrighted material from the following work(s):
                                    <listBibl>
                                        <xsl:if test="*[matches(name(),'Barsoum_syr') and string-length(normalize-space(node()))]">
                                            <bibl>
                                                <ptr>
                                                    <xsl:attribute name="target" select="concat('#', $bib-ids/*[contains(name(), 'Barsoum_syr')][1])"/>
                                                </ptr>
                                            </bibl>
                                        </xsl:if>
                                        <xsl:if test="*[matches(name(),'Barsoum_ar') and string-length(normalize-space(node()))]">
                                            <bibl>
                                                <ptr>
                                                    <xsl:attribute name="target" select="concat('#', $bib-ids/*[contains(name(), 'Barsoum_ar')][1])"/>
                                                </ptr>
                                            </bibl>
                                        </xsl:if>
                                    </listBibl>
                                    <note>used under a Creative Commons Attribution license <ref target="http://creativecommons.org/licenses/by/3.0/"/></note>
                                </p>
                            </xsl:if>
                        </licence>
                    </availability>
                    <date>
                        <xsl:value-of select="current-date()"/>
                    </date>
                </publicationStmt>
                <sourceDesc>
                    <p>Born digital.</p>
                </sourceDesc>
            </fileDesc>
            <encodingDesc>
                <editorialDecl>
                    <p>This record created following the Syriaca.org guidelines. 
                        Documentation available at: <ref target="http://syriaca.org/documentation">http://syriaca.org/documentation</ref>.</p>
                    <interpretation>
                        <p>Approximate dates described in terms of centuries or partial centuries
                            have been interpreted as documented in 
                            <ref target="http://syriaca.org/documentation/dates.html">Syriaca.org Dates</ref>.</p>
                    </interpretation>
                    <!-- Are there other editorial decisions we need to record here? -->
                </editorialDecl>
                <classDecl>
                    <taxonomy>
                        <category xml:id="syriaca-headword">
                            <catDesc>The name used by Syriaca.org for document titles, citation, and disambiguation. 
                                These names have been created according to the Syriac.org guidelines for headwords: 
                                <ref target="http://syriaca.org/documentation/headwords.html">http://syriaca.org/documentation/headwords.html</ref>.</catDesc>
                        </category>
                        <category xml:id="syriaca-anglicized">
                            <catDesc>An anglicized version of a name, included to facilitate searching.</catDesc>
                        </category>
                    </taxonomy>
                    <taxonomy>
                        <category xml:id="syriaca-author">
                            <catDesc>A person who is relevant to the Guide to Syriac Authors</catDesc>
                        </category>
                        <category xml:id="syriaca-saint">
                            <catDesc>A person who is relevant to the Bibliotheca Hagiographica Syriaca.</catDesc>
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
                <change who="http://syriaca.org/documentation/editors.xml#tcarlson" n="1.0">
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