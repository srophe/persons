<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:syriaca="http://syriaca.org" xmlns:saxon="http://saxon.sf.net/" xmlns:functx="http://www.functx.com">

    <!-- FORMAT OF COMMENTS -->
    <!-- ??? Indicates an issue that needs resolving. -->
    <!-- ALL CAPS is a section header. -->
    <!-- !!! Shows items that may need to be changed/customized when running this template on a new spreadsheet. -->
    <!-- lower case comments explain the code -->

    <!-- FILE OUTPUT PROCESSING -->
    <!-- specifies how the output file will look -->
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml"/>

    <!-- ??? Not sure what these variables do. They're from Winona's saints XSL. -->
    <xsl:variable name="n">
        <xsl:text/>
    </xsl:variable>
    <xsl:variable name="s">
        <xsl:text> </xsl:text>
    </xsl:variable>

    <!-- COLUMN MAPPING FROM INPUT SPREADSHEET -->
    <!-- !!! When modifying this stylesheet for a new spreadsheet, you should (in most cases) only need to  
            1. name your columns according to the conventions here (https://docs.google.com/spreadsheets/d/1_uilPEx2XFU8dlsTx2O8B1itZZL3CrCxMBaiS1eKofU/edit?usp=sharing) 
                or change the contents of the $column-mapping variable below manually to use the column names from your spreadsheet with appropriate attributes,
            2. change the TEI header information, 
            3. change the $directory (optional), and
            4. add to the column-mapping and bibls TEMPLATES any attributes that we haven't used before. 
            NB: * Each cell in the spreadsheet must contain data from only one source.
                * The spreadsheet must contain a column named "New_URI". This column should not be "mapped" below; it is hard-coded into the stylesheet.
                * A person_ana column is also hard-coded into the stylesheet, but is not required. The values in this column determine what (if anything) goes into the person/@ana attribute,
                and which series statements are used.
                * Each record should have at least one column marked with syriaca-tags="#syriaca-headword", otherwise it will be placed into the "incomplete" folder.
                * It's fine to map multiple spreadsheets below, as long as they don't contain columns with the same names but different attributes (e.g., @source or @xml:lang). 
                * Columns for <sex> element will go into the @value. If they contain the abbreviations "M" or "F", then "male" or "female" will be inserted into the element content.
                * The column-mapping template (see below) defines content of the <state> element as nested inside <desc> (needed for valid TEI) -->
    <xsl:variable name="column-mapping">
        <!-- This variable contains a set of pseudo-TEI nodes that have TEI element names and attributes, plus an @column specifying the name or position of 
             the spreadsheet column that contains the data that should be put into those TEI elements and a @sourceUriColumn specifying the name of the column that contains 
             the bibl URI of this column's source.
             For example, <persName xml:lang="syr" sourceUriColumn="Source 2" column="3"/> -->

        <!-- AUTOMATIC COLUMN MAPPING -->
        <!-- column mapping using the column nameing conventions. Format for column name is "elementName attributeValueOrType.sourceColumnName.languageCode" 
             See https://docs.google.com/spreadsheets/d/1_uilPEx2XFU8dlsTx2O8B1itZZL3CrCxMBaiS1eKofU/edit?usp=sharing -->
        <!-- uses the first row to define columns -->
        <xsl:for-each select="/root/row[1]/*">
            <!-- uses the column name to find out which element name and attributes it should use -->
            <xsl:variable name="column-info" select="syriaca:column-name(name())"/>
            <!--            <xsl:variable name="test-element-name" select="$column-info/*[1]"/>-->
            <!--<xsl:if
                test="$column-info/elementName=('persName' or 'sex' or 'state' or 'birth' or 'death' or 'floruit' or 'citedRange' or 'idno' or 'relation' or 'note' or 'trait') and $column-info/attributeValueOrType!=('when' or 'notBefore' or 'notAfter')">
-->
            <xsl:variable name="element-name" as="xs:string">
                <!-- chooses the name for the TEI element, based on the part of the column name before any (_) or (.). -->
                <!-- !!! If you want to add another type of TEI element, you should add it here and also in the main ("/root") template under 
                        TEI/text/body/listPerson/person (see format there). If the default behavior of placing the column contents directly inside this element 
                        is not adequate, you should also modify the column-mapping template below. -->
                <xsl:choose>
                    <xsl:when test="matches(name(),'^persName[\._]')">persName</xsl:when>
                    <xsl:when test="matches(name(),'^sex[\._]')">sex</xsl:when>
                    <xsl:when test="matches(name(),'^state[\._]')">state</xsl:when>
                    <!-- the different regex for date columns (birth, death, floruit )is so that elements are created only the main date columns 
                            and not for their subsidiaries (birth when, birth notBefore, etc.), which are processed as attributes of the main date elements (see below). -->
                    <xsl:when test="matches(name(),'^birth\.')">birth</xsl:when>
                    <xsl:when test="matches(name(),'^death\.')">death</xsl:when>
                    <xsl:when test="matches(name(),'^floruit\.')">floruit</xsl:when>
                    <xsl:when test="matches(name(),'^citedRange[\._]')">citedRange</xsl:when>
                    <xsl:when test="matches(name(),'^idno[\._]')">idno</xsl:when>
                    <xsl:when test="matches(name(),'^relation[\._]')">relation</xsl:when>
                    <xsl:when test="matches(name(),'^note[\._]')">note</xsl:when>
                    <xsl:when test="matches(name(),'^trait[\._]')">trait</xsl:when>
                    <xsl:when test="matches(name(),'^event[\._]')">event</xsl:when>
                    <!-- a non-empty string is required in this variable type, thus "none" -->
                    <xsl:otherwise>none</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$element-name!='none'">
                <xsl:element name="{$element-name}">
                    <!-- adds @xml:lang using the codes at the end of the column name (after the final dot). -->
                    <!-- !!! Add any additional languages you need here. -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'\.en-x-gedsh$')">
                            <xsl:attribute name="xml:lang" select="'en-x-gedsh'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.en$')">
                            <xsl:attribute name="xml:lang" select="'en'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.syr$')">
                            <xsl:attribute name="xml:lang" select="'syr'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.syr-Syrj$')">
                            <xsl:attribute name="xml:lang" select="'syr-Syrj'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.syr-Syrn$')">
                            <xsl:attribute name="xml:lang" select="'syr-Syrn'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.ar$')">
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.fr$')">
                            <xsl:attribute name="xml:lang" select="'fr'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.de-x-baumstark$')">
                            <xsl:attribute name="xml:lang" select="'de-x-baumstark'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.de$')">
                            <xsl:attribute name="xml:lang" select="'de'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'\.la$')">
                            <xsl:attribute name="xml:lang" select="'la'"/>
                        </xsl:when>
                    </xsl:choose>
                    <!-- adds @type based on the text immediately following the element name -->
                    <!-- !!! Add any additional types you need here. -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_office')">
                            <xsl:attribute name="type" select="'office'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_saint')">
                            <xsl:attribute name="type" select="'saint'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_occupation')">
                            <xsl:attribute name="type" select="'occupation'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_abstract')">
                            <xsl:attribute name="type" select="'abstract'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_attestation')">
                            <xsl:attribute name="type" select="'attestation'"/>
                        </xsl:when>
                        <xsl:when test="starts-with(name(),'idno_')">
                            <xsl:attribute name="type" select="substring-after(name(),'idno_')"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="column" select="name()"/>
                    <!-- adds @unit, based on the part of the column name immediately after the element name. -->
                    <!-- ??? does not yet support @target -->
                    <xsl:if test="starts-with(name(),'citedRange_')">
                        <xsl:attribute name="unit"
                            select="replace(replace(name(),'citedRange_',''),'\..*$','')"/>
                    </xsl:if>
                    <!-- adds @when, @notBefore, @notAfter attributes to date columns -->
                    <!-- ??? dates for state not supported yet. -->
                    <!-- !!! You can add more date-type elements here. -->
                    <xsl:if test="matches(name(),'^birth\.|^death\.|^floruit\.')">
                        <xsl:variable name="date-type">
                            <!-- captures the type of element -->
                            <xsl:choose>
                                <xsl:when test="matches(name(),'^birth\.')">birth</xsl:when>
                                <xsl:when test="matches(name(),'^death\.')">death</xsl:when>
                                <xsl:when test="matches(name(),'^floruit\.')">floruit</xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="date-source">
                            <!-- captures the name of the source column this column is using, to use when constructing the machine-readable date attribute columns below -->
                            <xsl:analyze-string select="name()" regex="Source_[0-9]+">
                                <xsl:matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <!-- gets the names of the columns used for @when, @notBefore, and @notAfter machine-readable dates and puts them into attributes. 
                                Note that the column-mapping creates only one element per category of date (e.g., "birth", "death", "floruit"), not one for each of the 
                                associated machine-readable columns (e.g., "birth notBefore"). -->
                        <!-- ??? The following regex will run into problems if there are more than 10 sources! (E.g., 'Source_1' will also match 'Source_11') -->
                        <!-- ??? This could be made more efficient with variables -->
                        <xsl:if
                            test="/root/row[1]/*[matches(name(),concat($date-type,'_when','\.',$date-source))]">
                            <xsl:attribute name="whenColumn"
                                select="name(/root/row[1]/*[matches(name(),concat($date-type,'_when','\.',$date-source))])"
                            />
                        </xsl:if>
                        <xsl:if
                            test="/root/row[1]/*[matches(name(),concat($date-type,'_notBefore','\.',$date-source))]">
                            <xsl:attribute name="notBeforeColumn"
                                select="name(/root/row[1]/*[matches(name(),concat($date-type,'_notBefore','\.',$date-source))])"
                            />
                        </xsl:if>
                        <xsl:if
                            test="/root/row[1]/*[matches(name(),concat($date-type,'_notAfter','\.',$date-source))]">
                            <xsl:attribute name="notAfterColumn"
                                select="name(/root/row[1]/*[matches(name(),concat($date-type,'_notAfter','\.',$date-source))])"
                            />
                        </xsl:if>
                    </xsl:if>

                    <!-- adds relation name, using as a value the text in the column name immediately after the element name ("relation_"). -->
                    <xsl:if test="matches(name(),'^relation_[a-zA-Z\-]+')">
                        <xsl:attribute name="name"
                            select="replace(replace(name(),'relation_',''),'\..*$','')"/>
                    </xsl:if>

                    <xsl:attribute name="column" select="name()"/>
                    <!-- adds syriaca-headword -->
                    <xsl:choose>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_syriaca-headword')">
                            <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                        </xsl:when>
                        <xsl:when test="matches(name(),'^[a-zA-Z]*_anonymous-description')">
                            <xsl:attribute name="syriaca-tags" select="'#anonymous-description'"/>
                        </xsl:when>
                    </xsl:choose>
                    <!-- adds sourceUriColumn -->
                    <!-- ??? This could be consolidated with the $date-source variable above. -->
                    <xsl:choose>
                        <!-- checks whether the column name contains the name of a source column, in the format ".Source_1" -->
                        <xsl:when test="matches(name(),'\.Source_[0-9]*')">
                            <!-- splits the column name into parts at the dots -->
                            <xsl:variable name="tokenized-column-name"
                                select="tokenize(name(),'\.')"/>
                            <xsl:variable name="source-name">
                                <!-- grabs the part of the column name that contains the source column name -->
                                <xsl:for-each select="$tokenized-column-name">
                                    <xsl:if test="matches(.,'^Source_[0-9]*')">
                                        <xsl:value-of select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <!-- adds the name of the source column as @sourceUriColumn -->
                            <xsl:attribute name="sourceUriColumn" select="$source-name"/>
                        </xsl:when>
                    </xsl:choose>
                    <!-- adds an @column containing the numbered position of the column in the spreadsheet. This is used in the column-mapping template to 
                            determine which column to grab data from for this element. -->
                    <xsl:attribute name="column" select="position()"/>
                </xsl:element>
            </xsl:if>
            <!--            </xsl:if>-->
        </xsl:for-each>

        <!-- MANUAL COLUMN MAPPING -->
        <!-- !!! Insert any manual column mapping here. Each column in the spreadsheet should have a unique name. Note that spaces in column names are converted to underscores (_). 
            For example ... -->
        <!-- ??? This might need a little debugging. Mainly, I'm not entirely sure that whether using column names instead of numbers 
            works properly. If that's a problem, you could try it with column numbers instead of names. -->
        <persName xml:lang="en" sourceUriColumn="Brooks_URI" syriaca-tags="#syriaca-headword"
            column="Name_in_Index"/>
        <note xml:lang="en" type="abstract" column="Additional_Info"/>
        <birth xml:lang="en" whenColumn="Birth_Standard" notBeforeColumn="Birth_Not_Before"
            notAfterColumn="Birth_Not_After" sourceUriColumn="Brooks_URI" column="Birth"/>
        <citedRange unit="pp" sourceUriColumn="Brooks_URI" column="page"/>
    </xsl:variable>

    <!-- DIRECTORY -->
    <!-- specifies where the output TEI files should go -->
    <!-- !!! Change this to where you want the output files to be placed relative to the XML file being converted. 
        This should end with a trailing slash (/).-->
    <xsl:variable name="directory">../../working-files/spear20160812/</xsl:variable>

    <!-- CUSTOM FUNCTIONS -->
    <!-- used in auto column-mapping to determine the element name and attributes that should be created for that column. 
        Column naming format is "elementName attributeValueOrType.sourceColumnName.languageCode" -->
    <xsl:function name="syriaca:column-name">
        <xsl:param name="column-name" as="xs:string"/>
        <!-- separates the column name into its relevant parts -->
        <xsl:analyze-string select="$column-name"
            regex="^([a-zA-Z0-9\-]+)(_([a-zA-Z0-9\-]+))?(\.(Source_[0-9]+))?(\.([a-zA-Z0-9\-]+))?$">
            <xsl:matching-substring>
                <elementName>
                    <xsl:value-of select="regex-group(1)"/>
                </elementName>
                <attributeValueOrType>
                    <xsl:value-of select="regex-group(3)"/>
                </attributeValueOrType>
                <sourceColumnName>
                    <xsl:value-of select="regex-group(5)"/>
                </sourceColumnName>
                <languageCode>
                    <xsl:value-of select="regex-group(7)"/>
                </languageCode>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <!-- date processing by Winona Salesky -->
    <!-- creates the dates to be used for @syriaca-computed-start and @syriaca-computed-end. 
        Called by the column-mapping template -->
    <xsl:function name="syriaca:custom-dates" as="xs:date">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="trim-date" select="normalize-space($date)"/>
        <xsl:choose>
            <xsl:when test="starts-with($trim-date,'0000') and string-length($trim-date) eq 4">
                <xsl:text>0001-01-01</xsl:text>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 4">
                <xsl:value-of select="concat($trim-date,'-01-01')"/>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 5">
                <xsl:value-of select="concat($trim-date,'-01-01')"/>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 5">
                <xsl:value-of select="concat($trim-date,'-01-01')"/>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 7">
                <xsl:value-of select="concat($trim-date,'-01')"/>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 3">
                <xsl:value-of select="concat('0',$trim-date,'-01-01')"/>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 2">
                <xsl:value-of select="concat('00',$trim-date,'-01-01')"/>
            </xsl:when>
            <xsl:when test="string-length($trim-date) eq 1">
                <xsl:value-of select="concat('000',$trim-date,'-01-01')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$trim-date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Applies the TEI namespace to all descendants of a node. -->
    <xsl:function name="syriaca:include-tei-children" as="node()*">
        <xsl:param name="parent-node" as="node()*"/>
        <xsl:choose>
            <xsl:when test="$parent-node/*">
                <xsl:for-each select="$parent-node/node()">
                    <xsl:choose>
                        <xsl:when test="local-name()">
                            <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0"><xsl:copy-of select="attribute::*|syriaca:include-tei-children(.)"/></xsl:element>
                        </xsl:when>
                        <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($parent-node)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="functx:substring-after-if-contains" as="xs:string?"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="delim" as="xs:string"/>
        
        <xsl:sequence select="
            if (contains($arg,$delim))
            then substring-after($arg,$delim)
            else $arg
            "/>
        
    </xsl:function>
    
    
    <xsl:function name="functx:name-test" as="xs:boolean"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="testname" as="xs:string?"/>
        <xsl:param name="names" as="xs:string*"/>
        
        <xsl:sequence select="
            $testname = $names
            or
            $names = '*'
            or
            functx:substring-after-if-contains($testname,':') =
            (for $name in $names
            return substring-after($name,'*:'))
            or
            substring-before($testname,':') =
            (for $name in $names[contains(.,':*')]
            return substring-before($name,':*'))
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:remove-attributes" as="element()"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="elements" as="element()*"/>
        <xsl:param name="names" as="xs:string*"/>
        
        <xsl:for-each select="$elements">
            <xsl:element name="{node-name(.)}">
                <xsl:sequence
                    select="(@*[not(functx:name-test(name(),$names))],
                    node())"/>
            </xsl:element>
        </xsl:for-each>
        
    </xsl:function>
    
    <xsl:function name="syriaca:remove-attributes" as="node()*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="names" as="xs:string*"/>
        <xsl:for-each select="$nodes">
            <xsl:copy-of select="functx:remove-attributes(.,$names)"/>
        </xsl:for-each>        
    </xsl:function>
    
    <xsl:function name="functx:is-node-in-sequence-deep-equal" as="xs:boolean"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="node" as="node()?"/>
        <xsl:param name="seq" as="node()*"/>
        
        <xsl:sequence select="
            some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:distinct-deep" as="node()*"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="nodes" as="node()*"/>
        
        <xsl:sequence select="
            for $seq in (1 to count($nodes))
            return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
            .,$nodes[position() &lt; $seq]))]
            "/>
        
    </xsl:function>
    
    <!-- Consolidates matching elements from different sources -->
    <xsl:function name="syriaca:consolidate-sources" as="node()*">
        <xsl:param name="input-nodes" as="node()*"/>
        <xsl:for-each select="functx:distinct-deep(syriaca:remove-attributes($input-nodes,('source','syriaca-tags')))">
            <xsl:variable name="this-node" select="."/>
            <xsl:element name="{$this-node/name()}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:variable name="source" select="$input-nodes[deep-equal($this-node,functx:remove-attributes(.,('source','syriaca-tags')))]/attribute::source"/>
                <xsl:variable name="syriaca-tags" select="$input-nodes[deep-equal($this-node,functx:remove-attributes(.,('source','syriaca-tags')))]/attribute::syriaca-tags"/>
                <xsl:for-each select="$this-node/@*">
                    <xsl:attribute name="{name()}" select="."/>
                </xsl:for-each>
                <xsl:if test="$syriaca-tags!=''"><xsl:attribute name="syriaca-tags" select="$syriaca-tags"/></xsl:if>
                <xsl:if test="$source!=''"><xsl:attribute name="source" select="$source"/></xsl:if>
                <xsl:copy-of select="$this-node/node()"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>

    <!-- Adds xml:id to each node -->
    <xsl:function name="syriaca:add-xml-id" as="node()*">
        <xsl:param name="input-nodes" as="node()*"/>
        <xsl:param name="record-id" as="xs:string"/>
        <xsl:param name="id-prefix" as="xs:string"/>
        <xsl:for-each select="$input-nodes">
            <xsl:variable name="index" select="index-of($input-nodes,.)"/>
            <xsl:element name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="xml:id" select="concat($id-prefix,$record-id,'-',$index[1])"/>
                <xsl:copy-of select="@*"/>
                <!--<xsl:for-each select="@*">
                    <xsl:attribute name="{name()}" select="."/>
                </xsl:for-each>-->
                <xsl:copy-of select="node()"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>

    <!-- MAIN TEMPLATE -->
    <!-- processes each row of the spreadsheet -->
    <xsl:template match="/root">
        <!-- creates ids for new persons. -->
        <!-- ??? How should we deal with matched persons, where the existing TEI records need to be supplemented? -->
        <xsl:for-each select="row[not(contains(.,'***'))]">
            <xsl:variable name="record-id">
                <!-- gets a record ID from the New_URI column, or generates one if that column is blank -->
                <xsl:choose>
                    <xsl:when test="New_URI != ''">
                        <xsl:value-of select="New_URI"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('unresolved-',generate-id())"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- creates the URI from the record ID -->
            <xsl:variable name="record-uri" select="concat('http://syriaca.org/person/',New_URI)"/>

            <!-- creates bibls for this record (row) using the @sourceUriColumn attributes defined in $column-mapping -->
            <xsl:variable name="record-bibls">
                <xsl:call-template name="bibls">
                    <xsl:with-param name="record-id" select="$record-id"/>
                    <xsl:with-param name="this-row" select="*"/>
                </xsl:call-template>
            </xsl:variable>

            <!-- converts spreadsheet row contents into TEI elements for this record using the $column-mapping variable -->
            <xsl:variable name="converted-columns">
                <xsl:call-template name="column-mapping">
                    <xsl:with-param name="columns-to-convert" select="*"/>
                    <xsl:with-param name="record-bibls" select="$record-bibls"/>
                    <xsl:with-param name="record-uri" select="$record-uri"/>
                </xsl:call-template>
            </xsl:variable>

            <!-- creates a variable containing the path of the file to be created for this record, in the location defined by $directory -->
            <xsl:variable name="filename">
                <xsl:choose>
                    <!-- tests whether there is sufficient data to create a complete record. If not, puts it in an 'incomplete' folder inside the $directory -->
                    <xsl:when test="empty($converted-columns/*[@syriaca-tags='#syriaca-headword'])">
                        <xsl:value-of select="concat($directory,'/incomplete/',$record-id,'.xml')"/>
                    </xsl:when>
                    <!-- if record is complete and has a URI, puts it in the $directory folder -->
                    <xsl:when test="New_URI != ''">
                        <xsl:value-of select="concat($directory,$record-id,'.xml')"/>
                    </xsl:when>
                    <!-- if record doesn't have a URI, puts it in 'unresolved' folder inside the $directory  -->
                    <xsl:otherwise>
                        <xsl:value-of select="concat($directory,'unresolved/',$record-id,'.xml')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- creates the XML file, if the filename has been sucessfully created. -->
            <xsl:if test="$filename != ''">
                <xsl:result-document href="{$filename}" format="xml">
                    <!-- adds the xml-model instruction with the link to the Syriaca.org validator -->
                    <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
                    <xsl:value-of select="$n"/>

                    <!-- RECORD CONTENT BEGINS -->
                    <TEI xml:lang="en" xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:variable name="en-headword" select="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang, 'en')]"></xsl:variable>
                        <!-- Adds header from the header template -->
                        <xsl:call-template name="header">
                            <xsl:with-param name="record-id" select="$record-id"/>
                            <xsl:with-param name="converted-columns" select="$converted-columns"/>
                            <xsl:with-param name="en-headword" select="$en-headword"/>
                        </xsl:call-template>
                        <text>
                            <body>
                                <listPerson>
                                    <person>
                                        <!-- creates an @xml:id and adds it to the person element -->
                                        <xsl:attribute name="xml:id"
                                            select="concat('person-', $record-id)"/>
                                        <!-- adds the person type (author/saint) -->
                                        <xsl:if test="person_ana!=''">
                                            <xsl:attribute name="ana" select="person_ana"/>
                                        </xsl:if>

                                        <!-- allows referencing the current row within nested for-each statements -->
                                        <xsl:variable name="this-row" select="."/>

                                        <!-- PERSON ELEMENTS -->
                                        <!-- these copy-of instructions grab specific TEI elements from the $converted-columns variable (columns processed from spreadsheet) 
                                    and import them here. -->
                                        <!-- !!! If you have added any new types of elements in $column-mapping, you must call them here. 
                                    You must include @xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
                                    You can also change the order of these elements according to your preference, so long as it still produces valid TEI. -->
                                        <xsl:copy-of select="syriaca:add-xml-id(syriaca:consolidate-sources($converted-columns/persName),$record-id,'name')"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:if test="$converted-columns/tei:note[@type='abstract']!=''">
                                            <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                                                <!-- this can't use the syriaca:add-xml-id function because the attribute value has a different format -->
                                                <xsl:attribute name="xml:id" select="concat('abstract-en-',$record-id)"/>
                                                <xsl:copy-of select="$converted-columns/note[@type='abstract']/(node()|@*)"
                                                    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
                                                </xsl:copy-of>
                                            </xsl:element>
                                        </xsl:if>
                                        <xsl:copy-of select="$converted-columns/note[@type!='abstract']"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>

                                        <!-- IDNO -->
                                        <!-- gives the person URI as an idno -->
                                        <xsl:if test="New_URI != ''">
                                            <idno type="URI">
                                                <xsl:value-of select="$record-uri"/>
                                            </idno>
                                        </xsl:if>

                                        <!-- PERSON ELEMENTS CONTINUED -->
                                        <!-- continues copy-of instructions for TEI elements from $converted-columns -->
                                        <xsl:copy-of select="$converted-columns/idno"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/birth)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/death)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/floruit)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/state)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/trait)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/sex)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/event)"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>

                                        <!-- BIBLS -->
                                        <!-- inserts bibl elements created by the bibls template-->
                                        <xsl:copy-of select="$record-bibls/bibl"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                                            copy-namespaces="no"/>

                                    </person>

                                    <!-- RELATIONS -->
                                    <!-- imports relation elements from $converted-columns-->
                                    <xsl:copy-of select="syriaca:consolidate-sources($converted-columns/relation)"
                                        xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>

                                </listPerson>
                            </body>
                        </text>
                    </TEI>
                </xsl:result-document>

            </xsl:if>

        </xsl:for-each>

    </xsl:template>

    <!-- TEI HEADER TEMPLATE -->
    <!-- ??? Update the following! -->
    <!-- !!! This will need to be updated for each new spreadsheet that has different contributors -->
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="converted-columns"/>
        <xsl:param name="en-headword"/>
        <xsl:variable name="en-title">
            <!-- checks whether there is an English Syriaca headword. If not, just uses the record-id as the page title. -->
            <xsl:choose>
                <xsl:when
                    test="$en-headword">
                    <xsl:value-of
                        select="$en-headword"
                    />
                </xsl:when>
                <xsl:otherwise>Person <xsl:value-of select="$record-id"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="anonymous-description">
            <!-- grabs the anonymous description, if there is one. -->
            <xsl:choose>
                <xsl:when
                    test="$converted-columns/*[@syriaca-tags='#anonymous-description']">
                    <xsl:value-of
                        select="$converted-columns/*[@syriaca-tags='#anonymous-description']"
                    />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="syriac-headword">
            <!-- grabs the Syriac headword, if there is one. -->
            <xsl:choose>
                <xsl:when
                    test="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang,'syr')]">
                    <xsl:value-of
                        select="$converted-columns/*[@syriaca-tags='#syriaca-headword' and starts-with(@xml:lang,'syr')]"
                    />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- combines the English and Syriac headwords to make the record title -->
        <xsl:variable name="record-title">
            <xsl:value-of select="$en-title"/>
            <xsl:choose>
                <xsl:when test="string-length($anonymous-description)"> — <xsl:value-of
                    select="$anonymous-description"/></xsl:when>
                <xsl:when test="string-length($syriac-headword)"> — <foreign xml:lang="syr"><xsl:value-of
                    select="$syriac-headword"/></foreign></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- checks whether the person has been categorized as a saint or author (neither is required) -->
        <xsl:variable name="is-saint" select="contains(person_ana,'#syriaca-saint')"/>
        <xsl:variable name="is-author" select="contains(person_ana,'#syriaca-author')"/>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title level="a" xml:lang="en">
                        <xsl:copy-of select="$record-title"/>
                    </title>
                    <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
                    <funder>The International Balzan Prize Foundation</funder>
                    <funder>The National Endowment for the Humanities</funder>
                    <principal>David A. Michelson</principal>

                    <!-- EDITORS -->
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                        Michelson</editor>
                    <editor role="associate" ref="http://syriaca.org/documentation/editors.xml#jnsaint-laurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P.
                        Gibson</editor>
                    <editor role="associate" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L.
                        Schwartz</editor>

                    <!-- CREATOR -->
                    <!-- designates the editor responsible for creating this person record (may be different from the file creator) -->
                    <editor role="creator" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L.
                        Schwartz</editor>

                    <!-- CONTRIBUTORS -->
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dschwartz">Daniel L. Schwartz</name>
                    </respStmt>
                    <respStmt>
                        <resp>Data architecture by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Data conversion by</resp>
                        <name ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P. Gibson</name>
                    </respStmt>
                </titleStmt>
                <editionStmt>
                    <edition n="1.0"/>
                </editionStmt>
                <publicationStmt>
                    <authority>Syriaca.org: The Syriac Reference Portal</authority>
                    <idno type="URI">http://syriaca.org/person/<xsl:value-of select="$record-id"
                        />/tei</idno>
                    <availability>
                        <licence target="http://creativecommons.org/licenses/by/3.0/">
                            <p>Distributed under a Creative Commons Attribution 3.0 Unported
                                License.</p>
                            <!-- !!! If copyright material is included, the following should be adapted and used. -->
                            <!--<p>This entry incorporates copyrighted material from the following work(s):
                                    <listBibl>
                                            <bibl>
                                                <ptr>
                                                    <xsl:attribute name="target" select="'foo1'"/>
                                                </ptr>
                                            </bibl>
                                            <bibl>
                                                <ptr>
                                                    <xsl:attribute name="target" select="'foo2'"/>
                                                </ptr>
                                            </bibl>
                                    </listBibl>
                                    <note>used under a Creative Commons Attribution license <ref target="http://creativecommons.org/licenses/by/3.0/"/></note>
                                </p>-->
                        </licence>
                    </availability>
                    <date>
                        <xsl:value-of select="current-date()"/>
                    </date>
                </publicationStmt>

                <!-- SERIES STATEMENTS -->
                <seriesStmt>
                    <title level="s">The Syriac Biographical Dictionary</title>
                    <editor role="general"
                        ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                        Michelson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A.
                        Carlson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#ngibson">Nathan P.
                        Gibson</editor>
                    <editor role="associate"
                        ref="http://syriaca.org/documentation/editors.xml#jnsaint-laurent"
                        >Jeanne-Nicole Mellon Saint-Laurent</editor>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                            Michelson</name>
                    </respStmt>
                    <respStmt>
                        <resp>Edited by</resp>
                        <name type="person"
                            ref="http://syriaca.org/documentation/editors.xml#tcarlson">Thomas A.
                            Carlson</name>
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
                            ref="http://syriaca.org/documentation/editors.xml#jnsaint-laurent"
                            >Jeanne-Nicole Mellon Saint-Laurent</name>
                    </respStmt>
                    <idno type="URI">http://syriaca.org/persons</idno>
                    <!-- selects which vol. of SBD this record is contained in, depending on whether the person is a saint and/or author. 
                        Vol. 1 for saints, vol. 2 for authors, vol. 3 for neither. -->
                    <xsl:if test="$is-saint">
                        <biblScope unit="vol" from="1" to="1">
                            <title level="m">Qadishe: A Guide to the Syriac Saints</title>
                            <idno type="URI">http://syriaca.org/q</idno>
                        </biblScope>
                    </xsl:if>
                    <xsl:if test="$is-author">
                        <biblScope unit="vol" from="2" to="2">
                            <title level="m">A Guide to Syriac Authors</title>
                            <idno type="URI">http://syriaca.org/authors</idno>
                        </biblScope>
                    </xsl:if>
                    <xsl:if test="not($is-saint) and not($is-author)">
                        <biblScope unit="vol">3</biblScope>
                    </xsl:if>
                </seriesStmt>
                
                <!-- adds a series statement for saints dataset if the person is a saint -->
                <xsl:if test="$is-saint">
                    <seriesStmt>
                        <title level="s">Gateway to the Syriac Saints</title>
                        <editor role="general"
                            ref="http://syriaca.org/documentation/editors.xml#jnsaint-laurent"
                            >Jeanne-Nicole Mellon Saint-Laurent</editor>
                        <editor role="general"
                            ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A.
                            Michelson</editor>
                        <respStmt>
                            <resp>Edited by</resp>
                            <name type="person"
                                ref="http://syriaca.org/documentation/editors.xml#jnsaint-laurent"
                                >Jeanne-Nicole Mellon Saint-Laurent</name>
                        </respStmt>
                        <respStmt>
                            <resp>Edited by</resp>
                            <name type="person"
                                ref="http://syriaca.org/documentation/editors.xml#dmichelson">David
                                A. Michelson</name>
                        </respStmt>
                        <idno type="URI">http://syriaca.org/saints</idno>
                        <biblScope unit="vol" from="2" to="2">
                            <title level="m">Qadishe: A Guide to the Syriac Saints</title>
                            <idno type="URI">http://syriaca.org/q</idno>
                        </biblScope>
                    </seriesStmt>
                </xsl:if>
                
                <sourceDesc>
                    <p>Born digital.</p>
                </sourceDesc>
            </fileDesc>

            <!-- SYRIACA.ORG TEI DOCUMENTATION -->
            <encodingDesc>
                <editorialDecl>
                    <p>This record created following the Syriaca.org guidelines. Documentation
                        available at: <ref target="http://syriaca.org/documentation"
                            >http://syriaca.org/documentation</ref>.</p>
                    <interpretation>
                        <p>Approximate dates described in terms of centuries or partial centuries
                            have been interpreted as documented in <ref
                                target="http://syriaca.org/documentation/dates.html">Syriaca.org
                                Dates</ref>.</p>
                    </interpretation>
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
                            <catDesc>A person who is relevant to the Guide to Syriac
                                Authors</catDesc>
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
                    <!-- !!! Additional languages, if used, should be added here. -->
                    <language ident="syr">Unvocalized Syriac of any variety or period</language>
                    <language ident="syr-Syrj">Vocalized West Syriac</language>
                    <language ident="syr-Syrn">Vocalized East Syriac</language>
                    <language ident="en">English</language>
                    <language ident="en-x-gedsh">Names or terms Romanized into English according to
                        the standards adopted by the Gorgias Encyclopedic Dictionary of the Syriac
                        Heritage</language>
                    <language ident="ar">Arabic</language>
                    <language ident="fr">French</language>
                    <language ident="de">German</language>
                    <language ident="la">Latin</language>
                </langUsage>
            </profileDesc>
            <revisionDesc status="draft">

                <!-- FILE CREATOR -->
                <change who="http://syriaca.org/documentation/editors.xml#ngibson" n="1.0">
                    <xsl:attribute name="when" select="current-date()"/>CREATED: person</change>

                <!-- PLANNED CHANGES -->
                <!-- ??? Are there any change @type='planned' ? -->
            </revisionDesc>
        </teiHeader>
    </xsl:template>

    <!-- COLUMN MAPPING TEMPLATE -->
    <!-- converts spreadsheet columns using $column-mapping variable above -->
    <!-- ??? This template does not yet try to reconcile identical elements coming from different sources -->
    <!-- ??? This is producing extra spaces on some Syriac names, e.g., person/2246 -->
    <xsl:template name="column-mapping" xmlns="http://www.tei-c.org/ns/1.0">
        <!-- the columns of this particular row that should be converted, with the data they contain. -->
        <xsl:param name="columns-to-convert"/>
        <xsl:param name="record-bibls"/>
        <xsl:param name="record-uri"/>
        <!-- attributes that should not be attached to converted columns -->
        <xsl:variable name="custom-attributes" select="('column','sourceUriColumn','whenColumn','notBeforeColumn','notAfterColumn')"/>
        <!-- cycles through each of the columns that should be converted, to pull them into the elements pre-defined in $column-mapping -->
        <xsl:for-each select="$columns-to-convert">
            <xsl:variable name="column-name" select="name()"/>
            <xsl:variable name="column-position" select="position()"/>
            <xsl:if test=".!=''">
                <!-- grabs the contents of the column so that it can be used in nested for-each statements -->
                <xsl:variable name="column-contents">
                    <xsl:copy-of select="syriaca:include-tei-children(.)"/>
                </xsl:variable>
                <!-- cycles through each of the elements pre-defined in $column-mapping, checking whether they have the current spreadsheet column as @column 
                    and processing the data if they do. -->
                <xsl:for-each select="$column-mapping/*">
                    <xsl:variable name="this-column" select="."/>
                    <!-- gets the bibl URI number from the cell that contains the source for the spreadsheet cell being processed -->
                    <xsl:variable name="this-column-source"
                        select="$columns-to-convert[name()=$this-column/@sourceUriColumn][1]"/>
                    <!-- turns that bibl URI number into a complete Syriaca.org URI -->
                    <xsl:variable name="column-uri"
                        select="concat('http://syriaca.org/bibl/',$this-column-source)"/>
                    <!-- gets the name/position of the spreadsheet column that contains the citedRange data for this cell (using the source column name) -->
                    <xsl:variable name="cited-range"
                        select="$column-mapping/citedRange[@sourceUriColumn=name($this-column-source)]/@column"/>
                    <!-- gets the contents of that citedRange cell (e.g., page number) -->
                    <xsl:variable name="cited-range-contents"
                        select="$columns-to-convert[position()=$cited-range or name()=$cited-range]"/>
                    <!-- gets the values of subsidiary date columns (machine-readable dates) to use as attribute values  -->
                    <xsl:variable name="when"
                        select="$columns-to-convert[name()=$this-column/@whenColumn]"/>
                    <xsl:variable name="not-before"
                        select="$columns-to-convert[name()=$this-column/@notBeforeColumn]"/>
                    <xsl:variable name="not-after"
                        select="$columns-to-convert[name()=$this-column/@notAfterColumn]"/>
                    <!-- checks whether this $column-mapping/@column matches the name or position of the spreadsheet column being processed. 
                        (Column name is used for manual column mapping; unique column names required. Column position is used for auto column mapping.) -->
                    <xsl:if
                        test="string(@column)=string($column-name) or string(@column)=string($column-position)">
                        <!-- creates an element with the same name as the $column-mapping element, 
                        unless it is an event attestation, which needs to create multiple elements -->
                        <xsl:choose>
                            <xsl:when test="name()='event' and @type='attestation'">
                                <!-- Creates an event type="attestation" for each work URI -->
                                <xsl:variable name="node-name" select="name()"/>
                                <xsl:variable name="node-attributes" select="attribute::*[not(name()=$custom-attributes) and not(.!='')]"/>
                                <xsl:variable name="attestation-URIs" select="tokenize($column-contents,'\s*,\s*')"/>
                                <xsl:variable name="en-headword" select="normalize-space($columns-to-convert[matches(name(.),'.*syriaca\-headword.*\.en.*') and .!=''][1])"/>
                                <xsl:for-each select="$attestation-URIs">
                                    <xsl:variable name="attesting-work-url" select="concat(replace(.,'http://syriaca.org','http://wwwb.library.vanderbilt.edu'),'/tei')"/>
                                    <xsl:variable name="attesting-work-title">
                                        <xsl:copy-of
                                            select="document($attesting-work-url)/TEI/text/body/bibl/title[contains(@syriaca-tags,'#syriaca-headword') and starts-with(@xml:lang,'en')]"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                    </xsl:variable>
                                    <xsl:element name="{$node-name}">
                                        <xsl:copy-of select="$node-attributes"/>
                                        <p xml:lang="en"><xsl:value-of select="$en-headword"/> is commemorated in <title ref="{.}"><xsl:value-of select="$attesting-work-title"/></title>.</p>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{name()}">
                                    <!-- adds the general attributes defined in $column-mapping, plus date attributes-->
                                    <!-- !!! If you add new types of attributes in $column-mapping, you must also create them here -->
                                    <xsl:copy-of select="@*[not(name()=$custom-attributes)]"/>
                                    <xsl:if test="$when!=''">
                                        <xsl:attribute name="when" select="$when"/>
                                        <xsl:attribute name="syriaca-computed-start"
                                            select="syriaca:custom-dates($when)"/>
                                    </xsl:if>
                                    <xsl:if test="$not-before!=''">
                                        <xsl:attribute name="notBefore" select="$not-before"/>
                                        <xsl:attribute name="syriaca-computed-start"
                                            select="syriaca:custom-dates($not-before)"/>
                                    </xsl:if>
                                    <xsl:if test="$not-after!=''">
                                        <xsl:attribute name="notAfter" select="$not-after"/>
                                        <xsl:attribute name="syriaca-computed-end"
                                            select="syriaca:custom-dates($not-after)"/>
                                    </xsl:if>
                                    <!-- adds the source column by matching the @sourceUriColumn (and corresponding citedRange, where present) to the available bibl ptr elements.  -->
                                    <xsl:choose>
                                        <xsl:when test="@sourceUriColumn!='' and $cited-range-contents!='' and tei:citedRange!=''">
                                            <xsl:attribute name="source"
                                                select="concat('#',$record-bibls/*[tei:ptr/@target=$column-uri and matches($cited-range-contents,tei:citedRange/text())][1]/@xml:id)"
                                            />
                                        </xsl:when>
                                        <xsl:when test="@sourceUriColumn!=''">
                                            <xsl:attribute name="source"
                                                select="concat('#',$record-bibls/*[tei:ptr/@target=$column-uri][1]/@xml:id)"
                                            />
                                        </xsl:when>
                                    </xsl:choose>
                                    <!-- creates element contents. Default is to put the contents of the column directly inside the element, but certain elements 
                                        have to be handled differently. -->
                                    <!-- !!! If you have added element types in $column-mapping that require special handling (e.g., as an attribute value or inside a <desc>), 
                                        you should process them here. -->
                                    <xsl:choose>
                                        <!-- puts column contents inside a <label> -->
                                        <xsl:when test="name()='state'">
                                            <xsl:element name="label">
                                                <xsl:value-of select="$column-contents"/>
                                            </xsl:element>
                                        </xsl:when>
                                        <!-- puts column contents inside a <label> -->
                                        <xsl:when test="name()='trait'">
                                            <xsl:element name="label">
                                                <xsl:value-of select="$column-contents"/>
                                            </xsl:element>
                                        </xsl:when>
                                        <!-- processes relation elements -->
                                        <xsl:when test="name()='relation'">
                                            <!-- processes multiple comma-separated relation uris -->
                                            <!-- ??? Need to sanitize possible spaces between uris using normalize-space()? -->
                                            <xsl:variable name="tokenized-relation-uris">
                                                <xsl:for-each select="tokenize($column-contents,',')">
                                                    <!-- makes a partial URI into a full URI -->
                                                    <xsl:if test="not(contains(.,'http'))"
                                                        >http://syriaca.org/person/</xsl:if>
                                                    <xsl:value-of select="concat(.,' ')"/>
                                                </xsl:for-each>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <!-- adds possibly identical relation -->
                                                <!-- !!! You can define more relation types here (and in $column-mapping) -->
                                                <xsl:when test="@name='possibly-identical'">
                                                    <xsl:attribute name="mutual"
                                                        select="concat($record-uri,' ',normalize-space($tokenized-relation-uris))"/>
                                                    <desc xml:lang="en">This person is possibly identical
                                                        with one or more persons represented in another
                                                        record</desc>
                                                </xsl:when>
                                                <xsl:when test="@name='different-from'">
                                                    <xsl:attribute name="mutual"
                                                        select="concat($record-uri,' ',normalize-space($tokenized-relation-uris))"/>
                                                    <desc xml:lang="en">The following persons are not identical but have been or could be confused: 
                                                        <xsl:value-of select="string-join(($record-uri,string-join(normalize-space($tokenized-relation-uris),', ')),', ')"/></desc>
                                                </xsl:when>
                                                <xsl:when test="@name='has-relation-to-place'">
                                                    <xsl:attribute name="active"
                                                        select="$record-uri"/>
                                                    <xsl:attribute name="passive"
                                                        select="normalize-space($tokenized-relation-uris)"/>
                                                    <desc xml:lang="en">This person has an unspecified connection to places.</desc>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- creates <sex> and puts the column contents into the @value -->
                                        <xsl:when test="name()='sex'">
                                            <xsl:attribute name="value" select="$column-contents"/>
                                            <!-- puts a long-form value into the element content -->
                                            <!-- !!! Other abbreviations for <sex> could be spelled out here. -->
                                            <xsl:choose>
                                                <xsl:when test="$column-contents='M'">male</xsl:when>
                                                <xsl:when test="$column-contents='F'">female</xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- if the column does not meet the above tests for special processing, the column contents are put directly into the element -->
                                        <xsl:otherwise>
                                            <xsl:copy-of select="$column-contents"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- BIBLS TEMPLATE -->
    <!-- creates bibl elements for the row when called, using the @sourceUriColumn values defined in $column-mapping -->
    <!-- ??? bibl-ids are not consecutive when not all sources are used. Perhaps this could be solved by only processing the @sourceUriColumn for cells that are not blank? -->
    <xsl:template name="bibls" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <!-- the contents of the spreadsheet row being processed -->
        <xsl:param name="this-row"/>
        <!-- creates a sequence of the column names of all the source columns used in the spreadsheet. -->
        <xsl:variable name="sources" select="distinct-values($column-mapping//@sourceUriColumn)"/>
        <!-- creates a bibl for each of the source columns used in the spreadsheet. -->
        <xsl:for-each select="$sources">
            <xsl:variable name="source-uri-column" select="."/>
            <!-- cycles through each of the columns in $this-row, checking whether it matches the source column being processed -->
            <xsl:for-each select="$this-row">
                <xsl:variable name="this-column-position" select="position()"/>
                <xsl:if test=".!=''">
                    <xsl:variable name="this-column" select="name()"/>
                    <!-- checks whether the name of this column matches the name of the source column (boolean) -->
                    <xsl:variable name="is-matching-source-column"
                        select="name()=$source-uri-column"/>
                    <!-- gets the citedRange from $column-mapping that names this column as its @sourceUriColumn -->
                    <xsl:variable name="cited-ranges"
                        select="$column-mapping/citedRange[@sourceUriColumn=$this-column]"/>
                    <!-- checks whether there is cited range data for this source column (boolean) -->
                    <xsl:variable name="has-cited-ranges"
                        select="$this-row[name()=$cited-ranges/@column or position()=$cited-ranges/@column]!=''"/>
                    <!-- produces bibl only if this is the matching source column and has data in corresponding cited range columns -->
                    <xsl:if test="$is-matching-source-column and $has-cited-ranges">
                        <!-- creates the path to the bibl TEI using the URI number from the cell being processed -->
                        <xsl:variable name="bibl-url"
                            select="concat('http://wwwb.library.vanderbilt.edu/bibl/',.,'/tei')"/>

                        <!-- BIBL ELEMENT -->
                        <bibl>
                            <!-- adds an @xml:id in the format "bib000-0", where 000 is the ID of this record and 0 is the number of this <bibl>  -->
                            <xsl:attribute name="xml:id"
                                select="concat('bib',$record-id,'-',index-of($sources,$source-uri-column))"/>
                            <!-- grabs the title of the remote bibl record and imports it here. -->
                            <!-- ??? What info do we want to include here - just the title or more? The title of the TEI doc or the title of the described bibl? -->
                            <xsl:copy-of
                                select="document($bibl-url)/TEI/teiHeader/fileDesc/titleStmt/title"
                                xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                            <!-- adds a pointer with this bibl's URI -->
                            <ptr target="{concat('http://syriaca.org/bibl/',.)}"/>
                            <!-- cycles through citedRange(s) and adds to bibl. This accepts multiple citedRanges for the same bibl (e.g., both page and section numbers), 
                                if they exist. -->
                            <xsl:for-each select="$cited-ranges">
                                <xsl:variable name="this-cited-range" select="."/>
                                <xsl:variable name="this-cited-range-content" select="$this-row[name()=$this-cited-range/@column or position()=$this-cited-range/@column]"/>
                                <xsl:if test="not(matches($this-cited-range-content,'^\s*[Nn][Oo][Nn][Ee]\s*$')) and string-length($this-cited-range-content)">
                                    <xsl:variable name="this-cited-range-URL">
                                        <xsl:analyze-string select="$this-cited-range-content" regex="\[(http://.*)\]">
                                            <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:variable>
                                    <xsl:variable name="this-cited-range-non-URL" select="replace($this-cited-range-content,'\s*\[http://.*\]\s*','')"/>
                                    <xsl:element name="citedRange">
                                        <xsl:attribute name="unit" select="$this-cited-range/@unit"/>
                                        <!-- adds URI of citedRange to @target
                                        expects URI for citedRange in square brackets, e.g., [http://archive.org/...] -->
                                        <xsl:if test="$this-cited-range-URL!=''">
                                            <xsl:attribute name="target" select="$this-cited-range-URL"/>
                                        </xsl:if>
                                        <!-- gets the value of the cited range cell in the spreadsheet whose column name or position matches the @column 
                                            defined in $column-mapping/citedRange -->
                                        <xsl:value-of select="normalize-space($this-cited-range-non-URL)"/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </bibl>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
