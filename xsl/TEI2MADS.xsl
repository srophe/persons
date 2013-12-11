<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mads="http://www.loc.gov/mads/v2"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="tei"
  version="2.0">

  <xsl:output method="xml" indent="yes" name="xml"/>
 
  <xsl:strip-space elements="tei:span"/>
  
  <xsl:template match="/">
  	<xsl:for-each select="collection('../xml/tei/viaf?select=*.xml')">
	  	<xsl:variable name="filename" select="substring-after(tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/@xml:id,'person-')"></xsl:variable>
  		<xsl:result-document href="../xml/mads/{$filename}-mads.xml" format="xml">
		    <mads:mads version="2.0"
		      xsi:schemaLocation="http://www.loc.gov/standards/mads/mads-2-0.xsd"
			  xmlns:xlink="http://www.w3.org/1999/xlink">
			  <xsl:call-template name="authority"/>
			  <xsl:call-template name="variants"/>
			  <xsl:call-template name="note"/>
			  <xsl:call-template name="identifier"/>
			  <mads:fieldOfActivity>Syriac literature</mads:fieldOfActivity>
			  <xsl:call-template name="recordInfo"/>
			  <xsl:call-template name="urls"/>
			  </mads:mads>
	  	</xsl:result-document>
  	</xsl:for-each>
  </xsl:template>
	
  <xsl:template name="authority">
    <xsl:if test="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:persName[@xml:lang='syr' and @syriaca-tags='#syriaca-headword']">
	  <mads:authority>
	    <mads:name type="personal" authority="SRP" xml:lang="syr">
		  <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:persName[@xml:lang='syr' and @syriaca-tags='#syriaca-headword']"/>
	    	<xsl:if test="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:birth">	      	
	    		<mads:namePart type="date"><xsl:value-of select="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:birth"/>.00.00-<xsl:value-of select="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:death"/>.00.00</mads:namePart>
	    	</xsl:if>	
		  </mads:name>
	    </mads:authority>
	  </xsl:if>
    </xsl:template>

  <xsl:template name="identifier">
    <mads:identifier>
	  <xsl:text>http://syriaca.org/person/</xsl:text>
      <xsl:value-of select="substring-after(tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/@xml:id, '-')"/>  
    </mads:identifier>    
  </xsl:template>
  
  <!-- 
  	NOTE: question, should these be seperate note fields, can then specify lang attributes for each as appropriate
  	also do we want to pull data from bibl file or leave as is?
  -->
  <xsl:template name="note">
    <mads:note type="source">
      <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:bibl">
	    <xsl:value-of select="tei:title"/>
		<xsl:if test="tei:citedRange">
		  <xsl:text> (</xsl:text>
		  <xsl:for-each select="tei:citedRange">
		    <xsl:value-of select="@unit"/>: <xsl:value-of select="."/>
		    <xsl:if test="not(position()=last())">
		      <xsl:text>, </xsl:text>
		      </xsl:if>
		    </xsl:for-each>
		  <xsl:text>)</xsl:text>
		  </xsl:if>
		<xsl:if test="tei:span">
		  <xsl:text> (</xsl:text>
		  <xsl:value-of select="tei:span"/>
		  <xsl:text>)</xsl:text>
		  </xsl:if>
		<xsl:if test="not(position()=last())">
		  <xsl:text>, </xsl:text>
		  </xsl:if>
	    </xsl:for-each>
	  </mads:note>
    </xsl:template>

  <xsl:template name="recordInfo">
    <mads:recordInfo>
	  <mads:recordOrigin>Converted from TEI to MADS using TEI2MADS.xsl</mads:recordOrigin>
	  <mads:recordContentSource><xsl:value-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor"/></mads:recordContentSource>
	  <mads:recordCreationDate encoding="iso8601"><xsl:value-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date"/></mads:recordCreationDate>
	  <xsl:for-each select="tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change">
	    <mads.recordChangeDate encoding="iso8601"><xsl:value-of select="@when"/></mads.recordChangeDate>
	    </xsl:for-each>
	  <mads:recordIdentifier source="SRP">
		<xsl:text>http://syriaca.org/person/</xsl:text>
		<xsl:value-of select="substring-after(tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/@xml:id, '-')"/>        
	  </mads:recordIdentifier>
	  <mads:languageOfCataloging>
        <mads:languageTerm authority="iso639-2b" type="code"><xsl:value-of select="tei:TEI/@xml:lang"/></mads:languageTerm>
	  </mads:languageOfCataloging>
	  <mads:descriptionStandard>aacr2</mads:descriptionStandard>
	  </mads:recordInfo>
    </xsl:template>

  <xsl:template name="urls">
	<xsl:for-each select="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:idno[@type='URI']">
	  <mads:url note="URI"><xsl:value-of select="."/></mads:url>	  
	</xsl:for-each>
  </xsl:template>

	<xsl:template name="variants">
	<xsl:for-each select="tei:TEI/tei:text/tei:body/tei:listPerson/tei:person/tei:persName[not(@xml:lang='syr' and @syriaca-tags='#syriaca-headword')]">
	  <mads:variant type="other">
	    <mads:name type="personal" xml:lang="{@xml:lang}">
	      <xsl:apply-templates select="."/>
	    </mads:name>
	  </mads:variant>
	  </xsl:for-each>
    </xsl:template>

  <xsl:template match="tei:persName">
    <xsl:for-each select="*">
	  <xsl:choose>
	    <xsl:when test="name()='forename'">
		  <mads:namePart type="given"><xsl:value-of select="."/></mads:namePart>
		  </xsl:when>
	    <xsl:when test="name()='family'">
	    	<mads:namePart type="family"><xsl:value-of select="."/></mads:namePart>
		  </xsl:when>
	    <xsl:otherwise>
		  <mads:namePart type="termsOfAddress"><xsl:value-of select="."/></mads:namePart>
		  </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	</xsl:template>
  </xsl:stylesheet>