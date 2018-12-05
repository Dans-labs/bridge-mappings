package nl.knaw.dans.dataverse.util;

import net.sf.saxon.s9api.*;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.json.*;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.invoke.MethodHandles;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * @Author: Eko Indarto
 *
 */
public class DataverseJsonToDaraXml {

    private static final Logger LOG = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
    private static final String INITIAL_TEMPLATE = "initialTemplate";
    private static final String PARAM_DVN_JSON = "dvnJson";
    private static final String PARAM_LANG_DICT = "langdict";
    
    public static Map<String, String> getMapfromJson(String path)
	{
    	try {
             ObjectMapper mapper = new ObjectMapper();
             Map<String, String> map = mapper.readValue(
 					new File(path), 
 					new TypeReference<Map<String, String>>() {
 			});
 			// convert JSON string to Map
             //System.out.println(map.get("Mursi"));
             return map;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
	}
    
    public static String convert(String xsltSourceUrl, String dvnJsonMetadataSourceUrl) throws SaxonApiException, IOException {
        LOG.debug("xsltSourceUrl: {} \tdvnJsonMetadataSourceUrl: {}", xsltSourceUrl, dvnJsonMetadataSourceUrl);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Processor processor = new Processor(false);
        Serializer serializer = processor.newSerializer(baos);
        XsltCompiler compiler = processor.newXsltCompiler();
        XsltExecutable executable = compiler.compile(new StreamSource(xsltSourceUrl));
        XsltTransformer transformer = executable.load();
        transformer.setInitialTemplate(new QName(INITIAL_TEMPLATE));
        transformer.setParameter(new QName(PARAM_LANG_DICT), XdmMap.makeMap(getMapfromJson("src/main/resources/xsl/dara/dict_lang_map_resource.json")));
        transformer.setParameter(new QName(PARAM_DVN_JSON), new XdmAtomicValue(IOUtils.toString(new URL(dvnJsonMetadataSourceUrl), StandardCharsets.UTF_8)));
        transformer.setDestination(serializer);
        transformer.transform();
        return baos.toString();
    }
    
    public static void main(String [] args) throws SaxonApiException, IOException
	{
    	final String xsltPath = "src/main/resources/xsl/dara/dataverseJson-to-DaraXml.xsl";
    	final String dvnJsonMetadataUrl ="https://raw.githubusercontent.com/Dans-labs/bridge-mappings/development/src/test/resources/json/hdl-12345-EWKZSR.json ";
    	String result = convert(xsltPath, dvnJsonMetadataUrl);
    	String[] splitedstring=dvnJsonMetadataUrl.split("/");
    	File file = new File("src/main/resources/data/"+splitedstring[splitedstring.length-1].replaceAll(".json", ".xml"));
		FileWriter fileWriter = new FileWriter(file);
		fileWriter.write(result);
		fileWriter.close();
    	System.out.print(result);
	}
    
}

