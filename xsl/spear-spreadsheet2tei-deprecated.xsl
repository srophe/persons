<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:syriaca="http://syriaca.org">
        
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
    
    <!-- Column-Source Mapping - change for each new spreadsheet! -->
    <!-- 1. define bibl URIs for each source here: -->
    <xsl:variable name="source-1-uri">633</xsl:variable>
    <xsl:variable name="source-2-uri">657</xsl:variable>
        <!-- and so on...  -->
    
    <!-- 2. define which columns come from which source  -->
    <xsl:variable name="source-1-columns" as="xs:string*">
        <xsl:sequence select="'Syriac_Canonical'"/>
        <xsl:sequence select="'Name_Variant_1_SYR'"/>
    </xsl:variable>
    <xsl:variable name="source-2-columns" as="xs:string*">
        <xsl:sequence select="'Name_Variant_1'"/>
        <xsl:sequence select="'Name_Variant_2'"/>
        <xsl:sequence select="'Sex'"/>
        <xsl:sequence select="'Office'"/>
        <xsl:sequence select="'Birth'"/>
        <xsl:sequence select="'Death'"/>
        <xsl:sequence select="'Floruit'"/>
    </xsl:variable>
    
    <!-- 3. define which columns should have which language tags -->
    <xsl:variable name="lang-gedsh-columns">
        <xsl:sequence select="'Canonical_Name'"/>
    </xsl:variable>
    <xsl:variable name="lang-en-columns">
        <xsl:sequence select="'Name_Variant_1'"/>
        <xsl:sequence select="'Name_Variant_2'"/>
        <xsl:sequence select="'Sex'"/>
        <xsl:sequence select="'Office'"/>
    </xsl:variable>
    <xsl:variable name="lang-syr-columns">
        <xsl:sequence select="'Syriac_Canonical'"/>
        <xsl:sequence select="'Name_Variant_1_SYR'"/>
    </xsl:variable>
        <!-- and so on... -->
    
    <!-- OR -->
    <xsl:variable name="column-mapping">
        <Canonical_Name xml:lang="en-x-gedsh">persName</Canonical_Name>
        <Syriac_Canonical xml:lang="syr" source="http://syriaca.org/bibl/633">persName</Syriac_Canonical>
    </xsl:variable>
    
    
    <xsl:function name="syriaca:custom-dates" as="xs:date">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="trim-date" select="normalize-space($date)"/>
        <xsl:choose>
            <xsl:when test="starts-with($trim-date,'0000') and string-length($trim-date) eq 4"><xsl:text>0001-01-01</xsl:text></xsl:when>
            <xsl:when test="string-length($trim-date) eq 4"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 5"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 5"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 7"><xsl:value-of select="concat($trim-date,'-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 3"><xsl:value-of select="concat('0',$trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 2"><xsl:value-of select="concat('00',$trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 1"><xsl:value-of select="concat('000',$trim-date,'-01-01')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$trim-date"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/root">
        <!-- [not(starts-with(SRP_ID,'F'))] -->
        <!-- Create IDs for new persons. DEAL WITH MATCHED PERSONS ELSEWHERE (URI COLUMN)! -->
        <xsl:for-each select="row">
            <xsl:variable name="record-id">
                <xsl:choose>
                    <xsl:when test="New_URI != ''"><xsl:value-of select="New_URI"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="concat('unresolved-',generate-id())"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- Creates a variable containing the path of the file that should be created for this record. -->
            <xsl:variable name="filename">
                <xsl:choose>
                    <xsl:when test="Canonical_Name[.=''] or Syriac_Canonical[.='']">
                        <xsl:value-of select="concat('../../working-files/chronicle-data/tei/incomplete/',$record-id,'.xml')"/>
                    </xsl:when>
                    <xsl:when test="New_URI != ''"><xsl:value-of select="concat('../../working-files/chronicle-data/tei/',$record-id,'.xml')"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="concat('../../working-files/chronicle-data/tei/unresolved/',$record-id,'.xml')"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- Changed test from not empty New_URI to not empty $filename so that it will generate files for "unresolved" records. -->
            <xsl:if test="$filename != ''">
            <xsl:result-document href="{$filename}" format="xml">
                <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$n"/>
                
                <!-- determine which sources will need to be cited; to be used in header formation as well -->
                <xsl:variable name="bib-prefix">bib<xsl:value-of select="$record-id"/>-</xsl:variable>
                <!-- WHAT DOES THIS DO WITH RECORD 2246 WHICH HAS NEITHER SOURCE LISTED? -->
                <xsl:variable name="sources" as="xs:string*">
                    <xsl:if test="Source_1 != ''">
                        <xsl:sequence select="('Source_1')"/>
                    </xsl:if>
                    <xsl:if test="Source_2 != ''">
                        <xsl:sequence select="('Source_2')"/>
                    </xsl:if>
                </xsl:variable>
                <!-- therefore the xml:id of the <bibl> element representing a source is $bib-prefix followed by the index of the source name in the $sources sequence -->
                <!-- and the citation format is #<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/> for Fiey, etc. -->
                <xsl:variable name="all-full-name-fields" as="xs:string*">
                    <xsl:if test="Syriac_Canonical != ''">
                        <xsl:sequence select="('Syriac_Canonical')"/>
                    </xsl:if>
                    <xsl:if test="Canonical_Name != ''">
                        <xsl:sequence select="('Canonical_Name')"/>
                    </xsl:if>
                    <xsl:if test="Name_Variant_1_SYR != ''">
                        <xsl:sequence select="('Name_Variant_1_SYR')"/>
                    </xsl:if>
                    <xsl:if test="Name_Variant_1 != ''">
                        <xsl:sequence select="('Name_Variant_1')"/>
                    </xsl:if>
                    <xsl:if test="Name_Variant_2 != ''">
                        <xsl:sequence select="('Name_Variant_2')"/>
                    </xsl:if>
                </xsl:variable>
                <TEI xml:lang="en" xmlns="http://www.tei-c.org/ns/1.0">
                    <!-- Adds header -->
                    <xsl:call-template name="header">
                        <xsl:with-param name="record-id" select="$record-id"/>
                    </xsl:call-template>
                    <text>
                        <body>
                            <listPerson>
                                <person>
                                    <!-- WHAT PREFIX SHOULD WE USE - PERSON OR SPEAR? -->
                                    <xsl:attribute name="xml:id" select="concat('person-', $record-id)"/>
                                    <xsl:attribute name="ana" select="'#syriaca-spear'"/>
                                    <!-- DEAL WITH SAINT NAMES -->
                                    <xsl:variable name="this-row" select="."/>    <!-- Used to permit reference to the current row within nested for-each statements -->
                                    <xsl:variable name="name-prefix">name<xsl:value-of select="$record-id"/>-</xsl:variable>
                                    <!-- DEAL WITH THE SYRIACA HEADWORDS  -->
                                    <!-- Below is simplified. If dealing with multiple sources, see how saints-spreadsheet2tei.xsl handles this. -->
                                    <!-- FOR SOME REASON, THIS IS PRODUCING A SPACE BEFORE THE SYRIAC. (SEE ABGAR.) -->
                                    <xsl:for-each select="Syriac_Canonical[.!='']">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($all-full-name-fields,'Syriac_Canonical')"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">syr</xsl:attribute>
                                            <xsl:attribute name="syriaca-tags">#syriaca-headword</xsl:attribute>
                                            <xsl:if test="(../Source_1 != '') or (../Source_2 != '')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Source_1')"/></xsl:attribute>                                                
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <!-- SHOULD THIS BE SOURCED? -->
                                    <xsl:for-each select="Canonical_Name[.!='']">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($all-full-name-fields,'Canonical_Name')"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">en-x-gedsh</xsl:attribute>
                                            <xsl:attribute name="syriaca-tags">#syriaca-headword</xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <!-- SHOULD THE NAME VARIANTS BE SOURCED? -->
                                    <!-- For multiple and potentially overlapping name forms from multiple sources, see how the saints-spreadsheet2tei.xsl handes this. -->
                                    <!-- NOW DEAL WITH THE ALTERNATE SYRIAC NAMES -->
                                    <xsl:for-each select="Name_Variant_1_SYR[.!='']">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($all-full-name-fields,'Name_Variant_1_SYR')"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">syr</xsl:attribute>
                                            <xsl:if test="(../Source_1 != '') or (../Source_2 != '')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Source_1')"/></xsl:attribute>                                                
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <!-- English names -->
                                    <xsl:for-each select="Name_Variant_1[.!='']">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($all-full-name-fields,'Name_Variant_1')"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">en</xsl:attribute>
                                            <xsl:if test="(../Source_1 != '') or (../Source_2 != '')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Source_1')"/></xsl:attribute>                                                
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <xsl:for-each select="Name_Variant_2[.!='']">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($all-full-name-fields,'Name_Variant_2')"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">en</xsl:attribute>
                                            <xsl:if test="(../Source_1 != '') or (../Source_2 != '')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Source_1')"/></xsl:attribute>                                                
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    
                                    <!-- ID numbers -->
                                    <!-- Syriaca.org id -->
                                    <idno type="URI">http://syriaca.org/person/<xsl:value-of select="$record-id"/></idno>
                                    <!-- Additional ID's -->
                                    <!--<xsl:for-each select="Fiey_ID[.!=''][matches(.,'\d*')]">
                                        <xsl:choose>
                                            <xsl:when test="preceding-sibling::Fiey_ID and . = preceding-sibling::Fiey_ID"/>
                                            <xsl:otherwise><idno type="FIEY"><xsl:value-of select="."/></idno></xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    <xsl:for-each select="Z1_[.!=''][matches(.,'\d*')] | *[starts-with(name(self::*),'Heading')][.!=''][matches(.,'\d*')]">
                                        <idno type="BHSYRE"><xsl:value-of select="."/></idno>
                                    </xsl:for-each>-->
                                    
                                    <!-- SEX -->
                                    <!--<xsl:if test="Sex != '' and Sex != 'N/A'"> <!-\- does this need a source? -\->
                                        <sex>
                                            <xsl:attribute name="value" select="Sex"/>
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <xsl:choose>
                                                <xsl:when test="Sex = 'M'">male</xsl:when>
                                                <xsl:when test="Sex = 'F'">female</xsl:when>
                                                <xsl:when test="Sex = 'E'">eunuch</xsl:when>
                                                <xsl:otherwise><xsl:value-of select="Sex"/></xsl:otherwise>
                                            </xsl:choose>
                                        </sex>
                                    </xsl:if>
                                    
                                    <!-\- BIRTH, DEATH, and FLORUIT dates -\->
                                    <xsl:for-each select="Birth[. != '']">
                                        <birth when="{normalize-space(.)}"  
                                            syriaca-computed-start="{syriaca:custom-dates(.)}">
                                            <xsl:if test="index-of($sources,'Fiey')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:value-of select="normalize-space(.)"/></birth>
                                    </xsl:for-each>
                                    <!-\- Death -\->
                                    <xsl:for-each select="Death[. != '']">
                                        <death when="{normalize-space(.)}"  
                                            syriaca-computed-start="{syriaca:custom-dates(.)}">
                                            <xsl:if test="index-of($sources,'Fiey')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:value-of select="normalize-space(.)"/></death>
                                    </xsl:for-each>
                                    <xsl:if test="*[starts-with(name(),'Floruit')][. != '']">
                                        <floruit>
                                            <xsl:if test="index-of($sources,'Fiey')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="Floruit_when[. != '']">
                                                <xsl:attribute name="when"><xsl:value-of select="normalize-space(Floruit_when)"/></xsl:attribute>
                                                <xsl:attribute name="syriaca-computed-start"><xsl:value-of select="normalize-space(Floruit_when)"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="Floruit_from[. != '']">
                                                <xsl:attribute name="from"><xsl:value-of select="normalize-space(Floruit_from)"/></xsl:attribute>
                                                <xsl:attribute name="syriaca-computed-start"><xsl:value-of select="normalize-space(Floruit_from)"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="Floruit_to[. != '']">
                                                <xsl:attribute name="to"><xsl:value-of select="normalize-space(Floruit_to)"/></xsl:attribute>
                                                <xsl:attribute name="syriaca-computed-end"><xsl:value-of select="normalize-space(Floruit_to)"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="Floruit_notBefore[. != '']">
                                                <xsl:attribute name="notBefore"><xsl:value-of select="normalize-space(Floruit_notBefore)"/></xsl:attribute>
                                                <xsl:attribute name="syriaca-computed-start"><xsl:value-of select="normalize-space(Floruit_notBefore)"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="Floruit_notAfter[. != '']">
                                                <xsl:attribute name="notAfter"><xsl:value-of select="normalize-space(Floruit_notAfter)"/></xsl:attribute>
                                                <xsl:attribute name="syriaca-computed-end"><xsl:value-of select="normalize-space(Floruit_notAfter)"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="Floruit_when[. != '']">
                                                <xsl:value-of select="Floruit_when"/>
                                            </xsl:if>
                                            <xsl:if test="Floruit_from[. != '']">
                                                <xsl:value-of select="Floruit_from"/>
                                                <xsl:if test="Floruit_to[. != '']">
                                                    <xsl:text>-</xsl:text>
                                                </xsl:if>
                                            </xsl:if>
                                            <xsl:if test="Floruit_to[. != '']">
                                                <xsl:value-of select="Floruit_to"/>
                                            </xsl:if>    
                                            <xsl:if test="Floruit_notBefore[. != '']">
                                                <xsl:value-of select="Floruit_notBefore"/>
                                                <xsl:if test="Floruit_notAfter[. != '']">
                                                    <xsl:text>-</xsl:text>
                                                </xsl:if>
                                            </xsl:if>
                                            <xsl:if test="Floruit_notAfter[. != '']">
                                                <xsl:value-of select="Floruit_notAfter"/>
                                            </xsl:if>  
                                        </floruit>
                                    </xsl:if>
                                    
                                    <xsl:if test="Martyr_[matches(.,'Yes')]">
                                        <state type="martyr">
                                            <xsl:if test="index-of($sources,'Fiey')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            </xsl:if>
                                            <p><xsl:text>Martyr</xsl:text></p>
                                        </state>
                                    </xsl:if>
                                    
                                    <xsl:if test="Bibliography[. !='']">
                                        <note><xsl:text>Fiey provides the following bibliographic citations: </xsl:text> 
                                            <quote>
                                                <xsl:if test="index-of($sources,'Fiey')">
                                                    <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="Bibliography"/>
                                            </quote>
                                        </note>
                                    </xsl:if>
                                    
                                    <!-\-NOTE:  Left overs from previouse code? -\->
                                    <xsl:choose>
                                        <xsl:when test="Dates != ''">
                                            <note type="dates">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                                <xsl:value-of select="Dates"/>
                                            </note>
                                        </xsl:when>
                                    </xsl:choose>
                                    <!-\- abstract-\->
                                    <xsl:if test="Short_Description_or_Abstract != ''">
                                        <note type="abstract"><xsl:value-of select="Short_Description_or_Abstract"/></note>
                                    </xsl:if>
                                    
                                    <!-\- VENERATION date -\->
                                    <xsl:if test="Veneration_Date != ''">
                                        <event type="veneration">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <desc>The saint is venerated on <xsl:value-of select="Veneration_Date"/>.</desc>
                                        </event>
                                    </xsl:if>
                                    
                                    <!-\- How do disambiguation? -\->
                                    <xsl:if test="Disambiguation_Notes != ''">
                                        <note type="disambiguation"><xsl:value-of select="Disambiguation_Notes"/></note>
                                    </xsl:if>
                                 
                                    <xsl:if test="Edit_notes != ''">
                                        <note type="misc">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <xsl:value-of select="Edit_notes"/>
                                        </note>
                                    </xsl:if>-->
                                    <!--
                                    <xsl:if test="Bibliography != ''">
                                        <note type="bibliography">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            Fiey cites <xsl:value-of select="Bibliography"/>
                                        </note>
                                    </xsl:if>
                                    -->
                                    <!-- ADD BIBLIOGRAPHY -->
                                    
                                    <xsl:if test="(Source_1 != '') or (Source_2 != '')">
                                        <bibl xml:id="bib{$record-id}-1">
                                            <title level="m" xml:lang="la">Chronica Minora</title>
                                            <ptr target="http://syriaca.org/bibl/633"/>
                                            <xsl:if test="page != ''">
                                                <citedRange unit="pp">
                                                    <xsl:for-each select="page">
                                                        <xsl:value-of select="."/><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                                    </xsl:for-each>    
                                                </citedRange>
                                            </xsl:if>
                                            <!-- SHOULD WE CALL THIS UNIT "SECTION" OR SOMETHING ELSE? -->
                                            <xsl:if test="Section != ''">
                                                <citedRange unit="section">
                                                    <xsl:for-each select="Section">
                                                        <xsl:value-of select="."/><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                                    </xsl:for-each>    
                                                </citedRange>
                                            </xsl:if>
                                        </bibl>
                                    </xsl:if>
                                    <!--Already commented out 10/5/15
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
                                    -->
                                </person>
                            </listPerson>
                            <!-- Finally, deal with relations to other entities 
                            <xsl:if test="Friends_with != '' or Fiey_Related != ''">
                                <note type="relation">This saint is related to persons <xsl:value-of select="Friends_with"/> and <xsl:value-of select="Fiey_Related"/>.</note>
                            </xsl:if>
                            <xsl:if test="Locations != '' or Cult_center != ''">
                                <note type="relation">This saint is related to places "<xsl:value-of select="Locations"/>" and "<xsl:value-of select="Cult_center"/>"</note>
                            </xsl:if>
                            -->
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="bib-ids"/>
        
        <xsl:variable name="english-headword">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(Canonical_Name)) != 0"><xsl:value-of select="Canonical_Name"/></xsl:when>
                <xsl:otherwise>Person <xsl:value-of select="$record-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="syriac-headword">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(Syriac_Canonical)) != 0"><xsl:value-of select="Syriac_Canonical"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="record-title">
            <xsl:value-of select="$english-headword"/>
            <xsl:if test="string-length($syriac-headword)"> — <foreign xml:lang="syr"><xsl:value-of select="$syriac-headword"/></foreign></xsl:if>
        </xsl:variable>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <!-- CHECK WHETHER THIS IS CORRECT! -->
                    <title level="a" xml:lang="en"><xsl:copy-of select="$record-title"/></title>
                    <title level="m">SPEAR: Syriac Persons Events and Relations</title>
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The International Balzan Prize Foundation</funder>
                    <funder>The National Endowment for the Humanities</funder>
                    <principal>David A. Michelson</principal>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L. Schwartz</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L. Schwartz</editor>
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L. Schwartz</name>
                    </respStmt>
                    <!-- MORE RESP STATEMENTS? -->
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
                            <!-- Removed copyright notice about Barsoum - unnecessary here. -->
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
                    <taxonomy>
                        <category xml:id="syriaca-author">
                            <catDesc>A person who is relevant to the Guide to Syriac Authors</catDesc>
                        </category>
                        <category xml:id="syriaca-saint">
                            <catDesc>A person who is relevant to the Bibliotheca Hagiographica
                                Syriaca.</catDesc>
                        </category>
                        <!-- WHAT ABOUT THE FOLLOWING CATEGORY FOR SPEAR? -->
                        <category xml:id="syriaca-spear">
                            <catDesc>A person who is relevant to the Syriac Persons Events and Relations.</catDesc>
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
                <change who="http://syriaca.org/documentation/editors.xml#ngibson" n="1.0">
                    <xsl:attribute name="when" select="current-date()"/>CREATED: person</change>
                <!--<xsl:if test="string-length(normalize-space(For_Post-Publication_Review))">
                    <change type="planned">
                        <xsl:value-of select="For_Post-Publication_Review"/>
                    </change>
                </xsl:if>-->
            </revisionDesc>
        </teiHeader>
    </xsl:template>
</xsl:stylesheet>