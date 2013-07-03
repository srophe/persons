<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 2, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nathan Gibson</xd:p>
            <xd:p>This stylesheet contains various templates for generating names for person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
      
    <xd:doc>
        <xd:desc>
            <xd:p>This template creates the persName element with all its attributes, then calls the name-parts template 
            to fill in any child elements containing individual parts of the name.</xd:p>
        </xd:desc>
        <xd:param name="all-full-names">This param contains a sequence of all the elements containing full names. It is 
        used to help create the $name-ids and $name-links params.</xd:param>
        <xd:param name="person-name-id">This param contains the first part of the persName @xml:id attribute content in the 
            format "name10", where the 10 is the SRP ID of the person entity. It is used for creating the full persName @xml:id 
        by calling the persName-id template, which is in the format "name10-1".</xd:param>
        <xd:param name="ids-base">A sequence of numbers (which may include "a" or "b" in addition to the number) which correspond 
        to bibl ids and vocalization markers. Each element name is the name of a column coming from that source/vocalization. 
        These numbers are used to create @xml:id attributes for various elements. Here they are used to create $name-ids.</xd:param>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
        <xd:param name="sort">Determines which name part should be used first in alphabetical lists by consulting the order in GEDSH or 
            GEDSH-style. Doesn't work for comma-separated name parts that should be sorted as first (a situation that should be rare). 
            If no name part can be matched with beginning of full name, defaults to given, then family, then titles, if they exist.
            If no GEDSH or GEDSH-style name exists, defaults to given.</xd:param>
    </xd:doc>
    <xsl:template name="names" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="all-full-names"/>
        <xsl:param name="person-name-id"/>
        <xsl:param name="ids-base"/>
        <xsl:param name="bib-ids"/>
        <xsl:param name="sort">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(GEDSH_en-Full)) and string-length(normalize-space(concat(GEDSH_en-Given, GEDSH_en-Family, GEDSH_en-Titles)))">
                    <xsl:choose>
                        <xsl:when test="starts-with(GEDSH_en-Full, GEDSH_en-Given)">given</xsl:when>
                        <xsl:when test="starts-with(GEDSH_en-Full, GEDSH_en-Family)">family</xsl:when>
                        <xsl:when test="starts-with(GEDSH_en-Full, GEDSH_en-Titles)">titles</xsl:when>
                        <xsl:when test="string-length(normalize-space(GEDSH_en-Given))">given</xsl:when>
                        <xsl:when test="string-length(normalize-space(GEDSH_en-Family))">family</xsl:when>
                        <xsl:when test="string-length(normalize-space(GEDSH_en-Titles))">titles</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="string-length(normalize-space(GS_en-Full)) and string-length(normalize-space(concat(GS_en-Given, GS_en-Family, GS_en-Titles)))">
                    <xsl:choose>
                        <xsl:when test="starts-with(GS_en-Full, GS_en-Given)">given</xsl:when>
                        <xsl:when test="starts-with(GS_en-Full, GS_en-Family)">family</xsl:when>
                        <xsl:when test="starts-with(GS_en-Full, GS_en-Titles)">titles</xsl:when>
                        <xsl:when test="string-length(normalize-space(GS_en-Given))">given</xsl:when>
                        <xsl:when test="string-length(normalize-space(GS_en-Family))">family</xsl:when>
                        <xsl:when test="string-length(normalize-space(GS_en-Titles))">titles</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>given</xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <!-- Selects any non-empty fields ending with "_Full" or "-Full" (i.e., full names) -->
        <xsl:for-each
            select="*[matches(name(),'(_|-)Full') and string-length(normalize-space(node()))]">
            <persName>
                <!-- Adds xml:id attribute. -->
                <xsl:call-template name="persName-id">
                    <xsl:with-param name="all-full-names" select="$all-full-names"/>
                    <xsl:with-param name="person-name-id" select="$person-name-id"/>
                    <xsl:with-param name="ids-base" select="$ids-base"/>
                </xsl:call-template>
                <!-- Adds language attributes. -->
                <xsl:call-template name="language"/>
                <!-- Adds source attributes. -->
                <xsl:call-template name="source">
                    <xsl:with-param name="bib-ids" select="$bib-ids"/>
                </xsl:call-template>
                <!-- Shows which name forms are syriaca.org headwords. -->
                <!-- Need to test whether this properly overrides GEDSH with GS as headword. -->
                <xsl:choose>
                    <xsl:when test="contains(name(),'GS_en')">
                        <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                    </xsl:when>
                    <xsl:when test="contains(name(),'GEDSH') and not(string-length(normalize-space(*[contains(name(), 'GS_en')])))">
                        <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                    </xsl:when>
                    <xsl:when test="contains(name(),'Authorized_syr')">
                        <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                    </xsl:when>
                    <xsl:when test="contains(name(), 'Barsoum_syr-NV') and contains(../Authorized_syr-Source, 'Barsoum')">
                        <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                    </xsl:when>
                    <xsl:when test="contains(name(), 'Abdisho_YdQ_syr-NV') and contains(../Authorized_syr-Source, 'Abdisho')">
                        <xsl:attribute name="syriaca-tags" select="'#syriaca-headword'"/>
                    </xsl:when>
                </xsl:choose>
                <!--A variable to hold the first part of the column name, which must be the same for all name columns from that source 
                    and vocalization. E.g., "Barsoum_en" for the columns "Barsoum_en", "Barsoum_en-Given", etc.-->
                <xsl:variable name="group" select="replace(name(), '(_|-)Full', '')"/>
                <!-- Adds name parts -->
                <xsl:call-template name="name-parts">
                    <xsl:with-param name="name" select="."/>
                    <xsl:with-param name="count" select="1"/>
                    <xsl:with-param name="all-name-parts"
                        select="following-sibling::*[contains(name(), $group)]"/>
                    <xsl:with-param name="sort" select="$sort"/>
                </xsl:call-template>
            </persName>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a @xml:id attribute for persName elements, as well as @corresp attribute for parallel names. Requires that 
                names that should be parallel have column names starting with same word (before underscore) and that names that should 
                not be parallel do not.</xd:p>
        </xd:desc>
        <xd:param name="all-full-names">This param contains a sequence of all the elements containing full names. It is 
            used to help create the $name-ids and $name-links params.</xd:param>
        <xd:param name="person-name-id">This param contains the first part of the persName @xml:id attribute content in the 
            format "name10", where the 10 is the SRP ID of the person entity. It is used for creating the full persName @xml:id 
            by calling the persName-id template, which is in the format "name10-1".</xd:param>
        <xd:param name="ids-base">A sequence of numbers (which may include "a" or "b" in addition to the number) which correspond 
            to bibl ids and vocalization markers. Each element name is the name of a column coming from that source/vocalization. 
            These numbers are used to create @xml:id attributes for various elements. Here they are used to create $name-ids.</xd:param>
        <xd:param name="name-ids">Creates a sequence of @xml:id attributes for persName elements, in the format "name10-1", where "10" is the 
            record ID of the person record and "1" is the numerical part of the source ID. See Syriaca TEI Manual for more information.</xd:param>
        <xd:param name="name-links">Creates a sequence of links to @xml:id attributes of persName elements, by adding a "#" to the beginning of each 
            node that has content. IMPORTANT - This should create links only for names that actually exist, since these links are 
            added in @corresp to corresponding name elements.</xd:param>
        <xd:param name="current-column-name">The name of the current column being processed. By default, this is the name of the 
        context node.</xd:param>
    </xd:doc>
    <xsl:template name="persName-id" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="all-full-names"/>
        <xsl:param name="person-name-id"/>
        <xsl:param name="ids-base"/>
        <xsl:param name="name-ids">
            <xsl:for-each select="$all-full-names/*">
                <xsl:variable name="name" select="name()"/>
                <xsl:element name="{name()}">
                    <xsl:value-of
                        select="concat($person-name-id, '-', $ids-base/*[contains(name(), $name)])"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:param>
        <xsl:param name="name-links">
            <xsl:for-each select="$name-ids/*">
                <xsl:variable name="name" select="name()"/>
                <!-- If the corresponding full name has content ... -->
                <xsl:if
                    test="string-length(normalize-space($all-full-names/*[contains(name(), $name)]))">
                    <!-- ... create a link to the name id by adding a hash tag to it. -->
                    <xsl:element name="{name()}">#<xsl:value-of select="."/></xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:param>
        <xsl:param name="current-column-name" select="name()"/>
        
        <xsl:attribute name="xml:id" select="$name-ids/*[contains(name(), $current-column-name)]"/>
        <!-- Gets all other name links whose column names start with the same word (e.g., "Barsoum", "Abdisho"). -->
        <!-- Is it OK that vocalized and non-vocalized names from different editions are parallel to each other or should I weed these out? -->
        <xsl:if test="exists($name-links/*[matches(substring-before($current-column-name, '_'), substring-before(name(), '_')) and not(contains(name(), $current-column-name))])">
            <xsl:attribute name="corresp" select="$name-links/*[matches(substring-before($current-column-name, '_'), substring-before(name(), '_')) and not(contains(name(), $current-column-name))]"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Cycles through the fields containing the individual parts of a name, creating and populating the appropriate TEI name fields.
                Name fields using this template should end in one of the following:
                <xd:ul>
                    <xd:li>Given</xd:li>
                    <xd:li>Family</xd:li>
                    <xd:li>Titles</xd:li>
                    <xd:li>Office</xd:li>
                    <xd:li>Saint_Title</xd:li>
                    <xd:li>Numeric_Title</xd:li>
                    <xd:li>Terms_of_Address</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="name">The full name column being processed by the template that calls this one. When this template is called 
        recursively (i.e., loops through to match multiple name parts), this param is updated to include all the child elements that 
        have been added along the way.</xd:param>
        <xd:param name="count">A counter to use for determining the next element to process.</xd:param>
        <xd:param name="all-name-parts">All the individual name part columns corresponding to the full name in $name.</xd:param>
        <xd:param name="sort">Contains a one-word description showing which name part should be used first in alphabetical lists.</xd:param>
        <xd:param name="next-column-name">The name of the next element being processed, which is the element immediately following in $all-name-parts sequence.</xd:param>
        <xd:param name="next-column">Content of the next column being processed, which is the element immediately following in the $all-name-parts sequence.</xd:param>
    </xd:doc>
    <xsl:template name="name-parts" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name"/>
        <xsl:param name="count"/>
        <xsl:param name="all-name-parts"/>
        <xsl:param name="sort"/>
        <xsl:param name="next-column" select="$all-name-parts[$count]"/>
        <xsl:param name="next-column-name" select="name($all-name-parts[$count])"/>
        <xsl:choose>
            <!-- When there are name parts to process ... -->
            <xsl:when test="count($all-name-parts)">
                <!-- Creates a $name-element-name variable that contains the name of the TEI element name to be used for that name part. -->
                <xsl:variable name="name-element-name">
                    <xsl:choose>
                        <xsl:when test="matches($next-column-name,'(_|-)Given')">forename</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Family')">addName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Titles') and exists($roles/*[matches($next-column, node(), 'i')])">roleName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Titles') or matches($next-column-name,'(_|-)Saint_Title') or matches($next-column-name,'(_|-)Terms_of_Address')">addName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Office')">roleName</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Numeric_Title')">genName</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <!-- Creates a $name-element-type variable that contains the value of the TEI @type attribute to be used for that name part. -->
                <!-- Might be able to machine-generate title types based on content (e.g., "III", etc.) -->
                <xsl:variable name="name-element-type">
                    <xsl:choose>
                        <xsl:when test="matches($next-column-name,'(_|-)Family')">family</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Titles') and exists($roles/*[matches($next-column, node(), 'i')])"><xsl:value-of select="$roles/*[matches($next-column, node(), 'i')][1]/@type"/></xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Titles')">untagged-title</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Saint_Title')">saint-title</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Terms_of_Address')">terms-of-address</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Office')">office</xsl:when>
                        <xsl:when test="matches($next-column-name,'(_|-)Numeric_Title')">numeric-title</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <!-- When the name part column contains comma-separated values, processes them each individually by calling 
                    this template recursively. -->
                    <xsl:when test="contains($next-column, ', ') or contains($next-column, '، ')">
                        <xsl:call-template name="name-parts">
                            <xsl:with-param name="name">
                                <xsl:call-template name="name-part-comma-separated">
                                    <xsl:with-param name="name" select="$name"/>
                                    <xsl:with-param name="count" select="1"/>
                                    <!-- The token for splitting comma-separated values doesn't work well for commas inside parentheses. (See SRP 224) -->
                                    <xsl:with-param name="all-name-parts" select="tokenize($next-column, ',\s|،\s')"/>
                                    <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                    <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:with-param>
                            <xsl:with-param name="count" select="$count + 1"/>
                            <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                            <xsl:with-param name="sort" select="$sort"/>
                        </xsl:call-template>                    
                    </xsl:when>
                    <!-- Otherwise, if the next column has a name (i.e., exists at all) ... -->
                    <xsl:when test="string-length($next-column-name)">
                        <xsl:choose>
                            <!-- If the next name part column has content, try to match the name part against the full name 
                                (non-case-sensitive) and turn that part of the full name into a child element by calling 
                            the name-part-element template. Non-matching strings in the full name get reprocessed through 
                            this template (with an incremented counter) to be matched against other name part columns.-->
                            <xsl:when test="string-length($name-element-name) and string-length(normalize-space($next-column))">
                                <xsl:analyze-string select="$name" regex="{functx:escape-for-regex($next-column)}" flags="i">
                                    <xsl:matching-substring>
                                        <xsl:call-template name="name-part-element">
                                            <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                            <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                            <xsl:with-param name="sort" select="$sort"/>
                                        </xsl:call-template>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:call-template name="name-parts">
                                            <xsl:with-param name="name" select="."/>
                                            <xsl:with-param name="count" select="$count + 1"/>
                                            <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                                            <xsl:with-param name="sort" select="$sort"/>
                                        </xsl:call-template>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:when>
                            <!-- If the next column only has a name but no content, increment the counter and run the template again. -->
                            <xsl:otherwise>
                                <xsl:call-template name="name-parts">
                                    <xsl:with-param name="name" select="$name"/>
                                    <xsl:with-param name="count" select="$count + 1"/>
                                    <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- If the next column does not have a name (i.e., does not exist), this template has run its course and 
                        returns the name with any child elements added from previous loops. -->
                    <xsl:otherwise>
                        <xsl:value-of select="$name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- If there are no name parts to process, simply returns the name as is. -->
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template does much the same as the name-part template. See notes there.</xd:p>
        </xd:desc>
        <xd:param name="name">The full name column being processed by the template that calls this one. When this template is called 
            recursively (i.e., loops through to match multiple name parts), this param is updated to include all the child elements that 
            have been added along the way.</xd:param>
        <xd:param name="count">A counter to use for determining the next element to process.</xd:param>
        <xd:param name="all-name-parts">All the individual name part columns corresponding to the full name in $name.</xd:param>
        <xd:param name="name-element-name">The name of the TEI element that will be used for this name part element.</xd:param>
        <xd:param name="name-element-type">The attribute content of the TEI @type attribute that will be used for this name part element.</xd:param>
        <xd:param name="next-column">Content of the next column being processed, which is the element immediately following in the $all-name-parts sequence.</xd:param>
        <xd:param name="sort">Contains a one-word description showing which name part should be used first in alphabetical lists.</xd:param>
    </xd:doc>
    <xsl:template name="name-part-comma-separated" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name"/>
        <xsl:param name="count"/>
        <xsl:param name="all-name-parts"/>
        <xsl:param name="name-element-name"/>
        <xsl:param name="name-element-type"/>
        <xsl:param name="next-column" select="$all-name-parts[$count]"/>
        <xsl:param name="sort"/>
        <xsl:choose>
            <!-- If the counter is less than the number of name parts ... -->
            <xsl:when test="count($all-name-parts) >= $count">
                <xsl:choose>
                    <!-- If there is both an element name to use and the next column has content, tries to match the name part
                        against the full name (non-case-sensitive) and turns that part of the full name into a child element 
                        by calling the name-part-element template. Non-matching strings in the full name get reprocessed through 
                        this template (with an incremented counter) to be matched against other name part columns.  -->
                    <xsl:when test="string-length($name-element-name) and string-length(normalize-space($next-column))">
                        <xsl:analyze-string select="$name" regex="{functx:escape-for-regex($next-column)}" flags="i">
                            <xsl:matching-substring>
                                <xsl:call-template name="name-part-element">
                                    <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                    <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:call-template name="name-part-comma-separated">
                                    <xsl:with-param name="name" select="."/>
                                    <xsl:with-param name="count" select="$count + 1"/>
                                    <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                                    <xsl:with-param name="name-element-name" select="$name-element-name"/>
                                    <xsl:with-param name="name-element-type" select="$name-element-type"/>
                                    <xsl:with-param name="sort" select="$sort"/>
                                </xsl:call-template>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- If there is not both an element name to use and content in the next column, runs this template again 
                    with an incremented counter (to process the next column). -->
                    <xsl:otherwise>
                        <xsl:call-template name="name-part-comma-separated">
                            <xsl:with-param name="name" select="$name"/>
                            <xsl:with-param name="count" select="$count + 1"/>
                            <xsl:with-param name="all-name-parts" select="$all-name-parts"/>
                            <xsl:with-param name="name-element-name" select="$name-element-name"/>
                            <xsl:with-param name="name-element-type" select="$name-element-type"/>
                            <xsl:with-param name="sort" select="$sort"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Once the counter has exceeded the number of name parts, returns the full name with any of the child elements 
            that have been added. -->
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template creates an element for the name part being processed (context node), using the name from 
            $name-element-name and the @type value from $name-element-type. It also creates a @sort attribute to show 
            which part of the name should be evaluated first when alphabetizing lists.</xd:p>
        </xd:desc>
        <xd:param name="name-element-name">The name of the TEI element that will be used for this name part element.</xd:param>
        <xd:param name="name-element-type">The attribute content of the TEI @type attribute that will be used for this name part element.</xd:param>
        <xd:param name="sort">Contains a one-word description showing which name part should be used first in alphabetical lists.</xd:param>
    </xd:doc>
    <xsl:template name="name-part-element" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="name-element-name"/>
        <xsl:param name="name-element-type"/>
        <xsl:param name="sort"/>
        <xsl:element name="{$name-element-name}">
            <xsl:if test="string-length($name-element-type)">
                <xsl:attribute name="type" select="$name-element-type"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space($sort))">
                <xsl:attribute name="sort">
                    <xsl:choose>
                        <xsl:when test="($name-element-name = 'forename') and ($sort = 'given')">1</xsl:when>
                        <xsl:when test="($name-element-name = 'addName')">
                            <xsl:choose>
                                <xsl:when test="($name-element-type = 'family') and ($sort = 'family')">1</xsl:when>
                                <xsl:when test="$sort = 'titles'">1</xsl:when>
                                <xsl:otherwise>2</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="($name-element-name = 'roleName') and ($sort = 'titles')">1</xsl:when>
                        <xsl:otherwise>2</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="."/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>