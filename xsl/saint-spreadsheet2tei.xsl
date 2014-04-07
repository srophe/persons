<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:syriaca="http://syriaca.org"
    xmlns="http://www.tei-c.org/ns/1.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" />
    
    <xsl:variable name="n">
        <xsl:text>
</xsl:text>
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
    
    <xsl:template match="/">
        <xsl:for-each select="//row[not(starts-with(SRP_ID,'F'))]">
            <xsl:variable name="filename" select="concat('../tei/saints/saint',SRP_Saint_ID,'eg.xml')"/>
            <xsl:result-document href="{$filename}" format="xml">
                <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$n"/>
                
                <!-- determine which sources will need to be cited; to be used in header formation as well -->
                <xsl:variable name="bib-prefix">bib<xsl:value-of select="SRP_Saint_ID"/>-</xsl:variable>
                <xsl:variable name="sources" as="xs:string*">
                    <xsl:if test="Fiey_ID[. != ''] or Raw_Fiey_Name != '' or Fiey_Name != '' or v_see_also_French != '' or Dates != '' or Locations != '' or Veneration_Date != '' or Bibliography != '' or Fiey_Related != ''">
                        <xsl:sequence select="('Fiey')"/>
                    </xsl:if>
                    <xsl:if test="Syr_Name != '' or Syr_Name_2 != '' or Syr_Name_3 != '' or Syr_Name_4 != '' or Zanetti_Transcr. != '' or Zan_Tran_2 != '' or Fr_Name_1 != '' or Fr_Name_2 != '' or Fr_Name_3 != '' or Fr_Name_4 != '' or Fr_Name_5 != '' or Zanetti_Numbers != '' or Z1_ != ''">
                        <xsl:sequence select="('Zanetti')"/>
                    </xsl:if>
                </xsl:variable>
                <!-- therefore the xml:id of the <bibl> element representing a source is $bib-prefix followed by the index of the source name in the $sources sequence -->
                <!-- and the citation format is #<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/> for Fiey, etc. -->
                
                <TEI
                    xml:lang="en"
                    xmlns:xi="http://www.w3.org/2001/XInclude"
                    xmlns:svg="http://www.w3.org/2000/svg"
                    xmlns:math="http://www.w3.org/1998/Math/MathML"
                    xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title level="a" xml:lang="en">Saint number <xsl:value-of select="SRP_Saint_ID"/></title>
                                <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                                <principal>Jeanne-Nicole Saint-Laurent</principal>
                                <editor role="general" ref="http://syriaca.org/editors.xml#jsaint-laurent">Jeanne-Nicole Saint-Laurent</editor>
                                <editor role="general" ref="http://syriaca.org/editors.xml#dmichelson">David A. Michelson</editor>
                                <editor role="creator" ref="http://syriaca.org/editors.xml#jsaint-laurent">Jeanne-Nicole Saint-Laurent</editor>
                                <editor role="creator" ref="http://syriaca.org/editors.xml#dmichelson">David A. Michelson</editor>
                                <editor role="creator" ref="http://syriaca.org/editors.xml#tcarlson">Thomas A. Carlson</editor>
                                <respStmt>
                                    <resp>Spreadsheet cleanup and database matching by</resp>
                                    <name>Adam Kane</name>
                                </respStmt>
                                <respStmt>
                                    <resp>Spreadsheet design by</resp>
                                    <name ref="http://syriaca.org/editors.xml#ngibson">Nathan P. Gibson</name>
                                </respStmt>
                            </titleStmt>
                            <editionStmt>
                                <edition n="1.0"/>
                            </editionStmt>
                            <publicationStmt>
                                <authority>Syriaca.org: The Syriac Reference Portal</authority>
                                <idno type="URI">http://syriaca.org/person/COMING SOON TO A THEATER NEAR YOU/tei</idno>
                                <availability>
                                    <licence target="http://creativecommons.org/licenses/by/3.0/">
                                        <p>Distributed under a Creative Commons Attribution 3.0 Unported License.</p>
                                    </licence>
                                </availability>
                                <date><xsl:value-of select="current-date()"></xsl:value-of></date>
                            </publicationStmt>
                            <sourceDesc>
                                <p>Born digital.</p>
                            </sourceDesc>
                        </fileDesc>
                        <encodingDesc>
                            <editorialDecl>
                                <p>This record created following the Syriaca.org guidelines. Documentation available at: <ref target="http://syriaca.org/documentation">http://syriaca.org/documentation</ref>.</p>
                            </editorialDecl>
                            <classDecl>
                                <taxonomy>
                                    <category xml:id="syriaca-headword">
                                        <catDesc>The name used by Syriaca.org for document titles, citation, and disambiguation. These names have been created according to the Syriac.org guidelines for headwords: <ref target="http://syriaca.org/documentation/headwords.html">http://syriaca.org/documentation/headwords.html</ref>.</catDesc>
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
                                <language ident="fr">French</language>
                                <language ident="fr-x-zanetti">Zanetti's transcription of Syriac into French</language>
                                <language ident="fr-x-fiey">Fiey's transcription of Syriac into French</language>
                            </langUsage>
                        </profileDesc>
                        <revisionDesc>
                            <change who="http://syriaca.org/editors.xml#tcarlson"><xsl:attribute name="when"><xsl:value-of select="current-date()"></xsl:value-of></xsl:attribute>CREATED: saint</change>
                        </revisionDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <listPerson>
                                <person>
                                    <xsl:attribute name="xml:id" select="concat('saint',SRP_Saint_ID)"/>
                                    
                                    <!-- DEAL WITH SAINT NAMES -->
                                    <!-- First deal with English names -->
                                    <!-- create one <persName> per name form, with @source citing multiple sources as necessary -->
                                    <!-- to do that, first we need to create a sequence of all name forms, then remove duplicates -->
                                    <xsl:variable name="english-names-with-duplicates" as="xs:string*">
                                        <xsl:if test="Nam_Eng != ''">
                                            <xsl:sequence select="tokenize(Nam_Eng,'/')"/>
                                        </xsl:if>
                                        <xsl:if test="Eng_2 != ''">
                                            <xsl:sequence select="(Eng_2)"/>
                                        </xsl:if>
                                        <xsl:if test="Eng_3 != ''">
                                            <xsl:sequence select="(Eng_3)"/>
                                        </xsl:if>
                                        <xsl:if test="English_Saint_Name != ''">
                                            <xsl:sequence select="(English_Saint_Name)"/>
                                        </xsl:if>
                                    </xsl:variable>
                                    <xsl:variable name="english-names" as="xs:string*"><xsl:sequence select="distinct-values($english-names-with-duplicates)"/></xsl:variable>
                                    
                                    <!-- for each name, we create a <placeName> element -->
                                    <xsl:variable name="this-row" select="."/>    <!-- Used to permit reference to the current row within nested for-each statements -->
                                    <xsl:variable name="name-prefix">name<xsl:value-of select="SRP_Saint_ID"/>-</xsl:variable>
                                    <xsl:for-each select="$english-names">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($english-names,.)"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">en</xsl:attribute>
                                            <!-- HOW DECIDE WHICH FORM IS THE ENGLISH HEADWORD? -->
                                            <xsl:if test="index-of($english-names,.) = 1">
                                                <xsl:attribute name="syriaca-tags">#syriaca-headword</xsl:attribute>
                                            </xsl:if>
                                            <xsl:attribute name="resp">http://syriaca.org/</xsl:attribute>
                                            
                                            <!-- finally output the value of the <persName> element, the name form itself -->
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <xsl:variable name="num-english-names" select="count($english-names)"/>
                                    
                                    <!-- NOW DEAL WITH THE SYRIAC NAMES -->
                                    <!-- create one <persName> per name form, with @source citing multiple sources as necessary -->
                                    <!-- to do that, first we need to create a sequence of all name forms, then remove duplicates -->
                                    <xsl:variable name="syriac-names-with-duplicates" as="xs:string*">
                                        <xsl:if test="Syr_Name != ''">
                                            <xsl:sequence select="tokenize(Syr_Name,'/')"/>
                                        </xsl:if>
                                        <xsl:if test="Syr_Name_2 != ''">
                                            <xsl:sequence select="(Syr_Name_2)"/>
                                        </xsl:if>
                                        <xsl:if test="Syr_Name_3 != ''">
                                            <xsl:sequence select="(Syr_Name_3)"/>
                                        </xsl:if>
                                        <xsl:if test="Syr_Name_4 != ''">
                                            <xsl:sequence select="(Syr_Name_4)"/>
                                        </xsl:if>
                                    </xsl:variable>
                                    <xsl:variable name="syriac-names" as="xs:string*"><xsl:sequence select="distinct-values($syriac-names-with-duplicates)"/></xsl:variable>
                                    
                                    <!-- for each name, we create a <placeName> element -->
                                    <xsl:variable name="this-row" select="."/>    <!-- Used to permit reference to the current row within nested for-each statements -->
                                    <xsl:variable name="name-prefix">name<xsl:value-of select="SRP_Saint_ID"/>-</xsl:variable>
                                    <xsl:for-each select="$syriac-names">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($syriac-names,.) + $num-english-names"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">syr</xsl:attribute>
                                            <!-- HOW DECIDE WHICH FORM IS THE SYRIAC HEADWORD? -->
                                            <xsl:if test="index-of($syriac-names,.) = 1">
                                                <xsl:attribute name="syriaca-tags">#syriaca-headword</xsl:attribute>
                                            </xsl:if>
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>
                                            
                                            <!-- finally output the value of the <persName> element, the name form itself -->
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <xsl:variable name="num-non-french-names" select="count($syriac-names) + $num-english-names"/>
                                    
                                    <!-- NOW DEAL WITH FRENCH NAMES -->
                                    <!-- create one <persName> per name form, with @source citing multiple sources as necessary -->
                                    <!-- to do that, first we need to create a sequence of all name forms, then remove duplicates -->
                                    <xsl:variable name="french-names-with-duplicates" as="xs:string*">
                                        <xsl:if test="Zanetti_Transcr. != ''">
                                            <xsl:sequence select="tokenize(Zanetti_Transcr.,'/')"/>
                                        </xsl:if>
                                        <xsl:if test="Zan_Tran_2 != ''">
                                            <xsl:sequence select="(Zan_Tran_2)"/>
                                        </xsl:if>
                                        <xsl:if test="Fr_Name_1 != ''">
                                            <xsl:sequence select="(Fr_Name_1)"/>
                                        </xsl:if>
                                        <xsl:if test="Fr_Name_2 != ''">
                                            <xsl:sequence select="(Fr_Name_2)"/>
                                        </xsl:if>
                                        <xsl:if test="Fr_Name_3 != ''">
                                            <xsl:sequence select="(Fr_Name_3)"/>
                                        </xsl:if>
                                        <xsl:if test="Fr_Name_4 != ''">
                                            <xsl:sequence select="(Fr_Name_4)"/>
                                        </xsl:if>
                                        <xsl:if test="Fr_Name_5 != ''">
                                            <xsl:sequence select="(Fr_Name_5)"/>
                                        </xsl:if>
                                        <xsl:if test="Fiey_Name != ''">
                                            <xsl:sequence select="(Fiey_Name)"/>
                                        </xsl:if>
                                    </xsl:variable>
                                    <xsl:variable name="french-names" as="xs:string*"><xsl:sequence select="distinct-values($french-names-with-duplicates)"/></xsl:variable>
                                    
                                    <!-- for each name, we create a <placeName> element -->
                                    <xsl:for-each select="$french-names">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($french-names,.) + $num-non-french-names"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">
                                                <xsl:choose>
                                                    <xsl:when test="compare($this-row/Zanetti_Transcr.,.) = 0 or compare($this-row/Zan_Tran_2,.) = 0">fr-x-zanetti</xsl:when>
                                                    <xsl:when test="compare($this-row/Fiey_Name,.) = 0">fr-x-fiey</xsl:when>
                                                    <xsl:otherwise>fr</xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
                                            <!-- Need a source attribute: if not Fiey, then certainly Zanetti; if Fiey, then possibly also Zanetti -->
                                            <xsl:choose>
                                                <xsl:when test="compare($this-row/Fiey_Name,.) = 0">
                                                    <xsl:choose>
                                                        <xsl:when test="compare($this-row/Zanetti_Transcr.,.) = 0 or compare($this-row/Zan_Tran_2,.) = 0 or compare($this-row/Fr_Name_1,.) = 0 or compare($this-row/Fr_Name_2,.) = 0 or compare($this-row/Fr_Name_3,.) = 0 or compare($this-row/Fr_Name_4,.) = 0 or compare($this-row/Fr_Name_5,.) = 0">
                                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/> #<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                                                                        
                                            <!-- finally output the value of the <persName> element, the name form itself -->
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    
                                    <!-- ID numbers -->
                                    <xsl:choose>
                                        <xsl:when test="SRP_ID != ''">
                                            <idno type="URI">http://syriaca.org/person/<xsl:value-of select="SRP_ID"/></idno>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <idno type="URI">http://syriaca.org/person/COMING SOON TO A PERSON NEAR YOU!</idno>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                    <!-- SEX -->
                                    <xsl:if test="Sex != '' and Sex != 'N/A'"> <!-- does this need a source? -->
                                        <sex>
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <xsl:value-of select="Sex"/>
                                        </sex>
                                    </xsl:if>
                                    
                                    <!-- BIRTH, DEATH, and FLORUIT dates -->
                                    <xsl:choose>
                                        <xsl:when test="Dates != ''">
                                            <note type="dates">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                                <xsl:value-of select="Dates"/>
                                            </note>
                                        </xsl:when>
                                    </xsl:choose>
                                    
                                    <!-- VENERATION date -->
                                    <xsl:if test="Veneration_Date != ''">
                                        <event type="veneration">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <desc>The saint is venerated on <xsl:value-of select="Veneration_Date"/>.</desc>
                                        </event>
                                    </xsl:if>
                                    
                                    <!-- How do disambiguation? -->
                                    <xsl:if test="Disambiguation_Notes != ''">
                                        <note type="disambiguation"><xsl:value-of select="Disambiguation_Notes"/></note>
                                    </xsl:if>
                                    
                                    <!-- Random notes -->
                                    <xsl:if test="Type_of_Vita != '' or Type_2 != '' or Type_3 != ''">
                                        <state type="commemoration-mode">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>
                                            <xsl:if test="Type_of_Vita != ''">
                                                <label><xsl:value-of select="Type_of_Vita"/></label>
                                            </xsl:if>
                                            <xsl:if test="Type_2 != ''">
                                                <label><xsl:value-of select="Type_2"/></label>
                                            </xsl:if>
                                            <xsl:if test="Type_3 != ''">
                                                <label><xsl:value-of select="Type_3"/></label>
                                            </xsl:if>
                                        </state>
                                    </xsl:if>
                                    
                                    <xsl:if test="Problem_Entry = 'Yes'">
                                        <note type="problem">This is a problem entry</note>
                                    </xsl:if>
                                    <xsl:if test="v_see_also_French != ''">
                                        <note type="see-also">See also <xsl:value-of select="v_see_also_French"/></note>
                                    </xsl:if>
                                    <xsl:if test="Multiple_Saint != ''">
                                        <note type="schizophrenia">This Fiey record includes multiple saints.</note>
                                    </xsl:if>
                                    <xsl:if test="Beruf_Keyword != ''">
                                        <note type="abstract"><xsl:value-of select="Beruf_Keyword"/></note>
                                    </xsl:if>
                                    <xsl:if test="Martyr_ != ''">
                                        <note type="martyrdom">This saint is a martyr.</note>
                                    </xsl:if>
                                    <xsl:if test="Edit_notes != ''">
                                        <note type="misc">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <xsl:value-of select="Edit_notes"/>
                                        </note>
                                    </xsl:if>
                                    <xsl:if test="Bibliography != ''">
                                        <note type="bibliography">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            Fiey cites <xsl:value-of select="Bibliography"/>
                                        </note>
                                    </xsl:if>
                                    
                                    <!-- ADD BIBLIOGRAPHY -->
                                    <xsl:if test="exists(index-of($sources,'Fiey'))">
                                        <bibl>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <author>J.-M. Fiey</author>
                                            <title>Saints Syriaques</title>
                                            <ptr target="http://syriaca.org/bibl/NEED-FIEY-URI"/>
                                            <xsl:choose>
                                                <xsl:when test="Fiey_ID[1] != ''">
                                                    <citedRange unit="entry"><xsl:value-of select="Fiey_ID[1]"/></citedRange>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <note type="ERROR">THERE IS NO ENTRY NUMBER FOR THIS FIEY DATA!</note>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </bibl>
                                    </xsl:if>
                                    <xsl:if test="exists(index-of($sources,'Zanetti'))">
                                        <bibl>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>
                                            <author>Ugo Zanetti</author>
                                            <title>WHAT TITLE DO WE GIVE ZANETTI'S DATABASE?</title>
                                            <ptr target="http://syriaca.org/bibl/NEED-ZANETTI-URI"/>
                                            <xsl:choose>
                                                <xsl:when test="Z1_ = ''">
                                                    <note type="ERROR">THERE ARE NO ZANETTI TEXT NUMBERS FOR THIS ZANETTI DATA!</note>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <citedRange unit="entry">FIGURE SOME WAY TO GET ALL OF THE ZANETTI TEXT NUMBERS FROM THEIR SPLIT CELLS.</citedRange>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </bibl>
                                    </xsl:if>
                                </person>
                            </listPerson>
                            <!-- Finally, deal with relations to other entities -->
                            <xsl:if test="Friends_with != '' or Fiey_Related != ''">
                                <note type="relation">This saint is related to persons <xsl:value-of select="Friends_with"/> and <xsl:value-of select="Fiey_Related"/>.</note>
                            </xsl:if>
                            <xsl:if test="Locations != '' or Cult_center != ''">
                                <note type="relation">This saint is related to places "<xsl:value-of select="Locations"/>" and "<xsl:value-of select="Cult_center"/>"</note>
                            </xsl:if>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>