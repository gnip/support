Data Collector Stream Connection
=========================

C# Example
-----------
The Following C# example uses a asynchronous design by implementing a .Net AsyncCallback delegate.  This example performs more explicit management of the incoming stream buffer.  It explicitly looks for end of line markers which denote either the end of an incoming activity, or a "heartbeat" signal from the Gnip server.  When that marker is found, it immediately writes out the buffered data.

