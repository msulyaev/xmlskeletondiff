<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
Test if two xml files are structurally equivalent.

Differences in textual nodes, comments, processing instructions are ignored. 
Differences in element names or namespaces, attribute names, namespaces, and values, 
are considered.

Usage: 
  xsltproc --stringparam debug.strings true \
           --stringparam file1 art1.xml \
           --stringparam file2 art2.xml \
           xmlskeletondiff.xsl xmlskeletondiff.xsl 
           
Returns:
Nothing if no significant difference found; the word 'DIFF' otherwise (the difference, 
if found, is not displayed, but just signalled).
           
Method: 
A string representation of each XML file passed as a parameter is created in a variable. 
The string represenation looks a bit like JSON. Node types mentioned above as ignored 
are not written in the string.
The two string are then compared for equality.

Complexity: 
O(n) both in time and memory. 
Better speed and O(1) memory footprint may only be achieved with concurrent processing
of SAX streams emitted by parsers. No provisioning for such approach in XSLT.

-->

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:output method="text"/>
  
  <xsl:param name="file1"/>
  <xsl:param name="file2"/>
  
  <xsl:param name="emit.ns" select="true()"/>
  <xsl:param name="emit.text" select="false()"/>
  <xsl:param name="consider.comments" select="false()"/>
  
  <xsl:param name="debug.strings" select="false()"/>
  
  <xsl:variable name="doc1" select="document($file1)"/>
  <xsl:variable name="doc2" select="document($file2)"/>

  <xsl:template match="/">
    <xsl:variable name="s1">
      <xsl:apply-templates select="$doc1" mode="tostring"/>
    </xsl:variable>
    <xsl:variable name="s2">
      <xsl:apply-templates select="$doc2" mode="tostring"/>
    </xsl:variable>
    <xsl:if test="($debug.strings=true() or $debug.strings='true') and $debug.strings!='false'">
      <xsl:value-of select="$s1"/>
      <xsl:value-of select="$s2"/>
    </xsl:if>
    <xsl:if test="not($s1 = $s2)">DIFF
</xsl:if>
  </xsl:template>
  
  <xsl:template match="@*" mode="tostring"
    >@{<xsl:if test="$emit.ns"
      >ns:'<xsl:value-of select="namespace-uri()"/>',</xsl:if
    > n:'<xsl:value-of select="name()"
    />', v:='<xsl:value-of select="."
    />'}</xsl:template>
  
  <xsl:template match="*" mode="tostring">
    <xsl:text>
</xsl:text><xsl:for-each select="ancestor::*"><xsl:text> </xsl:text></xsl:for-each
    >{<xsl:if
      test="$emit.ns and namespace-uri(.)!=namespace-uri(..)">ns:'<xsl:value-of select="namespace-uri()"/>', </xsl:if
    >n:'<xsl:value-of select="name()"
      />', <xsl:if test="@*"
        >@*:[<xsl:apply-templates select="@*" mode="tostring"/>], </xsl:if
    ><xsl:if test="
      count(comment()[$consider.comments]
      |processing-instruction()
      |text()[$emit.text]
      |*) &gt; 0">*:[<xsl:apply-templates 
        select="
        comment()[$consider.comments]
        |processing-instruction()
        |text()[$emit.text]
        |*" mode="tostring"
    />]</xsl:if>}</xsl:template>

  <xsl:template match="comment()" mode="tostring"
    ><xsl:if test="$consider.comments">/* <xsl:value-of select="."/> */</xsl:if
    ></xsl:template>
  
  <!-- TODO: add the same for PIs -->
  <xsl:template match="processing-instruction()" mode="tostring"/>
  
  <xsl:template match="text()[string-length(normalize-space(.)) = 0]" mode="tostring"/>

  <xsl:template match="text()[string-length(normalize-space(.)) &gt; 0]" mode="tostring">
    <xsl:text>
</xsl:text><xsl:for-each select="ancestor::*"><xsl:text> </xsl:text></xsl:for-each
    >text[value=[<xsl:value-of select="normalize-space(.)"
    />]]</xsl:template>
  
</xsl:stylesheet>