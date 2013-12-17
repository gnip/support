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
			op.MonitorJob();
		}

		public HttpWebRequest makeRequest()
		{

            // Enter the jobURL for the historical job below.  This is a field returned when you create the job.
			string urlString = "ENTER_JOB_URL_HERE";

			string username = "ENTER_USERNAME";
			string password = "ENTER_PASSWORD";

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


		public void MonitorJob()
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
