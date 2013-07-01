<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template creates idno elements, by generating the VIAF URI corresponding to the entity described in 
            this record, as well as including any URL's logged in the spreadsheet.</xd:p>
        </xd:desc>
        <xd:param name="record-id"></xd:param>
    </xd:doc>
    <xsl:template name="idno" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        
        <idno type="URI">http://syriaca.org/person/<xsl:value-of select="$record-id"
        /></idno>
        <!--What will our VIAF source ID be? SRP?-->
        <idno type="URI">http://viaf.org/viaf/sourceID/SRP|<xsl:value-of select="$record-id"
            /></idno>

        <xsl:for-each select="URL[string-length(normalize-space()) > 0]">
            <idno type="URI">
                <xsl:value-of select="."/>
            </idno>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>