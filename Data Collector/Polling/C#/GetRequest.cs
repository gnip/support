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
//			Ensure that your stream format matches the rule format you intend to use (e.g. '.xml' or '.json')
			
//			Expected Enterprise Data Collector URL formats:
//				JSON:	https://<host>.gnip.com/data_collectors/<data_collector_id>/activities.json
//				XML:	https://<host>.gnip.com/data_collectors/<data_collector_id>/activities.xml

			string urlString = "ENTER_API_URL_HERE";
			string username = "ENTER_USERNAME_HERE";
			string password = "ENTER_PASSWORD_HERE";

			HttpWebRequest request = (HttpWebRequest)WebRequest.Create(urlString);
		
			NetworkCredential nc = new NetworkCredential(username, password);
			request.Credentials = nc;
			request.PreAuthenticate = true;

			return request;			
		}


		public void getActivities()
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
