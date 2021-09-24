<?php
/**
 * 获奖信息
 * User: luoning
 * Date: 14-12-5
 * Time: 下午8:54
 */
$domains = array(
    "http://tank-fl-app.raysns.com",
    "http://tank-fl-app-01.raysns.com",
    "http://tank-fl-app-02.raysns.com",
    "http://tank-fl-app-03.raysns.com",
    "http://tank-fl-app-04.raysns.com",
    "http://tank-fl-app-05.raysns.com",
    "http://tank-fl-app-06.raysns.com",
    "http://tank-fl-app-07.raysns.com",
    "http://tank-fl-app-08.raysns.com",
    "http://tank-fl-app-09.raysns.com",
);

$date = $_GET['date'];
if (!$date) {
    $date = date("Ymd");
}

foreach($domains as $value) {
    $value = $value."/active_zhenqinghuikui.php?date=".$date;
    echo "--------------------------------------------<br/>";
    echo $value . "<br />";
    $contents = file_get_contents($value);
    echo $contents;
}