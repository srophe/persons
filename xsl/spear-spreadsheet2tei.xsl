<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:syriaca="http://syriaca.org">
    
    <!-- FORMAT OF COMMENTS -->
    <!-- ??? Indicates an issue that needs resolving. -->
    <!-- ALL CAPS is a section header. -->
    <!-- !!! Shows items that may need to be changed/customized when running this template on a new spreadsheet. -->
    <!-- lower case comments explain the code -->
    
    <!-- FILE OUTPUT PROCESSING -->
    <!-- specifies how the output file will look -->
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" />
    
    <!-- ??? Not sure what these variables do -->
    <xsl:variable name="n">
        <xsl:text></xsl:text>
    </xsl:variable>
    <xsl:variable name="s"><xsl:text> </xsl:text></xsl:variable>
    
    <!-- ??? Switch over the below to use @sourceUriColumn -->
    <!-- ??? Add date processing -->
    <!-- ??? Add additional references -->
    
    <!-- COLUMN MAPPING FROM INPUT SPREADSHEET -->
    <!-- !!! When modifying this stylesheet for a new spreadsheet, you should (in most cases) only need to  
            1. change the contents of the $column-mapping variable below,
            2. change the TEI header information, 
            3. change the $directory (optional), and
            4. add to the column-mapping and bibls TEMPLATES any attributes that we haven't used before. 
            NB: * Each column in the spreadsheet must contain data from only one source.
                * The spreadsheet must contain a column named "New_URI". This column should not be "mapped" below; it is hard-coded into the stylesheet.
                * Spreadsheet columns containing citedRange data should be mapped using the $all-sources variable below.
                * Each record should have at least one column marked with syriaca-tags="#syriaca-headword", otherwise it will be placed into the "incomplete" folder.
                * It's fine to map multiple spreadsheets below, as long as they don't contain columns with the same names but different attributes (e.g., @source or @xml:lang). 
                * Columns for <sex> element will go into the @value. If they contain the abbreviations "M" or "F", then "male" and "female" will be inserted into the element content.
                * The column-mapping template (see below) defines content of the <state> element as nested inside <desc> (needed for valid TEI) -->
    <xsl:variable name="column-mapping">
        <!-- auto column mapping using default column names -->
        <xsl:for-each select="/root/row[1]/*">
            <xsl:variable name="element-name" as="xs:string">
                <xsl:choose>
                    <xsl:when test="matches(name(),'^persName[\._]')">persName</xsl:when>
                    <xsl:when test="matches(name(),'^sex[\._]')">sex</xsl:when>
                    <xsl:when test="matches(name(),'^state[\._]')">state</xsl:when>
                    <xsl:when test="matches(name(),'^birth[\._]')">birth</xsl:when>
                    <xsl:when test="matches(name(),'^death[\._]')">death</xsl:when>
                    <xsl:when test="matches(name(),'^floruit[\._]')">floruit</xsl:when>
                    <xsl:when test="matches(name(),'^citedRange[\._]')">floruit</xsl:when>
                    <xsl:otherwise>none</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$element-name!='none'">
                <xsl:element name="{$element-name}">
                    <!-- add @xml:lang -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'\.en-x-gedsh$')"><xsl:attribute name="xml:lang" select="'en-x-gedsh'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.en$')"><xsl:attribute name="xml:lang" select="'en'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.syr$')"><xsl:attribute name="xml:lang" select="'syr'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.syr-Syrj$')"><xsl:attribute name="xml:lang" select="'syr-Syrj'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.syr-Syrn$')"><xsl:attribute name="xml:lang" select="'syr-Syrn'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.ar$')"><xsl:attribute name="xml:lang" select="'ar'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.fr$')"><xsl:attribute name="xml:lang" select="'fr'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.de$')"><xsl:attribute name="xml:lang" select="'de'"/></xsl:when>
                        <xsl:when test="matches(name(),'\.la$')"><xsl:attribute name="xml:lang" select="'la'"/></xsl:when>
                    </xsl:choose>
                    <!-- add office -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_office')"><xsl:attribute name="type" select="'office'"/></xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="column" select="name()"/>
                    <!-- add unit -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_pp')"><xsl:attribute name="unit" select="'pp'"/></xsl:when>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_section')"><xsl:attribute name="unit" select="'section'"/></xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="column" select="name()"/>
                    <!-- add syriaca-headword -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_syriaca-headword')"><xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/></xsl:when>
                    </xsl:choose>
                    <!-- add sourceUriColumn -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'\.Source_[0-9]*[\.$]')">
                            <xsl:variable name="tokenized-column-name" select="tokenize(name(),'\.')"/>
                            <xsl:variable name="source-name">
                                <xsl:for-each select="$tokenized-column-name">
                                    <xsl:if test="matches(.,'^Source_[0-9]*')"><xsl:value-of select="."/></xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:variable name="column-prefix" select="substring-before(name(),'Source_1')"/>
                            <xsl:variable name="column-suffix" select="substring-after(name(),'Source_1')"/>
                            <!-- removes column prefix and suffix, leaving only the "Source 1" and so on -->
                            <xsl:attribute name="sourceUriColumn" select="$source-name"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="column" select="name()"/>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
        <!-- column mapping from spear-severus.xml -->
        <persName xml:lang="en" source="http://syriaca.org/bibl/foo1" syriaca-tags="#syriaca-headword" column="Name_in_Index"/>
        <note xml:lang="en" type="abstract" column="Additional_Info"/>
        <!-- column mapping from spear-chronicle.xml -->
        <persName xml:lang="en-x-gedsh" syriaca-tags="#syriaca-headword" column="Canonical_Name"/>
        <persName xml:lang="syr" sourceUriColumn="Source_1" syriaca-tags="#syriaca-headword" column="Syriac_Canonical"/>
        <persName xml:lang="syr" sourceUriColumn="Source_1" column="Name_Variant_1_SYR"/>
        <persName xml:lang="en" sourceUriColumn="Source_2" column="Name_Variant_1"/>
        <persName xml:lang="en" sourceUriColumn="Source_2" column="Name_Variant_2"/>
        <sex xml:lang="en" sourceUriColumn="Source_2" column="Sex"/>
        <state xml:lang="en" type="role" sourceUriColumn="Source_2" column="Office"/>
        <citedRange unit="pp" sourceUriColumn="Source_1" column="page"/>
        <citedRange unit="section" sourceUriColumn="Source_2" column="Section"/>
    </xsl:variable>
    
    <!-- ??? The following is an example of how the bibl info could be grabbed automatically -->
<!--    <xsl:variable name="bibl-url" select="'http://syriaca.org/bibl/633/tei'"/>-->
    
    <!-- BIBL ELEMENTS TO USE AS SOURCES -->
    <!-- !!! Modify/add bibl elements here. You MUST put in a @column attribute on citedRange to specify which spreadsheet column the page num.,etc. comes from. -->
    <!-- @xml:id and <citedRange> will be added automatically based on $column-mapping -->
    <!--<xsl:variable name="all-sources">
        <!-\- bibl source mapping for spear-severus.xml -\->
        <!-\- ??? Placeholder ptr/@target URIs being used here -\->
        <bibl>
            <!-\- ??? Is this the right title @level? -\->
            <title xml:lang="en" level="a">A Collection of Letters of Severus of Antioch from Numerous Syriac Manuscripts</title>
            <ptr target="http://syriaca.org/bibl/foo2"/>
            <biblScope unit="fascicle">1</biblScope>
            <citedRange unit="pp" column="PO_12"/>
        </bibl>
        <bibl>
            <!-\- ??? Is this the right title @level? -\->
            <title xml:lang="en" level="a">A Collection of Letters of Severus of Antioch from Numerous Syriac Manuscripts</title>
            <ptr target="http://syriaca.org/bibl/foo3"/>
            <biblScope unit="fascicle">2</biblScope>
            <citedRange unit="pp" column="PO_14"/>
        </bibl>
        <bibl>
            <title xml:lang="en">The Sixth Book of the Select Letters of Severus, Patriarch of Antioch in the Syriac Version of Athanasius of Nisibis</title>
            <title type="sub">Translation, I.1 - II.3</title>
            <!-\- ??? Conflict between bibl/665 here and in bibl URIs spreadsheet -\->
            <ptr target="http://syriaca.org/bibl/665-1"/>
            <citedRange unit="pp" column="SL_Vol._II.I"/>
        </bibl>
        <bibl>
            <title xml:lang="en">The Sixth Book of the Select Letters of Severus, Patriarch of Antioch in the Syriac Version of Athanasius of Nisibis</title>
            <title type="sub">Translation, III.1 - XI.1</title>
            <!-\- ??? Conflict between bibl/665 here and in bibl URIs spreadsheet -\->
            <ptr target="http://syriaca.org/bibl/665-2"/>
            <citedRange unit="pp" column="SL_Vol._II.II"/>
        </bibl>
        <!-\- bibl source mapping for spear-chronicle.xml -\->
        <bibl>
            <!-\- ??? The following is an example of how the bibl info could be grabbed automatically -\->
<!-\-            <xsl:copy-of select="document($bibl-url)/TEI/teiHeader/fileDesc/titleStmt/title" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>-\->
            <title xml:lang="la" level="m">Chronica Minora</title>
            <ptr target="http://syriaca.org/bibl/633"/>
            <citedRange unit="pp" column="page"/>
        </bibl>
        <bibl>
            <title level="a" xml:lang="en">Selections from the Syriac. No. 1: The Chronicle of Edessa</title>
            <ptr target="http://syriaca.org/bibl/657"/>
            <citedRange unit="section" column="Section"/>
        </bibl>
    </xsl:variable>-->
    
    <!-- !!! Change this to where you want the files to be placed relative to this stylesheet. 
        This should end with a trailing slash (/).-->
    <xsl:variable name="directory">../../working-files-2/persons/tei/</xsl:variable>
    
    <!-- this is the main template that processes each row of the spreadsheet -->
    <xsl:template match="/root">
        <!-- creates ids for new persons. -->
        <!-- ??? How should we deal with matched persons, where the existing TEI records need to be supplemented? -->
        <xsl:for-each select="row">
            <xsl:variable name="record-id">
                <xsl:choose>
                    <!-- creates a new record with the URI from the spreadsheet, when the URI field is not blank -->
                    <xsl:when test="New_URI != ''"><xsl:value-of select="New_URI"/></xsl:when>
                    <!-- if the URI field is blank, creates the record with 'unresolved' and an autogenerated id -->
                    <xsl:otherwise><xsl:value-of select="concat('unresolved-',generate-id())"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- creates bibls using the $all-sources variable the citedRange for this particular row -->
            <xsl:variable name="record-bibls">
                <xsl:call-template name="bibls">
                    <xsl:with-param name="record-id" select="$record-id"/>
                    <xsl:with-param name="this-row" select="*[.!='']"/>
                </xsl:call-template>
            </xsl:variable>
            
            <!-- uses the $column-mapping variable to convert spreadsheet columns into correct format -->
            <xsl:variable name="converted-columns">
                <xsl:call-template name="column-mapping">
                    <xsl:with-param name="columns-to-convert" select="*[.!='']"/>
                    <xsl:with-param name="record-bibls" select="$record-bibls"/>
                </xsl:call-template>
            </xsl:variable>            
            
            <!-- creates a variable containing the path of the file that should be created for this record, in the location defined by $directory -->
            <xsl:variable name="filename">
                <xsl:choose>
                    <!-- tests whether there is sufficient data to create a complete record and puts it in an 'incomplete' folder if not -->
                    <xsl:when test="empty($converted-columns/*[@syriaca-tags='#syriaca-headword'])">
                        <xsl:value-of select="concat($directory,'/incomplete/',$record-id,'.xml')"/>
                    </xsl:when>
                    <!-- if record is complete and has a URI, puts it in this folder -->
                    <xsl:when test="New_URI != ''"><xsl:value-of select="concat($directory,$record-id,'.xml')"/></xsl:when>
                    <!-- if record doesn't have a URI, puts it in 'unresolved' folder -->
                    <xsl:otherwise><xsl:value-of select="concat($directory,'unresolved/',$record-id,'.xml')"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- creates the XML file, as long as the filename has been sucessfully created. -->
            <xsl:if test="$filename != ''">
                <xsl:result-document href="{$filename}" format="xml">
                    <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
                    <xsl:value-of select="$n"/>
                    
                    
            <TEI xml:lang="en" xmlns="http://www.tei-c.org/ns/1.0">
                <!-- Adds header -->
                <xsl:call-template name="header">
                    <xsl:with-param name="record-id" select="$record-id"/>
                    <xsl:with-param name="converted-columns" select="$converted-columns"/>
                </xsl:call-template>
                <text>
                    <body>
                        <listPerson>
                            <person>
                                <xsl:attribute name="xml:id" select="concat('person-', $record-id)"/>
                                <!-- DEAL WITH PERSON NAMES -->
                                <xsl:variable name="this-row" select="."/>    <!-- Used to permit reference to the current row within nested for-each statements -->
                                <xsl:variable name="name-prefix">name<xsl:value-of select="$record-id"/>-</xsl:variable>
                                
                                <!-- ??? Need persName xml:ids? -->
                                <!-- gets the persName columns that have been converted from the spreadsheet in the $converted-columns variable -->
                                <xsl:copy-of select="$converted-columns/persName" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                
                                <!-- gets the persName columns that have been converted from the spreadsheet in the $converted-columns variable -->
                                <xsl:copy-of select="$converted-columns/note" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                
                                <!-- gives the person URI as an idno -->
                                <xsl:if test="New_URI != ''"><idno type="URI"><xsl:value-of select="concat('http://syriaca.org/person/',New_URI)"></xsl:value-of></idno></xsl:if>
                                                   
                                <!-- gets the state columns that have been converted from the spreadsheet in the $converted-columns variable -->
                                <xsl:copy-of select="$converted-columns/state" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                
                                <!-- inserts sex columns that have been converted from the spreadsheet in the $converted-columns variable -->
                                <xsl:copy-of select="$converted-columns/sex" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                             
                                <!-- inserts bibl elements -->
                                <xsl:copy-of select="$record-bibls/bibl" xpath-default-namespace="http://www.tei-c.org/ns/1.0" copy-namespaces="no"/>
                                                    
                            </person>
                        </listPerson>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
        
    </xsl:if>
    
</xsl:for-each>
        
    </xsl:template>
    
    <!-- ??? Update the following! -->
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="converted-columns"/>
        <xsl:variable name="english-headword">
            <!-- checks whether there is an English Syriaca headword. If not, just uses the record-id as the page title. -->
            <xsl:choose>
                <xsl:when test="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang, 'en')]"><xsl:value-of select="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang, 'en')]"/></xsl:when>
                <xsl:otherwise>Person <xsl:value-of select="$record-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="syriac-headword">
            <!-- grabs the Syriaca Syriac headword, if there is one. -->
            <xsl:choose>
                <xsl:when test="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang,'syr')]"><xsl:value-of select="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang,'syr')]"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- combines the English and Syriac headwords to make the record title -->
        <xsl:variable name="record-title">
            <xsl:value-of select="$english-headword"/>
            <xsl:if test="string-length($syriac-headword)"> — <foreign xml:lang="syr"><xsl:value-of select="$syriac-headword"/></foreign></xsl:if>
        </xsl:variable>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title level="a" xml:lang="en"><xsl:copy-of select="$record-title"/></title>
                    <!-- ??? Make sure to add the series title and series statements for persons who are also saints or authors. Also, change SBD vol. number (biblScope) in series statement if author or saint. -->
                    <title level="s">The Syriac Biographical Dictionary</title>
                    <!-- ??? Add title for saints or authors -->
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The National Endowment for the Humanities</funder>
                    <principal>David A. Michelson</principal>
                    <editor role="general" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A. Carlson</editor>
                    <editor role="associate"
                            ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P. Gibson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L. Schwartz</editor>
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L. Schwartz</name>
                    </respStmt>
                    <respStmt>
                        <resp>Data architecture and encoding by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Syriac data conversion and reconciling by</resp>
                        <name ref="http://syriaca.org/editors.xml#ngibson">Nathan P. Gibson</name>
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
                            <!-- !!! If copyright material is included, the following can be adapted. -->
                            <!--<xsl:if test="*[matches(name(),'Barsoum_syr|Barsoum_ar') and string-length(normalize-space(node()))]">
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
                            </xsl:if>-->
                        </licence>
                    </availability>
                    <date>
                        <xsl:value-of select="current-date()"/>
                    </date>
                </publicationStmt>
                <seriesStmt>
                    <title level="s">The Syriac Biographical Dictionary</title>
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                        Michelson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A. Carlson</editor>
                    <editor role="associate"
                            ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P. Gibson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                            Michelson</name>
                    </respStmt>
                    <respStmt>
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
                            ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</name>
                    </respStmt>
                    <biblScope unit="vol">3</biblScope>
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
                        <!-- ??? syriaca-person? -->
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
                <!-- ??? Are there any change @type='planned' ? -->
            </revisionDesc>
        </teiHeader>
    </xsl:template>
    
    <!-- converts spreadsheet columns using $column-mapping variable above -->
    <!-- ??? This template does not yet try to reconcile identical elements coming from different sources -->
    <xsl:template name="column-mapping" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="columns-to-convert"/>
        <xsl:param name="record-bibls"/>
        <xsl:for-each select="$columns-to-convert">
            <xsl:variable name="column-name" select="name()"/>
            <xsl:variable name="column-contents"><xsl:value-of select="."/></xsl:variable>
            <xsl:for-each select="$column-mapping/*">
                <xsl:variable name="source-uri-column" select="@sourceUriColumn"/>
                <xsl:variable name="column-source" select="concat('http://syriaca.org/bibl/',$columns-to-convert[name()=$source-uri-column])"/>
                <xsl:if test="@column=$column-name">
                    <xsl:element name="{name()}">
                        <xsl:if test="@xml:lang!=''"><xsl:attribute name="xml:lang" select="@xml:lang"/></xsl:if>
                        <xsl:if test="@type!=''"><xsl:attribute name="type" select="@type"/></xsl:if>
                        <xsl:if test="@sourceUriColumn!=''"><xsl:attribute name="source" select="concat('#',$record-bibls/*[tei:ptr/@target=$column-source]/@xml:id)"/></xsl:if>
                        <xsl:if test="@syriaca-tags!=''"><xsl:attribute name="syriaca-tags" select="@syriaca-tags"/></xsl:if>
                    <xsl:choose>
                        <!-- ??? Syriac names have extra spaces in them. Can't seem to get normalize-space() to do the trick.-->
                        <xsl:when test="name()='state'">
                            <xsl:element name="desc"><xsl:value-of select="$column-contents"/></xsl:element>
                        </xsl:when>
                        <xsl:when test="name()='sex'">
                            <xsl:attribute name="value" select="$column-contents"/>
                            <xsl:choose>
                                <xsl:when test="$column-contents='M'">male</xsl:when>
                                <xsl:when test="$column-contents='F'">female</xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="$column-contents"/></xsl:otherwise>
                    </xsl:choose>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- creates bibl elements -->
    <xsl:template name="bibls" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="this-row"/>
        <xsl:variable name="sources" select="distinct-values($column-mapping//@sourceUriColumn)"/>
        <xsl:for-each select="$sources">
            <xsl:variable name="source-uri-column" select="."/>
            <xsl:for-each select="$this-row">
                <xsl:variable name="this-column" select="name()"/>
                <!-- gets the citedRange from $column-mapping that names this column as its @sourceUriColumn -->
                <xsl:variable name="this-cited-range" select="$column-mapping/citedRange[@sourceUriColumn=$this-column]"/>
                <xsl:if test="name()=$source-uri-column">
                    <xsl:variable name="bibl-url" select="concat('http://syriaca.org/bibl/',.,'/tei')"></xsl:variable>
                    <bibl>
                        <xsl:attribute name="xml:id" select="concat('bib',$record-id,'-',index-of($sources,$source-uri-column))"/>
                        <!-- ??? What info do we want to include here - just the title or more? The title of the TEI doc or the title of the described bibl? -->
                        <xsl:copy-of select="document($bibl-url)/TEI/teiHeader/fileDesc/titleStmt/title" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                        <ptr target="{concat('http://syriaca.org/bibl/',.)}"/>
                        <!-- adds citedRange to bibl -->
                        <xsl:element name="citedRange">
                            <xsl:attribute name="unit" select="$this-cited-range/@unit"/>
                            <xsl:value-of select="$this-row[name()=$this-cited-range/@column]"/>
                        </xsl:element>
                    </bibl>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
        
        
        <!--<xsl:for-each select="$all-sources/*">
            <xsl:variable name="position" select="index-of($all-sources//ptr/@target,ptr/@target)"/>
            <xsl:element name="bibl">
                <!-\- ??? There are namespace issues on these child elements - I can't figure out why. -\->
                <xsl:attribute name="xml:id" select="concat('bib',$record-id,'-',$position)"/>
                <xsl:copy-of select="./*[name()!='citedRange']"/>
                <xsl:for-each select="citedRange">
                    <xsl:element name="citedRange">
                        <xsl:attribute name="unit" select="@unit"/>
                        <xsl:choose>
                            <xsl:when test="@column">
                                <xsl:variable name="citedRange-column" select="@column"/>
                                <xsl:for-each select="$this-row">
                                    <xsl:if test="name()=$citedRange-column">
                                        <xsl:value-of select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                        </xsl:choose>    
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:for-each>-->
    </xsl:template>
    
</xsl:stylesheet>