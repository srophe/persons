<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs functx syriaca" version="2.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:syriaca="http://syriaca.org"
    xmlns:functx="http://www.functx.com">
        
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
            <xsl:when test="string-length($trim-date) eq 3"><xsl:value-of select="concat('0',$trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 2"><xsl:value-of select="concat('00',$trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 1"><xsl:value-of select="concat('000',$trim-date,'-01-01')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$trim-date"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/root">
        <!-- [not(starts-with(SRP_ID,'F'))] -->
        <xsl:for-each select="row">
            <xsl:variable name="record-id">
                <xsl:choose>
                    <xsl:when test="URI != ''"><xsl:value-of select="URI"/></xsl:when>
                    <xsl:when test="SRP_ID != ''"><xsl:value-of select="SRP_ID"/></xsl:when>
                    <xsl:when test="SRP_Saint_ID != ''"><xsl:value-of select="SRP_Saint_ID"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="concat('unresolved-',generate-id())"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- Creates a variable containing the path of the file that should be created for this record. -->
            <xsl:variable name="filename">
                <xsl:choose>
                    <xsl:when test="GEDSH_Romanized_Name[.=''] or Syriac_Headword[.='']">
                        <xsl:value-of select="concat('../new-saints-data/incomplete/tei/',$record-id,'.xml')"/>
                    </xsl:when>
                    <xsl:when test="URI != ''"><xsl:value-of select="concat('../new-saints-data/new-saints/tei/',$record-id,'.xml')"/></xsl:when>
                    <xsl:when test="SRP_ID != ''"><xsl:value-of select="concat('../new-saints-data/overlap/',$record-id,'.xml')"/></xsl:when>
                    <xsl:when test="SRP_Saint_ID !=''"><xsl:value-of select="concat('../new-saints-data/srp-saint-no-uri/tei/',$record-id,'.xml')"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="concat('../new-saints-data/unresolved/tei/',$record-id,'.xml')"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="URI != ''">
            <xsl:result-document href="{$filename}" format="xml">
                <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$n"/>
                
                <!-- determine which sources will need to be cited; to be used in header formation as well -->
                <xsl:variable name="bib-prefix">bibl<xsl:value-of select="$record-id"/>-</xsl:variable>
                <xsl:variable name="sources" as="xs:string*">
                    <xsl:if test="Fiey_ID[. != ''] or Raw_Fiey_Name != '' or Fiey_Name != '' or v_see_also_French != '' or Dates != '' or Locations != '' or Veneration_Date != '' or Bibliography != '' or Fiey_Related != ''">
                        <xsl:sequence select="('Fiey')"/>
                    </xsl:if>
                    <xsl:if test="Z1_[.!=''][matches(.,'\d*')] | *[starts-with(name(self::*),'Fiche')][.!=''][matches(.,'\d*')]">
                    <!--<xsl:if test="Syr_Name != '' or Syr_Name_2 != '' or Syr_Name_3 != '' or Syr_Name_4 != '' or Zanetti_Transcr. != '' or Zan_Tran_2 != '' or Fr_Name_1 != '' or Fr_Name_2 != '' or Fr_Name_3 != '' or Fr_Name_4 != '' or Fr_Name_5 != '' or Zanetti_Numbers != '' or Z1_ != ''">-->
                        <xsl:sequence select="('Zanetti')"/>
                    </xsl:if>
                </xsl:variable>
                <!-- therefore the xml:id of the <bibl> element representing a source is $bib-prefix followed by the index of the source name in the $sources sequence -->
                <!-- and the citation format is #<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/> for Fiey, etc. -->
                <xsl:variable name="all-full-names">
                    <xsl:copy-of select="GEDSH_Romanized_Name | Syriac_Headword | Syr_Name | Syr_Name_2| Syr_Name_3
                        | Syr_Name_4
                        | Zanetti_Transcr.
                        | Zan_Tran_2
                        | Nam_Eng
                        | Eng_2
                        | Eng_3
                        | Fr_Name_1
                        | Fr_Name_2
                        | Fr_Name_3
                        | Fr_Name_4
                        | Fr_Name_5
                        | Fiey_Name "></xsl:copy-of>
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
                                    <xsl:attribute name="xml:id" select="concat('saint-', $record-id)"/>
                                    <xsl:attribute name="ana" select="'#syriaca-saint'"/>
                                    <!-- DEAL WITH SAINT NAMES -->
                                    <xsl:variable name="this-row" select="."/>    <!-- Used to permit reference to the current row within nested for-each statements -->
                                    <xsl:variable name="name-prefix">name<xsl:value-of select="$record-id"/>-</xsl:variable>
                                    <!-- DEAL WITH THE SYRIAC HEADWORDS  -->
                                    <xsl:if test="Syriac_Headword != ''">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/>1</xsl:attribute>
                                            <xsl:attribute name="xml:lang">syr</xsl:attribute>
                                            <xsl:attribute name="syriaca-tags">#syriaca-headword</xsl:attribute>
                                            <xsl:if test="Z1_[.!=''][matches(.,'\d*')] | *[starts-with(name(self::*),'Fiche')][.!=''][matches(.,'\d*')]">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>                                                
                                            </xsl:if>
                                            <xsl:value-of select="Syriac_Headword"/>
                                        </persName>
                                    </xsl:if>
                                    <xsl:if test="GEDSH_Romanized_Name != ''">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/>2</xsl:attribute>
                                            <xsl:attribute name="xml:lang">en-x-gedsh</xsl:attribute>
                                            <xsl:attribute name="syriaca-tags">#syriaca-headword</xsl:attribute>
                                            <xsl:value-of select="GEDSH_Romanized_Name"/>
                                        </persName>
                                    </xsl:if>
                                    
                                    <!-- NOW DEAL WITH THE SYRIAC NAMES -->
                                    <!-- create one <persName> per name form, with @source citing multiple sources as necessary -->
                                    <!-- to do that, first we need to create a sequence of all name forms, then remove duplicates -->
                                    <xsl:variable name="syriac-names-with-duplicates" as="xs:string*">
                                        <xsl:if test="Syr_Name != ''">
                                            <xsl:choose>
                                                <xsl:when test="contains(Syr_Name,'/')"><xsl:sequence select="tokenize(Syr_Name,'/')"/></xsl:when>
                                                <xsl:otherwise><xsl:sequence select="Syr_Name"/></xsl:otherwise>
                                            </xsl:choose>
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
                                    <xsl:variable name="num-syriac-names" select="count($syriac-names)"/>
                                    <xsl:for-each select="$syriac-names[. != $this-row/Syriac_Headword]">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($syriac-names,.) + 1"/></xsl:attribute>
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
                                    <!-- First deal with English names -->
                                    <!-- create one <persName> per name form, with @source citing multiple sources as necessary -->
                                    <!-- to do that, first we need to create a sequence of all name forms, then remove duplicates -->
                                    <xsl:variable name="english-names-with-duplicates" as="xs:string*">
                                        <xsl:if test="Nam_Eng != ''">
                                            <xsl:choose>
                                                <xsl:when test="contains(Nam_Eng,'/')"><xsl:sequence select="tokenize(Nam_Eng,'/')"/></xsl:when>
                                                <xsl:otherwise><xsl:sequence select="Nam_Eng"/></xsl:otherwise>
                                            </xsl:choose>
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

                                    <xsl:for-each select="$english-names[. != $this-row/GEDSH_Romanized_Name]">
                                        <persName>
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($english-names,.) + $num-syriac-names + 1"/></xsl:attribute>
                                            <xsl:attribute name="xml:lang">en</xsl:attribute>
                                            <!--<xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Zanetti')"/></xsl:attribute>-->
                                            <!--<xsl:attribute name="resp">http://syriaca.org/</xsl:attribute>-->
                                            
                                            <!-- finally output the value of the <persName> element, the name form itself -->
                                            <xsl:value-of select="."/>
                                        </persName>
                                    </xsl:for-each>
                                    <xsl:variable name="num-english-names" select="count($english-names)"/>
                                    <xsl:variable name="num-non-french-names" select="$num-syriac-names + $num-english-names"/>
                                    
                                    <!-- NOW DEAL WITH FRENCH NAMES -->
                                    <!-- create one <persName> per name form, with @source citing multiple sources as necessary -->
                                    <!-- to do that, first we need to create a sequence of all name forms, then remove duplicates -->
                                    <xsl:variable name="french-names-with-duplicates" as="xs:string*">
                                        <xsl:if test="Zanetti_Transcr. != ''">
                                            <xsl:choose>
                                                <xsl:when test="contains(Zanetti_Transcr.,'/')"><xsl:sequence select="tokenize(Zanetti_Transcr.,'/')"/></xsl:when>
                                                <xsl:otherwise><xsl:sequence select="Zanetti_Transcr."/></xsl:otherwise>
                                            </xsl:choose>
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
                                            <xsl:attribute name="xml:id"><xsl:value-of select="$name-prefix"/><xsl:value-of select="index-of($french-names,.) + $num-non-french-names + 1"/></xsl:attribute>
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
                                    <!-- Syriaca.org id -->
                                    <idno type="URI">http://syriaca.org/person/<xsl:value-of select="$record-id"/></idno>
                                    <!-- Additional ID's -->
                                    <xsl:for-each select="Fiey_ID[.!=''][matches(.,'\d*')]">
                                        <xsl:choose>
                                            <xsl:when test="preceding-sibling::Fiey_ID and . = preceding-sibling::Fiey_ID"/>
                                            <xsl:otherwise><idno type="FIEY"><xsl:value-of select="."/></idno></xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    <!-- Do we still need this? -->
                                     <xsl:for-each select="Fiche[normalize-space(.) != '']">
                                        <idno type="BHS"><xsl:value-of select="."/></idno>
                                    </xsl:for-each>
                                    
                                    <!-- SEX -->
                                    <xsl:if test="Sex != '' and Sex != 'N/A'"> <!-- does this need a source? -->
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
                                    
                                    <!-- BIRTH, DEATH, and FLORUIT dates -->
                                    <xsl:for-each select="Birth[. != '']">
                                        <birth when="{normalize-space(.)}"  
                                            syriaca-computed-start="{syriaca:custom-dates(.)}">
                                            <xsl:if test="index-of($sources,'Fiey')">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            </xsl:if>
                                            <xsl:value-of select="normalize-space(.)"/></birth>
                                    </xsl:for-each>
                                    <!-- Death -->
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
                                    
                                    <!--NOTE:  Left overs from previouse code? -->
                                    <xsl:choose>
                                        <xsl:when test="Dates != ''">
                                            <note type="dates">
                                                <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                                <xsl:value-of select="Dates"/>
                                            </note>
                                        </xsl:when>
                                    </xsl:choose>
                                    <!-- abstract-->
                                    <xsl:if test="Short_Description_or_Abstract != ''">
                                        <note type="abstract"><xsl:value-of select="Short_Description_or_Abstract"/></note>
                                    </xsl:if>
                                    
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
                                 
                                    <xsl:if test="Edit_notes != ''">
                                        <note type="misc">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            <xsl:value-of select="Edit_notes"/>
                                        </note>
                                    </xsl:if>
                                    <!--
                                    <xsl:if test="Bibliography != ''">
                                        <note type="bibliography">
                                            <xsl:attribute name="source">#<xsl:value-of select="$bib-prefix"/><xsl:value-of select="index-of($sources,'Fiey')"/></xsl:attribute>
                                            Fiey cites <xsl:value-of select="Bibliography"/>
                                        </note>
                                    </xsl:if>
                                    -->
                                    <!-- ADD BIBLIOGRAPHY -->
                                    
                                    <xsl:if test="Z1_[.!=''][matches(.,'\d*')] | *[starts-with(name(self::*),'Fiche')][.!=''][matches(.,'\d*')]">
                                        <bibl xml:id="bib{$record-id}-1">
                                            <title level="m" xml:lang="la">Bibliotheca Hagiographica Syriaca</title>
                                            <ptr target="http://syriaca.org/bibl/649"/>
                                            <citedRange unit="entry">
                                                <xsl:for-each select="Fiche[normalize-space(.) != '']">
                                                    <xsl:value-of select="."/><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                                                </xsl:for-each>    
                                            </citedRange>
                                        </bibl>
                                    </xsl:if>
                                    <xsl:if test="Fiey_ID[.!='']">
                                        <xsl:variable name="num">
                                            <xsl:choose>
                                                <xsl:when test="Z1_[.!=''][matches(.,'\d*')] | *[starts-with(name(self::*),'Fiche')][.!=''][matches(.,'\d*')]">2</xsl:when>
                                                <xsl:otherwise>1</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <bibl xml:id="bib{$record-id}-{$num}">
                                            <title level="m" xml:lang="fr">Saints Syriaques</title>
                                            <title level="a" xml:lang="fr"><xsl:value-of select="Fiey_Name"/></title>
                                            <ptr target="http://syriaca.org/bibl/650"/>    
                                            <citedRange unit="entry"><xsl:value-of select="Fiey_ID[1]"/></citedRange>                                            
                                        </bibl>
                                    </xsl:if>
                                    <xsl:variable name="fieyid" select="Fiey_ID[1]"/>
                                    <xsl:for-each select="doc('fiey-bibl.xml')//descendant::tei:listBibl[tei:head/text() = $fieyid]">
                                        <xsl:for-each select="tei:bibl">
                                            <xsl:choose>
                                                <xsl:when test="tei:note and not(tei:note/following-sibling::*)">
                                                    <xsl:copy-of select="child::*"/>
                                                </xsl:when>
                                                <xsl:when test="not(child::*) and text()">
                                                    <note><xsl:value-of select="."/></note>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:variable name="num" select="position() + 2"/>
                                                    <bibl xml:id="bib{$record-id}-{$num}">
                                                        <xsl:copy-of select="child::*"/>
                                                    </bibl>                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>  
                                    </xsl:for-each>
                                    <!--
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
                <xsl:when test="string-length(normalize-space(GEDSH_Romanized_Name)) != 0"><xsl:value-of select="GEDSH_Romanized_Name"/></xsl:when>
                <xsl:otherwise>Person <xsl:value-of select="$record-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="syriac-headword">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(Syriac_Headword)) != 0"><xsl:value-of select="Syriac_Headword"/></xsl:when>
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
                    <title level="m">Qadishe: A Guide to the Syriac Saints</title>
                    <title level="s">Gateway to the Syriac Saints</title>
                    <title level="s">The Syriac Biographical Dictionary</title>
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The International Balzan Prize Foundation</funder>
                    <funder>The National Endowment for the Humanities</funder>
                    <principal>David A. Michelson</principal>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</name>
                    </respStmt>
                    <respStmt>
                        <resp>Data architecture and encoding by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Editing, Syriac data conversion, data entry, and reconciling by</resp>
                        <name ref="http://syriaca.org/editors.xml#akane">Adam P. Kane</name>
                    </respStmt>
                    <respStmt>
                        <resp>Editing and Syriac data proofreading by</resp>
                        <name ref="http://syriaca.org/editors.xml#abarschabo">Aram Bar Schabo</name>
                    </respStmt>
                    <respStmt>
                        <resp>Entries adapted from the work of</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#jmfiey">Jean Maurice Fiey</name>
                    </respStmt>
                    <respStmt>
                        <resp>Entries adapted from the work of</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#uzanetti">Ugo Zanetti</name>
                    </respStmt>
                    <respStmt>
                        <resp>Entries adapted from the work of</resp>
                        <name type="person" ref="http://syriaca.org/editors.xml#cdetienne">Claude Detienne</name>
                    </respStmt>
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
                <seriesStmt>
                    <title level="s">Gateway to the Syriac Saints</title>
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent"
                        >Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                        Michelson</editor>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent"
                            >Jeanne-Nicole Mellon Saint-Laurent</name>
                    </respStmt>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                            Michelson</name>
                    </respStmt>
                    <biblScope unit="vol">2</biblScope>
                    <idno type="URI">http://syriaca.org/q</idno>
                </seriesStmt>
                <seriesStmt>
                    <title level="s">The Syriac Biographical Dictionary</title>
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                        Michelson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#tcarlson"
                        >Thomas A. Carlson</editor><editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P.
                        Gibson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent"
                        >Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                            Michelson</name>
                    </respStmt><respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ef="http://syriaca.org/documentation/editors.xml#tcarlson"
                            >Thomas A. Carlson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P.
                            Gibson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent"
                            >Jeanne-Nicole Mellon Saint-Laurent</name>
                    </respStmt>
                    <biblScope unit="vol">2</biblScope>
                    <idno type="URI">http://syriaca.org/persons</idno>
                </seriesStmt>
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
                    <xsl:attribute name="when" select="current-date()"/>CREATED: person</change>
                <xsl:if test="string-length(normalize-space(For_Post-Publication_Review))">
                    <change type="planned">
                        <xsl:value-of select="For_Post-Publication_Review"/>
                    </change>
                </xsl:if>
            </revisionDesc>
        </teiHeader>
    </xsl:template>
</xsl:stylesheet>