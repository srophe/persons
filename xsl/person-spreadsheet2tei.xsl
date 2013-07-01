<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 21, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b>Nathan Gibson</xd:p>
            <xd:p>Transforms XML data imported from the Google Spreadsheet "Author Names from Barsoum..." into Syriaca.org TEI.</xd:p>
            <xd:p>For information on how to set up a spreadsheet to use this stylesheet, see the "Persons spreadsheet2tei stylesheet guide" doc.
            For reading or modifying this stylesheet, see the inline comments in this stylesheet.</xd:p>
            <!-- What is the correct name and URL of the manual? -->
            <xd:p>For information about Syriaca.org's use of the TEI schema, see the Syriaca TEI manual.</xd:p>
            <xd:p>This is a master file that uses modules contained in separate xsl files (in the "person-spreadsheet2tei-modules" directory) to process a persons spreadsheet.
            To create a stylesheet that should process rows differently, such as by adding content to existing records 
            rather than creating new records from each row, you can duplicate this stylesheet and modify it to create a 
            new master stylesheet that uses the same modules.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="text"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Defines an XML format for the transformed data.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes" name="xml"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Defines an HTML format for the transformed data.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="html" indent="yes" name="html"/>
    
    <!-- Modules -->
    
    <!-- Creates an HTML index for easily viewing result TEI files -->
    <xsl:include href="person-spreadsheet2tei-modules/index.xsl"/>
    <!-- Assists creation of @xml:id attributes -->
    <xsl:include href="person-spreadsheet2tei-modules/ids.xsl"/>
    <!-- Creates a TEI Header -->
    <xsl:include href="person-spreadsheet2tei-modules/header.xsl"/>
    <!-- Adds @xml:lang (language) attributes to elements -->
    <xsl:include href="person-spreadsheet2tei-modules/language.xsl"/>
    <!-- Adds @source attributes to elements -->
    <xsl:include href="person-spreadsheet2tei-modules/source.xsl"/>
    <!-- Creates personal name elements -->
    <xsl:include href="person-spreadsheet2tei-modules/names.xsl"/>
    <!-- Creates idno elements -->
    <xsl:include href="person-spreadsheet2tei-modules/idno.xsl"/>
    <!-- Creates events or other date-related elements -->
    <xsl:include href="person-spreadsheet2tei-modules/events.xsl"/>
    <!-- Creates bibl elements -->
    <xsl:include href="person-spreadsheet2tei-modules/bibl.xsl"/>
    <!-- Creates relation elements -->
    <xsl:include href="person-spreadsheet2tei-modules/relation.xsl"/>
    <!-- Creates state elements -->
    <xsl:include href="person-spreadsheet2tei-modules/state.xsl"/>
    
    <!-- Functions -->
    <xsl:include href="person-spreadsheet2tei-modules/functions.xsl"/> 
        
        

    <xd:doc>
        <xd:desc>
            <xd:p>This template matches the root element and processes any templates that should create documents from the entire 
            spreadsheet, such as an index file containing links to the records produced from each row.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/root">
        <xsl:apply-templates/>
        <xsl:call-template name="index"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template processes each row (assumed to contain one person per row), creating a TEI record for each row 
            and naming it by its SRP ID number (e.g., "Aphrahat" is 10.xml).</xd:p>
            <xd:p>First, it creates several variables to be used by the rest of the stylesheet (e.g., xml:ids). 
            Then it creates the TEI document, adds the root element, and creates additional content by calling templates 
            contained in various modules.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="main" match="row">
        <!-- Variables -->
        <!-- Creates a variable to use as the id for the person record, which is in turn used for generating @xml:id attributes 
        of elements contained in the record.-->
        <xsl:variable name="record-id"><xsl:value-of select="SRP_ID"/></xsl:variable>
        
        <!-- Creates a variable to use as the xml:id for the person element -->
        <xsl:variable name="person-id">person-<xsl:value-of select="$record-id"/></xsl:variable>
        
        <!-- Creates a variable containing the first part of any persName id. -->
        <xsl:variable name="person-name-id">name<xsl:value-of select="$record-id"/></xsl:variable>
        
        <!-- Creates a sequence variable containing all full name elements for the row, so that variables can be created by processing this only once. -->
        <xsl:variable name="all-full-names">
            <xsl:copy-of select="*[matches(name(), '(_|-)Full')]"/>
        </xsl:variable>
        
        <!-- Creates a sequence variable of one column per source (or two for vocalized/non-vocalized versions), using full name if available 
        or another column if information other than a name is derived from the source. 
        The is the basis for creating sequence variables that contain the same element names as these columns in the spreadsheet, 
        but have different content, which can be retreived by comparing the name of the element to be processed with the name (or partial name) 
        of an element in the sequence variable. -->
        <!-- Use copy-of to add a representative column from a source not used in full names (only one per source). -->
        <xsl:variable name="sourced-columns">
            <xsl:copy-of select="$all-full-names"/>
            <xsl:copy-of select="VIAF-Dates_Raw"/>
        </xsl:variable>
        
        <!-- Creates a sequence variable containing the part of @xml:id attributes that should be different for columns from different sources. -->
        <xsl:variable name="ids-base">
            <xsl:call-template name="ids-base">
                <xsl:with-param name="sourced-columns" select="$sourced-columns"/>
                <xsl:with-param name="count" select="1"/>
                <xsl:with-param name="same-source-adjustment" select="0"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Creates a sequence variable containing the @xml:id attributes for bibl elements. 
        This needs to be at beginning so that it can be used by the source module. -->
        <!-- Should this be bibl- instead of bib? (If changed, need to change in places records too.) -->
        <xsl:variable name="bib-ids">
            <xsl:call-template name="bib-ids">
                <xsl:with-param name="sourced-columns" select="$sourced-columns"/>
                <xsl:with-param name="record-id" select="$record-id"/>
                <xsl:with-param name="ids-base" select="$ids-base"/>
            </xsl:call-template>
        </xsl:variable>         
        
        <!-- Creates a variable containing the path of the file that should be created for this record. -->
        <xsl:variable name="filename"
            select="concat('persons-authorities-spreadsheet-output/',$record-id,'.xml')"/>
        
        <!-- Writes the file to the path specified in the $filename variable. -->
        <xsl:result-document href="{$filename}" format="xml">
            <TEI xml:lang="en" xmlns="http://www.tei-c.org/ns/1.0">
                
                <!-- Adds header -->
                <xsl:call-template name="header">
                    <xsl:with-param name="record-id" select="$record-id"/>
                </xsl:call-template>
                
                <text>
                    <body>
                        <listPerson>
                            <!-- Is there any additional way we should mark anonymous writers, other than in the format of the name? -->
                                <person xml:id="{$person-id}">
                                    
                                    <!-- Creates persName elements. -->
                                    <xsl:call-template name="names">
                                        <xsl:with-param name="all-full-names" select="$all-full-names"/>
                                        <xsl:with-param name="person-name-id" select="$person-name-id"/>
                                        <xsl:with-param name="ids-base" select="$ids-base"/>
                                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                    </xsl:call-template>
                                    
                                    <!-- Adds VIAF URLs. -->
                                    <xsl:call-template name="idno">
                                        <xsl:with-param name="record-id" select="$record-id"/>
                                    </xsl:call-template>
                                  
                                  <!-- Adds birth/death/floruit/event elements -->
                                    <xsl:for-each 
                                        select="*[ends-with(name(),'Floruit') or ends-with(name(),'DOB') or ends-with(name(),'DOD')]">
                                        <xsl:call-template name="event-element">
                                            <xsl:with-param name="bib-ids" select="$bib-ids"/>     
                                        </xsl:call-template>
                                    </xsl:for-each>
                                    <!-- Tests whether there are any columns with content that will be put into event elements (e.g., "Reign"). 
                                    If so, creates a listEvent parent element to contain them. 
                                    Add to the if test and to the for-each the descriptors of any columns that should be put into event elements. -->
                                    <xsl:if test="exists(*[contains(name(), 'Reign') and string-length(normalize-space(node()))])">
                                        <listEvent>
                                            <xsl:for-each 
                                                select="*[ends-with(name(),'Reign')]">
                                                    <xsl:call-template name="event-element">
                                                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                                    </xsl:call-template>
                                            </xsl:for-each>
                                        </listEvent>
                                    </xsl:if>
                                    
                                    <!-- Creates states -->
                                    <xsl:call-template name="state">
                                        <xsl:with-param name="all-titles" select="*[ends-with(name(), 'Titles') and string-length(normalize-space(node()))]"/>
                                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                    </xsl:call-template>
                                    
                                    <!-- Creates bibl elements -->
                                    <xsl:call-template name="bibl">
                                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                    </xsl:call-template>                                        
                                    
                                    <!-- Adds Record Description field as a note. -->
                                    <xsl:if test="string-length(normalize-space(Record_Description))">
                                        <note type="record-description">
                                            <xsl:value-of select="Record_Description"/>
                                        </note>
                                    </xsl:if>
                                    
                                </person>
                            
                            <!-- Create relations. -->
                            <xsl:call-template name="relation">
                                <xsl:with-param name="person-id" select="$person-id"/>
                            </xsl:call-template>
                            </listPerson>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Prevents any unprocessed elements from being included in the output.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*"/>
    
</xsl:stylesheet>
