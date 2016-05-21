<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:syriaca="http://syriaca.org"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
        
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" />
    <xsl:variable name="n">
        <xsl:text></xsl:text>
    </xsl:variable>
    <xsl:variable name="s"><xsl:text> </xsl:text></xsl:variable>
    
    <xsl:function name="syriaca:normalizeYear" as="xs:string">
        <!-- The spreadsheet presents years normally, but datable attributes need 4-digit years -->
        <xsl:param name="year" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($year,'-')">
                <xsl:value-of select="concat('-',syriaca:normalizeYear(substring($year,2)))"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($year) &gt; 3">
                        <xsl:value-of select="$year"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="syriaca:normalizeYear(concat('0',$year))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="syriaca:custom-dates" as="xs:date">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="trim-date" select="normalize-space($date)"/>
        <xsl:choose>
            <xsl:when test="starts-with($trim-date,'0000') and string-length($trim-date) eq 4"><xsl:text>0001-01-01</xsl:text></xsl:when>
            <xsl:when test="string-length($trim-date) eq 4"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 5"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 5"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 7"><xsl:value-of select="concat($trim-date,'-01')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$trim-date"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/root">
        <!-- [not(starts-with(SRP_ID,'F'))] -->
        <xsl:for-each select="row">
            <xsl:variable name="record-id" select="position() + 221"/>
            
            <!-- Creates a variable containing the path of the file that should be created for this record. -->
            <xsl:variable name="filename" select="concat('works/',$record-id,'.xml')"/>

            <xsl:result-document href="{$filename}" format="xml">
                <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
                <TEI xml:lang="en" xmlns="http://www.tei-c.org/ns/1.0">
                    <!-- Adds header -->
                    <xsl:call-template name="header">
                        <xsl:with-param name="record-id" select="$record-id"/>
                    </xsl:call-template>
                    <text>
                        <body>
                            <listBibl>
                                <bibl>
                                    <xsl:attribute name="xml:id" select="concat('work-', $record-id)"/>
                                    <xsl:attribute name="ana" select="'#syriaca-saint'"/>
                                    
                                    <xsl:for-each select="Syriac_Name | Transcr. | Saint_French | Saint_English">
                                        <xsl:if test="not(empty(.))">
                                            <title xml:id="{concat('name', $record-id, '-',position())}"  xml:lang="{
                                                if(self::Transcr. or self::Saint_English) then 'en' 
                                                else if(self::Syriac_Name) then 'syr'
                                                else if(self::Saint_French) then 'fr'
                                                else ()}" source="#bib{$record-id}-1">
                                                <xsl:choose>
                                                    <xsl:when test="self::Transcr. or self::Syriac_Name">
                                                        <xsl:attribute name="syriaca-tags" namespace="">#syriaca-headword</xsl:attribute>
                                                    </xsl:when>
                                                </xsl:choose>
                                                <xsl:if test="self::Saint_French">[Histoire de] </xsl:if>
                                                <xsl:if test="self::Saint_English">[Story of] </xsl:if>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </title>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <xsl:if test="not(empty(Auct_FR))">
                                        <author xml:lang="fr" source="#bib1000-1">
                                            <xsl:value-of select="normalize-space(Auct_FR)"/>
                                        </author>
                                    </xsl:if>
                                    <xsl:if test="not(empty(A_ET_))">
                                        <author xml:lang="en" source="#bib1000-1">
                                            <xsl:value-of select="normalize-space(Auct_FR)"/>
                                        </author>
                                    </xsl:if>
                                    <!-- ID numbers -->
                                    <!-- Syriaca.org id -->
                                    <idno type="URI">http://syriaca.org/work/<xsl:value-of select="$record-id"/></idno>
                                </bibl>
                            </listBibl>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="bib-ids"/>
        
        <xsl:variable name="english-headword">
            <xsl:value-of select="concat('[Story of] ',normalize-space(Transcr.))"/>
        </xsl:variable>
        <xsl:variable name="syriac-headword">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(Syriac_Name)) != 0"><xsl:value-of select="Syriac_Name"/></xsl:when>
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
                    <title level="m">Qadishe: A Guide to the Lives of the Syriac Saints</title>
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The International Balzan Prize Foundation</funder>
                    <funder>The National Endowment for the Humanities</funder>
                    <principal>David A. Michelson</principal>
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole
                        Mellon Saint-Laurent</editor>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#dmichelson"
                        >David A. Michelson</editor>
                    <editor role="creator"
                        ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole
                        Mellon Saint-Laurent</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#uzanetti">Ugo Zanetti</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#cdetienne">Claude Detienne</editor>
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole
                            Mellon Saint-Laurent</name>
                    </respStmt>
                    <respStmt>
                        <resp>Data architecture and encoding by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dmichelson"
                            >David A. Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Editing, Syriac data conversion, data entry, and reconciling by</resp>
                        <name ref="http://syriaca.org/documentation/editors.xml#akane">Adam P. Kane</name>
                    </respStmt>
                    <respStmt>
                        <resp>Editing and Syriac data proofreading by</resp>
                        <name ref="http://syriaca.org/documentation/editors.xml#abarschabo">Aram Bar Schabo</name>
                    </respStmt>
                    <respStmt>
                        <resp>Entries adapted from the work of</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#uzanetti">Ugo Zanetti</name>
                    </respStmt>
                    <respStmt>
                        <resp>Entries adapted from the work of</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#cdetienne">Claude
                            Detienne</name>
                    </respStmt>
                </titleStmt>
                <editionStmt>
                    <edition n="1.0"/>
                </editionStmt>
                <publicationStmt>
                    <authority>Syriaca.org: The Syriac Reference Portal</authority>
                    <idno type="URI">http://syriaca.org/work/<xsl:value-of select="$record-id"/>/tei</idno>
                    <availability>
                        <licence target="http://creativecommons.org/licenses/by/3.0/">
                            <p>Distributed under a Creative Commons Attribution 3.0 Unported License.</p>
                                <p>This entry incorporates copyrighted material from the following work(s):
                                    <listBibl>    
                                        <bibl>
                                            <ptr target="http://syriaca.org/bibl/649"/>
                                        </bibl>
                                    </listBibl>
                                    <note>used under a Creative Commons Attribution license <ref target="http://creativecommons.org/licenses/by/3.0/"/></note>
                                </p>
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
                            <catDesc>The name used by Syriaca.org for document titles, citation, and
                                disambiguation. These names have been created according to the
                                Syriac.org guidelines for headwords: <ref
                                    target="http://syriaca.org/documentation/headwords.html"
                                    >http://syriaca.org/documentation/headwords.html</ref>.</catDesc>
                        </category>
                        <category xml:id="syriaca-anglicized">
                            <catDesc>An anglicized version of a name, included to facilitate
                                searching.</catDesc>
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
                <change who="http://syriaca.org/documentation/editors.xml#dmichelson" n="1.0">
                    <xsl:attribute name="when" select="current-date()"/>CREATED: work</change>
            </revisionDesc>
        </teiHeader>
    </xsl:template>
</xsl:stylesheet>