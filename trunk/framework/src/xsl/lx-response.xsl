<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX Response
    Constants definitions.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <!-- @const response root node (lx:response) -->
  <xsl:variable name="LX_RESPONSE" select="/lx:response"/>

  <!-- @const response view node (lx:view) -->
  <xsl:variable name="LX_VIEW" select="$LX_RESPONSE/lx:view"/>
  <!-- @const view name -->
  <xsl:variable name="LX_VIEW_NAME" select="$LX_VIEW/@name"/>

  <!-- @const layout name -->
  <xsl:variable name="LX_LAYOUT_NAME" select="$LX_VIEW/@layout"/>
  <!-- @const layout filename URI -->
  <xsl:variable name="LX_LAYOUT_FILE" select="concat($LX_VIEW_NAME, '/layouts/', $LX_LAYOUT_NAME, '.xml')"/>
  <!-- @const layout document root node -->
  <xsl:variable name="LX_LAYOUT" select="document($LX_LAYOUT_FILE)/lx:layout"/>

  <!-- @const template name -->
  <xsl:variable name="LX_TEMPLATE_NAME" select="$LX_VIEW/@template"/>
  <!-- @const template filename URI -->
  <xsl:variable name="LX_TEMPLATE_FILE" select="concat($LX_VIEW_NAME, '/templates/', $LX_TEMPLATE_NAME, '.xml')"/>
  <!-- @const template document root node -->
  <xsl:variable name="LX_TEMPLATE" select="document($LX_TEMPLATE_FILE)/lx:template"/>

  <!-- @const filter nodes (lx:filter) -->
  <xsl:variable name="LX_FILTERS" select="$LX_RESPONSE/lx:filters"/>

  <!-- @const controller node (lx:controller) -->
  <xsl:variable name="LX_CONTROLLER" select="$LX_RESPONSE/lx:controller"/>

  <!--
      @template lx:insert-template
      Set where to insert the view template.
      If an lx:exception node is available, it is matchd instead of the template.
    -->
  <xsl:template match="lx:insert-template">
    <xsl:choose>
      <xsl:when test="$LX_RESPONSE/lx:error">
	<xsl:apply-templates select="$LX_RESPONSE/lx:error"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$LX_TEMPLATE"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      @template lx:insert-controller
      Set where to insert the view generated output.
    -->
  <xsl:template match="lx:insert-controller">
    <xsl:apply-templates select="$LX_CONTROLLER"/>
  </xsl:template>

  <xsl:template match="lx:controller|lx:template">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

</xsl:stylesheet>