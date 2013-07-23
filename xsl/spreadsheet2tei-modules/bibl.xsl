<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	schematypens="http://purl.oclc.org/dsdl/schematron"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:functx="http://www.functx.com">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 1, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Nathan Gibson</xd:p>
            <xd:p>This stylesheet creates all bibl elements for person records in TEI format.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates bibl elements, including the cited page numbers, entry numbers, and links.</xd:p>
            <xd:p>Include here the bibliographical information for any source that should be identified using the @source attribute. 
            Use a test to include that bibl element only if the row contains content from that source.</xd:p>
            <xd:p>Perhaps this code could be more concise.</xd:p>
        </xd:desc>
        <xd:param name="bib-ids">A sequence containing @xml:id values for bibl elements. Since node names are the same as those in 
        the sourced columns, you can extract the correct value by getting the node that contains the abbreviation of the source.</xd:param>
    </xd:doc>
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="bib-ids"></xd:param>
    </xd:doc>
    <xsl:template name="bibl" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="bib-ids"/>
        <!-- Languages should be declared for English titles as well as only non-English -->
        <!-- Citation for GEDSH -->
        <!-- If there is GEDSH data ... -->
        <xsl:if
            test="string-length(normalize-space(concat(GEDSH_en-Start_Pg,GEDSH_en-Entry_Num,GEDSH_en-Full)))">
            <!-- Add the @xml:id to a <bibl> element by getting it from the corresponding element in the $bib-ids sequence variable. -->
            <bibl xml:id="{$bib-ids/*[contains(name(), 'GEDSH')]}">
                <title level="m" xml:lang="en">The Gorgias Encyclopedic Dictionary of the Syriac Heritage</title>
                <ptr target="http://syriaca.org/bibl/1"/>
                <xsl:if test="string-length(normalize-space(GEDSH_en-Entry_Num))">
                    <citedRange unit="entry">
                        <xsl:value-of select="GEDSH_en-Entry_Num"/>
                    </citedRange>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(GEDSH_en-Start_Pg))">
                    <citedRange unit="pp">
                        <xsl:value-of select="GEDSH_en-Start_Pg"/>
                    </citedRange>
                </xsl:if>
            </bibl>
        </xsl:if>

        <!-- Citations for Barsoum-->
        <!-- Does the order matter here? -->
        <xsl:if test="string-length(normalize-space(Barsoum_en-Full))">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'Barsoum_en')]}">
                <title level="m" xml:lang="en">The Scattered Pearls: A History of Syriac Literature and Sciences</title>
                <ptr target="http://syriaca.org/bibl/4"/>
                <xsl:if test="string-length(normalize-space(Barsoum_en-Entry_Num))">
                    <citedRange unit="entry">
                        <xsl:value-of select="Barsoum_en-Entry_Num"/>
                    </citedRange>
                </xsl:if>
                <xsl:if test="string-length(normalize-space(Barsoum_en-Page_Num))">
                    <citedRange unit="pp">
                        <xsl:value-of select="Barsoum_en-Page_Num"/>
                    </citedRange>
                </xsl:if>
            </bibl>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(Barsoum_ar-Full))">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'Barsoum_ar')]}">
                <title level="m" xml:lang="ar">كتاب اللؤلؤ المنثور في تاريخ العلوم والأداب السريانية</title>
                <ptr target="http://syriaca.org/bibl/2"/>
                <!-- Does not include entry numbers as these are sometimes different in Arabic from the English. -->
                <xsl:if test="string-length(normalize-space(Barsoum_ar-Page_Num)) > 0">
                    <citedRange unit="pp">
                        <xsl:value-of select="Barsoum_ar-Page_Num"/>
                    </citedRange>
                </xsl:if>
            </bibl>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(Barsoum_syr-NV_Full))">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'Barsoum_syr-NV')]}">
                <!-- Is this the actual title? -->
                <title level="m" xml:lang="syr">ܒܪ̈ܘܠܐ ܒܕܝܪ̈ܐ ܕܥܠ ܡܪܕܘܬ ܝܘܠܦܢ̈ܐ ܣܘܪ̈ܝܝܐ ܗܕܝܪ̈ܐ</title>
                <ptr target="http://syriaca.org/bibl/3"/>
                <!-- Does not include entry numbers as these are sometimes different in Syriac from the English. -->
                <xsl:if test="string-length(normalize-space(Barsoum_syr-Page_Num))">
                    <citedRange unit="pp">
                        <xsl:value-of select="Barsoum_syr-Page_Num"/>
                    </citedRange>
                </xsl:if>
            </bibl>
        </xsl:if>

        <xsl:if test="string-length(normalize-space(Abdisho_YdQ_syr-NV_Full))">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'Abdisho_YdQ_syr-NV')]}">
                <title level="m" xml:lang="syr-Syrn">ܟܬ̣ܵܒ̣ܵܐ ܕܡܸܬ̣ܩܪܸܐ ܡܪܓܢܝܬ̣ܐ ܕܥܲܠ ܫܪܵܪܵܐ ܕܲܟ̣ܪܸܣܛܝܵܢܘܼܬ̣ܵܐ</title>
                <ptr target="http://syriaca.org/bibl/6"/>
                <xsl:if test="string-length(normalize-space(Abdisho_YdQ_syr-Page_Num)) > 0">
                    <citedRange unit="pp">
                        <xsl:value-of select="Abdisho_YdQ_syr-Page_Num"/>
                    </citedRange>
                </xsl:if>
            </bibl>
        </xsl:if>
        <xsl:if
            test="(string-length(normalize-space(Abdisho_BO_syr-NV_Full)) > 0) or (string-length(normalize-space(Abdisho_BO_syr-V_Full)) > 0)">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'Abdisho_BO_syr-NV')]}">
                <title level="m" xml:lang="la">Bibliotheca Orientalis Clementino-Vaticana</title>
                <ptr target="http://syriaca.org/bibl/7"/>
                <xsl:if test="string-length(normalize-space(Abdisho_BO_syr-Page_Num)) > 0">
                    <citedRange unit="pp">
                        III:<xsl:value-of select="Abdisho_BO_syr-Page_Num"/>  <!-- These pages are from volume 3 of this four-volume work -->
                    </citedRange>
                </xsl:if>
            </bibl>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(CBSC_en-Full)) > 0">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'CBSC')]}">
                <title level="a" xml:lang="en">
                    "<xsl:value-of select="replace(CBSC_en-Full,'; ','&quot;; &quot;')"/>"
                </title>
                <title level="m" xml:lang="en">A Comprehensive Bibliography on Syriac Christianity</title>
                <ptr target="http://syriaca.org/bibl/5"/>
                <!-- The precise link for the CBSC entry. -->
                <!-- The ampersands in the URL get changed into "&amp;", but perhaps this is OK since it will be changed back 
                when outputting as text/html? -->
                <ref>
                    <xsl:attribute name="target">
                        <xsl:value-of select="CBSC_en-Link"/>
                    </xsl:attribute>
                    <xsl:value-of select="CBSC_en-Link"/>
                </ref>
            </bibl>
        </xsl:if>
        <!-- Should we put the link to the extended VIAF record as a pointer? -->
        <xsl:if test="string-length(normalize-space(VIAF-Dates_Raw)) > 0">
            <bibl xml:id="{$bib-ids/*[contains(name(), 'VIAF')]}">
                <title xml:lang="en">Virtual International Authority File</title>
                <abbr>VIAF</abbr>
                <ptr target="http://viaf.org"/>
                <span xml:lang="en">Information cited from VIAF may come from any library or agency participating
                    with VIAF.</span>
            </bibl>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>