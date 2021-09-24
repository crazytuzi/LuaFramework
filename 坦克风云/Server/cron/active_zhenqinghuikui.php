<?php
//真情回馈活动
$riqi = $_GET['date'];
$activeName = "zhenqinghuikui";
if (!$riqi) {
    $riqi = date("Ymd");
}
$hostdir = "/opt/tankserver/service/tank-gameserver/log/";
$filesnames = scandir($hostdir);
$afile = array();
foreach($filesnames as $value) {
    if(strpos($value, $activeName) !== false && strpos($value, $riqi) !== false) {
        $afile[] = $value;
    }
}
if(empty($afile)) {
    echo "无中奖信息<br/>";
    exit;
}

$findUidZoneId = function($filename) {
    $result = array();
    $content = file_get_contents($filename);
    if (strlen($content) == 0) {
        return $result;
    }
    $contentArr = explode("\n", $content);
    foreach($contentArr as $key => $value) {
        if(preg_match('/\{([\s\S]*)\}/U', $value, $match)) {
            $result[] = json_decode($match[0], true);
        }
    }
    return $result;
};

foreach($afile as $value) {
    $info = $findUidZoneId($hostdir.$value);
    foreach($info as $ainfo) {
        echo "用户姓名： ".$ainfo["name"]. " 用户id： ".$ainfo["uid"]." 用户所在服: ". $ainfo["zoneid"] . "<br/>";
    }
}

