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
			op.retrieveRules();
		}

		public HttpWebRequest makeRequest()
		{
//			Expected Premium Stream URL Format:
//			https://api.gnip.com:443/accounts/<account>/publishers/<publisher>/streams/<stream>/<label>/rules.json

			string urlString = "ENTER_RULES_API_URL_HERE"; 	
			string username = "ENTER_USERNAME_HERE";
			string password = "ENTER_PASSWORD_HERE";

			HttpWebRequest request = (HttpWebRequest)WebRequest.Create(urlString);
		
			NetworkCredential nc = new NetworkCredential(username, password);
			request.Credentials = nc;
			request.PreAuthenticate = true;

			return request;			
		}


		public void retrieveRules()
		{
			HttpWebRequest request = makeRequest();
            		request.Method = "GET";
			HttpWebResponse response = (HttpWebResponse) request.GetResponse();
            
			Console.WriteLine (((HttpWebResponse)response).StatusDescription);
			StreamReader reader = new StreamReader(response.GetResponseStream());

            		string responseFromServer = reader.ReadToEnd ();
            		Console.WriteLine (responseFromServer);
			Console.WriteLine();
            		reader.Close ();
	        	response.Close ();
		}

	}
}
