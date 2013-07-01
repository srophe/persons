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
            <!-- TO DO: Make sure to filter out non-authors. -->
            <!-- Write the file to the subdirectory "output1" and give it the name of the record's SRP ID. -->
            <xsl:variable name="filename" select="concat('output1/',SRP_ID,'.xml')"/>
            <xsl:result-document href="{$filename}" format="xml">
                <eac-cpf xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd"
                    xmlns="urn:isbn:1-931666-33-4" xmlns:eac="urn:isbn:1-931666-33-4"
                    xmlns:xlink="http://www.w3.org/1999/xlink">
                    <control>
                        <recordId>
                            <xsl:value-of select="SRP_ID"/>
                        </recordId>
                        <xsl:if test="string-length(normalize-space(VIAF_URL)) > 0">
                            <otherRecordId>
                                <xsl:value-of select="VIAF_URL"/>
                            </otherRecordId>
                        </xsl:if>
                        <maintenanceStatus>new</maintenanceStatus>
                        <maintenanceAgency>
                            <agencyName>Syriac Reference Portal</agencyName>
                        </maintenanceAgency>
                        <!-- localTypeDeclaration needs tweaking. -->                        
                        <localTypeDeclaration>
                            <abbreviation>syriaca</abbreviation>
                            <citation xlink:href="http://syriaca.org/vocab/eac/localType" xlink:type="simple">Some sort of citation</citation>
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
                            <source xlink:href="http://syriaca.org">
                                <sourceEntry xml:id="syriaca.org">The Syriac Reference Portal
                                    (syriaca.org)</sourceEntry>
                            </source>
                            <xsl:if test="string-length(normalize-space(GEDSH_Entry)) > 0">
                                <!-- Need to also test for "None," etc. or remove from source data -->
                                <source xml:id="GEDSH">
                                    <sourceEntry>Gorgias Encyclopedic Dictionary of the Syriac
                                        Heritage</sourceEntry>
                                    <descriptiveNote>
                                        <p>Entry <xsl:value-of select="GEDSH_Entry_Number"/></p>
                                    </descriptiveNote>
                                </source>
                            </xsl:if>
                            <xsl:if
                                test="string-length(normalize-space(Syriac_Name_Non_Vocalized)) > 0">
                                <source xml:id="Barsoum-SY">
                                    <sourceEntry>Barsoum (Syriac)</sourceEntry>
                                    <descriptiveNote>
                                        <p>Page <xsl:value-of select="Syriac_Page_Number"/></p>
                                    </descriptiveNote>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(Arabic_Name)) > 0">
                                <source xml:id="Barsoum-AR">
                                    <sourceEntry>Barsoum (Arabic)</sourceEntry>
                                    <descriptiveNote>
                                        <p>Page <xsl:value-of select="Arabic_Page_Number"/></p>
                                    </descriptiveNote>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(EnglishName)) > 0">
                                <source xml:id="Barsoum-EN">
                                    <sourceEntry>Barsoum (English)</sourceEntry>
                                    <descriptiveNote>
                                        <p>Page <xsl:value-of select="EnglishPageNumber"/></p>
                                    </descriptiveNote>
                                </source>
                            </xsl:if>
                            <xsl:if
                                test="string-length(normalize-space(Syriac_from_Abdisho_YdQ_non-vocalized)) > 0">
                                <source xml:id="Abdisho-YDQ">
                                    <sourceEntry>Abdisho (YDQ)</sourceEntry>
                                    <descriptiveNote>
                                        <p>Page <xsl:value-of select="YdQ_Page"/></p>
                                    </descriptiveNote>
                                </source>
                            </xsl:if>
                            <xsl:if
                                test="string-length(normalize-space(Syriac_from_Abdisho_BO_non-vocalized)) > 0">
                                <!-- Need OR test for vocalized also -->
                                <source xml:id="Abdisho-BO">
                                    <sourceEntry>Abdisho (BO III)</sourceEntry>
                                    <descriptiveNote>
                                        <p>Page <xsl:value-of select="BO_Page"/></p>
                                    </descriptiveNote>
                                </source>
                            </xsl:if>
                            <xsl:if test="string-length(normalize-space(CBSC_Keyword)) > 0">
                                <source xlink:href="http://www.csc.org.il/db/db.aspx?db=SB"
                                    xml:id="CBSC">
                                    <sourceEntry>Comprehensive Bibliography of Syriac
                                        Christianity</sourceEntry>
                                </source>
                            </xsl:if>
                        </sources>
                    </control>
                    <cpfDescription>
                        <identity>
                            <entityType>person</entityType>
                            <!-- Need to create columns in source data for syriaca.org authorized forms. -->
                            <!-- Give GEDSH name in decomposed name parts. -->
                            <xsl:if
                                test="string-length(normalize-space(concat(GEDSH_Given_Names,GEDSH_Family_Names,GEDSH_Titles))) > 0">
                                <nameEntry localType="#GEDSH" scriptCode="Latn"
                                    transliteration="GEDSH" xml:lang="eng">
                                    <xsl:if
                                        test="string-length(normalize-space(GEDSH_Given_Names)) > 0">
                                        <part localType="given">
                                            <xsl:value-of select="GEDSH_Given_Names"/>
                                        </part>
                                    </xsl:if>
                                    <xsl:if
                                        test="string-length(normalize-space(GEDSH_Family_Names)) > 0">
                                        <part localType="family">
                                            <xsl:value-of select="GEDSH_Family_Names"/>
                                        </part>
                                    </xsl:if>
                                    <xsl:if test="string-length(normalize-space(GEDSH_Titles)) > 0">
                                        <part localType="termsOfAddress">
                                            <xsl:value-of select="GEDSH_Titles"/>
                                        </part>
                                    </xsl:if>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                            <!-- Give GEDSH name in a single name part. -->
                            <xsl:if test="string-length(normalize-space(GEDSH_Entry)) > 0">
                                <nameEntry localType="#GEDSH" scriptCode="Latn"
                                    transliteration="GEDSH" xml:lang="eng">
                                    <part localType="verbatim">
                                        <xsl:value-of select="GEDSH_Entry"/>
                                    </part>
                                    <alternativeForm>syriaca.org</alternativeForm>
                                </nameEntry>
                            </xsl:if>
                            <!-- Give Barsoum names as parallel name entries in decomposed name parts. -->
                            <!-- Test whether input data has the names split. -->
                            <xsl:if
                                test="string-length(normalize-space(concat(Barsoum_English_Given_Names,Barsoum_English_Family_Names,Barsoum_English_Titles,Barsoum_Arabic_Given_Names,Barsoum_Arabic_Family_Names,Barsoum_Arabic_Titles,Barsoum_Syriac_NV_Given_Names,Barsoum_Syriac_NV_Family_Names,Barsoum_Syriac_NV_Titles))) > 0">
                                <nameEntryParallel localType="Barsoum">
                                    <!-- Test for split English names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_English_Given_Names,Barsoum_English_Family_Names,Barsoum_English_Titles))) > 0">
                                        <nameEntry scriptCode="Latn"
                                            transliteration="Barsoum-Anglicized" xml:lang="eng"
                                            localType="#Barsoum-EN">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_English_Given_Names)) > 0">
                                                <part localType="given">
                                                  <xsl:value-of select="Barsoum_English_Given_Names"
                                                  />
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_English_Family_Names)) > 0">
                                                <part localType="family">
                                                  <xsl:value-of
                                                  select="Barsoum_English_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_English_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                  <xsl:value-of select="Barsoum_English_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for split Arabic names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_Arabic_Given_Names,Barsoum_Arabic_Family_Names,Barsoum_Arabic_Titles))) > 0">
                                        <nameEntry scriptCode="Arab" xml:lang="ara"
                                            localType="#Barsoum-AR">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Arabic_Given_Names)) > 0">
                                                <part localType="given">
                                                  <xsl:value-of select="Barsoum_Arabic_Given_Names"
                                                  />
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Arabic_Family_Names)) > 0">
                                                <part localType="family">
                                                  <xsl:value-of select="Barsoum_Arabic_Family_Names"
                                                  />
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Arabic_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                  <xsl:value-of select="Barsoum_Arabic_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for split non-vocalized Syriac names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_Syriac_NV_Given_Names,Barsoum_Syriac_NV_Family_Names,Barsoum_Syriac_NV_Titles))) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Syriac_NV_Given_Names)) > 0">
                                                <part localType="given">
                                                  <xsl:value-of
                                                  select="Barsoum_Syriac_NV_Given_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Syriac_NV_Family_Names)) > 0">
                                                <part localType="family">
                                                  <xsl:value-of
                                                  select="Barsoum_Syriac_NV_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Syriac_NV_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                  <xsl:value-of select="Barsoum_Syriac_NV_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for split vocalized Syriac names. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Barsoum_Syriac_V_Given_Names,Barsoum_Syriac_V_Family_Names,Barsoum_Syriac_V_Titles))) > 0">
                                        <nameEntry scriptCode="Syrj" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Syriac_V_Given_Names)) > 0">
                                                <part localType="given">
                                                  <xsl:value-of
                                                  select="Barsoum_Syriac_V_Given_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Syriac_V_Family_Names)) > 0">
                                                <part localType="family">
                                                  <xsl:value-of
                                                  select="Barsoum_Syriac_V_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Barsoum_Syriac_V_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                  <xsl:value-of select="Barsoum_Syriac_V_Titles"/>
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
                                test="string-length(normalize-space(concat(EnglishName,Arabic_Name,Syriac_Name_Non_Vocalized))) > 0">
                                <nameEntryParallel localType="Barsoum">
                                    <!-- Test for English name. -->
                                    <xsl:if test="string-length(normalize-space(EnglishName)) > 0">
                                        <nameEntry scriptCode="Latn"
                                            transliteration="Barsoum-Anglicized" xml:lang="eng"
                                            localType="#Barsoum-EN">
                                            <part localType="verbatim">
                                                <xsl:value-of select="EnglishName"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for Arabic name. -->
                                    <xsl:if test="string-length(normalize-space(Arabic_Name)) > 0">
                                        <nameEntry scriptCode="Arab" xml:lang="ara"
                                            localType="#Barsoum-AR">
                                            <part localType="verbatim">
                                                <xsl:value-of select="Arabic_Name"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for non-vocalized Syriac name. -->
                                    <xsl:if
                                        test="string-length(normalize-space(Syriac_Name_Non_Vocalized)) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <part localType="verbatim">
                                                <xsl:value-of select="Syriac_Name_Non_Vocalized"/>
                                            </part>
                                        </nameEntry>
                                    </xsl:if>
                                    <!-- Test for vocalized Syriac name. -->
                                    <xsl:if test="string-length(normalize-space(Syriac_Name)) > 0">
                                        <nameEntry scriptCode="Syrj" xml:lang="syr"
                                            localType="#Barsoum-SY">
                                            <part localType="verbatim">
                                                <xsl:value-of select="Syriac_Name"/>
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
                                    test="(string-length(normalize-space(Syriac_from_Abdisho_YdQ_non-vocalized)) > 0) and (string-length(normalize-space(Syriac_from_Abdisho_YdQ_Vocalized)) > 0)">
                                    <!-- Test whether names are split, and if so include them in multiple name parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_YdQ_NV_Given_Names,Abdisho_Syriac_YdQ_NV_Family_Names,Abdisho_Syriac_YdQ_NV_Titles,Abdisho_Syriac_YdQ_V_Given_Names,Abdisho_Syriac_YdQ_V_Family_Names,Abdisho_Syriac_YdQ_V_Titles))) > 0">
                                        <nameEntryParallel localType="#Abdisho-YDQ">
                                            <nameEntry scriptCode="Syrc" xml:lang="syr"
                                                localType="#Abdisho-YDQ">
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_YdQ_NV_Given_Names)) > 0">
                                                  <part localType="given">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_NV_Given_Names"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_YdQ_NV_Family_Names)) > 0">
                                                  <part localType="family">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_NV_Family_Names"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_YdQ_NV_Titles)) > 0">
                                                  <part localType="termsOfAddress">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_NV_Titles"/>
                                                  </part>
                                                </xsl:if>
                                            </nameEntry>
                                            <nameEntry scriptCode="Syre" xml:lang="syr"
                                                localType="#Abdisho-YDQ">
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_YdQ_V_Given_Names)) > 0">
                                                  <part localType="given">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_V_Given_Names"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_YdQ_V_Family_Names)) > 0">
                                                  <part localType="family">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_V_Family_Names"/>
                                                  </part>
                                                </xsl:if>
                                                <xsl:if
                                                  test="string-length(normalize-space(Abdisho_Syriac_YdQ_V_Titles)) > 0">
                                                  <part localType="termsOfAddress">
                                                  <xsl:value-of select="Abdisho_Syriac_YdQ_V_Titles"
                                                  />
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
                                            <part localType="verbatim">
                                                <xsl:value-of
                                                  select="Syriac_from_Abdisho_YdQ_non-vocalized"/>
                                            </part>
                                        </nameEntry>
                                        <nameEntry scriptCode="Syre" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <part localType="verbatim">
                                                <xsl:value-of
                                                  select="Syriac_from_Abdisho_YdQ_Vocalized"/>
                                            </part>
                                        </nameEntry>
                                        <alternativeForm>syriaca.org</alternativeForm>
                                    </nameEntryParallel>
                                </xsl:when>
                                <!-- If only non-vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Syriac_from_Abdisho_YdQ_non-vocalized)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_YdQ_NV_Given_Names,Abdisho_Syriac_YdQ_NV_Family_Names,Abdisho_Syriac_YdQ_NV_Titles))) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_YdQ_NV_Given_Names)) > 0">
                                                <part localType="given">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_NV_Given_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_YdQ_NV_Family_Names)) > 0">
                                                <part localType="family">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_NV_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_YdQ_NV_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                  <xsl:value-of
                                                  select="Abdisho_Syriac_YdQ_NV_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syrc" xml:lang="syr"
                                        localType="#Abdisho-YDQ">
                                        <part localType="verbatim">
                                            <xsl:value-of
                                                select="Syriac_from_Abdisho_YdQ_non-vocalized"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                                <!-- If only vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Syriac_from_Abdisho_YdQ_Vocalized)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_YdQ_V_Given_Names,Abdisho_Syriac_YdQ_V_Family_Names,Abdisho_Syriac_YdQ_V_Titles))) > 0">
                                        <nameEntry scriptCode="Syre" xml:lang="syr" localType="#Abdisho-YDQ">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_YdQ_V_Given_Names)) > 0">
                                                <part localType="given">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_YdQ_V_Given_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_YdQ_V_Family_Names)) > 0">
                                                <part localType="family">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_YdQ_V_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_YdQ_V_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_YdQ_V_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syre" xml:lang="syr" localType="#Abdisho-YDQ">
                                        <part localType="verbatim">
                                            <xsl:value-of
                                                select="Syriac_from_Abdisho_YdQ_Vocalized"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                            </xsl:choose>
                            <!-- Give Abdisho BO names as parallel name entries. -->
                            <xsl:choose>
                                <!-- Test whether both vocalized and non-vocalized are present, and if so use nameEntryParallel. -->
                                <xsl:when
                                    test="(string-length(normalize-space(Syriac_from_Abdisho_BO_non-vocalized)) > 0) and (string-length(normalize-space(Syriac_from_Abdisho_BO_Vocalized)) > 0)">
                                    <!-- Test whether names are split, and if so include them in multiple name parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_BO_NV_Given_Names,Abdisho_Syriac_BO_NV_Family_Names,Abdisho_Syriac_BO_NV_Titles,Abdisho_Syriac_BO_V_Given_Names,Abdisho_Syriac_BO_V_Family_Names,Abdisho_Syriac_BO_V_Titles))) > 0">
                                        <nameEntryParallel localType="#Abdisho-YDQ">
                                            <nameEntry scriptCode="Syrc" xml:lang="syr"
                                                localType="#Abdisho-YDQ">
                                                <xsl:if
                                                    test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Given_Names)) > 0">
                                                    <part localType="given">
                                                        <xsl:value-of
                                                            select="Abdisho_Syriac_BO_NV_Given_Names"/>
                                                    </part>
                                                </xsl:if>
                                                <xsl:if
                                                    test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Family_Names)) > 0">
                                                    <part localType="family">
                                                        <xsl:value-of
                                                            select="Abdisho_Syriac_BO_NV_Family_Names"/>
                                                    </part>
                                                </xsl:if>
                                                <xsl:if
                                                    test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Titles)) > 0">
                                                    <part localType="termsOfAddress">
                                                        <xsl:value-of
                                                            select="Abdisho_Syriac_BO_NV_Titles"/>
                                                    </part>
                                                </xsl:if>
                                            </nameEntry>
                                            <nameEntry scriptCode="Syre" xml:lang="syr"
                                                localType="#Abdisho-YDQ">
                                                <xsl:if
                                                    test="string-length(normalize-space(Abdisho_Syriac_BO_V_Given_Names)) > 0">
                                                    <part localType="given">
                                                        <xsl:value-of
                                                            select="Abdisho_Syriac_BO_V_Given_Names"/>
                                                    </part>
                                                </xsl:if>
                                                <xsl:if
                                                    test="string-length(normalize-space(Abdisho_Syriac_BO_V_Family_Names)) > 0">
                                                    <part localType="family">
                                                        <xsl:value-of
                                                            select="Abdisho_Syriac_BO_V_Family_Names"/>
                                                    </part>
                                                </xsl:if>
                                                <xsl:if
                                                    test="string-length(normalize-space(Abdisho_Syriac_BO_V_Titles)) > 0">
                                                    <part localType="termsOfAddress">
                                                        <xsl:value-of select="Abdisho_Syriac_BO_V_Titles"
                                                        />
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
                                            <part localType="verbatim">
                                                <xsl:value-of
                                                    select="Syriac_from_Abdisho_BO_non-vocalized"/>
                                            </part>
                                        </nameEntry>
                                        <nameEntry scriptCode="Syre" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <part localType="verbatim">
                                                <xsl:value-of
                                                    select="Syriac_from_Abdisho_BO_Vocalized"/>
                                            </part>
                                        </nameEntry>
                                        <alternativeForm>syriaca.org</alternativeForm>
                                    </nameEntryParallel>
                                </xsl:when>
                                <!-- If only non-vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Syriac_from_Abdisho_BO_non-vocalized)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_BO_NV_Given_Names,Abdisho_Syriac_BO_NV_Family_Names,Abdisho_Syriac_BO_NV_Titles))) > 0">
                                        <nameEntry scriptCode="Syrc" xml:lang="syr"
                                            localType="#Abdisho-YDQ">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Given_Names)) > 0">
                                                <part localType="given">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_BO_NV_Given_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Family_Names)) > 0">
                                                <part localType="family">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_BO_NV_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_NV_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_BO_NV_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syrc" xml:lang="syr"
                                        localType="#Abdisho-YDQ">
                                        <part localType="verbatim">
                                            <xsl:value-of
                                                select="Syriac_from_Abdisho_BO_non-vocalized"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                                <!-- If only vocalized present, do not use nameEntryParallel. -->
                                <xsl:when
                                    test="string-length(normalize-space(Syriac_from_Abdisho_BO_Vocalized)) > 0">
                                    <!-- Test whether name is split, and if so include name in multiple parts. -->
                                    <xsl:if
                                        test="string-length(normalize-space(concat(Abdisho_Syriac_BO_V_Given_Names,Abdisho_Syriac_BO_V_Family_Names,Abdisho_Syriac_BO_V_Titles))) > 0">
                                        <nameEntry scriptCode="Syre" xml:lang="syr" localType="#Abdisho-YDQ">
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_V_Given_Names)) > 0">
                                                <part localType="given">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_BO_V_Given_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_V_Family_Names)) > 0">
                                                <part localType="family">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_BO_V_Family_Names"/>
                                                </part>
                                            </xsl:if>
                                            <xsl:if
                                                test="string-length(normalize-space(Abdisho_Syriac_BO_V_Titles)) > 0">
                                                <part localType="termsOfAddress">
                                                    <xsl:value-of
                                                        select="Abdisho_Syriac_BO_V_Titles"/>
                                                </part>
                                            </xsl:if>
                                        </nameEntry>
                                    </xsl:if>
                                    <nameEntry scriptCode="Syre" xml:lang="syr" localType="#Abdisho-YDQ">
                                        <part localType="verbatim">
                                            <xsl:value-of
                                                select="Syriac_from_Abdisho_BO_Vocalized"/>
                                        </part>
                                    </nameEntry>
                                </xsl:when>
                            </xsl:choose>
                        </identity>
                    </cpfDescription>
                </eac-cpf>
            </xsl:result-document>
        </xsl:for-each>

        <!-- Create an index file that links to all of the EAC files. -->
        <xsl:result-document href="output1/index.html" format="html">
            <html>
                <head>
                    <title>Index</title>
                </head>
                <body>
                    <xsl:for-each select="row">
                        <a href="{SRP_ID}.xml">
                            <xsl:value-of select="Name__calculated_Barsoum_GEDSH_"/>
                        </a>
                        <br/>
                    </xsl:for-each>
                </body>
            </html>

        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
