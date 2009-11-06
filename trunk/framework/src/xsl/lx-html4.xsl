<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX HTML4
    HTML4 templates.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.html="http://lx.aerys.in/html">

  <xsl:output method="html"
	      version="4.0"
	      omit-xml-declaration="yes"
	      doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	      doctype-system="http://www.w3.org/TR/html4/loose.dtd"
	      indent="yes"
	      encoding="unicode"/>

  <xsl:include href="lx-std.xsl"/>
  <xsl:include href="lx-response.xsl"/>

  <xsl:template match="/">
    <html>
      <head>

	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>

	<base>
	  <xsl:attribute name="href">
	    <xsl:text>http://</xsl:text>
	    <xsl:value-of select="$LX_RESPONSE/@host"/>
	    <xsl:if test="$LX_RESPONSE/@document-root != '/'">
	      <xsl:value-of select="$LX_RESPONSE/@document-root"/>
	    </xsl:if>
	    <xsl:text>/</xsl:text>
	  </xsl:attribute>
	</base>

	<title>
	  <xsl:apply-templates select="$LX_LAYOUT/head/title/node()"/>
	  <xsl:apply-templates select="$LX_TEMPLATE/head/title/node()"/>
	</title>

	<xsl:apply-templates select="$LX_LAYOUT/head/*[name()!='title']"/>
	<xsl:apply-templates select="$LX_TEMPLATE/head/*[name()!='title']"/>

      </head>
      <body>
	<xsl:copy-of select="$LX_LAYOUT/body/@* | $LX_TEMPLATE/body/@*"/>

	<xsl:apply-templates select="$LX_LAYOUT/body/node()"/>
      </body>
    </html>
  </xsl:template>

  <!-- BEGIN IDENTITY -->
  <xsl:template match="*">
    <xsl:if test="not(ancestor::lx:response) and local-name()=name()">
      <xsl:element name="{name()}">
	<xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:if test="normalize-space(.) != '' or not(following-sibling::lx:text or preceding-sibling::lx:text)">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <!-- END IDENTITY -->

  <!--
      @template lx:template
      Default template template.
    -->
  <xsl:template match="lx:template">
    <xsl:apply-templates select="body/node()"/>
  </xsl:template>

  <!--
      @template lx:error
    -->
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
      @template lx.html:javascript-class
      Include a javascript class.
    -->
  <xsl:template name="lx.html:javascript-class"
		match="lx.html:javascript-class">
    <!-- @param name of the javascript class -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="javascript/class/{$name}.js"></script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:javascript-library
      Include a javascript library.
    -->
  <xsl:template name="lx.html:javascript-library"
		match="lx.html:javascript-library">
    <!-- @param name of the javascript library -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="javascript/libs/{$name}.js"></script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:javascript
      Embed javascript code.
    -->
  <xsl:template name="lx.html:javascript"
		match="lx.html:javascript">
    <!-- @param javascript code to embed -->
    <xsl:param name="script" select="."/>

    <script language="javascript" type="text/javascript">
      <xsl:value-of select="$script"/>
    </script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:skin
    -->
  <xsl:template match="lx.html:skin"
		name="lx.html:skin">
    <xsl:apply-templates select="lx.html:stylesheet">
      <xsl:with-param name="skin">
	<xsl:apply-templates select="@name" mode="lx:value-of"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <!--
      @template lx.html:stylesheet
      Include a CSS stylesheet.
    -->
  <xsl:template name="lx.html:stylesheet"
		match="lx.html:stylesheet">
    <!-- @param name of the CSS stylesheet -->
    <xsl:param name="name" select="@name"/>
    <!-- @param name of the skin -->
    <xsl:param name="skin">
      <xsl:apply-templates select="@skin" mode="lx:value-of"/>
    </xsl:param>

    <link rel="stylesheet" type="text/css" href="styles/{$skin}/{$name}.css"/>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:css
      Include a CSS style declaration
    -->
  <xsl:template name="lx.html:style"
		match="lx.html:style">
    <!-- @param style declaration -->
    <xsl:param name="style" select="text()"/>

    <style type="text/css">
      <xsl:copy-of select="$style"/>
    </style>
  </xsl:template>

  <!--
      @template lx.html:link-controller
      Create a link to a controller.
    -->
  <xsl:template match="lx.html:link[@controller] | lx.html:link[@module] | lx.html:link[@action]"
		name="lx.html:link-controller">
    <!-- @param module name -->
    <xsl:param name="module">
      <xsl:apply-templates select="@module" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param controller name -->
    <xsl:param name="controller">
      <xsl:apply-templates select="@controller" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param action to call -->
    <xsl:param name="action">
      <xsl:apply-templates select="@action" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param action arguments -->
    <xsl:param name="arguments" select="lx:argument"/>
    <!-- @param content of the link (string | node)-->
    <xsl:param name="content" select="node()[name() != 'lx:argument']"/>

    <xsl:variable name="url">
      <xsl:if test="$module != ''">
	<xsl:value-of select="$module"/>
	<xsl:if test="$controller != ''">
	  <xsl:text>/</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:if test="$controller != ''">
	<xsl:value-of select="$LX_RESPONSE/lx:request/@controller"/>
	<xsl:if test="$action != ''">
	  <xsl:text>/</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:if test="$action != ''">
	<xsl:value-of select="$action"/>
      </xsl:if>
      <xsl:call-template name="lx:for-each">
	<xsl:with-param name="begin" select="'/'"/>
	<xsl:with-param name="delimiter" select="'/'"/>
	<xsl:with-param name="collection" select="$arguments"/>
      </xsl:call-template>
      <xsl:if test="$LX_RESPONSE/lx:request/@handler!='xsl'">
	<xsl:value-of select="concat('.', $LX_RESPONSE/lx:request/@handler)"/>
      </xsl:if>
    </xsl:variable>


    <xsl:variable name="content_value">
      <xsl:choose>
	<xsl:when test="$content = node()">
	  <xsl:apply-templates select="$content"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a href="{$url}">
      <xsl:value-of select="normalize-space($content_value)"/>
    </a>
  </xsl:template>

  <xsl:template match="lx:argument">
    <xsl:value-of select="@name"/>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="@value"/>
  </xsl:template>

  <!--
      @template lx.html:link
      Create a link.
    -->
  <xsl:template match="lx.html:link[@href]"
		name="lx.html:link">
    <!-- @param URL of the link -->
    <xsl:param name="href" select="@href"/>
    <!-- @param content of the link -->
    <xsl:param name="content" select="node()"/>
    <!-- @param target of the link ('_blank' | '_parent') -->
    <xsl:param name="target" select="@target"/>

    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:value-of select="$href"/>
	<xsl:if test="$LX_RESPONSE/lx:request/@handler!='xsl' and $target!='_blank'">
	  <xsl:value-of select="concat('.', $LX_RESPONSE/lx:request/@handler)"/>
	</xsl:if>
      </xsl:attribute>

      <xsl:if test="$target!='' and $target!='_self'">
	<xsl:attribute name="target">
	  <xsl:value-of select="$target"/>
	</xsl:attribute>
      </xsl:if>

      <xsl:choose>
	<xsl:when test="$content = node()">
	  <xsl:apply-templates select="node()"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!--
      @template lx.html:flash
      Insert Flash content.
      The content of the tag is used as javascript code and is automagicaly called when the Flash application is ready.
    -->
  <xsl:template match="lx.html:flash"
                name="lx.html:flash">
    <!-- @param ressource name (without 'flash/' and '.swf') of the SWF file -->
    <xsl:param name="name">
      <xsl:apply-templates select="@name" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param javascript code to execute when the application is ready -->
    <xsl:param name="script" select="normalize-space(text())"/>
    <!-- @param width of the application -->
    <xsl:param name="width" select="@width"/>
    <!-- @param height of the application -->
    <xsl:param name="height" select="@height"/>
    <!-- @param flashvars -->
    <xsl:param name="flashvars" select="lx.html:flashvar"/>
    <!-- @param [opaque] wmode -->
    <xsl:param name="wmode">
      <xsl:value-of select="@wmode"/>
      <xsl:if test="@wmode = ''">
	<xsl:text>opaque</xsl:text>
      </xsl:if>
    </xsl:param>
    <!-- @param id -->
    <xsl:param name="id">
      <xsl:choose>
	<xsl:when test="@id">
	  <xsl:value-of select="@id"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="concat('flash_', generate-id())"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:variable name="swf">
      <xsl:text>http://</xsl:text>
      <xsl:value-of select="$LX_RESPONSE/@host"/>
      <xsl:value-of select="$LX_RESPONSE/@document-root"/>
      <xsl:text>flash/</xsl:text>
      <xsl:value-of select="$name"/>
    </xsl:variable>

    <xsl:variable name="flashvars_full">
      <xsl:if test="$script">
	<xsl:text>bridgeName=</xsl:text>
	<xsl:value-of select="$id"/>
	<xsl:if test="$flashvars">
	  <xsl:text>&amp;</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:apply-templates select="$flashvars"/>
    </xsl:variable>

    <span id="{$id}">
      <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
	      id="{$name}" width="{$width}" height="{$height}"
	      codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
	<param name="movie" value="{$swf}.swf" />
	<param name="quality" value="high" />
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullscreen" value="true" />
	<param name="flashvars" value="{$flashvars_full}" />
	<param name="wmode" value="{$wmode}" />
	<param name="name" value="{$id}"/>
	<embed src="{$swf}.swf"
	       width="{$width}" height="{$height}" name="{$id}" align="middle"
	       play="true"
	       loop="false"
	       flashvars="{$flashvars_full}"
	       quality="high"
	       allowScriptAccess="sameDomain"
	       type="application/x-shockwave-flash"
	       pluginspage="http://www.adobe.com/go/getflashplayer"
	       allowFullscreen="true"
               wmode="{$wmode}">
	</embed>
      </object>

    <xsl:call-template name="lx.html:javascript">
      <xsl:with-param name="script">
        <xsl:text>var app=new FlashApplication(</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $swf, $LX_DQUOTE)"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $id, $LX_DQUOTE)"/>
        <xsl:text>);</xsl:text>

        <xsl:if test="$script">
          <xsl:text>app.useFABridge=true;</xsl:text>
          <xsl:text>app.addEventListener(Event.COMPLETE,function(e){</xsl:text>
          <xsl:apply-templates select="$script"/>
          <xsl:text>});</xsl:text>
        </xsl:if>

        <xsl:text>app.run(document.getElementById(</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $id, $LX_DQUOTE)"/>
        <xsl:text>));</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    </span>
  </xsl:template>

  <!--
      @template lx.html:favicon
      Set the page favicon.
    -->
  <xsl:template match="lx.html:favicon"
		name="lx.html:favicon">
    <xsl:param name="href" select="@href"/>

    <link rel="icon" href="{$href}"/>
  </xsl:template>

  <xsl:template match="lx.html:flashvar">
    <xsl:if test="preceding-sibling::lx.html:flashvar">
      <xsl:value-of select="$LX_AMP"/>
    </xsl:if>
    <xsl:value-of select="concat(@name, '=', @value)"/>
  </xsl:template>

</xsl:stylesheet>
