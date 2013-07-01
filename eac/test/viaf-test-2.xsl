<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd"
    xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:output method="text"/>
    <xsl:output method="xml" indent="yes" name="xml"/>
    <xsl:output method="html" indent="yes" name="html"/>

    <xsl:template match="/root">

        <!-- Create an EAC file for each row. -->
        <xsl:for-each select="row">
            <!-- TO DO: Make sure to filter out non-persons/non-corporate-bodies. -->
            <!-- Create a variable for the entityId URL. -->
            <xsl:variable name="entityId">http://syriaca.org/person/<xsl:value-of select="SRP_ID"
                /></xsl:variable>
            <!-- Write the file to the subdirectory "output2" and give it the name of the record's SRP ID. -->
            <xsl:variable name="filename" select="concat('output2/',SRP_ID,'.xml')"/>
            <xsl:result-document href="{$filename}" format="xml">
                <eac-cpf xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd"
                    xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink">
                    <control>
                        <recordId>
                            <xsl:value-of select="SRP_ID"/>
                        </recordId>
                        <xsl:for-each select="URL">
                            <xsl:if test="string-length(normalize-space(.)) > 0">
                                <!-- This needs a forEach statement once we have multiple VIAF URL's to include. -->
                                <otherRecordId>
                                    <xsl:value-of select="."/>/</otherRecordId>
                            </xsl:if>
                        </xsl:for-each>
                        <maintenanceStatus>new</maintenanceStatus>
                        <maintenanceAgency>
                            <agencyName>Syriac Reference Portal</agencyName>
                        </maintenanceAgency>
                        <!-- localTypeDeclaration needs tweaking. -->
                        <localTypeDeclaration>
                            <abbreviation>syriaca</abbreviation>
                            <citation xlink:href="http://syriaca.org/vocab/eac/localType"
                                xlink:type="simple">Some sort of citation</citation>
                            <descriptiveNote>
                                <p>Some sort of description.</p>
                            </descriptiveNote>
                        </localTypeDeclaration>
                        <maintenanceHistory>
                            <maintenanceEvent>
                                <eventType>created</eventType>
                                <eventDateTime>
                                    <xsl:attribute name="standardDateTime"
                                        select="current-dateTime()"> </xsl:attribute>
                                </eventDateTime>
                                <agentType>machine</agentType>
                                <agent>Syriac Reference Portal</agent>
                            </maintenanceEvent>
                        </maintenanceHistory>
                        <sources>
                            <source xlink:href="http://syriaca.org" xml:id="syriaca.org">
                                <objectXMLWrap>
                                    <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                        <title>The Syriac Reference Portal (syriaca.org)</title>
                                        <abbr>syriaca.org</abbr>
                                        <citedRange>
                                            <xsl:attribute name="target">
                                                <xsl:value-of select="$entityId"/>
                                            </xsl:attribute>
                                        </citedRange>
                                        <!-- What pointer should we use here, if any? -->
                                        <ptr target="http://syriaca.org/about"/>
                                    </bibl>
                                </objectXMLWrap>
                            </source>
                            <xsl:if test="string-length(normalize-space(GEDSH_Full)) > 0">
                                <source xml:id="GEDSH">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <title>Gorgias Encyclopedic Dictionary of the Syriac
                                                Heritage</title>
                                            <abbr>GEDSH</abbr>
                                            <!-- How do we cite an entry number? Also we can put @target URL on citedRange if it refers to the particular unit. -->
                                            <xsl:if
                                                test="string-length(normalize-space(GEDSH_Entry_Num)) > 0">
                                                <!-- Ask Tom/Hugh whether we should use @from or element values for page numbers and entry numbers. -->
                                                <citedRange unit="entry">
                                                  <xsl:attribute name="from">
                                                  <xsl:value-of select="GEDSH_Entry_Num"/>
                                                  </xsl:attribute>
                                                </citedRange>
                                            </xsl:if>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/1"/>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(Barsoum_Sy_NV_Full)) > 0">
                                <source xml:id="Barsoum-SY">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <title>The Scattered Pearls: A History of Syriac
                                                Literature and Sciences</title>
                                            <abbr>Barsoum (Syriac)</abbr>
                                            <citedRange unit="pp">
                                                <xsl:attribute name="from">
                                                  <xsl:value-of select="Barsoum_Sy_Page_Num"/>
                                                </xsl:attribute>
                                            </citedRange>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/3"/>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(Barsoum_Ar_Full)) > 0">
                                <source xml:id="Barsoum-AR">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <title xml:lang="ara">كتاب اللؤلؤ المنثور في تاريخ
                                                العلوم والأداب السريانية</title>
                                            <abbr>Barsoum (Arabic)</abbr>
                                            <citedRange unit="pp">
                                                <xsl:attribute name="from">
                                                  <xsl:value-of select="Barsoum_Ar_Page_Num"/>
                                                </xsl:attribute>
                                            </citedRange>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/2"/>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(Barsoum_En_Full)) > 0">
                                <source xml:id="Barsoum-EN">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <title>The Scattered Pearls: A History of Syriac
                                                Literature and Sciences</title>
                                            <abbr>Barsoum (English)</abbr>
                                            <!-- Is the entry num the same for all versions of Barsoum or does it apply to English only? -->
                                            <!-- How do we cite an entry number? -->
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_En_Entry_Num)) > 0">
                                                <citedRange unit="entry">
                                                  <xsl:attribute name="from">
                                                  <xsl:value-of select="Barsoum_En_Entry_Num"/>
                                                  </xsl:attribute>
                                                </citedRange>
                                            </xsl:if>
                                            <!-- Can we have multiple citedRange elements? -->
                                            <citedRange unit="pp">
                                                <xsl:attribute name="from">
                                                  <xsl:value-of select="Barsoum_En_Page_Num"/>
                                                </xsl:attribute>
                                            </citedRange>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/4"/>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                            <xsl:if
                                test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Full)) > 0">
                                <source xml:id="Abdisho-YDQ">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <!-- What's the title for Abdisho? -->
                                            <title/>
                                            <abbr>Abdisho (YDQ)</abbr>
                                            <citedRange unit="pp">
                                                <xsl:attribute name="from">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_Page_Num"/>
                                                </xsl:attribute>
                                            </citedRange>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/6"/>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(Abdisho_BO_Sy_NV_Full)) > 0">
                                <!-- Need OR test for vocalized also -->
                                <source xml:id="Abdisho-BO">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <!-- What's the title for Abdisho? -->
                                            <title/>
                                            <abbr>Abdisho (BO III)</abbr>
                                            <citedRange unit="pp">
                                                <xsl:attribute name="from">
                                                  <xsl:value-of select="Abdisho_BO_Sy_Page_Num"/>
                                                </xsl:attribute>
                                            </citedRange>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/7"/>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(CBSC_En)) > 0">
                                <source xlink:href="http://www.csc.org.il/db/db.aspx?db=SB"
                                    xml:id="CBSC">
                                    <objectXMLWrap>
                                        <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                            <title>Comprehensive Bibliography of Syriac
                                                Christianity</title>
                                            <abbr>CBSC</abbr>
                                            <!-- Does pointer need fuller URI? -->
                                            <ptr target="http://syriaca.org/bibl/5"/>
                                            <!-- Tweak this to put in correct resolving link for CBSC. -->
                                            <citedRange>
                                                <xsl:attribute name="target"
                                                  >http://www.csc.org.il/db/db.aspx?db=SB<xsl:value-of
                                                  select="CBSC_En"/></xsl:attribute>
                                            </citedRange>
                                        </bibl>
                                    </objectXMLWrap>
                                </source>
                            </xsl:if>
                        </sources>
                    </control>
                    <cpfDescription>
                        <identity>
                            <entityId>
                                <xsl:value-of select="$entityId"/>
                            </entityId>
                            <xsl:for-each select="URL">
                                <xsl:if test="string-length(normalize-space(.)) > 0">
                                    <entityId>
                                        <xsl:value-of select="."/>
                                    </entityId>
                                </xsl:if>
                            </xsl:for-each>
                            <entityType>person</entityType>
                            <!-- Need to decide how our authorized/alternative & preferred forms work. -->
                            <!-- Need to create columns in source data for syriaca.org authorized forms (for Syriac at least). For English, can just pull them in using GEDSH/GEDSH-style. -->
                            <!-- Give GEDSH name in decomposed name parts. -->
                            <xsl:if
                                test="string-length(normalize-space(concat(GEDSH_Given,GEDSH_Family,GEDSH_Titles))) > 0">
                                <nameEntry localType="#GEDSH" transliteration="GEDSH" xml:lang="eng">
                                    <xsl:if test="string-length(normalize-space(GEDSH_Given)) > 0">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#given">
                                            <xsl:value-of select="GEDSH_Given"/>
                                        </part>
                                    </xsl:if>
                                    <xsl:if test="string-length(normalize-space(GEDSH_Family)) > 0">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#family">
                                            <xsl:value-of select="GEDSH_Family"/>
                                        </part>
                                    </xsl:if>
                                    <xsl:if test="string-length(normalize-space(GEDSH_Titles)) > 0">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                            <xsl:value-of select="GEDSH_Titles"/>
                                        </part>
                                    </xsl:if>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                            <!-- Give GEDSH name in a single name part. -->
                            <xsl:if test="string-length(normalize-space(GEDSH_Full)) > 0">
                                <nameEntry localType="#GEDSH" transliteration="GEDSH" xml:lang="eng">
                                    <part
                                        localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                        <xsl:value-of select="GEDSH_Full"/>
                                    </part>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                            <!-- Give Barsoum names as parallel name entries in decomposed name parts. -->
                            <!-- Test whether input data has the names split. -->
                            <xsl:if
                                test="string-length(normalize-space(concat(Barsoum_En_Given,Barsoum_En_Family,Barsoum_En_Titles,Barsoum_Ar_Given,Barsoum_Ar_Family,Barsoum_Ar_Titles,Barsoum_Sy_NV_Given,Barsoum_Sy_NV_Family,Barsoum_Sy_NV_Titles))) > 0">
                                <nameEntryParallel
                                    localType="http://syriaca.org/vocab/eac/localType#Barsoum">
                                    <!-- Test for split non-vocalized Syriac names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_Sy_NV_Given,Barsoum_Sy_NV_Family,Barsoum_Sy_NV_Titles))) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Sy_NV_Given)) > 0">
                                                <part
                                                    localType="http://syriaca.org/vocab/eac/localType#given">
                                                    <xsl:value-of select="Barsoum_Sy_NV_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Sy_NV_Family)) > 0">
                                                <part
                                                    localType="http://syriaca.org/vocab/eac/localType#family">
                                                    <xsl:value-of select="Barsoum_Sy_NV_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Sy_NV_Titles)) > 0">
                                                <part
                                                    localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                    <xsl:value-of select="Barsoum_Sy_NV_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for split vocalized Syriac names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_Sy_V_Given,Barsoum_Sy_V_Family,Barsoum_Sy_V_Titles))) > 0">
                                        <nameEntry scriptCode="Syrj" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Sy_V_Given)) > 0">
                                                <part
                                                    localType="http://syriaca.org/vocab/eac/localType#given">
                                                    <xsl:value-of select="Barsoum_Sy_V_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Sy_V_Family)) > 0">
                                                <part
                                                    localType="http://syriaca.org/vocab/eac/localType#family">
                                                    <xsl:value-of select="Barsoum_Sy_V_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Sy_V_Titles)) > 0">
                                                <part
                                                    localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                    <xsl:value-of select="Barsoum_Sy_V_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for split English names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_En_Given,Barsoum_En_Family,Barsoum_En_Titles))) > 0">
                                        <nameEntry transliteration="Barsoum-Anglicized"
                                            xml:lang="eng" localType="#Barsoum-EN">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_En_Given)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Barsoum_En_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_En_Family)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Barsoum_En_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_En_Titles)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Barsoum_En_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for split Arabic names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_Ar_Given,Barsoum_Ar_Family,Barsoum_Ar_Titles))) > 0">
                                        <nameEntry xml:lang="ara" localType="#Barsoum-AR">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Ar_Given)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Barsoum_Ar_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Ar_Family)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Barsoum_Ar_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Ar_Titles)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Barsoum_Ar_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntryParallel>
                            </xsl:if>
                            <!-- Give Barsoum names as parallel name entries in single name parts. -->
                            <!-- Test whether input data has the names. -->
                            <xsl:if
                                test="string-length(normalize-space(concat(Barsoum_En_Full,Barsoum_Ar_Full,Barsoum_Sy_NV_Full))) > 0">
                                <nameEntryParallel
                                    localType="http://syriaca.org/vocab/eac/localType#Barsoum">
                                    <!-- Test for non-vocalized Syriac name. -->
                                    <xsl:if
                                        test="string-length(normalize-space(Barsoum_Sy_NV_Full)) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Barsoum_Sy_NV_Full"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for vocalized Syriac name. -->
                                    <xsl:if
                                        test="string-length(normalize-space(Barsoum_Sy_V_Full)) > 0">
                                        <nameEntry scriptCode="Syrj" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Barsoum_Sy_V_Full"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for English name. -->
                                    <xsl:if
                                        test="string-length(normalize-space(Barsoum_En_Full)) > 0">
                                        <nameEntry transliteration="Barsoum-Anglicized"
                                            xml:lang="eng" localType="#Barsoum-EN">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Barsoum_En_Full"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for Arabic name. -->
                                    <xsl:if
                                        test="string-length(normalize-space(Barsoum_Ar_Full)) > 0">
                                        <nameEntry xml:lang="ara" localType="#Barsoum-AR">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Barsoum_Ar_Full"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntryParallel>
                            </xsl:if>
                            <!-- Give Abdisho YdQ names as parallel name entries. -->
                            <xsl:choose>
                                <!-- Test whether both vocalized and non-vocalized are present, and if so use nameEntryParallel. -->
                                <xsl:when
                                    test="(string-length(normalize-space(Abdisho_YdQ_Sy_NV_Full)) > 0) and (string-length(normalize-space(Abdisho_YdQ_Sy_V_Full)) > 0)">
                                    <!-- Test whether names are split, and if so include them in multiple name parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_YdQ_Sy_NV_Given,Abdisho_YdQ_Sy_NV_Family,Abdisho_YdQ_Sy_NV_Titles,Abdisho_YdQ_Sy_V_Given,Abdisho_YdQ_Sy_V_Family,Abdisho_YdQ_Sy_V_Titles))) > 0">
                                        <nameEntryParallel localType="#Abdisho-YDQ">
                                            <nameEntry scriptCode="Syrc" xml:lang="syr"
                                                localType="#Abdisho-YDQ">
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Given)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_NV_Given"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Family)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_NV_Family"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Titles)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_NV_Titles"/>
                                                  </part>
                                                </xsl:if>
                                            </nameEntry>
                                            <nameEntry scriptCode="Syre" xml:lang="syr"
                                                localType="#Abdisho-YDQ">
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Given)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_V_Given"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Family)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_V_Family"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Titles)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_V_Titles"/>
                                                  </part>
                                                </xsl:if>
                                            </nameEntry>
                                            <alternativeForm>syriaca.org</alternativeForm>
                                        </nameEntryParallel>
                                    </xsl:if>
                                    <!-- Include vocalized and non-vocalized name forms in parallel. -->
                                    <nameEntryParallel localType="#Abdisho-YDQ">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Abdisho_YdQ_Sy_NV_Full"/>
                                            </part>
                                        </nameEntry>
                                        <nameEntry scriptCode="Syre" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Abdisho_YdQ_Sy_V_Full"/>
                                            </part>
                                        </nameEntry>
                                        <alternativeForm>syriaca.org</alternativeForm>
                                    </nameEntryParallel>
                                </xsl:when>
                                <!-- If only non-vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Full)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_YdQ_Sy_NV_Given,Abdisho_YdQ_Sy_NV_Family,Abdisho_YdQ_Sy_NV_Titles))) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Given)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_NV_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Family)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_NV_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_YdQ_Sy_NV_Titles)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_NV_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syrc" xml:lang="syr"
                                        localType="#Abdisho-YDQ">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                            <xsl:value-of select="Abdisho_YdQ_Sy_NV_Full"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                                <!-- If only vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Full)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_YdQ_Sy_V_Given,Abdisho_YdQ_Sy_V_Family,Abdisho_YdQ_Sy_V_Titles))) > 0">
                                        <nameEntry scriptCode="Syre" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Given)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_V_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Family)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_V_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_YdQ_Sy_V_Titles)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_YdQ_Sy_V_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syre" xml:lang="syr"
                                        localType="#Abdisho-YDQ">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                            <xsl:value-of select="Abdisho_YdQ_Sy_V_Full"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                            </xsl:choose>
                            <!-- Give Abdisho BO names as parallel name entries. -->
                            <xsl:choose>
                                <!-- Test whether both vocalized and non-vocalized are present, and if so use nameEntryParallel. -->
                                <xsl:when
                                    test="(string-length(normalize-space(Abdisho_BO_Sy_NV_Full)) > 0) and (string-length(normalize-space(Abdisho_BO_Sy_V_Full)) > 0)">
                                    <!-- Test whether names are split, and if so include them in multiple name parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_BO_NV_Given,Abdisho_BO_Sy_NV_Family,Abdisho_BO_Sy_NV_Titles,Abdisho_BO_Sy_V_Given,Abdisho_BO_Sy_V_Family,Abdisho_BO_Sy_V_Titles))) > 0">
                                        <nameEntryParallel localType="#Abdisho-BO">
                                            <nameEntry scriptCode="Syrc" xml:lang="syr"
                                                localType="#Abdisho-BO">
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Given)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_Syriac_BO_NV_Given"
                                                  />
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_BO_Sy_NV_Family)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_BO_Sy_NV_Family"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_BO_Sy_NV_Titles)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_BO_Sy_NV_Titles"/>
                                                  </part>
                                                </xsl:if>
                                            </nameEntry>
                                            <nameEntry scriptCode="Syre" xml:lang="syr"
                                                localType="#Abdisho-BO">
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_BO_Sy_V_Given)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_BO_Sy_V_Given"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_BO_Sy_V_Family)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_BO_Sy_V_Family"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_BO_Sy_V_Titles)) > 0">
                                                  <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_BO_Sy_V_Titles"/>
                                                  </part>
                                                </xsl:if>
                                            </nameEntry>
                                            <alternativeForm>syriaca.org</alternativeForm>
                                        </nameEntryParallel>
                                    </xsl:if>
                                    <!-- Include vocalized and non-vocalized name forms in parallel. -->
                                    <nameEntryParallel localType="#Abdisho-BO">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Abdisho-BO">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Abdisho_BO_Sy_NV_Full"/>
                                            </part>
                                        </nameEntry>
                                        <nameEntry scriptCode="Syre" xml:lang="syr"
                                            localType="#Abdisho-BO">
                                            <part
                                                localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                                <xsl:value-of select="Abdisho_BO_Sy_V_Full"/>
                                            </part>
                                        </nameEntry>
                                        <alternativeForm>syriaca.org</alternativeForm>
                                    </nameEntryParallel>
                                </xsl:when>
                                <!-- If only non-vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Abdisho_BO_Sy_NV_Full)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_BO_NV_Given,Abdisho_BO_Sy_NV_Family,Abdisho_BO_Sy_NV_Titles))) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Abdisho-BO">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Given)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_Syriac_BO_NV_Given"
                                                  />
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_BO_Sy_NV_Family)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_BO_Sy_NV_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_BO_Sy_NV_Titles)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_BO_Sy_NV_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syrc" xml:lang="syr"
                                        localType="#Abdisho-BO">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                            <xsl:value-of select="Abdisho_BO_Sy_NV_Full"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                                <!-- If only vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Abdisho_BO_Sy_V_Full)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_BO_Sy_V_Given,Abdisho_BO_Sy_V_Family,Abdisho_BO_Sy_V_Titles))) > 0">
                                        <nameEntry scriptCode="Syre" xml:lang="syr"
                                            localType="#Abdisho-BO">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_BO_Sy_V_Given)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#given">
                                                  <xsl:value-of select="Abdisho_BO_Sy_V_Given"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_BO_Sy_V_Family)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#family">
                                                  <xsl:value-of select="Abdisho_BO_Sy_V_Family"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_BO_Sy_V_Titles)) > 0">
                                                <part
                                                  localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                                  <xsl:value-of select="Abdisho_BO_Sy_V_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syre" xml:lang="syr"
                                        localType="#Abdisho-BO">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                            <xsl:value-of select="Abdisho_BO_Sy_V_Full"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                            </xsl:choose>
                            <!-- Givr GEDSH-style name in decomposed name parts. -->
                            <xsl:if
                                test="string-length(normalize-space(concat(GS_En_Given,GS_En_Family,GS_En_Titles))) > 0">
                                <nameEntry localType="#syriaca.org" transliteration="GEDSH"
                                    xml:lang="eng">
                                    <xsl:if test="string-length(normalize-space(GS_En_Given)) > 0">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#given">
                                            <xsl:value-of select="GS_En_Given"/>
                                        </part>
                                    </xsl:if>
                                    <xsl:if test="string-length(normalize-space(GS_En_Family)) > 0">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#family">
                                            <xsl:value-of select="GS_En_Family"/>
                                        </part>
                                    </xsl:if>
                                    <xsl:if test="string-length(normalize-space(GS_En_Titles)) > 0">
                                        <part
                                            localType="http://syriaca.org/vocab/eac/localType#termsOfAddress">
                                            <xsl:value-of select="GS_En_Titles"/>
                                        </part>
                                    </xsl:if>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                            <!-- Give GEDSH-style name in a single name part. -->
                            <xsl:if test="string-length(normalize-space(GS_En_Full)) > 0">
                                <nameEntry localType="#syriaca.org" transliteration="GEDSH"
                                    xml:lang="eng">
                                    <part
                                        localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                        <xsl:value-of select="GS_En_Full"/>
                                    </part>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                            <!-- Include "Other English"? -->
                            <!-- Split CBSC name into decomposed name parts? -->
                            <!-- Give CBSC name in a single name part. -->
                            <!-- Needs to also test for #REF! errors here or in spreadsheet. -->
                            <xsl:if test="string-length(normalize-space(CBSC_En)) > 0">
                                <nameEntry localType="#CBSC" transliteration="CBSC" xml:lang="eng">
                                    <part
                                        localType="http://syriaca.org/vocab/eac/localType#verbatim">
                                        <xsl:value-of select="CBSC_En"/>
                                    </part>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                        </identity>
                        <!-- Test whether there are any items that need to go in description. -->
                        <xsl:if
                            test="string-length(normalize-space(concat(GEDSH_Birthdate,GEDSH_Death_Date,Barsoum_En_Death_Year,Barsoum_En_Other_Year,Barsoum_En_Century))) > 0">
                            <description>
                                <!-- Birth, death, and floruit dates. Need to add @standardDate, etc. once these are available from spreadsheet.-->
                                <xsl:choose>
                                    <!-- If there are both birth and death dates from GEDSH, use @localType "lifespan." -->
                                    <xsl:when
                                        test="(string-length(normalize-space(GEDSH_Birthdate)) > 0) and (string-length(normalize-space(GEDSH_Death_Date)) > 0)">
                                        <!-- Need to check this localType against list to make sure it's right. -->
                                        <existDates
                                            localType="http://syriaca.org/vocab/eac/localType#lifespan">
                                            <xsl:choose>
                                                <!-- If Barsoum has a death year, use a date set to include it. -->
                                                <xsl:when
                                                  test="string-length(normalize-space(Barsoum_En_Death_Year)) > 0">
                                                  <dateSet>
                                                  <dateRange localType="#GEDSH">
                                                  <fromDate>
                                                  <xsl:value-of select="GEDSH_Birthdate"/>
                                                  </fromDate>
                                                  <toDate>
                                                  <xsl:value-of select="GEDSH_Death_Date"/>
                                                  </toDate>
                                                  </dateRange>
                                                  <!-- Do we need to show with local types that Barsoum only gives death dates, or should we just build this into the HTML transform? 
                                                        Or is it legal to just put a toDate wihout a fromDate? -->
                                                  <dateRange localType="#Barsoum-EN">
                                                  <toDate>
                                                  <xsl:value-of select="Barsoum_En_Death_Year"/>
                                                  </toDate>
                                                  </dateRange>
                                                  </dateSet>
                                                </xsl:when>
                                                <!-- Otherwise, just give GEDSH dates as a date range. -->
                                                <xsl:otherwise>
                                                  <dateRange localType="#GEDSH">
                                                  <fromDate>
                                                  <xsl:value-of select="GEDSH_Birthdate"/>
                                                  </fromDate>
                                                  <toDate>
                                                  <xsl:value-of select="GEDSH_Death_Date"/>
                                                  </toDate>
                                                  </dateRange>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </existDates>
                                    </xsl:when>
                                    <!-- If either GEDSH or Barsoum have death dates (but no birthdate - see above), use @localType "death." -->
                                    <xsl:when
                                        test="(string-length(normalize-space(GEDSH_Death_Date)) > 0) or (string-length(normalize-space(Barsoum_En_Death_Year)) > 0)">
                                        <existDates
                                            localType="http://syriaca.org/vocab/eac/localType#death">
                                            <xsl:choose>
                                                <!-- If both GEDSH and Barsoum have death dates, use a date set. -->
                                                <xsl:when
                                                  test="(string-length(normalize-space(GEDSH_Death_Date)) > 0) and (string-length(normalize-space(Barsoum_En_Death_Year)) > 0)">
                                                  <dateSet>
                                                  <date localType="#GEDSH">
                                                  <xsl:value-of select="GEDSH_Death_Date"/>
                                                  </date>
                                                  <date localType="#Barsoum-EN">
                                                  <xsl:value-of select="Barsoum_En_Death_Year"/>
                                                  </date>
                                                  </dateSet>
                                                </xsl:when>
                                                <!-- If only GEDSH has a death date... -->
                                                <xsl:when
                                                  test="string-length(normalize-space(GEDSH_Death_Date)) > 0">
                                                  <date localType="#GEDSH">
                                                  <xsl:value-of select="GEDSH_Death_Date"/>
                                                  </date>
                                                </xsl:when>
                                                <!-- If only Barsoum has a death date... -->
                                                <xsl:otherwise>
                                                  <date localType="#Barsoum-EN">
                                                  <xsl:value-of select="Barsoum_En_Death_Year"/>
                                                  </date>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </existDates>
                                    </xsl:when>
                                    <!-- If GEDSH has a birthdate (but no death date) and Barsoum has a date, use @localType "existence" to show that these are dates of mixed types when the person existed. -->
                                    <xsl:when
                                        test="(string-length(normalize-space(GEDSH_Birthdate)) > 0) and ((string-length(normalize-space(Barsoum_En_Death_Year)) > 0) or (string-length(normalize-space(Barsoum_En_Other_Year)) > 0) or (string-length(normalize-space(Barsoum_En_Century)) > 0))">
                                        <!-- Add this localType to list, if needed. -->
                                        <existDates
                                            localType="http://syriaca.org/vocab/eac/localType#existence">
                                            <dateSet>
                                                <date localType="#GEDSH">
                                                  <xsl:value-of select="GEDSH_Birthdate"/>
                                                </date>
                                                <xsl:if
                                                    test="string-length(normalize-space(Barsoum_En_Other_Year)) > 0">
                                                  <date localType="#Barsoum-EN">
                                                      <xsl:value-of select="Barsoum_En_Other_Year"/>
                                                  </date>
                                                </xsl:if>
                                                <xsl:if
                                                    test="string-length(normalize-space(Barsoum_En_Century)) > 0">
                                                    <date localType="#Barsoum-EN">
                                                        <!-- What format is this century field in? Does it need to be reformatted? Note other occurences in this stylesheet too. -->
                                                        <xsl:value-of select="Barsoum_En_Century"/>
                                                    </date>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Barsoum_En_Death_Year)) > 0">
                                                  <date localType="#Barsoum-EN">
                                                      <xsl:value-of select="Barsoum_En_Death_Year"/>
                                                  </date>
                                                </xsl:if>
                                            </dateSet>
                                        </existDates>
                                    </xsl:when>
                                    <!-- If GEDSH has a birth date but no death date (and Barsoum has no dates), use @localType "birth."-->
                                    <xsl:when
                                        test="string-length(normalize-space(GEDSH_Birthdate)) > 0">
                                        <existDates
                                            localType="http://syriaca.org/vocab/eac/localType#birth">
                                            <date localType="#GEDSH">
                                                <xsl:value-of select="GEDSH_Birthdate"/>
                                            </date>
                                        </existDates>
                                    </xsl:when>
                                    <!-- If Barsoum has other year or century, use @localType "floruit" -->
                                    <xsl:when
                                        test="(string-length(normalize-space(Barsoum_En_Other_Year)) > 0) or (string-length(normalize-space(Barsoum_En_Century)) > 0)">
                                        <existDates
                                            localType="http://syriaca.org/vocab/eac/localType#floruit">
                                            <xsl:choose>
                                                <xsl:when test="string-length(normalize-space(Barsoum_En_Other_Year)) > 0">
                                                    <date localType="#Barsoum-EN">
                                                        <xsl:value-of select="Barsoum_En_Other_Year"/>
                                                    </date>
                                                </xsl:when>
                                                <xsl:when test="string-length(normalize-space(Barsoum_En_Century)) > 0">
                                                    <date localType="#Barsoum-EN">
                                                        <xsl:value-of select="Barsoum_En_Century"/>
                                                    </date>
                                                </xsl:when>
                                            </xsl:choose>
                                        </existDates>
                                    </xsl:when>
                                    <!-- What about GEDSH floruit?
                                    Also have not incorporated a scenario for a record that has both GEDSH birthdate and death date and has Barsoum other year or century.-->
                                </xsl:choose>
                            </description>
                        </xsl:if>
                    </cpfDescription>
                </eac-cpf>
            </xsl:result-document>
        </xsl:for-each>

        <!-- Create an index file that links to all of the EAC files.
        Index does not work for rows lacking a Calculated_Name.-->
        <xsl:result-document href="output2/index.html" format="html">
            <html>
                <head>
                    <title>Index</title>
                </head>
                <body>
                    <xsl:for-each select="row">
                        <a href="{SRP_ID}.xml">
                            <xsl:value-of select="Calculated_Name"/>
                        </a>
                        <br/>
                    </xsl:for-each>
                </body>
            </html>

        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
