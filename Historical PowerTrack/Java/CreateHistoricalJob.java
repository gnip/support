import sun.misc.BASE64Encoder;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

class CreateHistoricalJob {
  public static void main(String[] args) throws IOException  {

        String username = "ENTER_USERNAME_HERE";
        String password = "ENTER_PASSWORD_HERE";
        String accountName = "ENTER_GNIP_CONSOLE_ACCOUNT_NAME_HERE";

        String gnipURL = "https://historical.gnip.com/accounts/" + accountName + "/jobs.json";
        String charset = "UTF-8";

	    String publisher = "twitter";
        String streamType = "track";
        String dataFormat = "activity-streams";
        String fromDate = "201301010000"; // This time is inclusive -- meaning the minute specified will be included in the data returned
        String toDate = "201301010001"; // This time is exclusive -- meaning the data returned will not contain the minute specified, but will contain the minute immediately preceding it
        String jobTitle = "my historical job 2";
        String serviceUsername = "your_twitter_handle"; // This is the Twitter username your company white listed with Gnip for access.
        String rules = "[{\"value\":\"rule 1\",\"tag\":\"ruleTag\"},{\"value\":\"rule 2\",\"tag\":\"ruleTag\"}]";

        String jobData = "{\"publisher\":\"" + publisher + "\",\"streamType\":\"" + streamType + "\",\"dataFormat\":\"" + dataFormat + "\",\"fromDate\":\"" + fromDate + "\",\"toDate\":\"" + toDate + "\",\"title\":\"" + jobTitle + "\",\"serviceUsername\":\"" + serviceUsername + "\",\"rules\": " + rules + "}";

        HttpURLConnection connection = null;
        InputStream inputStream = null;

        try {
            connection = getConnection(gnipURL, username, password);
            connection.setDoOutput(true);
            connection.setRequestProperty("Accept-Charset", charset);
            connection.setRequestProperty("Content-Type", "text/json");
            OutputStream output = null;
            try {
                 output = connection.getOutputStream();
                 output.write(jobData.getBytes(charset));
            } finally {
                 if (output != null) try { output.close(); } catch (IOException logOrIgnore) {}
            }

            int responseCode = connection.getResponseCode();
            String responseMessage = connection.getResponseMessage();
            if (responseCode >= 200 && responseCode <= 299) {
                
                  inputStream  = connection.getInputStream();

                  InputStreamReader reader = new InputStreamReader(inputStream);
                  BufferedReader bReader = new BufferedReader(reader);
		  String line = bReader.readLine();
                  System.out.println("Response Code: " + responseCode + " -- " + responseMessage);
                  while(line != null){
                    System.out.println(line);
                    line = bReader.readLine();
                  }
            } else {
                 handleNonSuccessResponse(connection);
                 inputStream = connection.getErrorStream();
		 InputStreamReader reader2 = new InputStreamReader(inputStream);
                 BufferedReader bReader2 = new BufferedReader(reader2);
                 String line2 = bReader2.readLine();
                 while (line2 != null){
                      System.out.println(line2);
                      line2 = bReader2.readLine();
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
          connection.setRequestMethod("POST");
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

