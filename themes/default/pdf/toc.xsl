<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:outline="http://wkhtmltopdf.org/outline"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              indent="yes" />
  <xsl:template match="outline:outline">
    <html>
      <head>
        <title>Table of Contents</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <style>
          ol {
            padding: 0;
          }

          ol ol {
            padding-left: 1em;
          }

          ol ol ol {
            display: none;
          }

          li {
            list-style: none;
          }

          a {
            display: -webkit-box;
            display: flex;
            color: #333;
            text-decoration: none;
            margin: 8px 0;
          }

          a .dotted {
            -webkit-box-flex: 1;
            flex-grow: 1;
            border-bottom: 2px dotted #333;
            margin: 8px;
          }
        </style>
      </head>
      <body>
        <h1>Table of Contents</h1>
        <ol><xsl:apply-templates select="outline:item/outline:item"/></ol>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="outline:item">
    <li>
      <xsl:if test="@title!=''">
        <a>
          <xsl:if test="@link">
            <xsl:attribute name="href"><xsl:value-of select="@link"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="@backLink">
            <xsl:attribute name="name"><xsl:value-of select="@backLink"/></xsl:attribute>
          </xsl:if>
          <div class="title"><xsl:value-of select="@title" /></div>
          <div class="dotted"><xsl:comment>added to prevent self-closing tags in QtXmlPatterns</xsl:comment></div>
          <div class="page"><xsl:value-of select="@page" /></div>
        </a>
      </xsl:if>
      <ol>
        <xsl:comment>added to prevent self-closing tags in QtXmlPatterns</xsl:comment>
        <xsl:apply-templates select="outline:item"/>
      </ol>
    </li>
  </xsl:template>
</xsl:stylesheet>
