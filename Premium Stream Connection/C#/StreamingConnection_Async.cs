/*  This example uses a asynchronous design by implementing a .Net AsyncCallback delegate. This example performs more
 *  explicit management of the incoming stream buffer. It explicitly looks for end of line markers which denote either
 *  the end of an incoming activity, or a "heartbeat" signal from the Gnip server. When that marker is found, it
 *  immediately writes out the buffered data.
 *
 *  Several customers reported high data latency with our other, more basic, C# example when working with low volumes.
 *
 *  One of these customers posted a discussion of the issue at StackOverflow:
 *  http://stackoverflow.com/questions/14760303/streamed-http-with-gzip-being-buffered-by-streamreader/14778103#14778103
 * 
 *  Thanks to Dan for sharing his code to better handle the streaming data buffer.
 *
 */

using System;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Text;
using System.Collections.Generic;
using System.Linq;

namespace StreamingConnection 

{
    class Program
    {
        public static void Main(string[] args)
        {

            Console.WriteLine("Starting...");

            string urlString ="ENTER_STREAM_URL_HERE";  // "https://stream.gnip.com:443/accounts/<account_name>/publishers/twitter/streams/track/prod.json";
  
            HttpWebRequest request = (System.Net.HttpWebRequest)WebRequest.Create(urlString);
            request.Method = "GET";

            //Setup Credentials.
            string username = "ENTER_USERNAME_HERE";
            string password = "ENTER_PASSWORD_HERE";

            //Authentication details.
            NetworkCredential nc = new NetworkCredential(username, password);
            request.Credentials = nc;
            request.PreAuthenticate = true;

            request.Headers.Add("Accept-Encoding", "gzip");
            request.Accept = "application/json";
            request.ContentType = "application/json";

            request.Timeout = 30; //seconds, PowerTrack sends 15-second heartbeat.
            AsyncCallback asyncCallback = new AsyncCallback(handleResult);    //Setting handleResult as Callback method...
            request.BeginGetResponse(asyncCallback, request);    //Calling BeginGetResponse on request...

            Console.WriteLine("Main thread sleeping...");
            while (true)
            {
                System.Threading.Thread.Sleep(1000);
            }
            
        }

        static void handleResult(IAsyncResult result)
        {


            //string outputFile = @"C:\dev\csharp\Stream_Data.txt";     //Uncomment and update if you want to write to a local file.
            HttpWebRequest request = (HttpWebRequest)result.AsyncState;

            using (HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(result))
            using (Stream stream = response.GetResponseStream())
            using (MemoryStream memory = new MemoryStream())
            using (GZipStream gzip = new GZipStream(memory, CompressionMode.Decompress))
            {
                byte[] compressedBuffer = new byte[8192];
                byte[] uncompressedBuffer = new byte[8192];
                List<byte> output = new List<byte>();

                if (!stream.CanRead)
                {
                    Console.WriteLine(" --- Cannot Read Stream");
                }

                while (stream.CanRead)
                {
                    Console.WriteLine(" +++ Reading Stream");

                    try
                    {
                        int readCount = stream.Read(compressedBuffer, 0, compressedBuffer.Length);

                        memory.Write(compressedBuffer.Take(readCount).ToArray(), 0, readCount);
                        memory.Position = 0;

                        int uncompressedLength = gzip.Read(uncompressedBuffer, 0, uncompressedBuffer.Length);

                        output.AddRange(uncompressedBuffer.Take(uncompressedLength));

                        if (!output.Contains(0x0A)) continue;  //Heartbeat

                        byte[] bytesToDecode = output.Take(output.LastIndexOf(0x0A) + 1).ToArray();
                        string outputString = Encoding.UTF8.GetString(bytesToDecode);
                        output.RemoveRange(0, bytesToDecode.Length);

                        string[] lines = outputString.Split(new[] { Environment.NewLine }, new StringSplitOptions());
                        for (int i = 0; i < (lines.Length - 1); i++)
                        {
                            string heartBeatCheck = lines[i];
                            if (heartBeatCheck.Trim().Length > 0)
                            {
                                Console.WriteLine(lines[i]);  //Just echo out line onto terminal...
                                //File.AppendAllText(outputFile, lines[i] + Environment.NewLine); //Write out to the file...
                            }
                            else
                            {
                                Console.WriteLine(" *** Heartbeat Received");
                            }
                        }
                    }
                    catch (Exception error)
                    {
                        Console.WriteLine(error.Message);
                    }
                    memory.SetLength(0);
                }

                if (!stream.CanRead)
                {
                    Console.WriteLine(" --- Cannot Read Stream");
                }
            }

        }

    }
}
