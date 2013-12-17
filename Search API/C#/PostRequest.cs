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
			op.SearchPostRequest();
		}

		public HttpWebRequest makeRequest()
		{

			string urlString = "ENTER_SEARCH_API_URL_HERE";
			string username = "ENTER_USERNAME_HERE";
			string password = "ENTER_PASSWORD_HERE";

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

		public void SearchPostRequest()
		{
			HttpWebRequest request = makeRequest();
			
			string postData = "";
			string query = "gnip";

			request.Method = "POST";

			postData = "{\"query\":\"" + query + "\",\"publisher\":\"twitter\"}";

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
