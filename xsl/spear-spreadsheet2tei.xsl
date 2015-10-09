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
            2. change the bibl elements for source1, source2, etc. to reflect the sources of your spreadsheet,
            3. change the TEI header information, and
            4. add to the custom functions any languages/scripts or types that we haven't used before. 
            NB: * Each column in the spreadsheet must contain data from only one source. -->
    <xsl:variable name="column-mapping">
        <persName xml:lang="en-x-gedsh" column="Canonical_Name"/>
        <persName xml:lang="syr" source="http://syriaca.org/bibl/633" column="Syriac_Canonical"/>
        <state xml:lang="en" type="role" source="http://syriaca.org/bibl/657" column="Office"/>
    </xsl:variable>
    
    <!-- CUSTOM FUNCTIONS -->
    <!-- tests whether a column is of a given type, as defined in the $column-mapping.
    good for for-each statements that run through all the columns of the spreadsheet, but only act on those that are of the right type-->
    <xsl:function name="syriaca:if-column-type" as="xs:boolean">
        <!-- the name of the column to test -->
        <xsl:param name="column-name" as="xs:string"/>
        <!-- the type of column we're looking for -->
        <xsl:param name="column-type" as="xs:string"/>
        <!-- collects all columns of specified type as a sequence from the $column-mapping variable -->
        <xsl:variable name="columns-of-type" as="xs:string*">
            <xsl:for-each select="$column-mapping/descendant::*">
                <xsl:if test="matches(name(),$column-type)">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($columns-of-type, $column-name)">1</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    
    <!-- ??? Need to replace the deprecated variables $column-types and $column-langs with custom functions -->
    <!--<xsl:variable name="column-types">
        <persName>
            <xsl:for-each select="$column-mapping/persName">
                <xsl:value-of select="@column"/>
            </xsl:for-each>
        </persName>
        <state>
            <xsl:for-each select="$column-mapping/state">
                <xsl:value-of select="@column"/>
            </xsl:for-each>
        </state>
    </xsl:variable>
    
    <xsl:variable name="column-langs">
        <en-x-gedsh>
            <xsl:for-each select="$column-mapping/*[@xml:lang='en-x-gedsh']">
                <xsl:value-of select="@column"/>
            </xsl:for-each>
        </en-x-gedsh>
        <syr>
            <xsl:for-each select="$column-mapping/*[@xml:lang='syr']">
                <xsl:value-of select="@column"/>
            </xsl:for-each>
        </syr>                    
    </xsl:variable>-->
    
    
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
                
                    <!-- ??? Need to replace the following with a call to a custom function-->
                    <!--<xsl:for-each select="/root/row/child::*">
                        <xsl:variable name="column-name" select="name(.)"/>
                        <xsl:if test="contains($column-types/persName,$column-name)">
                            <xsl:element name="persName">
                                <!-\- language attribute -\->
                                <xsl:choose>
                                    <xsl:when test="contains($column-langs/en-x-gedsh,$column-name)">
                                        <xsl:attribute name="xml:lang" select="'en-x-gedsh'"/>
                                    </xsl:when>
                                    <xsl:when test="contains($column-langs/syr,$column-name)">
                                        <xsl:attribute name="xml:lang" select="'syr'"/>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>-->
                
                
                </xsl:result-document>
                
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>
    
    
</xsl:stylesheet>