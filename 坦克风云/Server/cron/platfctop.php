<?php 
/*******       姝ゆ��浠舵����昏法骞冲�版�����������N涓���╁�讹�����缁���惧�ㄥ��绔�tankheroclient涓�                 ***************/
set_time_limit(1800);
define('BASEPATH', str_replace("\\", "/", dirname($_SERVER['SCRIPT_FILENAME'])));
$config=array();
$secret='0d734a1dc94fe5a914185f45197ea846'; // ���淇″�����
$platIP='192.168.8.204'; //璺ㄥ钩��扮��璺ㄦ��ip
$platProt='17004';    //璺ㄦ��绔����
if(file_exists("svrcfg/tankconfig.php"))
	{
		include_once 'svrcfg/tankconfig.php';
	}
	if(empty($config))
	{
		if(file_exists("svrcfg/oldtankconfig.php"))
		{
			include_once 'svrcfg/oldtankconfig.php';
			
		}
	}
	//include_once 'svrcfg/testtankconfig.php';
	$admin_get=$_REQUEST['admin_get'];
 if (!empty($config))
 {	

 	$senddata=array();
 	$list=array();
 	$sendflag=false;
 	$joinLimit=0;
 	foreach ($config as $k=>$v)
 	{	
 		

 		$cmd = array (
 				'cmd'=>'admin.getfctop',
 				'params' => array (
 						'check'=>1,
 				),
 		);
 		if ($v['istest']==1||$v['zoneid']>=900)
 		{
 			continue;
 		}
 		$zid=intval($v['zoneid']);
 		if (isset($v['oldzoneid'])&&$v['oldzoneid']>0)
 		{
 			$zid=intval($v['oldzoneid']);
 			continue;
 		}
 		$ret=send_gameserver($cmd,$zid,$v,$secret);
 		$data=json_decode($ret,1);
 		if(!empty($data))
 		{	
 			if (!isset($data['data']['flag']) or $data['data']['flag']!=true)
 			{
 					continue;
 			}
 			$senddata['st']=$data['st'];
 			$senddata['et']=$data['et'];
 			$senddata['bid']=$data['bid'];
 			$senddata['platlist']=$data['platlist'];
 			$senddata['plat']=$data['plat'];
 			$joinLimit=$data['joinLimit'];
 			$sendflag=true;
 			
			if (!empty($data['data']['list']))
			{	
				
				$zlist=$data['data']['list'];
				foreach ($zlist  as $key=>$val)
				{
					$val['z']=$zid;
					$zlist[$key]=$val;
						
				}
	 			if (empty($list))
	 			{	
	 				$list=$zlist;
	 			}else
	 			{	
	 				$id=array();
	 				$tmp=array();
	 				for ($i=0;$i<$data['limit'];$i++)
	 				{	
	 					if (isset($list[$i]))
	 					{
	 						$id[]=$list[$i]['f'];
	 						$tmp[]=$list[$i];
	 					}
	 					if (isset($zlist[$i]))
	 					{
	 						$id[]=$zlist[$i]['f'];
	 						$tmp[]=$zlist[$i];
	 					}
	 					
	 				}

	 				
	 				array_multisort($id, SORT_DESC, $tmp);
	 				$talcount=count($tmp);

	 				if (count($tmp)>$data['limit'])
	 				{	
	 					
	 					
	 					for ($di=$data['limit'];$di<$talcount;$di++)
	 					{
	 						unset($tmp[$di]);
	 					}
	 					
	 				}
	 				$list=$tmp;
	 			}
			}
 			
 		}
 		
 	}
 	if($sendflag &&$admin_get!=='getlist' )
 	{
 		//print_r($tmp);
 		$senddata['info']=$list;
 		$cmd=array(
 			"params"=>$senddata,
			"cmd"=>"platwarserver.setlist",
 		);

 		$ret=send_gameserver($cmd,1,array('ip_server'=>$platIP,"port_server"=>$platProt),$secret);
 		$retdate=json_decode($ret,1);
 		if ($retdate!=null && $retdate['ret']==0)
 		{
 			if ($joinLimit>0 )
 			{
 				for ($i=1;$i<=$joinLimit;$i++)
 				{
	 				if (isset($list[$i-1]))
	 				{
	 				$user=$list[$i-1];
	 				$ret=send_mail($user['z'],$user['u'],$config,$secret);
	 			
	 				}
 				}
 			}
 		}
 		echo $ret;
 		return  $ret;
 		
 		
 	}
	echo json_encode($list);
 	return  json_encode($list);

 }
 
function send_mail($zoneid,$uid,$config,$secret)
 {
 	 
 	$cmd['zoneid'] = $zoneid;
 	$cmd['cmd'] = 'admin.mail';
 	$cmd['params'] = array( 'uid'=>$uid,
 			'subject'=>urlencode(38),
 			'sender'=>urlencode(1),
 			'content'=>urlencode(json_encode(array('type'=>38))),
 	);
 	foreach ($config as $k=>$v)
 	{
 		if ($v['zoneid']==$zoneid&&$v['oldzoneid']==0)
 		{
 			$cfg=$v;
 			break;
 		}
 		if (isset($v['oldzoneid'])&&$v['oldzoneid']>0)
 		{
 			$cfg=$v;
 			break;
 		}
 	}

 	return send_gameserver($cmd,$zoneid,$cfg,$secret);
 }
 

 function send_gameserver($request,$zoneid,$config,$secret) {

	$fp = fsockopen( $config['ip_server'], $config['port_server'] );


	if (! $fp) {
		return false;
	}
	
	$request ['zoneid'] = $zoneid;
	$request ['secret'] = $secret;

	$request = json_encode($request,JSON_UNESCAPED_UNICODE);
	$nwrite = fputs( $fp, "1 $request\r\n" );
	$len = 1024;
	$result = fread( $fp, $len );
	$binary = substr( $result, 1, 3 );
	$header = unpack( "v", $binary );

	$result_len = strlen( $result );

	if (isset( $header [1] )) {
		do {
			$next_len = $header [1] - $result_len;
			if ($next_len > 0) {
				$next_len = $next_len > $len ? $len : $next_len;
				$result .= fread( $fp, $next_len );
				$result_len += $next_len;
			}
		} while ( $header [1] - $result_len > 0 );
	}

	if (strlen( $result ) > 5) {
		$result = substr( $result, 5 );
	}

	fclose( $fp );
	return $result;
}
