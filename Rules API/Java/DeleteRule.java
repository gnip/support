import sun.misc.BASE64Encoder;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

class DeleteRule {
  public static void main(String[] args) throws IOException  {

        String username = "ENTER_USERNAME_HERE";
        String password = "ENTER_PASSWORD_HERE";

//	Expected Premium Stream URL Format:
//	https://api.gnip.com:443/accounts/<account>/publishers/<publisher>/streams/<stream>/<label>/rules.json
	
	String dataCollectorURL = "ENTER_RULES_API_URL_HERE";  
 
        String charset = "UTF-8";
        String param1 = "testrule"; //our rule to add
        String query = String.format("{\"rules\":[{\"value\":\"%s\"}]}",
             java.net.URLEncoder.encode(param1, charset));

        HttpURLConnection connection = null;
        InputStream inputStream = null;
        try {
            connection = getConnection(dataCollectorURL, username, password);

            connection.setDoOutput(true);
            connection.setRequestProperty("Accept-Charset", charset);
            connection.setRequestProperty("Content-Type", "text/json");
            
            OutputStream output = null;
            try {
                 output = connection.getOutputStream();
                 output.write(query.getBytes(charset));
            } finally {
                 if (output != null) try { output.close(); } catch (IOException logOrIgnore) {}
            }

            int responseCode = connection.getResponseCode();
            String responseMessage = connection.getResponseMessage();
            if (responseCode >= 200 && responseCode <= 299) {
                
                inputStream = connection.getInputStream();

                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                String line = reader.readLine();
                System.out.println("Response Code: " + responseCode + " -- " + responseMessage);
		while(line != null){
                    System.out.println(line);
                    line = reader.readLine();
                }
            } else {
                 handleNonSuccessResponse(connection);
                 inputStream = connection.getErrorStream();
                 BufferedReader reader3 = new BufferedReader(new InputStreamReader(inputStream));
                 String line2 = reader3.readLine();
                 while (line2 != null){
                 	System.out.println(line2);
                        line2 = reader3.readLine();
                 }
            }
        }
    catch (Exception e) {
            e.printStackTrace();
            if (connection != null) {
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
          System.out.println("Response Code: " + responseCode + " -- " + responseMessage);
      }

      private static HttpURLConnection getConnection(String urlString, String username, String password) throws IOException {
          URL url = new URL(urlString);

          HttpURLConnection connection = (HttpURLConnection) url.openConnection();
          connection.setRequestMethod("DELETE");
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

