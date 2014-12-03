/*  This example uses a asynchronous design by implementing a .Net AsyncCallback delegate. This example performs more
 *  explicit management of the incoming stream buffer. It explicitly looks for end of line markers which denote either
 *  the end of an incoming activity, or a "heartbeat" signal from the Gnip server. When that marker is found, it
 *  immediately writes out the buffered data.
 */

using System;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Text;
using System.Collections.Generic;
using System.Linq;

namespace StreamConnection
{
    class Program
    {
        public static void Main(string[] args)
        {
            AddToConsole("Starting...");

            string urlString = "YOUR_STREAM_URL_HERE";

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(urlString);
            request.Method = "GET";

            //Setup Credentials.
            string username = "YOUR_USERNAME_HERE";
            string password = "YOUR_PASSWORD_HERE";

            // Authentication
            string authInfo = string.Format("{0}:{1}", username, password);
            authInfo = Convert.ToBase64String(Encoding.Default.GetBytes(authInfo));
            request.Headers.Add("Authorization", "Basic " + authInfo);

            request.Headers.Add("Accept-Encoding", "gzip");
            request.Accept = "application/json";
            request.ContentType = "application/json";
            request.UserAgent = "Your Agent/Product Name";  // This setting is optional

            request.Timeout = 35; //GNIP sends 15 second heartbeats

            AsyncCallback asyncCallback = new AsyncCallback(handleResult);  //Setting handleResult as Callback method...

            try
            {
                request.BeginGetResponse(asyncCallback, request);   //Calling BeginGetResponse on request...
            }
            catch (WebException ex)
            {
                AddToConsole("CONNECTION EXCEPTION - " + ex.Message + Environment.NewLine);
                request.Abort();
                // Do whatever you need to do here e.g. re-connect, re-start etc.
                return;
            }
            catch (Exception ex)
            {
                AddToConsole("EXCEPTION - " + ex.Message + Environment.NewLine);
                // Do whatever you need to do, do here e.g. re-connect, re-start etc.
                return;
            }

            AddToConsole("Main thread sleeping...");

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
            {
                byte[] compressedBuffer = new byte[8192];
                byte[] uncompressedBuffer = new byte[8192];
                List<byte> output = new List<byte>();

                while (stream.CanRead)
                {
                    AddToConsole(" +++ Reading Stream");

                    try
                    {
                        int readCount = stream.Read(compressedBuffer, 0, compressedBuffer.Length);

                        memory.Write(compressedBuffer.Take(readCount).ToArray(), 0, readCount);
                        memory.Position = 0;

                        int uncompressedLength = memory.Read(uncompressedBuffer, 0, uncompressedBuffer.Length);

                        output.AddRange(uncompressedBuffer.Take(uncompressedLength));

                        byte[] bytesToDecode = output.Take(output.LastIndexOf(0x0A) + 1).ToArray();
                        string outputString = Encoding.UTF8.GetString(bytesToDecode);
                        output.RemoveRange(0, bytesToDecode.Length);

                        string[] lines = outputString.Split(new[] { Environment.NewLine }, new StringSplitOptions());

                        for (int i = 0; i < (lines.Length - 1); i++)
                        {
                            string heartBeatCheck = lines[i];
                            if (heartBeatCheck.Trim().Length > 0)
                            {
                                AddToConsole(lines[i]);  //Just print out to console window...
                                //File.AppendAllText(outputFile, lines[i] + Environment.NewLine); //Write out to the file...
                            }
                            else
                            {
                                AddToConsole(" ♥♥♥ Heartbeat Received");
                            }
                        }
                    }
                    catch (Exception error)
                    {
                        AddToConsole(error.Message);
                        // Handle the error as needed here
                    }

                    memory.SetLength(0);    // Everything needs to reach this line otherwise you will end up with 
                                            // merged activities and loads of errors. i.e. do not use "return", "continue" etc. 
                                            // above this line without setting the memory length to ZERO first.
                }

                if (!stream.CanRead)
                {
                    AddToConsole(" --- Cannot Read Stream");
                    // Handle the situation as needed here. The stream is probably corrupted.
                }
            }
        }

        static string TStamp()
        {
            DateTime dt = DateTime.Now;

            return dt.ToShortDateString() + " " + dt.ToLongTimeString() + ": ";
        }

        private void AddToConsole(string text)
        {
            Console.WriteLine(TStamp() + text + Environment.NewLine);
        }
    }
}
