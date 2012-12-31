NetworkCheckUtility
===================

About:
------
NetworkCheckUtility is a simple app which checks if machine is connected to Internet or not, on click of 'go' button.

The basic mechanism is to check for response from remote host, such as http://www.apple.com

This mechanism is implemented using below listed approaches:

1. NSTask + curl command
2. CFNetDiagnostics 
3. Reachability 
4. NSURLConnection

I came up with the idea of making this app when I was googling to look around for the best solution to implement it.

Here I have consolidated all suggestions through which I came across. 

Note:
-----
This code provides only a basic idea of using different methods, each method can be implemented more effectively and efficiently.

Please feel free to add new methods to the existing code base.


Have fun :-)
