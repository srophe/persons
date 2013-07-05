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
            <xd:p>This stylesheet contains template(s) for adding @source attributes to person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template adds an @source attribute to an element, using the column name before the hyphen to determine 
            the correct bibl xml:id to link to. For example, data from the column "GEDSH_en-Full" is assigned a @source attribute 
            by searching for elements in the $bib-ids sequence variable that contain "GEDSH en".</xd:p>
        </xd:desc>
        <xd:param name="bib-ids">A sequence of @xml:id attribute values for bibl elements, contained as the content of elements 
            which have as names the column name of a column coming from that source. For example, $bib-ids may contain the following: 
            &lt;GEDSH_en-Full&gt;bibl1-1&lt;/GEDSH_en-Full&gt;</xd:param>
        <xd:param name="column-name">The name of the column being processed, used to identify which corresponding 
        element in $bib-ids should be used as the value of the @source attribute. This defaults to the name of the current 
        node, but can be overwritten by by specifying something different when calling the parameter.</xd:param>
    </xd:doc>
    <xsl:template name="source" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <xsl:param name="column-name" select="name(.)"/>
        <!-- Adds @source if the column is from a source external to syriaca.org. -->
        <xsl:if test="not(matches($column-name, 'GS_|Authorized_|Other_en'))">
            <!-- Finds the bibl xml:id to use for this column by testing which of the $bib-ids elements matches the column name
            before the hyphen. -->
            <xsl:attribute name="source" select="concat('#', $bib-ids/*[contains(name(), substring-before($column-name, '-'))][1])"/>
        </xsl:if>
   </xsl:template>
</xsl:stylesheet>