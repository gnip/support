using System;
using System.IO;
using System.Net;
using System.Text;


namespace StreamingConnection
{
  class MainClass
  {
    public static void Main (string[] args)
    {
      string urlString = "ENTER_STREAM_URL_HERE";
      
      HttpWebRequest request = (System.Net.HttpWebRequest)WebRequest.Create("YOUR_STREAM_URL_HERE");
      request.Method = "GET";
       
      //Setup Credentials
      string username = "ENTER_USERNAME_HERE";
      string password = "ENTER_PASSWORD_HERE";
     
      NetworkCredential nc = new NetworkCredential(username, password);
      request.Credentials = nc;
      
      request.PreAuthenticate = true;
      request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;
      request.Headers.Add("Accept-Encoding", "gzip");
      request.Accept = "application/json";
      request.ContentType = "application/json";
          
      Stream objStream;
      objStream = request.GetResponse().GetResponseStream();

      StreamReader objReader = new StreamReader(objStream);

      string sLine = "";
       
      while (!objReader.EndOfStream)
      {
        sLine = objReader.ReadLine();
        if (sLine!=null)
          Console.WriteLine(sLine);
      }
      Console.ReadLine();      
    }
  }
}
