<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method='html'/>
    <xsl:template match="corpus">
<html>
<head>
<title>
Data about Paris
</title>
</head>
<body>
    <table border="1px">
    <xsl:apply-templates select="post/content"/>

    </table>
</body>
    </html>
    </xsl:template>


<xsl:template match="content">

        <tr><td>
        
        
        <xsl:apply-templates/>
        
        </td>
        </tr>

</xsl:template>



<xsl:template match="mark">
<span style="background:#FFFF00"><xsl:value-of select="." /></span>
</xsl:template>

</xsl:stylesheet>