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
    
    <!-- COLUMN MAPPING FROM INPUT SPREADSHEET -->
    <!-- !!! When modifying this stylesheet for a new spreadsheet, you should (in most cases) only need to  
            1. change the contents of the $column-mapping variable below,
            2. change the $all-sources variable to reflect the sources of your spreadsheet,
            3. change the TEI header information, and
            4. add to the column-mapping and bibls templates any attributes that we haven't used before. 
            NB: * Each column in the spreadsheet must contain data from only one source.
                * Spreadsheet columns containing citedRange data should be mapped using the $all-sources variable below.
                * The column-mapping template (see below) defines content of the <state> element as nested inside <desc> (needed for valid TEI) -->
    <xsl:variable name="column-mapping">
        <persName xml:lang="en-x-gedsh" column="Canonical_Name"/>
        <persName xml:lang="syr" source="http://syriaca.org/bibl/633" column="Syriac_Canonical"/>
        <state xml:lang="en" type="role" source="http://syriaca.org/bibl/657" column="Office"/>
    </xsl:variable>
    
    <!-- BIBL ELEMENTS TO USE AS SOURCES -->
    <!-- !!! Modify/add bibl elements here. You MUST put in a @column attribute on citedRange to specify which spreadsheet column the page num.,etc. comes from. -->
    <!-- @xml:id and <citedRange> will be added automatically based on $column-mapping -->
    <xsl:variable name="all-sources">
        <bibl>
            <title xml:lang="la" level="m">Chronica Minora</title>
            <ptr target="http://syriaca.org/bibl/633"/>
            <citedRange unit="pp" column="page"/>
        </bibl>
        <bibl>
            <title level="a" xml:lang="en">Selections from the Syriac. No. 1: The Chronicle of Edessa</title>
            <ptr target="http://syriaca.org/bibl/657"/>
            <citedRange unit="section" column="Section"/>
        </bibl>
    </xsl:variable>
    
    
    <!-- CUSTOM FUNCTIONS -->
    <!-- creates bibl elements from $all-sources, adding @xml:id and citedRange -->
<!--    <xsl:function name="syriaca:createBibls">
        <xsl:param name="record-id"/>
        <xsl:param name="current-row"/>
        <xsl:for-each select="$all-sources/*">
            <xsl:variable name="this-bibl" select="."/>
            <!-\- This column is causing it to break! -\->
            <xsl:variable name="position" select="index-of($all-sources/ptr/@target,$this-bibl/ptr/@target)"/>
            <xsl:element name="bibl">
                <xsl:attribute name="xml:id" select="concat('bib',$record-id,'-',$position)"/>
                <!-\-<xsl:copy-of select="./*"/>
               <xsl:for-each select="$column-mapping/citedRange[matches(@bibl,$this-bibl/ptr/@target)]">
                   <xsl:element name="citedRange">
                       <xsl:attribute name="unit" select="@unit"/>
                       <!-\- now need to grab column data -\->
                       <xsl:value-of select="$current-row/*[matches(name(),@column)]"/>
                   </xsl:element>
               </xsl:for-each>-\->
            </xsl:element>
        </xsl:for-each>
    </xsl:function>-->
    
    
    
    <!-- tests whether a column is of a given node type (e.g., "persName" or "state"), as defined in the $column-mapping.
    good for for-each statements that run through all the columns of the spreadsheet, but only act on those that are of the right type-->
    <!--<xsl:function name="syriaca:if-column-node-type" as="xs:boolean">
        <!-\- the name of the column to test -\->
        <xsl:param name="column-name" as="xs:string"/>
        <!-\- the type of column we're looking for -\->
        <xsl:param name="column-type" as="xs:string"/>
        <!-\- collects all columns of specified type as a sequence from the $column-mapping variable -\->
        <!-\- variable has to have @as='xs:string*' -\->
        <xsl:variable name="columns-of-type" as="xs:string*">
            <xsl:for-each select="$column-mapping/*[matches(name(),$column-type)]">
                <xsl:sequence select="attribute::column"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="index-of($columns-of-type, $column-name)">1</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-\- gets the @xml:lang attribute value of a column -\->
    <xsl:function name="syriaca:get-column-lang">
        <!-\-the name of the spreadsheet column-\->
        <xsl:param name="column-name" as="xs:string"/>
        <xsl:value-of select="$column-mapping/*[@column=$column-name]/attribute::xml:lang"/>
    </xsl:function>
    
    <!-\- gets the @type attribute value of a column -\->
    <xsl:function name="syriaca:get-column-type">
        <!-\-the name of the spreadsheet column-\->
        <xsl:param name="column-name" as="xs:string"/>
        <xsl:value-of select="$column-mapping/*[@column=$column-name]/attribute::type"/>
    </xsl:function>-->
    
    <!-- assigns the @xml:id of the bibl elements dynamically for each row, based on the number of sources for which there is data in that row -->
    <!--<xsl:function name="syriaca:assign-bibl-ids">
        <xsl:param name="row"/>
        <xsl:param name="record-id"/>
        <!-\- ??? Does this need an @as='xs:string*' -\->
        <!-\-<xsl:variable name="non-empty-columns">
            <xsl:for-each select="$row/*[.!='']">
                <xsl:sequence select="name()"/>
            </xsl:for-each>
        </xsl:variable>-\->
        <xsl:variable name="non-empty-columns" select="$row/*[.!='']/name()"/>
        
        <xsl:variable name="non-empty-column-sources" as="xs:string*">
            <xsl:for-each select="$non-empty-columns/*">
                <xsl:sequence select="$column-mapping/*[matches(name(.),@column)]/attribute::source"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="unique-non-empty-column-sources" select="distinct-values($non-empty-column-sources)"/>
            
        <xsl:for-each select="$unique-non-empty-column-sources">
            <bibl ptr="{.}">#bib<xsl:value-of select="$record-id"/>-<xsl:value-of select="index-of($unique-non-empty-column-sources,.)"/></bibl>
        </xsl:for-each>
        
    </xsl:function>-->
    
    
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
            <!-- ??? Need to change this to allow user to define these values as part of a variable above. -->
            <!-- creates a variable containing the path of the file that should be created for this record. -->
            <xsl:variable name="filename">
                <xsl:choose>
                    <!-- tests whether there is sufficient data to create a complete record and puts it in an 'incomplete' folder if not -->
                    <xsl:when test="Canonical_Name[.=''] or Syriac_Canonical[.='']">
                        <xsl:value-of select="concat('../../working-files/chronicle-data/tei/incomplete/',$record-id,'.xml')"/>
                    </xsl:when>
                    <!-- if record is complete and has a URI, puts it in this folder -->
                    <xsl:when test="New_URI != ''"><xsl:value-of select="concat('../../working-files/chronicle-data/tei/',$record-id,'.xml')"/></xsl:when>
                    <!-- if record doesn't have a URI, puts it in 'unresolved' folder -->
                    <xsl:otherwise><xsl:value-of select="concat('../../working-files/chronicle-data/tei/unresolved/',$record-id,'.xml')"/></xsl:otherwise>
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
                </xsl:call-template>
                
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
                
                <text>
                    <body>
                        <listPerson>
                            <person>
                                <xsl:attribute name="xml:id" select="concat('person-', $record-id)"/>
                                <xsl:attribute name="ana" select="'#spear-person'"/>
                                <!-- DEAL WITH SAINT NAMES -->
                                <xsl:variable name="this-row" select="."/>    <!-- Used to permit reference to the current row within nested for-each statements -->
                                <xsl:variable name="name-prefix">name<xsl:value-of select="$record-id"/>-</xsl:variable>
                                
                                <!-- gets the persName columns that have been converted from the spreadsheet in the $converted-columns variable -->
                                <xsl:copy-of select="$converted-columns/persName" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                   
                    
                                 <!-- uses the custom function to select all spreadsheet columns of the persName type (as defined in $column-mapping) and create a 
                                 persName element for each -->
                                 <!--<xsl:for-each select="./child::*[syriaca:if-column-node-type(name(.),'persName')]">
                                 
                                         <xsl:element name="persName">
                                             <!-\- applies the language attribute from $column-mapping -\->
                                             <xsl:attribute name="xml:lang" select="syriaca:get-column-lang(name())"/>
                                             
                                             <xsl:value-of select="."/>
                                         </xsl:element>
                                 </xsl:for-each>-->
                                
                                <!-- gets the state columns that have been converted from the spreadsheet in the $converted-columns variable -->
                                <xsl:copy-of select="$converted-columns/state" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                             
                                <!-- inserts bibl elements -->
                                <xsl:copy-of select="$record-bibls" xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                 
                                 
                                 
                                 <!--<bibl xml:id="bib{$record-id}-1">
                                     <title xml:lang="la" level="m">Chronica Minora</title>
                                     <ptr target="http://syriaca.org/bibl/633"/>                                            
                                 </bibl>
                                 <bibl xml:id="bib{$record-id}-2">
                                     <title level="a" xml:lang="en">Selections from the Syriac. No. 1: The Chronicle of Edessa</title>
                                     <ptr target="http://syriaca.org/bibl/657"/>                                            
                                 </bibl>-->
                    
                            </person>
                        </listPerson>
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
    
    <!-- converts spreadsheet columns using $column-mapping variable above -->
    <xsl:template name="column-mapping" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="columns-to-convert"/>
        <xsl:param name="record-bibls"/>
        <xsl:for-each select="$columns-to-convert">
            <xsl:variable name="column-name" select="name()"/>
            <xsl:variable name="column-contents"><xsl:value-of select="."/></xsl:variable>
            <xsl:for-each select="$column-mapping/*">
                <xsl:variable name="column-source" select="@source"/>
                <xsl:if test="matches(@column,$column-name)">
                    <xsl:element name="{name()}">
                        <xsl:if test="@xml:lang!=''"><xsl:attribute name="xml:lang" select="@xml:lang"/></xsl:if>
                        <xsl:if test="@type!=''"><xsl:attribute name="type" select="@type"/></xsl:if>
                        <xsl:if test="@source!=''"><xsl:attribute name="source" select="concat('#',$record-bibls/*[matches(ptr/@target,$column-source)]/@xml:id)"/></xsl:if>
                    <xsl:choose>
                        <xsl:when test="matches(name(),'state')">
                            <xsl:element name="desc"><xsl:value-of select="$column-contents"/></xsl:element>
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
        <xsl:for-each select="$all-sources/*">
            <xsl:variable name="position" select="index-of($all-sources//ptr/@target,ptr/@target)"/>
            <xsl:element name="bibl">
                <!-- ??? There are namespace issues on these child elements - I can't figure out why. -->
                <xsl:attribute name="xml:id" select="concat('bib',$record-id,'-',$position)"/>
                <xsl:copy-of select="./*[name()!='citedRange']"/>
                <xsl:element name="citedRange">
                    <xsl:attribute name="unit" select="citedRange/@unit"/>
                    <xsl:variable name="citedRange-column" select="citedRange/@column"/>
                    <xsl:for-each select="$this-row">
                        <xsl:if test="matches(name(),$citedRange-column)">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>