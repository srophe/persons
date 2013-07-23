<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 27, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nathan Gibson</xd:p>
            <xd:p>This stylesheet creates state elements for person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This variable contains a list of roles the stylesheet can use to automatically create roleName elements 
                and state elements. The @type in the variable corresponds to the @type attribute that should be 
            assigned to the roleName or state. The @role corresponds to the @role attribute that should be used on the state. 
            The content of each element is a regex expression to be automatically matched  (not case-sensitive).
            </xd:p>
            <xd:p>Since the @roleName type will reflect the first match in the list below, the list should be prioritized.</xd:p>
            <xd:p>This variable can be replaced or pointed to an xml document containing this info.</xd:p>
            <xd:p>This list needs more development.</xd:p>
            <xd:p>This is currently generating some false positives in titles referring to anonymous authors or groups. 
                (See, e.g., 124.xml and 476.xml.)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="roles">
        <role type="office" role="patriarch">patriarch|patr\.</role>
        <role type="office" role="catholicos">catholicos|cath\.</role>
        <role type="office" role="maphrian">maphrian|maphryono</role>
        <role type="office" role="metropolitan">metropolitan|metr\.</role>
        <role type="office" role="bishop">bishop|bp\.</role>
        <role type="office" role="abbot">abbot</role>
        <role type="office" role="priest">priest|presbyter</role>
        <role type="office" role="monk">monk</role>
        <role type="office" role="deacon">deacon</role>
        <role type="saint" role="saint">saint|st\.</role>
        <role type="saint" role="martyr">martyr</role>
    </xsl:variable>
    
 
    <xd:doc>
        <xd:desc>
            <xd:p>This template tests whether the "Titles" part of a name matches any of the roles defined in the $roles variable. 
            Matching elements (or comma-separated values) are sent to the state-element template to create the state element.</xd:p>
        </xd:desc>
        <xd:param name="all-titles">All non-empty titles, as determined by the master stylesheet.</xd:param>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
    </xd:doc>
    <!-- Should roles created from saint titles really be traits instead of states? -->
    <xsl:template name="roles-from-titles">
        <xsl:param name="all-titles"/>
        <xsl:param name="bib-ids"/>
        <xsl:for-each select="$all-titles">
            <xsl:variable name="column-name" select="name()"/>
            <xsl:variable name="column" select="."/>
            <xsl:choose>
                <xsl:when test="exists($roles/*[matches($column, node(), 'i')]) and matches(., ',\s')">
                    <xsl:for-each select="tokenize(., ',\s')">
                        <xsl:variable name="subcolumn" select="."/>
                        <xsl:if test="exists($roles/*[matches($subcolumn, node(), 'i')])">
                            <xsl:call-template name="state-element">
                                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                <xsl:with-param name="column" select="."/>
                                <xsl:with-param name="column-name" select="$column-name"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="exists($roles/*[matches($column, node(), 'i')])">
                    <xsl:call-template name="state-element">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="column" select="node()"/>
                        <xsl:with-param name="column-name" select="$column-name"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template generates a state element with @type, @role, @source, and @xml:lang attributes.</xd:p>
        </xd:desc>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
        <xd:param name="column">The column (or partial column) containing the content used for desc inside the state element, and which matches
            one of the elements in the $roles sequence variable.</xd:param>
        <xd:param name="column-name">The name of the column contained in the $column param. In the case of multiple, comma-separated 
        values being processed from individually from a single column, this is the name of the column containing the 
        comma-separated values. The $column-name param is passed to the source and language templates so that those templates 
        can use it to detect the language and source information contained in the column name.</xd:param>
    </xd:doc>
    <xsl:template name="state-element" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <xsl:param name="column"/>
        <xsl:param name="column-name"/>
        <state>
            <xsl:attribute name="type" select="$roles/*[matches($column, node(), 'i')][1]/@type"/>
            <xsl:attribute name="role" select="$roles/*[matches($column, node(), 'i')][1]/@role"/>
            
            <!-- Include GEDSH reign dates as @from and @to if this is a GEDSH column -->
            <xsl:if test="matches($column,'GEDSH') and string-length(normalize-space(GEDSH_en-Reign))">
                <xsl:if test="string-length(normalize-space(GEDSH_en-Reign_Begin_Standard))">
                    <xsl:attribute name="from"><xsl:value-of select="normalize-space(GEDSH_en-Reign_Begin_Standard)"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(GEDSH_en-Reign_End_Standard))">
                    <xsl:attribute name="from"><xsl:value-of select="normalize-space(GEDSH_en-Reign_End_Standard)"/></xsl:attribute>
                </xsl:if>
            </xsl:if>
            
            <xsl:call-template name="source">
                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                <xsl:with-param name="column-name" select="$column-name"/>
            </xsl:call-template>
            <desc>
                <xsl:call-template name="language">
                    <xsl:with-param name="column-name" select="$column-name"/>
                </xsl:call-template>
                <xsl:value-of select="$column"/>
            </desc>
        </state>
    </xsl:template>
</xsl:stylesheet>