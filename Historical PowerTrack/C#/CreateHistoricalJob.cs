using System;
using System.Net;
using System.IO;
using System.Text;

namespace BasicOps
{
	class MainClass
	{
		public static void Main (string[] args)
		{
			MainClass op = new MainClass();
			op.CreateHistoricalJob();
		}

		public HttpWebRequest makeRequest()
		{

			string accountName = "ENTER_ACCOUNT";

			string urlString = "https://historical.gnip.com/accounts/" + accountName + "/jobs.json";
			string username = "ENTER_USERNAME";
			string password = "ENTER_PASSWORD";

			HttpWebRequest request = (HttpWebRequest)WebRequest.Create(urlString);
            request.ServicePoint.Expect100Continue = false;

		    	string authInfo = string.Format("{0}:{1}", username, password);
                        authInfo = Convert.ToBase64String(Encoding.Default.GetBytes(authInfo));
                        request.Headers.Add("Authorization", "Basic " + authInfo);
                
                        //In some Windows environments, this alternative Basic Authentication method is available.
                        //NetworkCredential nc = new NetworkCredential(username, password);
                        //request.Credentials = nc;
                        //request.PreAuthenticate = true;

			request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;

			return request;			
		}

		public void CreateHistoricalJob()
		{
			HttpWebRequest request = makeRequest();
			
			string postData = "";
            string publisher = "twitter";
            string streamType = "track";
            string dataFormat = "activity-streams";
            string fromDate = "201301010000"; // This time is inclusive -- meaning the minute specified will be included in the data returned
            string toDate = "201301010001"; // This time is exclusive -- meaning the data returned will not contain the minute specified, but will contain the minute immediately preceding it
            string jobTitle = "my historical job";
            string serviceUsername = "your_twitter_handle"; // This is the Twitter username your company white listed with Gnip for access.
			string rules = "[{\"value\":\"rule 1\",\"tag\":\"ruleTag\"},{\"value\":\"rule 2\",\"tag\":\"ruleTag\"}]";

			request.Method = "POST";
			postData = "{\"publisher\":\"" + publisher + "\",\"streamType\":\"" + streamType + "\",\"dataFormat\":\"" + dataFormat + "\",\"fromDate\":\"" + fromDate + "\",\"toDate\":\"" + toDate + "\",\"title\":\"" + jobTitle + "\",\"serviceUsername\":\"" + serviceUsername + "\",\"rules\":" + rules + "}";

			byte[] byteArray = Encoding.UTF8.GetBytes (postData);
            		request.ContentType = "application/x-www-form-urlencoded";
	    		request.ContentLength = byteArray.Length;
            		Stream dataStream = request.GetRequestStream ();			
            		dataStream.Write (byteArray, 0, byteArray.Length);
            		dataStream.Close ();

            		WebResponse response = request.GetResponse ();
            		Console.WriteLine (((HttpWebResponse)response).StatusDescription);
            		dataStream = response.GetResponseStream ();
            		StreamReader reader = new StreamReader (dataStream);
            		string responseFromServer = reader.ReadToEnd ();
            		Console.WriteLine (responseFromServer);
				Console.WriteLine();
            		reader.Close ();
            		dataStream.Close ();
            		response.Close ();
		}		
	}
}
