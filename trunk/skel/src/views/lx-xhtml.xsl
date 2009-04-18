<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="/views/lx-doc.xsl"?>

<xsl:stylesheet version="1.0"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.promethe.net"
		exclude-result-prefixes="lx"
		id="LX XHTML Library">

  <xsl:output method="html"
	      omit-xml-declaration="yes"
	      doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
	      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
	      indent="yes"
	      encoding="unicode"/>

  <xsl:include href="/views/lx.xsl"/>

  <xsl:variable name="LX_RESPONSE" select="/lx:response"/>
  <xsl:variable name="LX_MEDIA" select="/lx:response/@media"/>

  <xsl:variable name="LX_LAYOUT_NAME" select="/lx:response/@layout"/>
  <xsl:variable name="LX_LAYOUT_FILE" select="concat('/views/', $LX_MEDIA, '/layouts/', $LX_LAYOUT_NAME, '.xml')"/>
  <xsl:variable name="LX_LAYOUT" select="document($LX_LAYOUT_FILE)/lx:layout"/>

  <xsl:variable name="LX_CONTROLLER" select="/lx:response/lx:controller"/>

  <xsl:variable name="LX_VIEW_NAME" select="/lx:response/@view"/>
  <xsl:variable name="LX_VIEW_FILE" select="concat('/views/', $LX_MEDIA, '/templates/', $LX_VIEW_NAME, '.xml')"/>
  <xsl:variable name="LX_VIEW" select="document($LX_VIEW_FILE)/lx:view"/>

  <xsl:variable name="LX_FILTERS" select="$LX_RESPONSE/lx:filter"/>

  <xsl:template match="/">
    <html>
      <head>
	<xsl:apply-templates select="$LX_LAYOUT/head/*"/>
	<xsl:apply-templates select="$LX_VIEW/head/*"/>
      </head>
      <body>
	<xsl:copy-of select="$LX_LAYOUT/body/@* | $LX_VIEW/body/@*"/>

	<xsl:apply-templates select="$LX_LAYOUT/body/node()"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:choose>
      <xsl:when test="ancestor::lx:response">
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	</xsl:copy>
	<xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates select="@* | node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:controller">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="lx:error">
    <div class="error">
      <em>ERROR: </em>
      <xsl:value-of select="message"/>
      <pre>
	<xsl:value-of select="trace"/>
      </pre>
    </div>
  </xsl:template>

  <!--
      @template lx:javascript-class
      Include a javascript class.
    -->
  <xsl:template name="lx:javascript-class"
		match="lx:javascript-class">
    <!-- @param name of the javascript class -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="/javascript/class/{$name}.js"></script>
  </xsl:template>

  <!--
      @template lx:javascript-library
      Include a javascript library.
    -->
  <xsl:template name="lx:javascript-library"
		match="lx:javascript-library">
    <!-- @param name of the javascript library -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="/javascript/libs/{$name}.js"></script>
  </xsl:template>

  <!--
      @template lx:javascript
      Embed javascript code.
    -->
  <xsl:template name="lx:javascript"
		match="lx:javascript">
    <!-- @param javascript code to embed -->
    <xsl:param name="script" select="."/>

    <script language="javascript" type="text/javascript">
      <xsl:value-of select="$script"/>
    </script>
  </xsl:template>

  <!--
      @template lx:css-stylesheet
      Include a CSS stylesheet.
    -->
  <xsl:template name="lx:css-stylesheet"
		match="lx:css-stylesheet">
    <!-- @param name of the CSS stylesheet -->
    <xsl:param name="name" select="@name"/>

    <link rel="stylesheet" type="text/css" href="/styles/default/{$name}.css"/>
  </xsl:template>

  <!--
      @template lx:css
      Include a CSS style declaration
    -->
  <xsl:template name="lx:css"
		match="lx:css">
    <!-- @param style declaration -->
    <xsl:param name="style" select="text()"/>

    <style type="text/css">
      <xsl:copy-of select="$style"/>
    </style>
  </xsl:template>

  <!--
      @template lx:link-controller
      Create a link to a controller.
    -->
  <xsl:template match="lx:link[@controller]"
		name="lx:link-controller">
    <!-- @param controller name -->
    <xsl:param name="controller" select="@controller"/>
    <!-- @param action to call -->
    <xsl:param name="action" select="@action"/>
    <!-- @param action arguments -->
    <xsl:param name="arguments" select="lx:argument"/>
    <!-- @param content of the link (string | node)-->
    <xsl:param name="content" select="node()[name() != 'lx:argument']"/>

    <xsl:variable name="url">
      <xsl:value-of select="concat('/', $controller, '/', $action)"/>
      <xsl:call-template name="lx:foreach">
	<xsl:with-param name="begin" select="'?'"/>
	<xsl:with-param name="delimiter" select="','"/>
	<xsl:with-param name="collection" select="$arguments"/>
      </xsl:call-template>
    </xsl:variable>

    <a href="{$url}">
      <xsl:choose>
	<xsl:when test="node()[name() != 'lx:argument']">
	  <xsl:apply-templates select="node()[name() != 'lx:argument']"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="lx:argument">
    <xsl:value-of select="@name"/>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="@value"/>
  </xsl:template>

  <!--
      @template lx:link
      Create a link.
    -->
  <xsl:template match="lx:link[@href]"
		name="lx:link">
    <!-- @param URL of the link -->
    <xsl:param name="href" select="@href"/>
    <!-- @param content of the link -->
    <xsl:param name="content" select="node()"/>
    <!-- @param target of the link ('_blank' | '_parent') -->
    <xsl:param name="target">
      <xsl:choose>
	<xsl:when test="@target">
	  <xsl:value-of select="@target"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>_self</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <a href="{$href}" target="{$target}">
      <xsl:choose>
	<xsl:when test="$content = node()">
	  <xsl:apply-templates select="node()"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <!--
      @template lx:insert-view-here
      Set where to insert the view template.
      If an lx:exception node is available, it is matchd instead of the view.
    -->
  <xsl:template match="lx:insert-view-here">
    <xsl:choose>
      <xsl:when test="$LX_RESPONSE/lx:error">
	<xsl:apply-templates select="$LX_RESPONSE/lx:exception"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$LX_VIEW/body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:view/body">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <!--
      @template lx:insert-controller-here
      Set where to insert the view generated output.
    -->
  <xsl:template match="lx:insert-controller-here">
    <xsl:apply-templates select="$LX_CONTROLLER"/>
  </xsl:template>

  <!--
      @template lx:flash
      Insert Flash content.
      The content of the tag is used as javascript code and is automagicaly called when the Flash application is ready.
    -->
  <xsl:template match="lx:flash"
		name="lx:flash">
    <!-- @param ressource name (without '/flash/') of the SWF file -->
    <xsl:param name="name" select="@name"/>
    <!-- @param javascript code to execute when the application is ready -->
    <xsl:param name="script" select="text()"/>
    <!-- @param width of the application -->
    <xsl:param name="width" select="@width"/>
    <!-- @param height of the application -->
    <xsl:param name="height" select="@height"/>
    <!-- @param ommit the default .swf extension -->
    <xsl:param name="ommit-extension" select="@ommit-extension"/>

    <xsl:variable name="id" select="concat('flash_', translate($name, '/?', '_'))"/>
    <xsl:variable name="url">
      <xsl:if test="not(starts-with($name, '/'))">
	<xsl:text>/flash/</xsl:text>
      </xsl:if>
      <xsl:value-of select="$name"/>
    </xsl:variable>

    <span id="{$id}">
    <xsl:call-template name="lx:javascript">
      <xsl:with-param name="script">
	var flashApplication = new FlashApplication('<xsl:value-of select="$name"/>');

	<xsl:if test="$ommit-extension = 'true'">
	  flashApplication.ommitExtension = true;
	</xsl:if>

	flashApplication.width = '<xsl:value-of select="$width"/>';
	flashApplication.height = '<xsl:value-of select="$height"/>';
	<xsl:if test="$script">
	  flashApplication.useFABridge = true;

	  flashApplication.addEventListener(Event.COMPLETE, function(e)
	  {
	  <xsl:value-of select="$script"/>
	  });
	</xsl:if>

	window.onload = function()
	{
  	  flashApplication.run(document.getElementById('<xsl:value-of select="$id"/>'));
	}
      </xsl:with-param>
    </xsl:call-template>
    </span>
  </xsl:template>

</xsl:stylesheet>