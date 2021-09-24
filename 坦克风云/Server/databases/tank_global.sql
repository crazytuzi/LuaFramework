-- MySQL dump 10.13  Distrib 5.1.69, for redhat-linux-gnu (x86_64)
--
-- Host: 192.168.8.204    Database: tank_global
-- ------------------------------------------------------
-- Server version	5.5.20-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `giftbag` (
  `cdkey` varchar(50) NOT NULL,
  `uid` int(10) unsigned DEFAULT '0',
  `type` tinyint(3) unsigned NOT NULL,
  `bag` int(10) unsigned NOT NULL,
  `st` int(10) unsigned NOT NULL DEFAULT '0',
  `et` int(10) unsigned NOT NULL DEFAULT '0',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `zoneid` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`cdkey`),
  KEY `uid` (`uid`),
  KEY `st` (`st`),
  KEY `et` (`et`),
  KEY `zoneid` (`zoneid`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

CREATE TABLE `services` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `number_server` varchar(100) DEFAULT NULL COMMENT '本服编号',
  `sname` varchar(100) DEFAULT NULL COMMENT '本服名称',
  `ip_server` varchar(100) NOT NULL COMMENT '本服IP',
  `ip_pay` varchar(100) NOT NULL COMMENT '支付IP',
  `port_server` int(10) unsigned NOT NULL COMMENT '本服端口',
  `zoneid` int(10) unsigned NOT NULL COMMENT '本服区服号',
  `domain` varchar(200) NOT NULL COMMENT '域名',
  `url_login` varchar(200) NOT NULL COMMENT '登陆地址',
  `url_pay` varchar(200) NOT NULL COMMENT '支付地址',
  `url_order` varchar(200) NOT NULL COMMENT '订单地址',
  `number_chat` varchar(100) NOT NULL COMMENT '聊天编号',
  `ip_chat` varchar(100) NOT NULL COMMENT '聊天IP',
  `port_chat` int(10) unsigned NOT NULL COMMENT '聊天端口',
  `enable` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '是否开启',
  `isdefault` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '是否默认服',
  `istest` int(4) unsigned NOT NULL DEFAULT '1',
  `default_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '置为默认服的时间',
  `opened_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '开服时间',
  `add_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '新增时间',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-03-21 17:11:42


--  2015 3-13
--  lmh
--   和服
ALTER TABLE `services` ADD `oldzoneid` INT( 10 ) NOT NULL DEFAULT '0' AFTER `add_at` ;

-- 激活码道具表
CREATE TABLE `giftbag_category` (
  `bagid` int(10) unsigned NOT NULL PRIMARY KEY  AUTO_INCREMENT ,
  `info` varchar(200) NOT NULL,
  `updated_at` int(10) unsigned NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1000;


ALTER TABLE `giftbag` CHANGE COLUMN  `bag` `bag` INT(10) unsigned  NOT NULL;
ALTER TABLE `giftbag_category` ADD COLUMN  `title` varchar(100) DEFAULT NULL AFTER `info`;
ALTER TABLE `giftbag_category` ADD COLUMN  `descp` varchar(200)  DEFAULT NULL AFTER `title`;
