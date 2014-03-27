<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mads="http://www.loc.gov/mads/v2"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="tei"
  version="2.0">

<!-- This is a utility XSL to count how many MADS files have date information with months instead of only years -->
	<!-- If there is month information, that means the date has YYYY-MM-DD, can tokenizing on '-' yields more than 2 results -->

  <xsl:output method="xml" indent="yes" name="xml"/>
	<xsl:variable name="n"><xsl:text>
</xsl:text></xsl:variable>
 
  <xsl:template match="/">
  	<root>
  	<xsl:for-each select="collection('../xml/mads?select=*.xml')">
  		<xsl:if test="mads:mads/mads:authority/mads:name/mads:namePart[@type='date']">
  			<xsl:variable name="this-date" select="mads:mads/mads:authority/mads:name/mads:namePart[@type='date']"/>
  			<xsl:if test="count(tokenize($this-date,'-')) &gt; 2">
  				<xsl:copy-of select="mads:mads/mads:identifier"/>
  				<xsl:value-of select="$n"/>
  			</xsl:if>
  		</xsl:if>
  	</xsl:for-each>
  	</root>
  </xsl:template>
	
  </xsl:stylesheet>