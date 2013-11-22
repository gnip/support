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
			op.SearchGetRequest();
		}

		public HttpWebRequest makeRequest()
		{

			string urlString = "ENTER_URL";
			string username = "ENTER_USERNAME";
			string password = "ENTER_PASSWORD";
            string query = "gnip";

            string queryString = urlString + "?query=" + query + "&publisher=twitter";

			HttpWebRequest request = (HttpWebRequest)WebRequest.Create(queryString);
		
			NetworkCredential nc = new NetworkCredential(username, password);
			request.Credentials = nc;
			request.PreAuthenticate = true;

			return request;			
		}


		public void SearchGetRequest()
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
