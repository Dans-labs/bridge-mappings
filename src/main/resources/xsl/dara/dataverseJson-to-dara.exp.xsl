<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://da-ra.de/schema/kernel-4">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="dvnJson"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template name="initialTemplate">
    <xsl:apply-templates select="json-to-xml($dvnJson)"/>
  </xsl:template>

  <xsl:template match="/" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">

    <resource>
      <resourceType>Collection</resourceType>
      <xsl:call-template name="resourceIdentifier"/>
      <xsl:call-template name="titles"/>
      <xsl:call-template name="creators"/>
      <xsl:call-template name="dataURLs"/>
      <xsl:call-template name="doiProposal"/>
      <xsl:call-template name="publicationDate"/>
      <availability><availabilityType>Delivery</availabilityType></availability>
      <xsl:call-template name="resourceLanguage"/>
      <xsl:call-template name="rights"/>
      <xsl:call-template name="freeKeywords"/>
      <xsl:call-template name="descriptions"/>
<!--       <xsl:call-template name="dataSets"/> -->
      <xsl:call-template name="publications"/>
    </resource>
  </xsl:template>


  <xsl:template name="resourceIdentifier"  match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <xsl:variable name="versionStateR" select="map[1]/map[1]/map[1]/string[@key='versionState']"/>
    <xsl:choose>
      <xsl:when  test="$versionStateR = 'RELEASED'">
        <resourceIdentifier>
          <identifier>
            <xsl:value-of select="map[1]/map[1]/string[@key='identifier']"/>
          </identifier>
          <xsl:variable name="versionNumber" select="map[1]/map[1]/map[1]/number[@key='versionNumber']"/>
          <xsl:variable name="versionMinorNumber" select="map[1]/map[1]/map[1]/number[@key='versionMinorNumber']"/>
          <currentVersion>
            <xsl:value-of select="concat($versionNumber, '.', $versionMinorNumber)"/>
          </currentVersion>
        </resourceIdentifier>
      </xsl:when>
      <xsl:otherwise>
        <resourceIdentifier>
          <identifier>
            <xsl:value-of select="map[1]/map[1]/number[@key='id']"/>
          </identifier>
          <currentVersion>1</currentVersion>
        </resourceIdentifier>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="titles" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <titles>
      <title>
        <language>en</language>
        <titleName>
          <xsl:value-of select="//array[@key='fields']/map[1]/string[@key='value']/."/>
        </titleName>
      </title>
    </titles>
  </xsl:template>
  <xsl:template name="creators" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <creators>
      <creator>
        <person>
          <xsl:variable name="name" select="tokenize(//array[1]/map[2]/array[1]/map[1]/map[1]/string[3], ',')"/>
          <firstName>
            <xsl:value-of select="$name[2]"/>
          </firstName>
          <lastName>
            <xsl:value-of select="$name[1]"/>
          </lastName>
        </person>
      </creator>
      <creator>
        <institution>
          <institutionName>
            <xsl:value-of select="//array[1]/map[2]/array[1]/map[1]/map[2]/string[3]"/>
          </institutionName>
        </institution>
      </creator>
    </creators>
  </xsl:template>

  <xsl:template name="dataURLs" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <xsl:variable name="persistentUrl" select="//map[@key='data']/string[@key='persistentUrl']/."/>
    <dataURLs>
      <xsl:choose>
        <xsl:when  test="$persistentUrl">
          <dataURL>
            <xsl:value-of select="//map[@key='data']/string[@key='persistentUrl']"/>
          </dataURL>
        </xsl:when>
        <xsl:otherwise>
          <dataURL>https://dataverse.nl/</dataURL>
        </xsl:otherwise>
      </xsl:choose>
    </dataURLs>
  </xsl:template>

  <xsl:template name="doiProposal" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <xsl:variable name="AuthoriyValue" select="map[1]/map[1]/string[@key='authority']"/>
    <xsl:variable name="identifier" select="map[1]/map[1]/string[@key='identifier']"/>
    <doiProposal></doiProposal>
  </xsl:template>

  <xsl:template name="publicationDate" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <!--<xsl:variable name="versionStateR" select="/map/map[@key='data']/string[@key='versionState']/."/>-->
    <!--<xsl:if test="$versionStateR = 'RELEASED'">-->
      <publicationDate>
        <date>
          <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')"/>
        </date>
      </publicationDate>
    <!--</xsl:if>-->
    <!--<xsl:if test="$versionStateR = 'DRAFT'">-->
      <!--<publicationDate>-->
        <!--<date>-->
          <!--<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')"/>-->
        <!--</date>-->
      <!--</publicationDate>-->
    <!--</xsl:if>-->
  </xsl:template>
  <xsl:template name="rights" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <xsl:variable name="versionStateR" select="map[1]/map[1]/map[1]/string[@key='versionState']"/>
    <xsl:if  test="$versionStateR = 'RELEASED'">
      <rights>
        <licenseType>
          <xsl:value-of select="map[1]/map[1]/map[1]/string[@key='license']"/>
        </licenseType>
        <right>
          <language>en</language>
          <freetext>
            <xsl:value-of select="map[1]/map[1]/map[1]/string[@key='termsOfAccess']"/>
          </freetext>
        </right>
      </rights>
    </xsl:if>
  </xsl:template>

  <xsl:template name="resourceLanguage" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <resourceLanguage>eng</resourceLanguage>
  </xsl:template>


  <xsl:template name="freeKeywords" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <freeKeywords>
      <freeKeyword>
        <language>en</language>
        <keywords>
          <!--<xsl:for-each select="//array[1]/map[6]/array[1]/map[*]/map[@key='keywordValue']">-->
            <keyword>keywords
              <!--<xsl:value-of select="string[3]"/>-->
            </keyword>
          <!--</xsl:for-each>-->
        </keywords>
      </freeKeyword>
    </freeKeywords>
  </xsl:template>

  <xsl:template name="descriptions" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <descriptions>
      <description>
        <language>en</language>
        <freetext>
          <xsl:value-of select="//array[1]/map[4]/array[1]/map[1]/map[1]/string[3]"/>
        </freetext>
        <descriptionType>Abstract</descriptionType>
      </description>
    </descriptions>
  </xsl:template>
<!--   <xsl:template name="dataSets" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <dataSets>
      <xsl:for-each select="//array[@key='files']/map[*]">
        <dataSet>
          <files>
            <file>
              <name>
                <xsl:value-of select="map[@key='dataFile']/string[@key='filename']"/>
              </name>
              <format>
                <xsl:value-of select="map[@key='dataFile']/string[@key='contentType']"/>
              </format>
              <size>
                <xsl:value-of select="map[@key='dataFile']/number[@key='filesize']"/>
              </size>
            </file>
          </files>
        </dataSet>
      </xsl:for-each>
    </dataSets>
  </xsl:template> -->

  <xsl:template name="publications" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <publications>
      <!--<xsl:for-each select="//array[1]/map[7]/array[1]/map[*]">-->
        <publication>
          <unstructuredPublication>
            <freetext>text
              <!--<xsl:value-of select="map[@key='publicationCitation']/string[@key='value']"/>-->
            </freetext>

            <xsl:variable name="pubIDNumber1" select="map[@key='publicationIDNumber']/string[@key='value']/."/>
            <xsl:if  test="$pubIDNumber1">
              <xsl:variable name="pubIDNumber" select="tokenize(map[@key='publicationIDNumber']/string[@key='value'], ':')"/>
              <PIDs>
                <PID>
                  <ID>
                    <xsl:value-of select="$pubIDNumber[2]"/>
                  </ID>
                  <pidType>
                    <xsl:value-of select="map[@key='publicationIDType']/string[@key='value']"/>
                  </pidType>
                </PID>
              </PIDs>
            </xsl:if>

          </unstructuredPublication>
        </publication>
      <!--</xsl:for-each>-->
    </publications>
  </xsl:template>

</xsl:stylesheet>
