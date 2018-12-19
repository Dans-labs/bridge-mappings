<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://da-ra.de/schema/kernel-4"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions">                
	<xsl:template name="resourceLanguage" match="." xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
			<resourceLanguage>
				<xsl:choose>
					<xsl:when test="count(/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='language']/following-sibling::array[@key='value']/string/.) > 0">
						<xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='language']/following-sibling::array[@key='value']/string/.">
 							<xsl:if test="position()=1">
 								<xsl:choose>
 									<xsl:when test="(.='Dutch') 
 									or (.='English') 
 									or (.='Latin')"
 									or (.='French')
 									or (.='Italian')
 									or (.='Swedish')
 									or (.='Slovenian')>
										<xsl:if test=".='Dutch'">dut</xsl:if>
										<xsl:if test=".='English'">eng</xsl:if>
										<xsl:if test=".='Latin'">lat</xsl:if>
										<xsl:if test=".='French'">fre</xsl:if>
										<xsl:if test=".='Italian'">ita</xsl:if>
										<xsl:if test=".='Swedish'">swe</xsl:if>
										<xsl:if test=".='Slovenian'">slv</xsl:if>
									</xsl:when>
                    			<xsl:otherwise>eng</xsl:otherwise>
                 			</xsl:choose>
                 		</xsl:if>
    				</xsl:for-each>
    			</xsl:when>
    			<xsl:otherwise>eng</xsl:otherwise>
    		</xsl:choose>
    	</resourceLanguage>
    </xsl:template>
</xsl:stylesheet>