# Multi-Language Reverse Shell Examples (C, Python, Ruby, JSP)

This project demonstrates reverse shell implementations across multiple programming languages:

- C
- PHP
- Powershell
- Python
- Ruby
- JSP (Java Server Pages)

The goal is to understand how reverse shells work at a low level across different environments and to study how attackers may establish outbound connections from a compromised system.

---

## Disclaimer

This project is strictly for:

- Educational purposes  
- Cybersecurity research  
- Authorized penetration testing in controlled lab environments  

Do **not** use these examples against systems without explicit permission.

---

## Purpose

Reverse shells are commonly used in offensive security to:

- Establish remote command execution on a target system
- Maintain access after exploitation
- Understand outbound network communication from a compromised host

This project helps demonstrate:

- Cross-language implementation of the same concept
- Differences between system-level and application-level shells
- How different runtimes handle sockets and process execution

---

## Concept Overview

A reverse shell works by:

1. The target machine initiating an outbound connection to an attacker-controlled listener
2. The attacker listening on a specific port
3. Redirecting input/output streams of a shell through the network connection

---


##  Usage (Lab Environment Only)

Each implementation requires:

- A listener running on the attacker machine
- Network connectivity between the target and listener

Example listener (for testing in a lab):

```bash
nc -lvnp <port>
```

---

## Language Overview
1- C and Powershell Implementations
- Uses low-level system calls
- Demonstrates process execution and socket handling
- Closest to OS-level interaction

2- Python Implementation
- Uses standard libraries such as socket and subprocess
- Simple and widely used in scripting environments

3- Ruby Implementation
- Uses built-in socket and process libraries
- Demonstrates scripting capabilities similar to Python

4- PHP Implementation
- Uses built-in socket and process libraries
- Demonstrates scripting capabilities similar to Python

5- JSP Implementation
- Runs within a Java web application
- Demonstrates how server-side code can be abused in web environments

