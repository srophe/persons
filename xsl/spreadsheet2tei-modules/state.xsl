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
            <xd:p>Don't forget to add new roles to the next variable too! (see rant ad loc.)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="roles">
        <role type="office" role="empress">empress</role>
        <role type="office" role="patriarch">patriarch|patr\.</role>
        <role type="office" role="catholicos">catholicos|cath\.</role>
        <role type="office" role="maphrian">maphrian|maphryono</role>
        <role type="office" role="metropolitan">metropolitan|metr\.</role>
        <role type="office" role="bishop">bishop|bp\.</role>
        <role type="office" role="periodeutes">periodeutes</role>
        <role type="office" role="abbot">abbot</role>
        <role type="office" role="priest">priest|presbyter</role>
        <role type="office" role="monk">monk</role>
        <role type="office" role="archdeacon">archdeacon</role>
        <role type="office" role="deacon">deacon</role>
        <role type="office" role="ascetic">stylite|ascetic|recluse|stranger</role>
        <role type="office" role="chanter">chanter</role>
        <role type="office" role="count">count</role>
        <role type="office" role="historian">historian</role>
        <role type="office" role="philosopher">philosopher</role>
        <role type="saint" role="saint">saint|st\.</role>
        <role type="saint" role="martyr">martyr</role>
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>This variable is used to test a string for ANY of the above roles.</xd:p>
            <xd:p>I know it should be automatically generated from the preceding variable, but I have not been able to find a way to
            do so in XSL.  I tried using string-join($roles,'\|'), replace(string($roles),' ','\'), and even making the content of this variable
            the result of cycling through $roles with a for-each outputing xsl:value-of @select="." followed by | (both encapsulated by
            xsl:text tags and free-standing), and none of these produced pipe delimited text values.  I also tried creating an auxiliary 
            variable using the xsl:sequence constructor with @select="$roles/*/text()" and then calling string-join on that with the pipe
            as the delimiter, and that also failed.  After four hours working on this one problem, it is more cost effective for me to leave
            this to someone who has better XSL skeelz than I do.  -Thomas Carlson</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="all-roles">patriarch|patr\.|catholicos|cath\.|maphrian|maphryono|metropolitan|metr\.|bishop|bp\.|abbot|priest|presbyter|monk|deacon|saint|st\.|martyr|archdeacon|count|chanter|stylite|ascetic|recluse|stranger|historian|empress|philosopher|periodeutes</xsl:variable>
    
 
    <xd:doc>
        <xd:desc>
            <xd:p>This template tests whether the "Titles" part of a name matches any of the roles defined in the $roles variable. 
            Matching elements (or comma-separated values) are sent to the state-element template to create the state element.</xd:p>
        </xd:desc>
        <xd:param name="all-titles">All non-empty titles, as determined by the master stylesheet.</xd:param>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
        <xd:param name="reign-dates">The row correspond to this entry.  Used to check whether reign dates exist.</xd:param>
    </xd:doc>
    <!-- Should roles created from saint titles really be traits instead of states? -->
    <xsl:template name="roles-from-titles">
        <xsl:param name="all-titles"/>
        <xsl:param name="bib-ids"/>
        <xsl:param name="reign-dates"/>
        <xsl:for-each select="$all-titles[not(matches(name(),'Other_en|GS_en'))]">
            <xsl:variable name="column-name" select="name()"/>
            <xsl:variable name="column" select="."/>
            <xsl:choose>
                <xsl:when test="exists($roles/*[matches($column, node(), 'i')]) and matches(., ',\s')">
                    <xsl:for-each select="tokenize(., ',\s')">
                        <xsl:variable name="subcolumn" select="."/>
                        <xsl:if test="exists($roles/*[matches($subcolumn, node(), 'i')])">
                            <xsl:call-template name="state-element">
                                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                                <xsl:with-param name="type" select="$roles/*[matches($subcolumn, node(), 'i')][1]/@type"/>
                                <xsl:with-param name="role" select="$roles/*[matches($subcolumn, node(), 'i')][1]/@role"/>
                                <xsl:with-param name="column" select="."/>
                                <xsl:with-param name="column-name" select="$column-name"/>
                                <xsl:with-param name="reign-dates" select="$reign-dates"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="exists($roles/*[matches($column, node(), 'i')])">
                    <xsl:call-template name="state-element">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="type" select="$roles/*[matches($column, node(), 'i')][1]/@type"/>
                        <xsl:with-param name="role" select="$roles/*[matches($column, node(), 'i')][1]/@role"/>
                        <xsl:with-param name="column" select="node()"/>
                        <xsl:with-param name="column-name" select="$column-name"/>
                        <xsl:with-param name="reign-dates" select="$reign-dates"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
        <!-- If there are regnal dates, but no title roles, then add a state with reign information but no @role -->
        <xsl:if test="exists($reign-dates) and not(exists($all-titles[matches(node(), $all-roles, 'i')]))">
            <xsl:call-template name="state-element">
                <xsl:with-param name="bib-ids" select="$bib-ids"/>
                <xsl:with-param name="type">office</xsl:with-param>
                <xsl:with-param name="column" select="$reign-dates[ends-with(name(),'Reign')][1]"/>
                <xsl:with-param name="column-name" select="name($reign-dates[ends-with(name(),'Reign')][1])"/>
                <xsl:with-param name="reign-dates" select="$reign-dates"/>
            </xsl:call-template>
        </xsl:if>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template generates a state element with @type, @role, @source, and @xml:lang attributes.</xd:p>
        </xd:desc>
        <xd:param name="bib-ids">The $bib-ids param is used for adding @source attributes. (See the source template.)</xd:param>
        <xd:param name="type">The value of the @type attribute of the state element.</xd:param>
        <xd:param name="role">The value of the @role attribute of the state element, if one exists.  Optional.</xd:param>
        <xd:param name="column">The column (or partial column) containing the content used for desc inside the state element, and which matches
            one of the elements in the $roles sequence variable.</xd:param>
        <xd:param name="column-name">The name of the column contained in the $column param. In the case of multiple, comma-separated 
        values being processed from individually from a single column, this is the name of the column containing the 
        comma-separated values. The $column-name param is passed to the source and language templates so that those templates 
        can use it to detect the language and source information contained in the column name.</xd:param>
        <xd:param name="reign-dates">The columns of the spreadsheet which may contain regnal dates.</xd:param>
    </xd:doc>
    <xsl:template name="state-element" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <xsl:param name="type"/>
        <xsl:param name="role"></xsl:param>
        <xsl:param name="column"/>
        <xsl:param name="column-name"/>
        <xsl:param name="reign-dates"/>
        <state>
            <xsl:attribute name="type" select="$type"/>
            <xsl:if test="string-length($role)">
                <xsl:attribute name="role" select="$role"/>
            </xsl:if>
            
            <!-- Include reign dates as @from and @to if they exist; if so, also need to cite souce -->
            <xsl:choose>
                <xsl:when test="exists($reign-dates)">
                    <xsl:if test="string-length(normalize-space($reign-dates[ends-with(name(), 'Begin_Standard')]))">
                        <xsl:attribute name="from"><xsl:value-of select="normalize-space($reign-dates[ends-with(name(), 'Begin_Standard')])"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space($reign-dates[ends-with(name(), 'End_Standard')]))">
                        <xsl:attribute name="to"><xsl:value-of select="normalize-space($reign-dates[ends-with(name(), 'End_Standard')])"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="multiple-sources">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="column-names" select="(name($reign-dates[ends-with(name(),'Reign')][1]),$column-name)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="multiple-sources">
                        <xsl:with-param name="bib-ids" select="$bib-ids"/>
                        <xsl:with-param name="column-names" select="($column-name)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            
            <desc>
                <xsl:call-template name="language">
                    <xsl:with-param name="column-name" select="$column-name"/>
                </xsl:call-template>
                <xsl:value-of select="$column"/>
            </desc>
        </state>
    </xsl:template>
</xsl:stylesheet>