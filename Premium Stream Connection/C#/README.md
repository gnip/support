PowerTrack & Firehose Stream Connection
=========================

C# Examples
-----------
There are two C# examples provided for establishing a streaming connection to PowerTrack and Firehose streams from Gnip.  Both use the System.Net HttpWebRequest class and its GetResponseStream mechanism.

 
+ StreamingConnection.cs - A single class and method that streams data to the console using simple StreamReader.ReadLine() handling.  While this example works well for high volume data streams, where the buffer fills and gets read out quickly, it does not perform well for low volume streams.  See the next example for more information on this issue.

+ StreamingConnection_async.cs - This example uses a asynchronous design by implementing a .Net AsyncCallback delegate.  This example performs more explicit management of the incoming stream buffer.  It explicitly looks for end of line markers which denote either the end of an incoming activity, or a "heartbeat" signal from the Gnip server.  When that marker is found, it immediately writes out the buffered data. 

