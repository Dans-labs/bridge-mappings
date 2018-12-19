<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://da-ra.de/schema/kernel-4"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="dvnJson"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template name="initialTemplate">
        <xsl:apply-templates select="json-to-xml($dvnJson)"/>
    </xsl:template>

    <xsl:template match="/" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">         
        <resource>
            <resourceType>Dataset</resourceType>
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
            <xsl:call-template name="dataSets"/>
            <xsl:call-template name="publications"/>
        </resource>
    </xsl:template>
 
    
    <xsl:template name="resourceIdentifier"  match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:variable name="versionStateR" select="map/map/map/string[@key='versionState']"/>
        <xsl:choose>
            <xsl:when  test="$versionStateR = 'RELEASED'">
                <resourceIdentifier>
                    <identifier>
                        <xsl:value-of select="map/map/string[@key='identifier']"/>
                    </identifier>
                    <xsl:variable name="versionNumber" select="map/map/map/number[@key='versionNumber']"/>
                    <xsl:variable name="versionMinorNumber" select="map/map/map/number[@key='versionMinorNumber']"/>
                    <currentVersion>
                        <xsl:value-of select="concat($versionNumber, '.', $versionMinorNumber)"/>
                    </currentVersion>
                </resourceIdentifier>
            </xsl:when>
            <xsl:otherwise>
                <resourceIdentifier>
                    <identifier>
                        <xsl:value-of select="map/map/number[@key='id']"/>
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
                    <xsl:value-of select="//array[@key='fields']/map/string[@key='typeName' and text()='title']/following-sibling::string[@key='value']/."/>
                </titleName>
            </title>
        </titles>
    </xsl:template>
    
    <xsl:template name="creators" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <creators>
         <xsl:for-each select="//map[@key='authorName']">
            <xsl:variable name="intial" select="substring-after(./string[@key='typeName' and text()='authorName']/following-sibling::string[@key='value']/., ', ')"/>
            <xsl:variable name="surname" select="substring-before(./string[@key='typeName' and text()='authorName']/following-sibling::string[@key='value']/., ', ')"/>
            <creator>
                <person>
                    <firstName>
                        <xsl:value-of select="$intial"/>
                    </firstName>
                    <lastName>
                        <xsl:value-of select="$surname"/>
                    </lastName>
                </person>
            </creator>
            <creator>
                <institution>
                    <institutionName>
                        <xsl:value-of select="//string[@key='typeName' and text()='authorAffiliation']/following-sibling::string[@key='value']/."/>
                    </institutionName>
                </institution>
            </creator>
        </xsl:for-each>
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
        <xsl:if test="$AuthoriyValue and  $identifier">
        	<doiProposal>
            	<xsl:value-of select="concat($AuthoriyValue, '/', $identifier)"/>
        	</doiProposal>
        </xsl:if>
    </xsl:template>

    <xsl:template name="publicationDate" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:variable name="pdate" select="/map[1]/map[1]/string[@key='publicationDate']/."/>
                <publicationDate>
                	<date>
                	<xsl:choose>
                		<xsl:when  test="$pdate">
                			<xsl:value-of select="map[1]/map[1]/string[@key='publicationDate']"/>	
                        </xsl:when>
                        <xsl:otherwise>
                        	<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')"/>
                    	</xsl:otherwise>
                   </xsl:choose> 
                    </date>                  		
                </publicationDate>
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
   
	
 	<xsl:include href="xsl/dara/inline_lang.xsl"/>
        						
   
    <xsl:template name="freeKeywords" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <freeKeywords>
            <freeKeyword>
            <language>en</language>
            <keywords>
                <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='keyword']/following-sibling::array[@key='value']/map/.">
                    <keyword>
                        <xsl:value-of select="./map[@key='keywordValue']/string[@key='value']/."/>
                    </keyword>
                </xsl:for-each>
            </keywords>
            </freeKeyword>
        </freeKeywords>
    </xsl:template>

    <xsl:template name="descriptions" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <descriptions>
            <description>
                <language>en</language>
                <freetext>
                    <xsl:value-of select="//map[@key='dsDescriptionValue']/string[@key='typeName' and text()='dsDescriptionValue']/following-sibling::string[@key='value']/."/>
                </freetext>
                <descriptionType>Abstract</descriptionType>
            </description>
        </descriptions>
    </xsl:template>
    <xsl:template name="dataSets" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
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
    </xsl:template>
        
    <xsl:template name="publications" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <publications>
                <publication>
                    <unstructuredPublication>
                        <freetext>
                            <xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/array/map/map[@key='publicationCitation']/string[@key='value']/."/>
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
        </publications>
    </xsl:template>
    
</xsl:stylesheet>
