import sun.misc.BASE64Encoder;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

class PostRequest {
	public static void main(String[] args) throws IOException  {

		String charset = "UTF-8"; //All things Gnip use UTF-8

		String username = "ENTER_USERNAME_HERE";
		String password = "ENTER_PASSWORD_HERE";

		//Expected Rehydration URL Format:
		//https://rehydration.gnip.com:443/accounts/<account>/publishers/twitter/rehydration/<label>.json
		//Update URL with your account name and stream label.
		//You can refer to the 'API Help' tab of your http://console.gnip.com Rehydration dashboard for your complete URL.
		String gnipURL = "https://rehydration.gnip.com:443/accounts/<account>/publishers/twitter/rehydration/<label>.json";

		String tweetIds = "\"443569001461846016\",\"443570733990440961\""; 
		String query = String.format("{\"ids\":[%s]}", tweetIds);
		
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
		     output.write(query.getBytes(charset));
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
		
	} catch (Exception e) {
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

