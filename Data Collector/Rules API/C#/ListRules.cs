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
//			See below to edit the rule format used when adding and deleting rules (xml or json)
			
//			Expected Enterprise Data Collector URL formats:
//				JSON:	https://<host>.gnip.com/data_collectors/<data_collector_id>/rules.json
//				XML:	https://<host>.gnip.com/data_collectors/<data_collector_id>/rules.xml

			string urlString = "ENTER_RULES_API_URL_HERE";
			string username = "ENTER_USERNAME_HERE";
			string password = "ENTER_PASSWORD_HERE";

			HttpWebRequest request = (HttpWebRequest)WebRequest.Create(urlString);
		
			string authInfo = string.Format("{0}:{1}", username, password);
                        authInfo = Convert.ToBase64String(Encoding.Default.GetBytes(authInfo));
                        request.Headers.Add("Authorization", "Basic " + authInfo);
                
                        //In some Windows environments, this alternative Basic Authentication method is available.
                        //NetworkCredential nc = new NetworkCredential(username, password);
                        //request.Credentials = nc;
                        //request.PreAuthenticate = true;

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
