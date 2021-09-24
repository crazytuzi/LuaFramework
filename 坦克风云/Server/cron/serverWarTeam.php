<?php 
/**
 * /opt/tankserver/embedded/bin/php serverWarTeam.php --host=127.0.0.1 --port=17002 --zid=1 --group=a
 *
 */

function send_gameserver($host, $port, $request)
{
    try{
        $fp = fsockopen( $host, $port );
    }catch (ErrorException $e){
        $fp = NULL;
        throw $e;
    }
    
    if (! $fp){
        return 'host:'.$host.'|port:'.$port.'php_network_getaddresses: getaddrinfo failed';
    }
    
    $nwrite = fputs( $fp, "1 $request\r\n" );
    $len = 1024;
    $result = fread( $fp, $len );
    $binary = substr($result,1,3);
    $header = unpack("v",$binary);
    
    $result_len = strlen($result);
    
    if (isset($header[1])){
        do{                
            $next_len = $header[1] - $result_len;                
            if ($next_len > 0){
                $next_len = $next_len > $len ? $len : $next_len;
                $result .= fread( $fp, $next_len);
                $result_len += $next_len;
            }                
        }
        while ( $header[1] - $result_len > 0 );
    }
    
    if (strlen( $result ) > 5)
    {
        $result = substr( $result, 5 );
    }
    
    fclose( $fp );
    
    return $result;
} 

function options($argv)
{
    $options = array();

    $arguments = array();

    for ($i = 0, $count = count($argv); $i < $count; $i++)
    {
        $argument = $argv[$i];
        if (strpos($argument, '--') === 0)
        {
            list($key, $value) = array(substr($argument, 2), true);

            if (($equals = strpos($argument, '=')) !== false)
            {
                $key = substr($argument, 2, $equals - 2);

                $value = substr($argument, $equals + 1);
            }

            $options[$key] = $value;
        }
        else
        {
            $arguments[] = $argument;
        }
    }

    // return array($arguments, $options);
    return $options;
}

$argv = options($_SERVER['argv']);

// if (isset($argv['debug'])){
    error_reporting(E_ALL);
// }

if (!isset($argv['host']) || !isset($argv['port']) || !isset($argv['group']) || !isset($argv['zid'])){
    $params = print_r($argv,true);
    exit($params);
}

if (!$argv['group']){
    exit('params error : no group');
}

$cmd = array(
    "cmd"=>"acrossserver.battle",
    "params"=>array(
        "group"=>$argv['group'],
        "areaServerId"=>(int)$argv['areaServerId'],
    ),
    "ts"=>time(),
    "zoneid"=>(int)$argv['zid'],
);

$cmd = json_encode($cmd);

$ret = send_gameserver($argv['host'], $argv['port'], $cmd);

print_r($ret);
echo "\r\n";
