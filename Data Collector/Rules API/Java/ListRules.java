import sun.misc.BASE64Encoder;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

public class ListRules {
    public static void main(String... args) throws IOException {

	String username = "ENTER_USERNAME_HERE";
    String password = "ENTER_PASSWORD_HERE";
    String charset = "UTF-8";

//	Ensure that your stream format matches the rule format you intend to use (e.g. '.xml' or '.json')
//	See below to edit the rule format used when retrieving rules (xml or json)
			
//	Expected Enterprise Data Collector URL formats:
//		JSON:	https://<host>.gnip.com/data_collectors/<data_collector_id>/rules.json
//		XML:	https://<host>.gnip.com/data_collectors/<data_collector_id>/rules.xml

	String dataCollectorURL = "ENTER_RULES_API_URL_HERE";

        HttpURLConnection connection = null;
        InputStream inputStream = null;

        try {
            connection = getConnection(dataCollectorURL, username, password);

            inputStream = connection.getInputStream();
            int responseCode = connection.getResponseCode();

            if (responseCode >= 200 && responseCode <= 299) {

                BufferedReader reader = new BufferedReader(new InputStreamReader((inputStream), charset));
                String line = reader.readLine();

                while(line != null){
                    System.out.println(line);
                    line = reader.readLine();
                }
            } else {
                handleNonSuccessResponse(connection);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (connection != null) {
                handleNonSuccessResponse(connection);
            }
        } finally {
            if (inputStream != null) {
                inputStream.close();
            }
        }
    }

    private static void handleNonSuccessResponse(HttpURLConnection connection) throws IOException {
        int responseCode = connection.getResponseCode();
        String responseMessage = connection.getResponseMessage();
        System.out.println("Non-success response: " + responseCode + " -- " + responseMessage);
    }

    private static HttpURLConnection getConnection(String urlString, String username, String password) throws IOException {
        URL url = new URL(urlString);

        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setReadTimeout(1000 * 60 * 60);
        connection.setConnectTimeout(1000 * 10);

        connection.setRequestProperty("Authorization", createAuthHeader(username, password));

   return connection;
    }

    private static String createAuthHeader(String username, String password) throws UnsupportedEncodingException {
        BASE64Encoder encoder = new BASE64Encoder();
        String authToken = username + ":" + password;
        return "Basic " + encoder.encode(authToken.getBytes());
    }
}
