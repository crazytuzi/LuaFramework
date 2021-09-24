-- MySQL dump 10.13  Distrib 5.1.69, for redhat-linux-gnu (x86_64)
--
-- Host: 192.168.8.204    Database: tank_account
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

--
-- Table structure for table `user_account_0`
--

DROP TABLE IF EXISTS `user_account_0`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_0` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_0`
--

LOCK TABLES `user_account_0` WRITE;
/*!40000 ALTER TABLE `user_account_0` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_0` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_1`
--

DROP TABLE IF EXISTS `user_account_1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_1` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_1`
--

LOCK TABLES `user_account_1` WRITE;
/*!40000 ALTER TABLE `user_account_1` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_10`
--

DROP TABLE IF EXISTS `user_account_10`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_10` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_10`
--

LOCK TABLES `user_account_10` WRITE;
/*!40000 ALTER TABLE `user_account_10` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_10` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_100`
--

DROP TABLE IF EXISTS `user_account_100`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_100` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_100`
--

LOCK TABLES `user_account_100` WRITE;
/*!40000 ALTER TABLE `user_account_100` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_100` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_101`
--

DROP TABLE IF EXISTS `user_account_101`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_101` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_101`
--

LOCK TABLES `user_account_101` WRITE;
/*!40000 ALTER TABLE `user_account_101` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_101` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_102`
--

DROP TABLE IF EXISTS `user_account_102`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_102` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_102`
--

LOCK TABLES `user_account_102` WRITE;
/*!40000 ALTER TABLE `user_account_102` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_102` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_103`
--

DROP TABLE IF EXISTS `user_account_103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_103` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_103`
--

LOCK TABLES `user_account_103` WRITE;
/*!40000 ALTER TABLE `user_account_103` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_103` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_104`
--

DROP TABLE IF EXISTS `user_account_104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_104` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_104`
--

LOCK TABLES `user_account_104` WRITE;
/*!40000 ALTER TABLE `user_account_104` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_104` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_105`
--

DROP TABLE IF EXISTS `user_account_105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_105` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_105`
--

LOCK TABLES `user_account_105` WRITE;
/*!40000 ALTER TABLE `user_account_105` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_105` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_106`
--

DROP TABLE IF EXISTS `user_account_106`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_106` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_106`
--

LOCK TABLES `user_account_106` WRITE;
/*!40000 ALTER TABLE `user_account_106` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_106` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_107`
--

DROP TABLE IF EXISTS `user_account_107`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_107` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_107`
--

LOCK TABLES `user_account_107` WRITE;
/*!40000 ALTER TABLE `user_account_107` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_107` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_108`
--

DROP TABLE IF EXISTS `user_account_108`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_108` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_108`
--

LOCK TABLES `user_account_108` WRITE;
/*!40000 ALTER TABLE `user_account_108` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_108` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_109`
--

DROP TABLE IF EXISTS `user_account_109`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_109` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_109`
--

LOCK TABLES `user_account_109` WRITE;
/*!40000 ALTER TABLE `user_account_109` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_109` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_11`
--

DROP TABLE IF EXISTS `user_account_11`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_11` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_11`
--

LOCK TABLES `user_account_11` WRITE;
/*!40000 ALTER TABLE `user_account_11` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_11` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_110`
--

DROP TABLE IF EXISTS `user_account_110`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_110` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_110`
--

LOCK TABLES `user_account_110` WRITE;
/*!40000 ALTER TABLE `user_account_110` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_110` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_111`
--

DROP TABLE IF EXISTS `user_account_111`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_111` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_111`
--

LOCK TABLES `user_account_111` WRITE;
/*!40000 ALTER TABLE `user_account_111` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_111` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_112`
--

DROP TABLE IF EXISTS `user_account_112`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_112` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_112`
--

LOCK TABLES `user_account_112` WRITE;
/*!40000 ALTER TABLE `user_account_112` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_112` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_113`
--

DROP TABLE IF EXISTS `user_account_113`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_113` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_113`
--

LOCK TABLES `user_account_113` WRITE;
/*!40000 ALTER TABLE `user_account_113` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_113` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_114`
--

DROP TABLE IF EXISTS `user_account_114`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_114` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_114`
--

LOCK TABLES `user_account_114` WRITE;
/*!40000 ALTER TABLE `user_account_114` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_114` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_115`
--

DROP TABLE IF EXISTS `user_account_115`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_115` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_115`
--

LOCK TABLES `user_account_115` WRITE;
/*!40000 ALTER TABLE `user_account_115` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_115` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_116`
--

DROP TABLE IF EXISTS `user_account_116`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_116` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_116`
--

LOCK TABLES `user_account_116` WRITE;
/*!40000 ALTER TABLE `user_account_116` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_116` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_117`
--

DROP TABLE IF EXISTS `user_account_117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_117` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_117`
--

LOCK TABLES `user_account_117` WRITE;
/*!40000 ALTER TABLE `user_account_117` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_117` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_118`
--

DROP TABLE IF EXISTS `user_account_118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_118` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_118`
--

LOCK TABLES `user_account_118` WRITE;
/*!40000 ALTER TABLE `user_account_118` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_118` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_119`
--

DROP TABLE IF EXISTS `user_account_119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_119` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_119`
--

LOCK TABLES `user_account_119` WRITE;
/*!40000 ALTER TABLE `user_account_119` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_119` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_12`
--

DROP TABLE IF EXISTS `user_account_12`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_12` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_12`
--

LOCK TABLES `user_account_12` WRITE;
/*!40000 ALTER TABLE `user_account_12` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_12` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_120`
--

DROP TABLE IF EXISTS `user_account_120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_120` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_120`
--

LOCK TABLES `user_account_120` WRITE;
/*!40000 ALTER TABLE `user_account_120` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_120` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_121`
--

DROP TABLE IF EXISTS `user_account_121`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_121` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_121`
--

LOCK TABLES `user_account_121` WRITE;
/*!40000 ALTER TABLE `user_account_121` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_121` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_122`
--

DROP TABLE IF EXISTS `user_account_122`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_122` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_122`
--

LOCK TABLES `user_account_122` WRITE;
/*!40000 ALTER TABLE `user_account_122` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_122` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_123`
--

DROP TABLE IF EXISTS `user_account_123`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_123` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_123`
--

LOCK TABLES `user_account_123` WRITE;
/*!40000 ALTER TABLE `user_account_123` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_123` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_124`
--

DROP TABLE IF EXISTS `user_account_124`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_124` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_124`
--

LOCK TABLES `user_account_124` WRITE;
/*!40000 ALTER TABLE `user_account_124` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_124` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_125`
--

DROP TABLE IF EXISTS `user_account_125`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_125` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_125`
--

LOCK TABLES `user_account_125` WRITE;
/*!40000 ALTER TABLE `user_account_125` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_125` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_126`
--

DROP TABLE IF EXISTS `user_account_126`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_126` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_126`
--

LOCK TABLES `user_account_126` WRITE;
/*!40000 ALTER TABLE `user_account_126` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_126` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_127`
--

DROP TABLE IF EXISTS `user_account_127`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_127` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_127`
--

LOCK TABLES `user_account_127` WRITE;
/*!40000 ALTER TABLE `user_account_127` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_127` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_128`
--

DROP TABLE IF EXISTS `user_account_128`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_128` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_128`
--

LOCK TABLES `user_account_128` WRITE;
/*!40000 ALTER TABLE `user_account_128` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_128` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_129`
--

DROP TABLE IF EXISTS `user_account_129`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_129` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_129`
--

LOCK TABLES `user_account_129` WRITE;
/*!40000 ALTER TABLE `user_account_129` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_129` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_13`
--

DROP TABLE IF EXISTS `user_account_13`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_13` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_13`
--

LOCK TABLES `user_account_13` WRITE;
/*!40000 ALTER TABLE `user_account_13` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_13` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_130`
--

DROP TABLE IF EXISTS `user_account_130`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_130` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_130`
--

LOCK TABLES `user_account_130` WRITE;
/*!40000 ALTER TABLE `user_account_130` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_130` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_131`
--

DROP TABLE IF EXISTS `user_account_131`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_131` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_131`
--

LOCK TABLES `user_account_131` WRITE;
/*!40000 ALTER TABLE `user_account_131` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_131` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_132`
--

DROP TABLE IF EXISTS `user_account_132`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_132` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_132`
--

LOCK TABLES `user_account_132` WRITE;
/*!40000 ALTER TABLE `user_account_132` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_132` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_133`
--

DROP TABLE IF EXISTS `user_account_133`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_133` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_133`
--

LOCK TABLES `user_account_133` WRITE;
/*!40000 ALTER TABLE `user_account_133` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_133` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_134`
--

DROP TABLE IF EXISTS `user_account_134`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_134` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_134`
--

LOCK TABLES `user_account_134` WRITE;
/*!40000 ALTER TABLE `user_account_134` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_134` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_135`
--

DROP TABLE IF EXISTS `user_account_135`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_135` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_135`
--

LOCK TABLES `user_account_135` WRITE;
/*!40000 ALTER TABLE `user_account_135` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_135` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_136`
--

DROP TABLE IF EXISTS `user_account_136`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_136` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_136`
--

LOCK TABLES `user_account_136` WRITE;
/*!40000 ALTER TABLE `user_account_136` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_136` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_137`
--

DROP TABLE IF EXISTS `user_account_137`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_137` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_137`
--

LOCK TABLES `user_account_137` WRITE;
/*!40000 ALTER TABLE `user_account_137` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_137` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_138`
--

DROP TABLE IF EXISTS `user_account_138`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_138` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_138`
--

LOCK TABLES `user_account_138` WRITE;
/*!40000 ALTER TABLE `user_account_138` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_138` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_139`
--

DROP TABLE IF EXISTS `user_account_139`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_139` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_139`
--

LOCK TABLES `user_account_139` WRITE;
/*!40000 ALTER TABLE `user_account_139` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_139` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_14`
--

DROP TABLE IF EXISTS `user_account_14`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_14` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_14`
--

LOCK TABLES `user_account_14` WRITE;
/*!40000 ALTER TABLE `user_account_14` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_14` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_140`
--

DROP TABLE IF EXISTS `user_account_140`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_140` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_140`
--

LOCK TABLES `user_account_140` WRITE;
/*!40000 ALTER TABLE `user_account_140` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_140` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_141`
--

DROP TABLE IF EXISTS `user_account_141`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_141` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_141`
--

LOCK TABLES `user_account_141` WRITE;
/*!40000 ALTER TABLE `user_account_141` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_141` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_142`
--

DROP TABLE IF EXISTS `user_account_142`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_142` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_142`
--

LOCK TABLES `user_account_142` WRITE;
/*!40000 ALTER TABLE `user_account_142` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_142` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_143`
--

DROP TABLE IF EXISTS `user_account_143`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_143` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_143`
--

LOCK TABLES `user_account_143` WRITE;
/*!40000 ALTER TABLE `user_account_143` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_143` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_144`
--

DROP TABLE IF EXISTS `user_account_144`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_144` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_144`
--

LOCK TABLES `user_account_144` WRITE;
/*!40000 ALTER TABLE `user_account_144` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_144` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_145`
--

DROP TABLE IF EXISTS `user_account_145`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_145` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_145`
--

LOCK TABLES `user_account_145` WRITE;
/*!40000 ALTER TABLE `user_account_145` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_145` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_146`
--

DROP TABLE IF EXISTS `user_account_146`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_146` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_146`
--

LOCK TABLES `user_account_146` WRITE;
/*!40000 ALTER TABLE `user_account_146` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_146` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_147`
--

DROP TABLE IF EXISTS `user_account_147`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_147` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_147`
--

LOCK TABLES `user_account_147` WRITE;
/*!40000 ALTER TABLE `user_account_147` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_147` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_148`
--

DROP TABLE IF EXISTS `user_account_148`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_148` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_148`
--

LOCK TABLES `user_account_148` WRITE;
/*!40000 ALTER TABLE `user_account_148` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_148` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_149`
--

DROP TABLE IF EXISTS `user_account_149`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_149` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_149`
--

LOCK TABLES `user_account_149` WRITE;
/*!40000 ALTER TABLE `user_account_149` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_149` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_15`
--

DROP TABLE IF EXISTS `user_account_15`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_15` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_15`
--

LOCK TABLES `user_account_15` WRITE;
/*!40000 ALTER TABLE `user_account_15` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_15` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_150`
--

DROP TABLE IF EXISTS `user_account_150`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_150` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_150`
--

LOCK TABLES `user_account_150` WRITE;
/*!40000 ALTER TABLE `user_account_150` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_150` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_151`
--

DROP TABLE IF EXISTS `user_account_151`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_151` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_151`
--

LOCK TABLES `user_account_151` WRITE;
/*!40000 ALTER TABLE `user_account_151` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_151` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_152`
--

DROP TABLE IF EXISTS `user_account_152`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_152` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_152`
--

LOCK TABLES `user_account_152` WRITE;
/*!40000 ALTER TABLE `user_account_152` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_152` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_153`
--

DROP TABLE IF EXISTS `user_account_153`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_153` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_153`
--

LOCK TABLES `user_account_153` WRITE;
/*!40000 ALTER TABLE `user_account_153` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_153` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_154`
--

DROP TABLE IF EXISTS `user_account_154`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_154` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_154`
--

LOCK TABLES `user_account_154` WRITE;
/*!40000 ALTER TABLE `user_account_154` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_154` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_155`
--

DROP TABLE IF EXISTS `user_account_155`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_155` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_155`
--

LOCK TABLES `user_account_155` WRITE;
/*!40000 ALTER TABLE `user_account_155` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_155` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_156`
--

DROP TABLE IF EXISTS `user_account_156`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_156` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_156`
--

LOCK TABLES `user_account_156` WRITE;
/*!40000 ALTER TABLE `user_account_156` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_156` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_157`
--

DROP TABLE IF EXISTS `user_account_157`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_157` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_157`
--

LOCK TABLES `user_account_157` WRITE;
/*!40000 ALTER TABLE `user_account_157` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_157` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_158`
--

DROP TABLE IF EXISTS `user_account_158`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_158` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_158`
--

LOCK TABLES `user_account_158` WRITE;
/*!40000 ALTER TABLE `user_account_158` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_158` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_159`
--

DROP TABLE IF EXISTS `user_account_159`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_159` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_159`
--

LOCK TABLES `user_account_159` WRITE;
/*!40000 ALTER TABLE `user_account_159` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_159` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_16`
--

DROP TABLE IF EXISTS `user_account_16`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_16` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_16`
--

LOCK TABLES `user_account_16` WRITE;
/*!40000 ALTER TABLE `user_account_16` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_16` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_160`
--

DROP TABLE IF EXISTS `user_account_160`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_160` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_160`
--

LOCK TABLES `user_account_160` WRITE;
/*!40000 ALTER TABLE `user_account_160` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_160` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_161`
--

DROP TABLE IF EXISTS `user_account_161`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_161` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_161`
--

LOCK TABLES `user_account_161` WRITE;
/*!40000 ALTER TABLE `user_account_161` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_161` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_162`
--

DROP TABLE IF EXISTS `user_account_162`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_162` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_162`
--

LOCK TABLES `user_account_162` WRITE;
/*!40000 ALTER TABLE `user_account_162` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_162` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_163`
--

DROP TABLE IF EXISTS `user_account_163`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_163` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_163`
--

LOCK TABLES `user_account_163` WRITE;
/*!40000 ALTER TABLE `user_account_163` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_163` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_164`
--

DROP TABLE IF EXISTS `user_account_164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_164` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_164`
--

LOCK TABLES `user_account_164` WRITE;
/*!40000 ALTER TABLE `user_account_164` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_164` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_165`
--

DROP TABLE IF EXISTS `user_account_165`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_165` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_165`
--

LOCK TABLES `user_account_165` WRITE;
/*!40000 ALTER TABLE `user_account_165` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_165` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_166`
--

DROP TABLE IF EXISTS `user_account_166`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_166` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_166`
--

LOCK TABLES `user_account_166` WRITE;
/*!40000 ALTER TABLE `user_account_166` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_166` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_167`
--

DROP TABLE IF EXISTS `user_account_167`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_167` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_167`
--

LOCK TABLES `user_account_167` WRITE;
/*!40000 ALTER TABLE `user_account_167` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_167` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_168`
--

DROP TABLE IF EXISTS `user_account_168`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_168` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_168`
--

LOCK TABLES `user_account_168` WRITE;
/*!40000 ALTER TABLE `user_account_168` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_168` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_169`
--

DROP TABLE IF EXISTS `user_account_169`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_169` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_169`
--

LOCK TABLES `user_account_169` WRITE;
/*!40000 ALTER TABLE `user_account_169` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_169` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_17`
--

DROP TABLE IF EXISTS `user_account_17`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_17` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_17`
--

LOCK TABLES `user_account_17` WRITE;
/*!40000 ALTER TABLE `user_account_17` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_17` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_170`
--

DROP TABLE IF EXISTS `user_account_170`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_170` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_170`
--

LOCK TABLES `user_account_170` WRITE;
/*!40000 ALTER TABLE `user_account_170` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_170` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_171`
--

DROP TABLE IF EXISTS `user_account_171`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_171` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_171`
--

LOCK TABLES `user_account_171` WRITE;
/*!40000 ALTER TABLE `user_account_171` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_171` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_172`
--

DROP TABLE IF EXISTS `user_account_172`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_172` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_172`
--

LOCK TABLES `user_account_172` WRITE;
/*!40000 ALTER TABLE `user_account_172` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_172` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_173`
--

DROP TABLE IF EXISTS `user_account_173`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_173` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_173`
--

LOCK TABLES `user_account_173` WRITE;
/*!40000 ALTER TABLE `user_account_173` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_173` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_174`
--

DROP TABLE IF EXISTS `user_account_174`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_174` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_174`
--

LOCK TABLES `user_account_174` WRITE;
/*!40000 ALTER TABLE `user_account_174` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_174` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_175`
--

DROP TABLE IF EXISTS `user_account_175`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_175` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_175`
--

LOCK TABLES `user_account_175` WRITE;
/*!40000 ALTER TABLE `user_account_175` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_175` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_176`
--

DROP TABLE IF EXISTS `user_account_176`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_176` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_176`
--

LOCK TABLES `user_account_176` WRITE;
/*!40000 ALTER TABLE `user_account_176` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_176` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_177`
--

DROP TABLE IF EXISTS `user_account_177`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_177` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_177`
--

LOCK TABLES `user_account_177` WRITE;
/*!40000 ALTER TABLE `user_account_177` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_177` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_178`
--

DROP TABLE IF EXISTS `user_account_178`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_178` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_178`
--

LOCK TABLES `user_account_178` WRITE;
/*!40000 ALTER TABLE `user_account_178` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_178` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_179`
--

DROP TABLE IF EXISTS `user_account_179`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_179` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_179`
--

LOCK TABLES `user_account_179` WRITE;
/*!40000 ALTER TABLE `user_account_179` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_179` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_18`
--

DROP TABLE IF EXISTS `user_account_18`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_18` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_18`
--

LOCK TABLES `user_account_18` WRITE;
/*!40000 ALTER TABLE `user_account_18` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_18` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_180`
--

DROP TABLE IF EXISTS `user_account_180`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_180` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_180`
--

LOCK TABLES `user_account_180` WRITE;
/*!40000 ALTER TABLE `user_account_180` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_180` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_181`
--

DROP TABLE IF EXISTS `user_account_181`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_181` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_181`
--

LOCK TABLES `user_account_181` WRITE;
/*!40000 ALTER TABLE `user_account_181` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_181` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_182`
--

DROP TABLE IF EXISTS `user_account_182`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_182` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_182`
--

LOCK TABLES `user_account_182` WRITE;
/*!40000 ALTER TABLE `user_account_182` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_182` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_183`
--

DROP TABLE IF EXISTS `user_account_183`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_183` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_183`
--

LOCK TABLES `user_account_183` WRITE;
/*!40000 ALTER TABLE `user_account_183` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_183` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_184`
--

DROP TABLE IF EXISTS `user_account_184`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_184` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_184`
--

LOCK TABLES `user_account_184` WRITE;
/*!40000 ALTER TABLE `user_account_184` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_184` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_185`
--

DROP TABLE IF EXISTS `user_account_185`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_185` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_185`
--

LOCK TABLES `user_account_185` WRITE;
/*!40000 ALTER TABLE `user_account_185` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_185` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_186`
--

DROP TABLE IF EXISTS `user_account_186`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_186` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_186`
--

LOCK TABLES `user_account_186` WRITE;
/*!40000 ALTER TABLE `user_account_186` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_186` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_187`
--

DROP TABLE IF EXISTS `user_account_187`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_187` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_187`
--

LOCK TABLES `user_account_187` WRITE;
/*!40000 ALTER TABLE `user_account_187` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_187` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_188`
--

DROP TABLE IF EXISTS `user_account_188`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_188` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_188`
--

LOCK TABLES `user_account_188` WRITE;
/*!40000 ALTER TABLE `user_account_188` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_188` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_189`
--

DROP TABLE IF EXISTS `user_account_189`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_189` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_189`
--

LOCK TABLES `user_account_189` WRITE;
/*!40000 ALTER TABLE `user_account_189` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_189` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_19`
--

DROP TABLE IF EXISTS `user_account_19`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_19` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_19`
--

LOCK TABLES `user_account_19` WRITE;
/*!40000 ALTER TABLE `user_account_19` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_19` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_190`
--

DROP TABLE IF EXISTS `user_account_190`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_190` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_190`
--

LOCK TABLES `user_account_190` WRITE;
/*!40000 ALTER TABLE `user_account_190` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_190` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_191`
--

DROP TABLE IF EXISTS `user_account_191`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_191` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_191`
--

LOCK TABLES `user_account_191` WRITE;
/*!40000 ALTER TABLE `user_account_191` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_191` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_192`
--

DROP TABLE IF EXISTS `user_account_192`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_192` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_192`
--

LOCK TABLES `user_account_192` WRITE;
/*!40000 ALTER TABLE `user_account_192` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_192` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_193`
--

DROP TABLE IF EXISTS `user_account_193`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_193` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_193`
--

LOCK TABLES `user_account_193` WRITE;
/*!40000 ALTER TABLE `user_account_193` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_193` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_194`
--

DROP TABLE IF EXISTS `user_account_194`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_194` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_194`
--

LOCK TABLES `user_account_194` WRITE;
/*!40000 ALTER TABLE `user_account_194` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_194` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_195`
--

DROP TABLE IF EXISTS `user_account_195`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_195` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_195`
--

LOCK TABLES `user_account_195` WRITE;
/*!40000 ALTER TABLE `user_account_195` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_195` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_196`
--

DROP TABLE IF EXISTS `user_account_196`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_196` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_196`
--

LOCK TABLES `user_account_196` WRITE;
/*!40000 ALTER TABLE `user_account_196` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_196` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_197`
--

DROP TABLE IF EXISTS `user_account_197`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_197` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_197`
--

LOCK TABLES `user_account_197` WRITE;
/*!40000 ALTER TABLE `user_account_197` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_197` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_198`
--

DROP TABLE IF EXISTS `user_account_198`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_198` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_198`
--

LOCK TABLES `user_account_198` WRITE;
/*!40000 ALTER TABLE `user_account_198` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_198` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_199`
--

DROP TABLE IF EXISTS `user_account_199`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_199` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_199`
--

LOCK TABLES `user_account_199` WRITE;
/*!40000 ALTER TABLE `user_account_199` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_199` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_2`
--

DROP TABLE IF EXISTS `user_account_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_2` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_2`
--

LOCK TABLES `user_account_2` WRITE;
/*!40000 ALTER TABLE `user_account_2` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_20`
--

DROP TABLE IF EXISTS `user_account_20`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_20` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_20`
--

LOCK TABLES `user_account_20` WRITE;
/*!40000 ALTER TABLE `user_account_20` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_20` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_200`
--

DROP TABLE IF EXISTS `user_account_200`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_200` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_200`
--

LOCK TABLES `user_account_200` WRITE;
/*!40000 ALTER TABLE `user_account_200` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_200` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_201`
--

DROP TABLE IF EXISTS `user_account_201`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_201` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_201`
--

LOCK TABLES `user_account_201` WRITE;
/*!40000 ALTER TABLE `user_account_201` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_201` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_202`
--

DROP TABLE IF EXISTS `user_account_202`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_202` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_202`
--

LOCK TABLES `user_account_202` WRITE;
/*!40000 ALTER TABLE `user_account_202` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_202` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_203`
--

DROP TABLE IF EXISTS `user_account_203`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_203` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_203`
--

LOCK TABLES `user_account_203` WRITE;
/*!40000 ALTER TABLE `user_account_203` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_203` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_204`
--

DROP TABLE IF EXISTS `user_account_204`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_204` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_204`
--

LOCK TABLES `user_account_204` WRITE;
/*!40000 ALTER TABLE `user_account_204` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_204` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_205`
--

DROP TABLE IF EXISTS `user_account_205`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_205` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_205`
--

LOCK TABLES `user_account_205` WRITE;
/*!40000 ALTER TABLE `user_account_205` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_205` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_206`
--

DROP TABLE IF EXISTS `user_account_206`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_206` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_206`
--

LOCK TABLES `user_account_206` WRITE;
/*!40000 ALTER TABLE `user_account_206` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_206` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_207`
--

DROP TABLE IF EXISTS `user_account_207`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_207` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_207`
--

LOCK TABLES `user_account_207` WRITE;
/*!40000 ALTER TABLE `user_account_207` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_207` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_208`
--

DROP TABLE IF EXISTS `user_account_208`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_208` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_208`
--

LOCK TABLES `user_account_208` WRITE;
/*!40000 ALTER TABLE `user_account_208` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_208` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_209`
--

DROP TABLE IF EXISTS `user_account_209`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_209` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_209`
--

LOCK TABLES `user_account_209` WRITE;
/*!40000 ALTER TABLE `user_account_209` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_209` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_21`
--

DROP TABLE IF EXISTS `user_account_21`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_21` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_21`
--

LOCK TABLES `user_account_21` WRITE;
/*!40000 ALTER TABLE `user_account_21` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_21` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_210`
--

DROP TABLE IF EXISTS `user_account_210`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_210` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_210`
--

LOCK TABLES `user_account_210` WRITE;
/*!40000 ALTER TABLE `user_account_210` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_210` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_211`
--

DROP TABLE IF EXISTS `user_account_211`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_211` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_211`
--

LOCK TABLES `user_account_211` WRITE;
/*!40000 ALTER TABLE `user_account_211` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_211` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_212`
--

DROP TABLE IF EXISTS `user_account_212`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_212` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_212`
--

LOCK TABLES `user_account_212` WRITE;
/*!40000 ALTER TABLE `user_account_212` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_212` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_213`
--

DROP TABLE IF EXISTS `user_account_213`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_213` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_213`
--

LOCK TABLES `user_account_213` WRITE;
/*!40000 ALTER TABLE `user_account_213` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_213` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_214`
--

DROP TABLE IF EXISTS `user_account_214`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_214` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_214`
--

LOCK TABLES `user_account_214` WRITE;
/*!40000 ALTER TABLE `user_account_214` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_214` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_215`
--

DROP TABLE IF EXISTS `user_account_215`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_215` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_215`
--

LOCK TABLES `user_account_215` WRITE;
/*!40000 ALTER TABLE `user_account_215` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_215` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_216`
--

DROP TABLE IF EXISTS `user_account_216`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_216` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_216`
--

LOCK TABLES `user_account_216` WRITE;
/*!40000 ALTER TABLE `user_account_216` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_216` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_217`
--

DROP TABLE IF EXISTS `user_account_217`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_217` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_217`
--

LOCK TABLES `user_account_217` WRITE;
/*!40000 ALTER TABLE `user_account_217` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_217` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_218`
--

DROP TABLE IF EXISTS `user_account_218`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_218` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_218`
--

LOCK TABLES `user_account_218` WRITE;
/*!40000 ALTER TABLE `user_account_218` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_218` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_219`
--

DROP TABLE IF EXISTS `user_account_219`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_219` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_219`
--

LOCK TABLES `user_account_219` WRITE;
/*!40000 ALTER TABLE `user_account_219` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_219` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_22`
--

DROP TABLE IF EXISTS `user_account_22`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_22` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_22`
--

LOCK TABLES `user_account_22` WRITE;
/*!40000 ALTER TABLE `user_account_22` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_22` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_220`
--

DROP TABLE IF EXISTS `user_account_220`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_220` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_220`
--

LOCK TABLES `user_account_220` WRITE;
/*!40000 ALTER TABLE `user_account_220` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_220` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_221`
--

DROP TABLE IF EXISTS `user_account_221`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_221` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_221`
--

LOCK TABLES `user_account_221` WRITE;
/*!40000 ALTER TABLE `user_account_221` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_221` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_222`
--

DROP TABLE IF EXISTS `user_account_222`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_222` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_222`
--

LOCK TABLES `user_account_222` WRITE;
/*!40000 ALTER TABLE `user_account_222` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_222` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_223`
--

DROP TABLE IF EXISTS `user_account_223`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_223` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_223`
--

LOCK TABLES `user_account_223` WRITE;
/*!40000 ALTER TABLE `user_account_223` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_223` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_224`
--

DROP TABLE IF EXISTS `user_account_224`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_224` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_224`
--

LOCK TABLES `user_account_224` WRITE;
/*!40000 ALTER TABLE `user_account_224` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_224` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_225`
--

DROP TABLE IF EXISTS `user_account_225`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_225` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_225`
--

LOCK TABLES `user_account_225` WRITE;
/*!40000 ALTER TABLE `user_account_225` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_225` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_226`
--

DROP TABLE IF EXISTS `user_account_226`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_226` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_226`
--

LOCK TABLES `user_account_226` WRITE;
/*!40000 ALTER TABLE `user_account_226` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_226` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_227`
--

DROP TABLE IF EXISTS `user_account_227`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_227` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_227`
--

LOCK TABLES `user_account_227` WRITE;
/*!40000 ALTER TABLE `user_account_227` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_227` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_228`
--

DROP TABLE IF EXISTS `user_account_228`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_228` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_228`
--

LOCK TABLES `user_account_228` WRITE;
/*!40000 ALTER TABLE `user_account_228` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_228` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_229`
--

DROP TABLE IF EXISTS `user_account_229`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_229` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_229`
--

LOCK TABLES `user_account_229` WRITE;
/*!40000 ALTER TABLE `user_account_229` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_229` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_23`
--

DROP TABLE IF EXISTS `user_account_23`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_23` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_23`
--

LOCK TABLES `user_account_23` WRITE;
/*!40000 ALTER TABLE `user_account_23` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_23` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_230`
--

DROP TABLE IF EXISTS `user_account_230`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_230` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_230`
--

LOCK TABLES `user_account_230` WRITE;
/*!40000 ALTER TABLE `user_account_230` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_230` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_231`
--

DROP TABLE IF EXISTS `user_account_231`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_231` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_231`
--

LOCK TABLES `user_account_231` WRITE;
/*!40000 ALTER TABLE `user_account_231` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_231` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_232`
--

DROP TABLE IF EXISTS `user_account_232`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_232` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_232`
--

LOCK TABLES `user_account_232` WRITE;
/*!40000 ALTER TABLE `user_account_232` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_232` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_233`
--

DROP TABLE IF EXISTS `user_account_233`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_233` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_233`
--

LOCK TABLES `user_account_233` WRITE;
/*!40000 ALTER TABLE `user_account_233` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_233` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_234`
--

DROP TABLE IF EXISTS `user_account_234`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_234` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_234`
--

LOCK TABLES `user_account_234` WRITE;
/*!40000 ALTER TABLE `user_account_234` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_234` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_235`
--

DROP TABLE IF EXISTS `user_account_235`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_235` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_235`
--

LOCK TABLES `user_account_235` WRITE;
/*!40000 ALTER TABLE `user_account_235` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_235` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_236`
--

DROP TABLE IF EXISTS `user_account_236`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_236` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_236`
--

LOCK TABLES `user_account_236` WRITE;
/*!40000 ALTER TABLE `user_account_236` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_236` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_237`
--

DROP TABLE IF EXISTS `user_account_237`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_237` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_237`
--

LOCK TABLES `user_account_237` WRITE;
/*!40000 ALTER TABLE `user_account_237` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_237` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_238`
--

DROP TABLE IF EXISTS `user_account_238`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_238` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_238`
--

LOCK TABLES `user_account_238` WRITE;
/*!40000 ALTER TABLE `user_account_238` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_238` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_239`
--

DROP TABLE IF EXISTS `user_account_239`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_239` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_239`
--

LOCK TABLES `user_account_239` WRITE;
/*!40000 ALTER TABLE `user_account_239` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_239` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_24`
--

DROP TABLE IF EXISTS `user_account_24`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_24` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_24`
--

LOCK TABLES `user_account_24` WRITE;
/*!40000 ALTER TABLE `user_account_24` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_24` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_240`
--

DROP TABLE IF EXISTS `user_account_240`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_240` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_240`
--

LOCK TABLES `user_account_240` WRITE;
/*!40000 ALTER TABLE `user_account_240` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_240` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_241`
--

DROP TABLE IF EXISTS `user_account_241`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_241` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_241`
--

LOCK TABLES `user_account_241` WRITE;
/*!40000 ALTER TABLE `user_account_241` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_241` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_242`
--

DROP TABLE IF EXISTS `user_account_242`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_242` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_242`
--

LOCK TABLES `user_account_242` WRITE;
/*!40000 ALTER TABLE `user_account_242` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_242` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_243`
--

DROP TABLE IF EXISTS `user_account_243`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_243` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_243`
--

LOCK TABLES `user_account_243` WRITE;
/*!40000 ALTER TABLE `user_account_243` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_243` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_244`
--

DROP TABLE IF EXISTS `user_account_244`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_244` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_244`
--

LOCK TABLES `user_account_244` WRITE;
/*!40000 ALTER TABLE `user_account_244` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_244` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_245`
--

DROP TABLE IF EXISTS `user_account_245`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_245` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_245`
--

LOCK TABLES `user_account_245` WRITE;
/*!40000 ALTER TABLE `user_account_245` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_245` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_246`
--

DROP TABLE IF EXISTS `user_account_246`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_246` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_246`
--

LOCK TABLES `user_account_246` WRITE;
/*!40000 ALTER TABLE `user_account_246` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_246` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_247`
--

DROP TABLE IF EXISTS `user_account_247`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_247` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_247`
--

LOCK TABLES `user_account_247` WRITE;
/*!40000 ALTER TABLE `user_account_247` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_247` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_248`
--

DROP TABLE IF EXISTS `user_account_248`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_248` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_248`
--

LOCK TABLES `user_account_248` WRITE;
/*!40000 ALTER TABLE `user_account_248` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_248` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_249`
--

DROP TABLE IF EXISTS `user_account_249`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_249` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_249`
--

LOCK TABLES `user_account_249` WRITE;
/*!40000 ALTER TABLE `user_account_249` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_249` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_25`
--

DROP TABLE IF EXISTS `user_account_25`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_25` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_25`
--

LOCK TABLES `user_account_25` WRITE;
/*!40000 ALTER TABLE `user_account_25` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_25` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_250`
--

DROP TABLE IF EXISTS `user_account_250`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_250` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_250`
--

LOCK TABLES `user_account_250` WRITE;
/*!40000 ALTER TABLE `user_account_250` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_250` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_251`
--

DROP TABLE IF EXISTS `user_account_251`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_251` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_251`
--

LOCK TABLES `user_account_251` WRITE;
/*!40000 ALTER TABLE `user_account_251` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_251` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_252`
--

DROP TABLE IF EXISTS `user_account_252`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_252` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_252`
--

LOCK TABLES `user_account_252` WRITE;
/*!40000 ALTER TABLE `user_account_252` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_252` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_253`
--

DROP TABLE IF EXISTS `user_account_253`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_253` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_253`
--

LOCK TABLES `user_account_253` WRITE;
/*!40000 ALTER TABLE `user_account_253` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_253` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_254`
--

DROP TABLE IF EXISTS `user_account_254`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_254` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_254`
--

LOCK TABLES `user_account_254` WRITE;
/*!40000 ALTER TABLE `user_account_254` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_254` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_255`
--

DROP TABLE IF EXISTS `user_account_255`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_255` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_255`
--

LOCK TABLES `user_account_255` WRITE;
/*!40000 ALTER TABLE `user_account_255` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_255` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_256`
--

DROP TABLE IF EXISTS `user_account_256`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_256` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_256`
--

LOCK TABLES `user_account_256` WRITE;
/*!40000 ALTER TABLE `user_account_256` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_256` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_257`
--

DROP TABLE IF EXISTS `user_account_257`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_257` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_257`
--

LOCK TABLES `user_account_257` WRITE;
/*!40000 ALTER TABLE `user_account_257` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_257` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_258`
--

DROP TABLE IF EXISTS `user_account_258`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_258` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_258`
--

LOCK TABLES `user_account_258` WRITE;
/*!40000 ALTER TABLE `user_account_258` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_258` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_259`
--

DROP TABLE IF EXISTS `user_account_259`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_259` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_259`
--

LOCK TABLES `user_account_259` WRITE;
/*!40000 ALTER TABLE `user_account_259` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_259` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_26`
--

DROP TABLE IF EXISTS `user_account_26`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_26` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_26`
--

LOCK TABLES `user_account_26` WRITE;
/*!40000 ALTER TABLE `user_account_26` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_26` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_260`
--

DROP TABLE IF EXISTS `user_account_260`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_260` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_260`
--

LOCK TABLES `user_account_260` WRITE;
/*!40000 ALTER TABLE `user_account_260` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_260` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_261`
--

DROP TABLE IF EXISTS `user_account_261`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_261` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_261`
--

LOCK TABLES `user_account_261` WRITE;
/*!40000 ALTER TABLE `user_account_261` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_261` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_262`
--

DROP TABLE IF EXISTS `user_account_262`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_262` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_262`
--

LOCK TABLES `user_account_262` WRITE;
/*!40000 ALTER TABLE `user_account_262` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_262` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_263`
--

DROP TABLE IF EXISTS `user_account_263`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_263` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_263`
--

LOCK TABLES `user_account_263` WRITE;
/*!40000 ALTER TABLE `user_account_263` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_263` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_264`
--

DROP TABLE IF EXISTS `user_account_264`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_264` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_264`
--

LOCK TABLES `user_account_264` WRITE;
/*!40000 ALTER TABLE `user_account_264` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_264` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_265`
--

DROP TABLE IF EXISTS `user_account_265`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_265` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_265`
--

LOCK TABLES `user_account_265` WRITE;
/*!40000 ALTER TABLE `user_account_265` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_265` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_266`
--

DROP TABLE IF EXISTS `user_account_266`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_266` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_266`
--

LOCK TABLES `user_account_266` WRITE;
/*!40000 ALTER TABLE `user_account_266` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_266` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_267`
--

DROP TABLE IF EXISTS `user_account_267`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_267` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_267`
--

LOCK TABLES `user_account_267` WRITE;
/*!40000 ALTER TABLE `user_account_267` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_267` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_268`
--

DROP TABLE IF EXISTS `user_account_268`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_268` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_268`
--

LOCK TABLES `user_account_268` WRITE;
/*!40000 ALTER TABLE `user_account_268` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_268` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_269`
--

DROP TABLE IF EXISTS `user_account_269`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_269` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_269`
--

LOCK TABLES `user_account_269` WRITE;
/*!40000 ALTER TABLE `user_account_269` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_269` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_27`
--

DROP TABLE IF EXISTS `user_account_27`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_27` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_27`
--

LOCK TABLES `user_account_27` WRITE;
/*!40000 ALTER TABLE `user_account_27` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_27` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_270`
--

DROP TABLE IF EXISTS `user_account_270`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_270` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_270`
--

LOCK TABLES `user_account_270` WRITE;
/*!40000 ALTER TABLE `user_account_270` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_270` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_271`
--

DROP TABLE IF EXISTS `user_account_271`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_271` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_271`
--

LOCK TABLES `user_account_271` WRITE;
/*!40000 ALTER TABLE `user_account_271` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_271` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_272`
--

DROP TABLE IF EXISTS `user_account_272`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_272` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_272`
--

LOCK TABLES `user_account_272` WRITE;
/*!40000 ALTER TABLE `user_account_272` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_272` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_273`
--

DROP TABLE IF EXISTS `user_account_273`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_273` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_273`
--

LOCK TABLES `user_account_273` WRITE;
/*!40000 ALTER TABLE `user_account_273` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_273` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_274`
--

DROP TABLE IF EXISTS `user_account_274`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_274` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_274`
--

LOCK TABLES `user_account_274` WRITE;
/*!40000 ALTER TABLE `user_account_274` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_274` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_275`
--

DROP TABLE IF EXISTS `user_account_275`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_275` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_275`
--

LOCK TABLES `user_account_275` WRITE;
/*!40000 ALTER TABLE `user_account_275` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_275` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_276`
--

DROP TABLE IF EXISTS `user_account_276`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_276` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_276`
--

LOCK TABLES `user_account_276` WRITE;
/*!40000 ALTER TABLE `user_account_276` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_276` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_277`
--

DROP TABLE IF EXISTS `user_account_277`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_277` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_277`
--

LOCK TABLES `user_account_277` WRITE;
/*!40000 ALTER TABLE `user_account_277` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_277` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_278`
--

DROP TABLE IF EXISTS `user_account_278`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_278` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_278`
--

LOCK TABLES `user_account_278` WRITE;
/*!40000 ALTER TABLE `user_account_278` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_278` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_279`
--

DROP TABLE IF EXISTS `user_account_279`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_279` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_279`
--

LOCK TABLES `user_account_279` WRITE;
/*!40000 ALTER TABLE `user_account_279` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_279` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_28`
--

DROP TABLE IF EXISTS `user_account_28`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_28` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_28`
--

LOCK TABLES `user_account_28` WRITE;
/*!40000 ALTER TABLE `user_account_28` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_28` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_280`
--

DROP TABLE IF EXISTS `user_account_280`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_280` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_280`
--

LOCK TABLES `user_account_280` WRITE;
/*!40000 ALTER TABLE `user_account_280` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_280` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_281`
--

DROP TABLE IF EXISTS `user_account_281`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_281` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_281`
--

LOCK TABLES `user_account_281` WRITE;
/*!40000 ALTER TABLE `user_account_281` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_281` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_282`
--

DROP TABLE IF EXISTS `user_account_282`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_282` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_282`
--

LOCK TABLES `user_account_282` WRITE;
/*!40000 ALTER TABLE `user_account_282` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_282` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_283`
--

DROP TABLE IF EXISTS `user_account_283`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_283` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_283`
--

LOCK TABLES `user_account_283` WRITE;
/*!40000 ALTER TABLE `user_account_283` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_283` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_284`
--

DROP TABLE IF EXISTS `user_account_284`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_284` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_284`
--

LOCK TABLES `user_account_284` WRITE;
/*!40000 ALTER TABLE `user_account_284` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_284` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_285`
--

DROP TABLE IF EXISTS `user_account_285`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_285` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_285`
--

LOCK TABLES `user_account_285` WRITE;
/*!40000 ALTER TABLE `user_account_285` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_285` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_286`
--

DROP TABLE IF EXISTS `user_account_286`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_286` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_286`
--

LOCK TABLES `user_account_286` WRITE;
/*!40000 ALTER TABLE `user_account_286` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_286` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_287`
--

DROP TABLE IF EXISTS `user_account_287`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_287` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_287`
--

LOCK TABLES `user_account_287` WRITE;
/*!40000 ALTER TABLE `user_account_287` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_287` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_288`
--

DROP TABLE IF EXISTS `user_account_288`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_288` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_288`
--

LOCK TABLES `user_account_288` WRITE;
/*!40000 ALTER TABLE `user_account_288` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_288` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_289`
--

DROP TABLE IF EXISTS `user_account_289`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_289` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_289`
--

LOCK TABLES `user_account_289` WRITE;
/*!40000 ALTER TABLE `user_account_289` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_289` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_29`
--

DROP TABLE IF EXISTS `user_account_29`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_29` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_29`
--

LOCK TABLES `user_account_29` WRITE;
/*!40000 ALTER TABLE `user_account_29` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_29` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_290`
--

DROP TABLE IF EXISTS `user_account_290`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_290` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_290`
--

LOCK TABLES `user_account_290` WRITE;
/*!40000 ALTER TABLE `user_account_290` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_290` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_291`
--

DROP TABLE IF EXISTS `user_account_291`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_291` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_291`
--

LOCK TABLES `user_account_291` WRITE;
/*!40000 ALTER TABLE `user_account_291` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_291` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_292`
--

DROP TABLE IF EXISTS `user_account_292`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_292` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_292`
--

LOCK TABLES `user_account_292` WRITE;
/*!40000 ALTER TABLE `user_account_292` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_292` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_293`
--

DROP TABLE IF EXISTS `user_account_293`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_293` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_293`
--

LOCK TABLES `user_account_293` WRITE;
/*!40000 ALTER TABLE `user_account_293` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_293` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_294`
--

DROP TABLE IF EXISTS `user_account_294`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_294` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_294`
--

LOCK TABLES `user_account_294` WRITE;
/*!40000 ALTER TABLE `user_account_294` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_294` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_295`
--

DROP TABLE IF EXISTS `user_account_295`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_295` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_295`
--

LOCK TABLES `user_account_295` WRITE;
/*!40000 ALTER TABLE `user_account_295` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_295` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_296`
--

DROP TABLE IF EXISTS `user_account_296`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_296` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_296`
--

LOCK TABLES `user_account_296` WRITE;
/*!40000 ALTER TABLE `user_account_296` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_296` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_297`
--

DROP TABLE IF EXISTS `user_account_297`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_297` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_297`
--

LOCK TABLES `user_account_297` WRITE;
/*!40000 ALTER TABLE `user_account_297` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_297` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_298`
--

DROP TABLE IF EXISTS `user_account_298`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_298` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_298`
--

LOCK TABLES `user_account_298` WRITE;
/*!40000 ALTER TABLE `user_account_298` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_298` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_299`
--

DROP TABLE IF EXISTS `user_account_299`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_299` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_299`
--

LOCK TABLES `user_account_299` WRITE;
/*!40000 ALTER TABLE `user_account_299` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_299` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_3`
--

DROP TABLE IF EXISTS `user_account_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_3` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_3`
--

LOCK TABLES `user_account_3` WRITE;
/*!40000 ALTER TABLE `user_account_3` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_30`
--

DROP TABLE IF EXISTS `user_account_30`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_30` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_30`
--

LOCK TABLES `user_account_30` WRITE;
/*!40000 ALTER TABLE `user_account_30` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_30` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_31`
--

DROP TABLE IF EXISTS `user_account_31`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_31` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_31`
--

LOCK TABLES `user_account_31` WRITE;
/*!40000 ALTER TABLE `user_account_31` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_31` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_32`
--

DROP TABLE IF EXISTS `user_account_32`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_32` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_32`
--

LOCK TABLES `user_account_32` WRITE;
/*!40000 ALTER TABLE `user_account_32` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_32` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_33`
--

DROP TABLE IF EXISTS `user_account_33`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_33` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_33`
--

LOCK TABLES `user_account_33` WRITE;
/*!40000 ALTER TABLE `user_account_33` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_33` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_34`
--

DROP TABLE IF EXISTS `user_account_34`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_34` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_34`
--

LOCK TABLES `user_account_34` WRITE;
/*!40000 ALTER TABLE `user_account_34` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_34` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_35`
--

DROP TABLE IF EXISTS `user_account_35`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_35` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_35`
--

LOCK TABLES `user_account_35` WRITE;
/*!40000 ALTER TABLE `user_account_35` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_35` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_36`
--

DROP TABLE IF EXISTS `user_account_36`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_36` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_36`
--

LOCK TABLES `user_account_36` WRITE;
/*!40000 ALTER TABLE `user_account_36` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_36` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_37`
--

DROP TABLE IF EXISTS `user_account_37`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_37` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_37`
--

LOCK TABLES `user_account_37` WRITE;
/*!40000 ALTER TABLE `user_account_37` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_37` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_38`
--

DROP TABLE IF EXISTS `user_account_38`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_38` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_38`
--

LOCK TABLES `user_account_38` WRITE;
/*!40000 ALTER TABLE `user_account_38` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_38` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_39`
--

DROP TABLE IF EXISTS `user_account_39`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_39` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_39`
--

LOCK TABLES `user_account_39` WRITE;
/*!40000 ALTER TABLE `user_account_39` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_39` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_4`
--

DROP TABLE IF EXISTS `user_account_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_4` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_4`
--

LOCK TABLES `user_account_4` WRITE;
/*!40000 ALTER TABLE `user_account_4` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_40`
--

DROP TABLE IF EXISTS `user_account_40`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_40` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_40`
--

LOCK TABLES `user_account_40` WRITE;
/*!40000 ALTER TABLE `user_account_40` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_40` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_41`
--

DROP TABLE IF EXISTS `user_account_41`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_41` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_41`
--

LOCK TABLES `user_account_41` WRITE;
/*!40000 ALTER TABLE `user_account_41` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_41` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_42`
--

DROP TABLE IF EXISTS `user_account_42`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_42` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_42`
--

LOCK TABLES `user_account_42` WRITE;
/*!40000 ALTER TABLE `user_account_42` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_42` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_43`
--

DROP TABLE IF EXISTS `user_account_43`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_43` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_43`
--

LOCK TABLES `user_account_43` WRITE;
/*!40000 ALTER TABLE `user_account_43` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_43` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_44`
--

DROP TABLE IF EXISTS `user_account_44`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_44` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_44`
--

LOCK TABLES `user_account_44` WRITE;
/*!40000 ALTER TABLE `user_account_44` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_44` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_45`
--

DROP TABLE IF EXISTS `user_account_45`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_45` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_45`
--

LOCK TABLES `user_account_45` WRITE;
/*!40000 ALTER TABLE `user_account_45` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_45` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_46`
--

DROP TABLE IF EXISTS `user_account_46`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_46` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_46`
--

LOCK TABLES `user_account_46` WRITE;
/*!40000 ALTER TABLE `user_account_46` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_46` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_47`
--

DROP TABLE IF EXISTS `user_account_47`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_47` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_47`
--

LOCK TABLES `user_account_47` WRITE;
/*!40000 ALTER TABLE `user_account_47` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_47` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_48`
--

DROP TABLE IF EXISTS `user_account_48`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_48` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_48`
--

LOCK TABLES `user_account_48` WRITE;
/*!40000 ALTER TABLE `user_account_48` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_48` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_49`
--

DROP TABLE IF EXISTS `user_account_49`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_49` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_49`
--

LOCK TABLES `user_account_49` WRITE;
/*!40000 ALTER TABLE `user_account_49` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_49` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_5`
--

DROP TABLE IF EXISTS `user_account_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_5` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_5`
--

LOCK TABLES `user_account_5` WRITE;
/*!40000 ALTER TABLE `user_account_5` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_50`
--

DROP TABLE IF EXISTS `user_account_50`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_50` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_50`
--

LOCK TABLES `user_account_50` WRITE;
/*!40000 ALTER TABLE `user_account_50` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_50` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_51`
--

DROP TABLE IF EXISTS `user_account_51`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_51` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_51`
--

LOCK TABLES `user_account_51` WRITE;
/*!40000 ALTER TABLE `user_account_51` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_51` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_52`
--

DROP TABLE IF EXISTS `user_account_52`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_52` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_52`
--

LOCK TABLES `user_account_52` WRITE;
/*!40000 ALTER TABLE `user_account_52` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_52` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_53`
--

DROP TABLE IF EXISTS `user_account_53`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_53` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_53`
--

LOCK TABLES `user_account_53` WRITE;
/*!40000 ALTER TABLE `user_account_53` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_53` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_54`
--

DROP TABLE IF EXISTS `user_account_54`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_54` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_54`
--

LOCK TABLES `user_account_54` WRITE;
/*!40000 ALTER TABLE `user_account_54` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_54` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_55`
--

DROP TABLE IF EXISTS `user_account_55`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_55` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_55`
--

LOCK TABLES `user_account_55` WRITE;
/*!40000 ALTER TABLE `user_account_55` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_55` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_56`
--

DROP TABLE IF EXISTS `user_account_56`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_56` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_56`
--

LOCK TABLES `user_account_56` WRITE;
/*!40000 ALTER TABLE `user_account_56` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_56` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_57`
--

DROP TABLE IF EXISTS `user_account_57`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_57` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_57`
--

LOCK TABLES `user_account_57` WRITE;
/*!40000 ALTER TABLE `user_account_57` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_57` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_58`
--

DROP TABLE IF EXISTS `user_account_58`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_58` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_58`
--

LOCK TABLES `user_account_58` WRITE;
/*!40000 ALTER TABLE `user_account_58` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_58` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_59`
--

DROP TABLE IF EXISTS `user_account_59`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_59` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_59`
--

LOCK TABLES `user_account_59` WRITE;
/*!40000 ALTER TABLE `user_account_59` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_59` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_6`
--

DROP TABLE IF EXISTS `user_account_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_6` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_6`
--

LOCK TABLES `user_account_6` WRITE;
/*!40000 ALTER TABLE `user_account_6` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_6` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_60`
--

DROP TABLE IF EXISTS `user_account_60`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_60` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_60`
--

LOCK TABLES `user_account_60` WRITE;
/*!40000 ALTER TABLE `user_account_60` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_60` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_61`
--

DROP TABLE IF EXISTS `user_account_61`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_61` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_61`
--

LOCK TABLES `user_account_61` WRITE;
/*!40000 ALTER TABLE `user_account_61` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_61` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_62`
--

DROP TABLE IF EXISTS `user_account_62`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_62` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_62`
--

LOCK TABLES `user_account_62` WRITE;
/*!40000 ALTER TABLE `user_account_62` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_62` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_63`
--

DROP TABLE IF EXISTS `user_account_63`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_63` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_63`
--

LOCK TABLES `user_account_63` WRITE;
/*!40000 ALTER TABLE `user_account_63` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_63` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_64`
--

DROP TABLE IF EXISTS `user_account_64`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_64` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_64`
--

LOCK TABLES `user_account_64` WRITE;
/*!40000 ALTER TABLE `user_account_64` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_64` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_65`
--

DROP TABLE IF EXISTS `user_account_65`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_65` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_65`
--

LOCK TABLES `user_account_65` WRITE;
/*!40000 ALTER TABLE `user_account_65` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_65` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_66`
--

DROP TABLE IF EXISTS `user_account_66`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_66` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_66`
--

LOCK TABLES `user_account_66` WRITE;
/*!40000 ALTER TABLE `user_account_66` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_66` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_67`
--

DROP TABLE IF EXISTS `user_account_67`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_67` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_67`
--

LOCK TABLES `user_account_67` WRITE;
/*!40000 ALTER TABLE `user_account_67` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_67` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_68`
--

DROP TABLE IF EXISTS `user_account_68`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_68` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_68`
--

LOCK TABLES `user_account_68` WRITE;
/*!40000 ALTER TABLE `user_account_68` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_68` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_69`
--

DROP TABLE IF EXISTS `user_account_69`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_69` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_69`
--

LOCK TABLES `user_account_69` WRITE;
/*!40000 ALTER TABLE `user_account_69` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_69` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_7`
--

DROP TABLE IF EXISTS `user_account_7`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_7` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_7`
--

LOCK TABLES `user_account_7` WRITE;
/*!40000 ALTER TABLE `user_account_7` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_7` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_70`
--

DROP TABLE IF EXISTS `user_account_70`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_70` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_70`
--

LOCK TABLES `user_account_70` WRITE;
/*!40000 ALTER TABLE `user_account_70` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_70` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_71`
--

DROP TABLE IF EXISTS `user_account_71`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_71` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_71`
--

LOCK TABLES `user_account_71` WRITE;
/*!40000 ALTER TABLE `user_account_71` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_71` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_72`
--

DROP TABLE IF EXISTS `user_account_72`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_72` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_72`
--

LOCK TABLES `user_account_72` WRITE;
/*!40000 ALTER TABLE `user_account_72` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_72` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_73`
--

DROP TABLE IF EXISTS `user_account_73`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_73` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_73`
--

LOCK TABLES `user_account_73` WRITE;
/*!40000 ALTER TABLE `user_account_73` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_73` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_74`
--

DROP TABLE IF EXISTS `user_account_74`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_74` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_74`
--

LOCK TABLES `user_account_74` WRITE;
/*!40000 ALTER TABLE `user_account_74` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_74` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_75`
--

DROP TABLE IF EXISTS `user_account_75`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_75` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_75`
--

LOCK TABLES `user_account_75` WRITE;
/*!40000 ALTER TABLE `user_account_75` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_75` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_76`
--

DROP TABLE IF EXISTS `user_account_76`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_76` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_76`
--

LOCK TABLES `user_account_76` WRITE;
/*!40000 ALTER TABLE `user_account_76` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_76` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_77`
--

DROP TABLE IF EXISTS `user_account_77`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_77` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_77`
--

LOCK TABLES `user_account_77` WRITE;
/*!40000 ALTER TABLE `user_account_77` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_77` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_78`
--

DROP TABLE IF EXISTS `user_account_78`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_78` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_78`
--

LOCK TABLES `user_account_78` WRITE;
/*!40000 ALTER TABLE `user_account_78` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_78` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_79`
--

DROP TABLE IF EXISTS `user_account_79`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_79` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_79`
--

LOCK TABLES `user_account_79` WRITE;
/*!40000 ALTER TABLE `user_account_79` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_79` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_8`
--

DROP TABLE IF EXISTS `user_account_8`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_8` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_8`
--

LOCK TABLES `user_account_8` WRITE;
/*!40000 ALTER TABLE `user_account_8` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_8` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_80`
--

DROP TABLE IF EXISTS `user_account_80`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_80` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_80`
--

LOCK TABLES `user_account_80` WRITE;
/*!40000 ALTER TABLE `user_account_80` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_80` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_81`
--

DROP TABLE IF EXISTS `user_account_81`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_81` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_81`
--

LOCK TABLES `user_account_81` WRITE;
/*!40000 ALTER TABLE `user_account_81` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_81` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_82`
--

DROP TABLE IF EXISTS `user_account_82`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_82` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_82`
--

LOCK TABLES `user_account_82` WRITE;
/*!40000 ALTER TABLE `user_account_82` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_82` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_83`
--

DROP TABLE IF EXISTS `user_account_83`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_83` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_83`
--

LOCK TABLES `user_account_83` WRITE;
/*!40000 ALTER TABLE `user_account_83` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_83` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_84`
--

DROP TABLE IF EXISTS `user_account_84`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_84` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_84`
--

LOCK TABLES `user_account_84` WRITE;
/*!40000 ALTER TABLE `user_account_84` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_84` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_85`
--

DROP TABLE IF EXISTS `user_account_85`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_85` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_85`
--

LOCK TABLES `user_account_85` WRITE;
/*!40000 ALTER TABLE `user_account_85` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_85` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_86`
--

DROP TABLE IF EXISTS `user_account_86`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_86` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_86`
--

LOCK TABLES `user_account_86` WRITE;
/*!40000 ALTER TABLE `user_account_86` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_86` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_87`
--

DROP TABLE IF EXISTS `user_account_87`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_87` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_87`
--

LOCK TABLES `user_account_87` WRITE;
/*!40000 ALTER TABLE `user_account_87` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_87` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_88`
--

DROP TABLE IF EXISTS `user_account_88`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_88` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_88`
--

LOCK TABLES `user_account_88` WRITE;
/*!40000 ALTER TABLE `user_account_88` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_88` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_89`
--

DROP TABLE IF EXISTS `user_account_89`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_89` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_89`
--

LOCK TABLES `user_account_89` WRITE;
/*!40000 ALTER TABLE `user_account_89` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_89` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_9`
--

DROP TABLE IF EXISTS `user_account_9`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_9` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_9`
--

LOCK TABLES `user_account_9` WRITE;
/*!40000 ALTER TABLE `user_account_9` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_9` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_90`
--

DROP TABLE IF EXISTS `user_account_90`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_90` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_90`
--

LOCK TABLES `user_account_90` WRITE;
/*!40000 ALTER TABLE `user_account_90` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_90` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_91`
--

DROP TABLE IF EXISTS `user_account_91`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_91` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_91`
--

LOCK TABLES `user_account_91` WRITE;
/*!40000 ALTER TABLE `user_account_91` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_91` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_92`
--

DROP TABLE IF EXISTS `user_account_92`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_92` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_92`
--

LOCK TABLES `user_account_92` WRITE;
/*!40000 ALTER TABLE `user_account_92` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_92` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_93`
--

DROP TABLE IF EXISTS `user_account_93`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_93` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_93`
--

LOCK TABLES `user_account_93` WRITE;
/*!40000 ALTER TABLE `user_account_93` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_93` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_94`
--

DROP TABLE IF EXISTS `user_account_94`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_94` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_94`
--

LOCK TABLES `user_account_94` WRITE;
/*!40000 ALTER TABLE `user_account_94` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_94` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_95`
--

DROP TABLE IF EXISTS `user_account_95`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_95` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_95`
--

LOCK TABLES `user_account_95` WRITE;
/*!40000 ALTER TABLE `user_account_95` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_95` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_96`
--

DROP TABLE IF EXISTS `user_account_96`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_96` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_96`
--

LOCK TABLES `user_account_96` WRITE;
/*!40000 ALTER TABLE `user_account_96` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_96` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_97`
--

DROP TABLE IF EXISTS `user_account_97`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_97` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_97`
--

LOCK TABLES `user_account_97` WRITE;
/*!40000 ALTER TABLE `user_account_97` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_97` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_98`
--

DROP TABLE IF EXISTS `user_account_98`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_98` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_98`
--

LOCK TABLES `user_account_98` WRITE;
/*!40000 ALTER TABLE `user_account_98` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_98` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_account_99`
--

DROP TABLE IF EXISTS `user_account_99`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_account_99` (
  `username` varchar(100) NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `type` int(4) NOT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `lastzindex` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_account_99`
--

LOCK TABLES `user_account_99` WRITE;
/*!40000 ALTER TABLE `user_account_99` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_account_99` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_0`
--

DROP TABLE IF EXISTS `userinfo_0`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_0` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_0`
--

LOCK TABLES `userinfo_0` WRITE;
/*!40000 ALTER TABLE `userinfo_0` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_0` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_1`
--

DROP TABLE IF EXISTS `userinfo_1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_1` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_1`
--

LOCK TABLES `userinfo_1` WRITE;
/*!40000 ALTER TABLE `userinfo_1` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_10`
--

DROP TABLE IF EXISTS `userinfo_10`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_10` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_10`
--

LOCK TABLES `userinfo_10` WRITE;
/*!40000 ALTER TABLE `userinfo_10` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_10` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_100`
--

DROP TABLE IF EXISTS `userinfo_100`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_100` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_100`
--

LOCK TABLES `userinfo_100` WRITE;
/*!40000 ALTER TABLE `userinfo_100` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_100` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_101`
--

DROP TABLE IF EXISTS `userinfo_101`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_101` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_101`
--

LOCK TABLES `userinfo_101` WRITE;
/*!40000 ALTER TABLE `userinfo_101` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_101` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_102`
--

DROP TABLE IF EXISTS `userinfo_102`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_102` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_102`
--

LOCK TABLES `userinfo_102` WRITE;
/*!40000 ALTER TABLE `userinfo_102` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_102` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_103`
--

DROP TABLE IF EXISTS `userinfo_103`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_103` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_103`
--

LOCK TABLES `userinfo_103` WRITE;
/*!40000 ALTER TABLE `userinfo_103` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_103` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_104`
--

DROP TABLE IF EXISTS `userinfo_104`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_104` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_104`
--

LOCK TABLES `userinfo_104` WRITE;
/*!40000 ALTER TABLE `userinfo_104` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_104` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_105`
--

DROP TABLE IF EXISTS `userinfo_105`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_105` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_105`
--

LOCK TABLES `userinfo_105` WRITE;
/*!40000 ALTER TABLE `userinfo_105` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_105` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_106`
--

DROP TABLE IF EXISTS `userinfo_106`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_106` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_106`
--

LOCK TABLES `userinfo_106` WRITE;
/*!40000 ALTER TABLE `userinfo_106` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_106` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_107`
--

DROP TABLE IF EXISTS `userinfo_107`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_107` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_107`
--

LOCK TABLES `userinfo_107` WRITE;
/*!40000 ALTER TABLE `userinfo_107` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_107` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_108`
--

DROP TABLE IF EXISTS `userinfo_108`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_108` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_108`
--

LOCK TABLES `userinfo_108` WRITE;
/*!40000 ALTER TABLE `userinfo_108` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_108` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_109`
--

DROP TABLE IF EXISTS `userinfo_109`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_109` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_109`
--

LOCK TABLES `userinfo_109` WRITE;
/*!40000 ALTER TABLE `userinfo_109` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_109` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_11`
--

DROP TABLE IF EXISTS `userinfo_11`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_11` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_11`
--

LOCK TABLES `userinfo_11` WRITE;
/*!40000 ALTER TABLE `userinfo_11` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_11` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_110`
--

DROP TABLE IF EXISTS `userinfo_110`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_110` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_110`
--

LOCK TABLES `userinfo_110` WRITE;
/*!40000 ALTER TABLE `userinfo_110` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_110` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_111`
--

DROP TABLE IF EXISTS `userinfo_111`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_111` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_111`
--

LOCK TABLES `userinfo_111` WRITE;
/*!40000 ALTER TABLE `userinfo_111` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_111` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_112`
--

DROP TABLE IF EXISTS `userinfo_112`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_112` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_112`
--

LOCK TABLES `userinfo_112` WRITE;
/*!40000 ALTER TABLE `userinfo_112` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_112` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_113`
--

DROP TABLE IF EXISTS `userinfo_113`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_113` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_113`
--

LOCK TABLES `userinfo_113` WRITE;
/*!40000 ALTER TABLE `userinfo_113` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_113` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_114`
--

DROP TABLE IF EXISTS `userinfo_114`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_114` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_114`
--

LOCK TABLES `userinfo_114` WRITE;
/*!40000 ALTER TABLE `userinfo_114` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_114` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_115`
--

DROP TABLE IF EXISTS `userinfo_115`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_115` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_115`
--

LOCK TABLES `userinfo_115` WRITE;
/*!40000 ALTER TABLE `userinfo_115` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_115` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_116`
--

DROP TABLE IF EXISTS `userinfo_116`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_116` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_116`
--

LOCK TABLES `userinfo_116` WRITE;
/*!40000 ALTER TABLE `userinfo_116` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_116` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_117`
--

DROP TABLE IF EXISTS `userinfo_117`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_117` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_117`
--

LOCK TABLES `userinfo_117` WRITE;
/*!40000 ALTER TABLE `userinfo_117` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_117` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_118`
--

DROP TABLE IF EXISTS `userinfo_118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_118` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_118`
--

LOCK TABLES `userinfo_118` WRITE;
/*!40000 ALTER TABLE `userinfo_118` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_118` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_119`
--

DROP TABLE IF EXISTS `userinfo_119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_119` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_119`
--

LOCK TABLES `userinfo_119` WRITE;
/*!40000 ALTER TABLE `userinfo_119` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_119` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_12`
--

DROP TABLE IF EXISTS `userinfo_12`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_12` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_12`
--

LOCK TABLES `userinfo_12` WRITE;
/*!40000 ALTER TABLE `userinfo_12` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_12` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_120`
--

DROP TABLE IF EXISTS `userinfo_120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_120` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_120`
--

LOCK TABLES `userinfo_120` WRITE;
/*!40000 ALTER TABLE `userinfo_120` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_120` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_121`
--

DROP TABLE IF EXISTS `userinfo_121`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_121` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_121`
--

LOCK TABLES `userinfo_121` WRITE;
/*!40000 ALTER TABLE `userinfo_121` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_121` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_122`
--

DROP TABLE IF EXISTS `userinfo_122`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_122` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_122`
--

LOCK TABLES `userinfo_122` WRITE;
/*!40000 ALTER TABLE `userinfo_122` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_122` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_123`
--

DROP TABLE IF EXISTS `userinfo_123`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_123` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_123`
--

LOCK TABLES `userinfo_123` WRITE;
/*!40000 ALTER TABLE `userinfo_123` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_123` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_124`
--

DROP TABLE IF EXISTS `userinfo_124`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_124` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_124`
--

LOCK TABLES `userinfo_124` WRITE;
/*!40000 ALTER TABLE `userinfo_124` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_124` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_125`
--

DROP TABLE IF EXISTS `userinfo_125`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_125` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_125`
--

LOCK TABLES `userinfo_125` WRITE;
/*!40000 ALTER TABLE `userinfo_125` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_125` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_126`
--

DROP TABLE IF EXISTS `userinfo_126`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_126` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_126`
--

LOCK TABLES `userinfo_126` WRITE;
/*!40000 ALTER TABLE `userinfo_126` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_126` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_127`
--

DROP TABLE IF EXISTS `userinfo_127`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_127` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_127`
--

LOCK TABLES `userinfo_127` WRITE;
/*!40000 ALTER TABLE `userinfo_127` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_127` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_128`
--

DROP TABLE IF EXISTS `userinfo_128`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_128` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_128`
--

LOCK TABLES `userinfo_128` WRITE;
/*!40000 ALTER TABLE `userinfo_128` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_128` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_129`
--

DROP TABLE IF EXISTS `userinfo_129`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_129` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_129`
--

LOCK TABLES `userinfo_129` WRITE;
/*!40000 ALTER TABLE `userinfo_129` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_129` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_13`
--

DROP TABLE IF EXISTS `userinfo_13`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_13` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_13`
--

LOCK TABLES `userinfo_13` WRITE;
/*!40000 ALTER TABLE `userinfo_13` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_13` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_130`
--

DROP TABLE IF EXISTS `userinfo_130`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_130` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_130`
--

LOCK TABLES `userinfo_130` WRITE;
/*!40000 ALTER TABLE `userinfo_130` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_130` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_131`
--

DROP TABLE IF EXISTS `userinfo_131`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_131` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_131`
--

LOCK TABLES `userinfo_131` WRITE;
/*!40000 ALTER TABLE `userinfo_131` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_131` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_132`
--

DROP TABLE IF EXISTS `userinfo_132`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_132` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_132`
--

LOCK TABLES `userinfo_132` WRITE;
/*!40000 ALTER TABLE `userinfo_132` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_132` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_133`
--

DROP TABLE IF EXISTS `userinfo_133`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_133` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_133`
--

LOCK TABLES `userinfo_133` WRITE;
/*!40000 ALTER TABLE `userinfo_133` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_133` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_134`
--

DROP TABLE IF EXISTS `userinfo_134`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_134` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_134`
--

LOCK TABLES `userinfo_134` WRITE;
/*!40000 ALTER TABLE `userinfo_134` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_134` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_135`
--

DROP TABLE IF EXISTS `userinfo_135`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_135` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_135`
--

LOCK TABLES `userinfo_135` WRITE;
/*!40000 ALTER TABLE `userinfo_135` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_135` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_136`
--

DROP TABLE IF EXISTS `userinfo_136`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_136` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_136`
--

LOCK TABLES `userinfo_136` WRITE;
/*!40000 ALTER TABLE `userinfo_136` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_136` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_137`
--

DROP TABLE IF EXISTS `userinfo_137`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_137` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_137`
--

LOCK TABLES `userinfo_137` WRITE;
/*!40000 ALTER TABLE `userinfo_137` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_137` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_138`
--

DROP TABLE IF EXISTS `userinfo_138`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_138` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_138`
--

LOCK TABLES `userinfo_138` WRITE;
/*!40000 ALTER TABLE `userinfo_138` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_138` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_139`
--

DROP TABLE IF EXISTS `userinfo_139`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_139` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_139`
--

LOCK TABLES `userinfo_139` WRITE;
/*!40000 ALTER TABLE `userinfo_139` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_139` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_14`
--

DROP TABLE IF EXISTS `userinfo_14`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_14` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_14`
--

LOCK TABLES `userinfo_14` WRITE;
/*!40000 ALTER TABLE `userinfo_14` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_14` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_140`
--

DROP TABLE IF EXISTS `userinfo_140`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_140` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_140`
--

LOCK TABLES `userinfo_140` WRITE;
/*!40000 ALTER TABLE `userinfo_140` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_140` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_141`
--

DROP TABLE IF EXISTS `userinfo_141`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_141` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_141`
--

LOCK TABLES `userinfo_141` WRITE;
/*!40000 ALTER TABLE `userinfo_141` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_141` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_142`
--

DROP TABLE IF EXISTS `userinfo_142`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_142` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_142`
--

LOCK TABLES `userinfo_142` WRITE;
/*!40000 ALTER TABLE `userinfo_142` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_142` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_143`
--

DROP TABLE IF EXISTS `userinfo_143`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_143` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_143`
--

LOCK TABLES `userinfo_143` WRITE;
/*!40000 ALTER TABLE `userinfo_143` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_143` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_144`
--

DROP TABLE IF EXISTS `userinfo_144`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_144` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_144`
--

LOCK TABLES `userinfo_144` WRITE;
/*!40000 ALTER TABLE `userinfo_144` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_144` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_145`
--

DROP TABLE IF EXISTS `userinfo_145`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_145` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_145`
--

LOCK TABLES `userinfo_145` WRITE;
/*!40000 ALTER TABLE `userinfo_145` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_145` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_146`
--

DROP TABLE IF EXISTS `userinfo_146`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_146` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_146`
--

LOCK TABLES `userinfo_146` WRITE;
/*!40000 ALTER TABLE `userinfo_146` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_146` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_147`
--

DROP TABLE IF EXISTS `userinfo_147`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_147` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_147`
--

LOCK TABLES `userinfo_147` WRITE;
/*!40000 ALTER TABLE `userinfo_147` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_147` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_148`
--

DROP TABLE IF EXISTS `userinfo_148`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_148` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_148`
--

LOCK TABLES `userinfo_148` WRITE;
/*!40000 ALTER TABLE `userinfo_148` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_148` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_149`
--

DROP TABLE IF EXISTS `userinfo_149`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_149` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_149`
--

LOCK TABLES `userinfo_149` WRITE;
/*!40000 ALTER TABLE `userinfo_149` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_149` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_15`
--

DROP TABLE IF EXISTS `userinfo_15`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_15` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_15`
--

LOCK TABLES `userinfo_15` WRITE;
/*!40000 ALTER TABLE `userinfo_15` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_15` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_150`
--

DROP TABLE IF EXISTS `userinfo_150`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_150` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_150`
--

LOCK TABLES `userinfo_150` WRITE;
/*!40000 ALTER TABLE `userinfo_150` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_150` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_151`
--

DROP TABLE IF EXISTS `userinfo_151`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_151` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_151`
--

LOCK TABLES `userinfo_151` WRITE;
/*!40000 ALTER TABLE `userinfo_151` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_151` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_152`
--

DROP TABLE IF EXISTS `userinfo_152`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_152` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_152`
--

LOCK TABLES `userinfo_152` WRITE;
/*!40000 ALTER TABLE `userinfo_152` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_152` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_153`
--

DROP TABLE IF EXISTS `userinfo_153`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_153` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_153`
--

LOCK TABLES `userinfo_153` WRITE;
/*!40000 ALTER TABLE `userinfo_153` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_153` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_154`
--

DROP TABLE IF EXISTS `userinfo_154`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_154` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_154`
--

LOCK TABLES `userinfo_154` WRITE;
/*!40000 ALTER TABLE `userinfo_154` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_154` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_155`
--

DROP TABLE IF EXISTS `userinfo_155`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_155` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_155`
--

LOCK TABLES `userinfo_155` WRITE;
/*!40000 ALTER TABLE `userinfo_155` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_155` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_156`
--

DROP TABLE IF EXISTS `userinfo_156`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_156` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_156`
--

LOCK TABLES `userinfo_156` WRITE;
/*!40000 ALTER TABLE `userinfo_156` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_156` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_157`
--

DROP TABLE IF EXISTS `userinfo_157`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_157` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_157`
--

LOCK TABLES `userinfo_157` WRITE;
/*!40000 ALTER TABLE `userinfo_157` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_157` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_158`
--

DROP TABLE IF EXISTS `userinfo_158`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_158` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_158`
--

LOCK TABLES `userinfo_158` WRITE;
/*!40000 ALTER TABLE `userinfo_158` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_158` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_159`
--

DROP TABLE IF EXISTS `userinfo_159`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_159` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_159`
--

LOCK TABLES `userinfo_159` WRITE;
/*!40000 ALTER TABLE `userinfo_159` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_159` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_16`
--

DROP TABLE IF EXISTS `userinfo_16`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_16` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_16`
--

LOCK TABLES `userinfo_16` WRITE;
/*!40000 ALTER TABLE `userinfo_16` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_16` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_160`
--

DROP TABLE IF EXISTS `userinfo_160`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_160` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_160`
--

LOCK TABLES `userinfo_160` WRITE;
/*!40000 ALTER TABLE `userinfo_160` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_160` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_161`
--

DROP TABLE IF EXISTS `userinfo_161`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_161` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_161`
--

LOCK TABLES `userinfo_161` WRITE;
/*!40000 ALTER TABLE `userinfo_161` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_161` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_162`
--

DROP TABLE IF EXISTS `userinfo_162`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_162` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_162`
--

LOCK TABLES `userinfo_162` WRITE;
/*!40000 ALTER TABLE `userinfo_162` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_162` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_163`
--

DROP TABLE IF EXISTS `userinfo_163`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_163` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_163`
--

LOCK TABLES `userinfo_163` WRITE;
/*!40000 ALTER TABLE `userinfo_163` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_163` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_164`
--

DROP TABLE IF EXISTS `userinfo_164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_164` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_164`
--

LOCK TABLES `userinfo_164` WRITE;
/*!40000 ALTER TABLE `userinfo_164` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_164` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_165`
--

DROP TABLE IF EXISTS `userinfo_165`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_165` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_165`
--

LOCK TABLES `userinfo_165` WRITE;
/*!40000 ALTER TABLE `userinfo_165` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_165` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_166`
--

DROP TABLE IF EXISTS `userinfo_166`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_166` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_166`
--

LOCK TABLES `userinfo_166` WRITE;
/*!40000 ALTER TABLE `userinfo_166` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_166` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_167`
--

DROP TABLE IF EXISTS `userinfo_167`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_167` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_167`
--

LOCK TABLES `userinfo_167` WRITE;
/*!40000 ALTER TABLE `userinfo_167` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_167` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_168`
--

DROP TABLE IF EXISTS `userinfo_168`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_168` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_168`
--

LOCK TABLES `userinfo_168` WRITE;
/*!40000 ALTER TABLE `userinfo_168` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_168` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_169`
--

DROP TABLE IF EXISTS `userinfo_169`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_169` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_169`
--

LOCK TABLES `userinfo_169` WRITE;
/*!40000 ALTER TABLE `userinfo_169` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_169` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_17`
--

DROP TABLE IF EXISTS `userinfo_17`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_17` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_17`
--

LOCK TABLES `userinfo_17` WRITE;
/*!40000 ALTER TABLE `userinfo_17` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_17` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_170`
--

DROP TABLE IF EXISTS `userinfo_170`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_170` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_170`
--

LOCK TABLES `userinfo_170` WRITE;
/*!40000 ALTER TABLE `userinfo_170` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_170` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_171`
--

DROP TABLE IF EXISTS `userinfo_171`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_171` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_171`
--

LOCK TABLES `userinfo_171` WRITE;
/*!40000 ALTER TABLE `userinfo_171` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_171` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_172`
--

DROP TABLE IF EXISTS `userinfo_172`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_172` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_172`
--

LOCK TABLES `userinfo_172` WRITE;
/*!40000 ALTER TABLE `userinfo_172` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_172` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_173`
--

DROP TABLE IF EXISTS `userinfo_173`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_173` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_173`
--

LOCK TABLES `userinfo_173` WRITE;
/*!40000 ALTER TABLE `userinfo_173` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_173` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_174`
--

DROP TABLE IF EXISTS `userinfo_174`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_174` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_174`
--

LOCK TABLES `userinfo_174` WRITE;
/*!40000 ALTER TABLE `userinfo_174` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_174` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_175`
--

DROP TABLE IF EXISTS `userinfo_175`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_175` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_175`
--

LOCK TABLES `userinfo_175` WRITE;
/*!40000 ALTER TABLE `userinfo_175` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_175` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_176`
--

DROP TABLE IF EXISTS `userinfo_176`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_176` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_176`
--

LOCK TABLES `userinfo_176` WRITE;
/*!40000 ALTER TABLE `userinfo_176` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_176` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_177`
--

DROP TABLE IF EXISTS `userinfo_177`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_177` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_177`
--

LOCK TABLES `userinfo_177` WRITE;
/*!40000 ALTER TABLE `userinfo_177` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_177` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_178`
--

DROP TABLE IF EXISTS `userinfo_178`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_178` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_178`
--

LOCK TABLES `userinfo_178` WRITE;
/*!40000 ALTER TABLE `userinfo_178` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_178` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_179`
--

DROP TABLE IF EXISTS `userinfo_179`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_179` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_179`
--

LOCK TABLES `userinfo_179` WRITE;
/*!40000 ALTER TABLE `userinfo_179` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_179` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_18`
--

DROP TABLE IF EXISTS `userinfo_18`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_18` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_18`
--

LOCK TABLES `userinfo_18` WRITE;
/*!40000 ALTER TABLE `userinfo_18` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_18` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_180`
--

DROP TABLE IF EXISTS `userinfo_180`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_180` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_180`
--

LOCK TABLES `userinfo_180` WRITE;
/*!40000 ALTER TABLE `userinfo_180` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_180` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_181`
--

DROP TABLE IF EXISTS `userinfo_181`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_181` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_181`
--

LOCK TABLES `userinfo_181` WRITE;
/*!40000 ALTER TABLE `userinfo_181` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_181` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_182`
--

DROP TABLE IF EXISTS `userinfo_182`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_182` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_182`
--

LOCK TABLES `userinfo_182` WRITE;
/*!40000 ALTER TABLE `userinfo_182` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_182` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_183`
--

DROP TABLE IF EXISTS `userinfo_183`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_183` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_183`
--

LOCK TABLES `userinfo_183` WRITE;
/*!40000 ALTER TABLE `userinfo_183` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_183` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_184`
--

DROP TABLE IF EXISTS `userinfo_184`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_184` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_184`
--

LOCK TABLES `userinfo_184` WRITE;
/*!40000 ALTER TABLE `userinfo_184` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_184` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_185`
--

DROP TABLE IF EXISTS `userinfo_185`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_185` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_185`
--

LOCK TABLES `userinfo_185` WRITE;
/*!40000 ALTER TABLE `userinfo_185` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_185` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_186`
--

DROP TABLE IF EXISTS `userinfo_186`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_186` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_186`
--

LOCK TABLES `userinfo_186` WRITE;
/*!40000 ALTER TABLE `userinfo_186` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_186` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_187`
--

DROP TABLE IF EXISTS `userinfo_187`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_187` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_187`
--

LOCK TABLES `userinfo_187` WRITE;
/*!40000 ALTER TABLE `userinfo_187` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_187` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_188`
--

DROP TABLE IF EXISTS `userinfo_188`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_188` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_188`
--

LOCK TABLES `userinfo_188` WRITE;
/*!40000 ALTER TABLE `userinfo_188` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_188` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_189`
--

DROP TABLE IF EXISTS `userinfo_189`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_189` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_189`
--

LOCK TABLES `userinfo_189` WRITE;
/*!40000 ALTER TABLE `userinfo_189` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_189` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_19`
--

DROP TABLE IF EXISTS `userinfo_19`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_19` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_19`
--

LOCK TABLES `userinfo_19` WRITE;
/*!40000 ALTER TABLE `userinfo_19` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_19` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_190`
--

DROP TABLE IF EXISTS `userinfo_190`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_190` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_190`
--

LOCK TABLES `userinfo_190` WRITE;
/*!40000 ALTER TABLE `userinfo_190` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_190` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_191`
--

DROP TABLE IF EXISTS `userinfo_191`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_191` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_191`
--

LOCK TABLES `userinfo_191` WRITE;
/*!40000 ALTER TABLE `userinfo_191` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_191` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_192`
--

DROP TABLE IF EXISTS `userinfo_192`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_192` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_192`
--

LOCK TABLES `userinfo_192` WRITE;
/*!40000 ALTER TABLE `userinfo_192` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_192` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_193`
--

DROP TABLE IF EXISTS `userinfo_193`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_193` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_193`
--

LOCK TABLES `userinfo_193` WRITE;
/*!40000 ALTER TABLE `userinfo_193` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_193` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_194`
--

DROP TABLE IF EXISTS `userinfo_194`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_194` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_194`
--

LOCK TABLES `userinfo_194` WRITE;
/*!40000 ALTER TABLE `userinfo_194` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_194` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_195`
--

DROP TABLE IF EXISTS `userinfo_195`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_195` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_195`
--

LOCK TABLES `userinfo_195` WRITE;
/*!40000 ALTER TABLE `userinfo_195` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_195` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_196`
--

DROP TABLE IF EXISTS `userinfo_196`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_196` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_196`
--

LOCK TABLES `userinfo_196` WRITE;
/*!40000 ALTER TABLE `userinfo_196` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_196` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_197`
--

DROP TABLE IF EXISTS `userinfo_197`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_197` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_197`
--

LOCK TABLES `userinfo_197` WRITE;
/*!40000 ALTER TABLE `userinfo_197` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_197` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_198`
--

DROP TABLE IF EXISTS `userinfo_198`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_198` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_198`
--

LOCK TABLES `userinfo_198` WRITE;
/*!40000 ALTER TABLE `userinfo_198` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_198` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_199`
--

DROP TABLE IF EXISTS `userinfo_199`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_199` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_199`
--

LOCK TABLES `userinfo_199` WRITE;
/*!40000 ALTER TABLE `userinfo_199` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_199` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_2`
--

DROP TABLE IF EXISTS `userinfo_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_2` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_2`
--

LOCK TABLES `userinfo_2` WRITE;
/*!40000 ALTER TABLE `userinfo_2` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_20`
--

DROP TABLE IF EXISTS `userinfo_20`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_20` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_20`
--

LOCK TABLES `userinfo_20` WRITE;
/*!40000 ALTER TABLE `userinfo_20` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_20` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_200`
--

DROP TABLE IF EXISTS `userinfo_200`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_200` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_200`
--

LOCK TABLES `userinfo_200` WRITE;
/*!40000 ALTER TABLE `userinfo_200` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_200` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_201`
--

DROP TABLE IF EXISTS `userinfo_201`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_201` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_201`
--

LOCK TABLES `userinfo_201` WRITE;
/*!40000 ALTER TABLE `userinfo_201` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_201` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_202`
--

DROP TABLE IF EXISTS `userinfo_202`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_202` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_202`
--

LOCK TABLES `userinfo_202` WRITE;
/*!40000 ALTER TABLE `userinfo_202` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_202` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_203`
--

DROP TABLE IF EXISTS `userinfo_203`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_203` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_203`
--

LOCK TABLES `userinfo_203` WRITE;
/*!40000 ALTER TABLE `userinfo_203` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_203` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_204`
--

DROP TABLE IF EXISTS `userinfo_204`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_204` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_204`
--

LOCK TABLES `userinfo_204` WRITE;
/*!40000 ALTER TABLE `userinfo_204` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_204` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_205`
--

DROP TABLE IF EXISTS `userinfo_205`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_205` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_205`
--

LOCK TABLES `userinfo_205` WRITE;
/*!40000 ALTER TABLE `userinfo_205` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_205` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_206`
--

DROP TABLE IF EXISTS `userinfo_206`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_206` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_206`
--

LOCK TABLES `userinfo_206` WRITE;
/*!40000 ALTER TABLE `userinfo_206` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_206` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_207`
--

DROP TABLE IF EXISTS `userinfo_207`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_207` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_207`
--

LOCK TABLES `userinfo_207` WRITE;
/*!40000 ALTER TABLE `userinfo_207` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_207` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_208`
--

DROP TABLE IF EXISTS `userinfo_208`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_208` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_208`
--

LOCK TABLES `userinfo_208` WRITE;
/*!40000 ALTER TABLE `userinfo_208` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_208` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_209`
--

DROP TABLE IF EXISTS `userinfo_209`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_209` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_209`
--

LOCK TABLES `userinfo_209` WRITE;
/*!40000 ALTER TABLE `userinfo_209` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_209` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_21`
--

DROP TABLE IF EXISTS `userinfo_21`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_21` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_21`
--

LOCK TABLES `userinfo_21` WRITE;
/*!40000 ALTER TABLE `userinfo_21` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_21` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_210`
--

DROP TABLE IF EXISTS `userinfo_210`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_210` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_210`
--

LOCK TABLES `userinfo_210` WRITE;
/*!40000 ALTER TABLE `userinfo_210` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_210` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_211`
--

DROP TABLE IF EXISTS `userinfo_211`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_211` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_211`
--

LOCK TABLES `userinfo_211` WRITE;
/*!40000 ALTER TABLE `userinfo_211` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_211` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_212`
--

DROP TABLE IF EXISTS `userinfo_212`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_212` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_212`
--

LOCK TABLES `userinfo_212` WRITE;
/*!40000 ALTER TABLE `userinfo_212` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_212` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_213`
--

DROP TABLE IF EXISTS `userinfo_213`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_213` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_213`
--

LOCK TABLES `userinfo_213` WRITE;
/*!40000 ALTER TABLE `userinfo_213` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_213` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_214`
--

DROP TABLE IF EXISTS `userinfo_214`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_214` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_214`
--

LOCK TABLES `userinfo_214` WRITE;
/*!40000 ALTER TABLE `userinfo_214` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_214` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_215`
--

DROP TABLE IF EXISTS `userinfo_215`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_215` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_215`
--

LOCK TABLES `userinfo_215` WRITE;
/*!40000 ALTER TABLE `userinfo_215` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_215` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_216`
--

DROP TABLE IF EXISTS `userinfo_216`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_216` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_216`
--

LOCK TABLES `userinfo_216` WRITE;
/*!40000 ALTER TABLE `userinfo_216` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_216` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_217`
--

DROP TABLE IF EXISTS `userinfo_217`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_217` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_217`
--

LOCK TABLES `userinfo_217` WRITE;
/*!40000 ALTER TABLE `userinfo_217` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_217` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_218`
--

DROP TABLE IF EXISTS `userinfo_218`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_218` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_218`
--

LOCK TABLES `userinfo_218` WRITE;
/*!40000 ALTER TABLE `userinfo_218` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_218` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_219`
--

DROP TABLE IF EXISTS `userinfo_219`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_219` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_219`
--

LOCK TABLES `userinfo_219` WRITE;
/*!40000 ALTER TABLE `userinfo_219` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_219` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_22`
--

DROP TABLE IF EXISTS `userinfo_22`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_22` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_22`
--

LOCK TABLES `userinfo_22` WRITE;
/*!40000 ALTER TABLE `userinfo_22` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_22` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_220`
--

DROP TABLE IF EXISTS `userinfo_220`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_220` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_220`
--

LOCK TABLES `userinfo_220` WRITE;
/*!40000 ALTER TABLE `userinfo_220` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_220` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_221`
--

DROP TABLE IF EXISTS `userinfo_221`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_221` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_221`
--

LOCK TABLES `userinfo_221` WRITE;
/*!40000 ALTER TABLE `userinfo_221` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_221` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_222`
--

DROP TABLE IF EXISTS `userinfo_222`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_222` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_222`
--

LOCK TABLES `userinfo_222` WRITE;
/*!40000 ALTER TABLE `userinfo_222` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_222` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_223`
--

DROP TABLE IF EXISTS `userinfo_223`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_223` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_223`
--

LOCK TABLES `userinfo_223` WRITE;
/*!40000 ALTER TABLE `userinfo_223` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_223` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_224`
--

DROP TABLE IF EXISTS `userinfo_224`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_224` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_224`
--

LOCK TABLES `userinfo_224` WRITE;
/*!40000 ALTER TABLE `userinfo_224` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_224` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_225`
--

DROP TABLE IF EXISTS `userinfo_225`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_225` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_225`
--

LOCK TABLES `userinfo_225` WRITE;
/*!40000 ALTER TABLE `userinfo_225` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_225` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_226`
--

DROP TABLE IF EXISTS `userinfo_226`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_226` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_226`
--

LOCK TABLES `userinfo_226` WRITE;
/*!40000 ALTER TABLE `userinfo_226` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_226` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_227`
--

DROP TABLE IF EXISTS `userinfo_227`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_227` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_227`
--

LOCK TABLES `userinfo_227` WRITE;
/*!40000 ALTER TABLE `userinfo_227` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_227` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_228`
--

DROP TABLE IF EXISTS `userinfo_228`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_228` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_228`
--

LOCK TABLES `userinfo_228` WRITE;
/*!40000 ALTER TABLE `userinfo_228` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_228` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_229`
--

DROP TABLE IF EXISTS `userinfo_229`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_229` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_229`
--

LOCK TABLES `userinfo_229` WRITE;
/*!40000 ALTER TABLE `userinfo_229` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_229` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_23`
--

DROP TABLE IF EXISTS `userinfo_23`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_23` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_23`
--

LOCK TABLES `userinfo_23` WRITE;
/*!40000 ALTER TABLE `userinfo_23` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_23` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_230`
--

DROP TABLE IF EXISTS `userinfo_230`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_230` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_230`
--

LOCK TABLES `userinfo_230` WRITE;
/*!40000 ALTER TABLE `userinfo_230` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_230` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_231`
--

DROP TABLE IF EXISTS `userinfo_231`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_231` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_231`
--

LOCK TABLES `userinfo_231` WRITE;
/*!40000 ALTER TABLE `userinfo_231` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_231` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_232`
--

DROP TABLE IF EXISTS `userinfo_232`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_232` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_232`
--

LOCK TABLES `userinfo_232` WRITE;
/*!40000 ALTER TABLE `userinfo_232` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_232` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_233`
--

DROP TABLE IF EXISTS `userinfo_233`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_233` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_233`
--

LOCK TABLES `userinfo_233` WRITE;
/*!40000 ALTER TABLE `userinfo_233` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_233` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_234`
--

DROP TABLE IF EXISTS `userinfo_234`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_234` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_234`
--

LOCK TABLES `userinfo_234` WRITE;
/*!40000 ALTER TABLE `userinfo_234` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_234` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_235`
--

DROP TABLE IF EXISTS `userinfo_235`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_235` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_235`
--

LOCK TABLES `userinfo_235` WRITE;
/*!40000 ALTER TABLE `userinfo_235` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_235` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_236`
--

DROP TABLE IF EXISTS `userinfo_236`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_236` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_236`
--

LOCK TABLES `userinfo_236` WRITE;
/*!40000 ALTER TABLE `userinfo_236` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_236` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_237`
--

DROP TABLE IF EXISTS `userinfo_237`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_237` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_237`
--

LOCK TABLES `userinfo_237` WRITE;
/*!40000 ALTER TABLE `userinfo_237` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_237` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_238`
--

DROP TABLE IF EXISTS `userinfo_238`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_238` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_238`
--

LOCK TABLES `userinfo_238` WRITE;
/*!40000 ALTER TABLE `userinfo_238` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_238` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_239`
--

DROP TABLE IF EXISTS `userinfo_239`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_239` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_239`
--

LOCK TABLES `userinfo_239` WRITE;
/*!40000 ALTER TABLE `userinfo_239` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_239` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_24`
--

DROP TABLE IF EXISTS `userinfo_24`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_24` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_24`
--

LOCK TABLES `userinfo_24` WRITE;
/*!40000 ALTER TABLE `userinfo_24` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_24` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_240`
--

DROP TABLE IF EXISTS `userinfo_240`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_240` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_240`
--

LOCK TABLES `userinfo_240` WRITE;
/*!40000 ALTER TABLE `userinfo_240` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_240` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_241`
--

DROP TABLE IF EXISTS `userinfo_241`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_241` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_241`
--

LOCK TABLES `userinfo_241` WRITE;
/*!40000 ALTER TABLE `userinfo_241` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_241` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_242`
--

DROP TABLE IF EXISTS `userinfo_242`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_242` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_242`
--

LOCK TABLES `userinfo_242` WRITE;
/*!40000 ALTER TABLE `userinfo_242` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_242` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_243`
--

DROP TABLE IF EXISTS `userinfo_243`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_243` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_243`
--

LOCK TABLES `userinfo_243` WRITE;
/*!40000 ALTER TABLE `userinfo_243` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_243` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_244`
--

DROP TABLE IF EXISTS `userinfo_244`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_244` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_244`
--

LOCK TABLES `userinfo_244` WRITE;
/*!40000 ALTER TABLE `userinfo_244` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_244` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_245`
--

DROP TABLE IF EXISTS `userinfo_245`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_245` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_245`
--

LOCK TABLES `userinfo_245` WRITE;
/*!40000 ALTER TABLE `userinfo_245` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_245` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_246`
--

DROP TABLE IF EXISTS `userinfo_246`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_246` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_246`
--

LOCK TABLES `userinfo_246` WRITE;
/*!40000 ALTER TABLE `userinfo_246` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_246` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_247`
--

DROP TABLE IF EXISTS `userinfo_247`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_247` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_247`
--

LOCK TABLES `userinfo_247` WRITE;
/*!40000 ALTER TABLE `userinfo_247` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_247` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_248`
--

DROP TABLE IF EXISTS `userinfo_248`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_248` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_248`
--

LOCK TABLES `userinfo_248` WRITE;
/*!40000 ALTER TABLE `userinfo_248` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_248` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_249`
--

DROP TABLE IF EXISTS `userinfo_249`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_249` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_249`
--

LOCK TABLES `userinfo_249` WRITE;
/*!40000 ALTER TABLE `userinfo_249` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_249` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_25`
--

DROP TABLE IF EXISTS `userinfo_25`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_25` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_25`
--

LOCK TABLES `userinfo_25` WRITE;
/*!40000 ALTER TABLE `userinfo_25` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_25` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_250`
--

DROP TABLE IF EXISTS `userinfo_250`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_250` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_250`
--

LOCK TABLES `userinfo_250` WRITE;
/*!40000 ALTER TABLE `userinfo_250` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_250` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_251`
--

DROP TABLE IF EXISTS `userinfo_251`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_251` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_251`
--

LOCK TABLES `userinfo_251` WRITE;
/*!40000 ALTER TABLE `userinfo_251` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_251` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_252`
--

DROP TABLE IF EXISTS `userinfo_252`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_252` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_252`
--

LOCK TABLES `userinfo_252` WRITE;
/*!40000 ALTER TABLE `userinfo_252` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_252` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_253`
--

DROP TABLE IF EXISTS `userinfo_253`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_253` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_253`
--

LOCK TABLES `userinfo_253` WRITE;
/*!40000 ALTER TABLE `userinfo_253` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_253` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_254`
--

DROP TABLE IF EXISTS `userinfo_254`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_254` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_254`
--

LOCK TABLES `userinfo_254` WRITE;
/*!40000 ALTER TABLE `userinfo_254` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_254` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_255`
--

DROP TABLE IF EXISTS `userinfo_255`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_255` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_255`
--

LOCK TABLES `userinfo_255` WRITE;
/*!40000 ALTER TABLE `userinfo_255` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_255` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_256`
--

DROP TABLE IF EXISTS `userinfo_256`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_256` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_256`
--

LOCK TABLES `userinfo_256` WRITE;
/*!40000 ALTER TABLE `userinfo_256` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_256` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_257`
--

DROP TABLE IF EXISTS `userinfo_257`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_257` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_257`
--

LOCK TABLES `userinfo_257` WRITE;
/*!40000 ALTER TABLE `userinfo_257` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_257` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_258`
--

DROP TABLE IF EXISTS `userinfo_258`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_258` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_258`
--

LOCK TABLES `userinfo_258` WRITE;
/*!40000 ALTER TABLE `userinfo_258` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_258` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_259`
--

DROP TABLE IF EXISTS `userinfo_259`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_259` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_259`
--

LOCK TABLES `userinfo_259` WRITE;
/*!40000 ALTER TABLE `userinfo_259` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_259` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_26`
--

DROP TABLE IF EXISTS `userinfo_26`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_26` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_26`
--

LOCK TABLES `userinfo_26` WRITE;
/*!40000 ALTER TABLE `userinfo_26` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_26` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_260`
--

DROP TABLE IF EXISTS `userinfo_260`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_260` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_260`
--

LOCK TABLES `userinfo_260` WRITE;
/*!40000 ALTER TABLE `userinfo_260` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_260` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_261`
--

DROP TABLE IF EXISTS `userinfo_261`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_261` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_261`
--

LOCK TABLES `userinfo_261` WRITE;
/*!40000 ALTER TABLE `userinfo_261` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_261` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_262`
--

DROP TABLE IF EXISTS `userinfo_262`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_262` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_262`
--

LOCK TABLES `userinfo_262` WRITE;
/*!40000 ALTER TABLE `userinfo_262` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_262` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_263`
--

DROP TABLE IF EXISTS `userinfo_263`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_263` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_263`
--

LOCK TABLES `userinfo_263` WRITE;
/*!40000 ALTER TABLE `userinfo_263` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_263` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_264`
--

DROP TABLE IF EXISTS `userinfo_264`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_264` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_264`
--

LOCK TABLES `userinfo_264` WRITE;
/*!40000 ALTER TABLE `userinfo_264` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_264` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_265`
--

DROP TABLE IF EXISTS `userinfo_265`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_265` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_265`
--

LOCK TABLES `userinfo_265` WRITE;
/*!40000 ALTER TABLE `userinfo_265` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_265` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_266`
--

DROP TABLE IF EXISTS `userinfo_266`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_266` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_266`
--

LOCK TABLES `userinfo_266` WRITE;
/*!40000 ALTER TABLE `userinfo_266` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_266` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_267`
--

DROP TABLE IF EXISTS `userinfo_267`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_267` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_267`
--

LOCK TABLES `userinfo_267` WRITE;
/*!40000 ALTER TABLE `userinfo_267` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_267` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_268`
--

DROP TABLE IF EXISTS `userinfo_268`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_268` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_268`
--

LOCK TABLES `userinfo_268` WRITE;
/*!40000 ALTER TABLE `userinfo_268` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_268` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_269`
--

DROP TABLE IF EXISTS `userinfo_269`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_269` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_269`
--

LOCK TABLES `userinfo_269` WRITE;
/*!40000 ALTER TABLE `userinfo_269` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_269` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_27`
--

DROP TABLE IF EXISTS `userinfo_27`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_27` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_27`
--

LOCK TABLES `userinfo_27` WRITE;
/*!40000 ALTER TABLE `userinfo_27` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_27` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_270`
--

DROP TABLE IF EXISTS `userinfo_270`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_270` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_270`
--

LOCK TABLES `userinfo_270` WRITE;
/*!40000 ALTER TABLE `userinfo_270` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_270` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_271`
--

DROP TABLE IF EXISTS `userinfo_271`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_271` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_271`
--

LOCK TABLES `userinfo_271` WRITE;
/*!40000 ALTER TABLE `userinfo_271` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_271` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_272`
--

DROP TABLE IF EXISTS `userinfo_272`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_272` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_272`
--

LOCK TABLES `userinfo_272` WRITE;
/*!40000 ALTER TABLE `userinfo_272` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_272` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_273`
--

DROP TABLE IF EXISTS `userinfo_273`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_273` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_273`
--

LOCK TABLES `userinfo_273` WRITE;
/*!40000 ALTER TABLE `userinfo_273` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_273` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_274`
--

DROP TABLE IF EXISTS `userinfo_274`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_274` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_274`
--

LOCK TABLES `userinfo_274` WRITE;
/*!40000 ALTER TABLE `userinfo_274` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_274` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_275`
--

DROP TABLE IF EXISTS `userinfo_275`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_275` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_275`
--

LOCK TABLES `userinfo_275` WRITE;
/*!40000 ALTER TABLE `userinfo_275` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_275` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_276`
--

DROP TABLE IF EXISTS `userinfo_276`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_276` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_276`
--

LOCK TABLES `userinfo_276` WRITE;
/*!40000 ALTER TABLE `userinfo_276` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_276` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_277`
--

DROP TABLE IF EXISTS `userinfo_277`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_277` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_277`
--

LOCK TABLES `userinfo_277` WRITE;
/*!40000 ALTER TABLE `userinfo_277` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_277` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_278`
--

DROP TABLE IF EXISTS `userinfo_278`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_278` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_278`
--

LOCK TABLES `userinfo_278` WRITE;
/*!40000 ALTER TABLE `userinfo_278` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_278` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_279`
--

DROP TABLE IF EXISTS `userinfo_279`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_279` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_279`
--

LOCK TABLES `userinfo_279` WRITE;
/*!40000 ALTER TABLE `userinfo_279` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_279` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_28`
--

DROP TABLE IF EXISTS `userinfo_28`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_28` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_28`
--

LOCK TABLES `userinfo_28` WRITE;
/*!40000 ALTER TABLE `userinfo_28` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_28` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_280`
--

DROP TABLE IF EXISTS `userinfo_280`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_280` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_280`
--

LOCK TABLES `userinfo_280` WRITE;
/*!40000 ALTER TABLE `userinfo_280` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_280` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_281`
--

DROP TABLE IF EXISTS `userinfo_281`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_281` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_281`
--

LOCK TABLES `userinfo_281` WRITE;
/*!40000 ALTER TABLE `userinfo_281` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_281` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_282`
--

DROP TABLE IF EXISTS `userinfo_282`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_282` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_282`
--

LOCK TABLES `userinfo_282` WRITE;
/*!40000 ALTER TABLE `userinfo_282` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_282` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_283`
--

DROP TABLE IF EXISTS `userinfo_283`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_283` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_283`
--

LOCK TABLES `userinfo_283` WRITE;
/*!40000 ALTER TABLE `userinfo_283` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_283` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_284`
--

DROP TABLE IF EXISTS `userinfo_284`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_284` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_284`
--

LOCK TABLES `userinfo_284` WRITE;
/*!40000 ALTER TABLE `userinfo_284` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_284` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_285`
--

DROP TABLE IF EXISTS `userinfo_285`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_285` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_285`
--

LOCK TABLES `userinfo_285` WRITE;
/*!40000 ALTER TABLE `userinfo_285` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_285` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_286`
--

DROP TABLE IF EXISTS `userinfo_286`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_286` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_286`
--

LOCK TABLES `userinfo_286` WRITE;
/*!40000 ALTER TABLE `userinfo_286` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_286` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_287`
--

DROP TABLE IF EXISTS `userinfo_287`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_287` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_287`
--

LOCK TABLES `userinfo_287` WRITE;
/*!40000 ALTER TABLE `userinfo_287` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_287` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_288`
--

DROP TABLE IF EXISTS `userinfo_288`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_288` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_288`
--

LOCK TABLES `userinfo_288` WRITE;
/*!40000 ALTER TABLE `userinfo_288` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_288` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_289`
--

DROP TABLE IF EXISTS `userinfo_289`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_289` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_289`
--

LOCK TABLES `userinfo_289` WRITE;
/*!40000 ALTER TABLE `userinfo_289` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_289` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_29`
--

DROP TABLE IF EXISTS `userinfo_29`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_29` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_29`
--

LOCK TABLES `userinfo_29` WRITE;
/*!40000 ALTER TABLE `userinfo_29` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_29` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_290`
--

DROP TABLE IF EXISTS `userinfo_290`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_290` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_290`
--

LOCK TABLES `userinfo_290` WRITE;
/*!40000 ALTER TABLE `userinfo_290` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_290` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_291`
--

DROP TABLE IF EXISTS `userinfo_291`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_291` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_291`
--

LOCK TABLES `userinfo_291` WRITE;
/*!40000 ALTER TABLE `userinfo_291` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_291` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_292`
--

DROP TABLE IF EXISTS `userinfo_292`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_292` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_292`
--

LOCK TABLES `userinfo_292` WRITE;
/*!40000 ALTER TABLE `userinfo_292` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_292` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_293`
--

DROP TABLE IF EXISTS `userinfo_293`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_293` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_293`
--

LOCK TABLES `userinfo_293` WRITE;
/*!40000 ALTER TABLE `userinfo_293` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_293` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_294`
--

DROP TABLE IF EXISTS `userinfo_294`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_294` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_294`
--

LOCK TABLES `userinfo_294` WRITE;
/*!40000 ALTER TABLE `userinfo_294` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_294` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_295`
--

DROP TABLE IF EXISTS `userinfo_295`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_295` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_295`
--

LOCK TABLES `userinfo_295` WRITE;
/*!40000 ALTER TABLE `userinfo_295` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_295` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_296`
--

DROP TABLE IF EXISTS `userinfo_296`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_296` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_296`
--

LOCK TABLES `userinfo_296` WRITE;
/*!40000 ALTER TABLE `userinfo_296` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_296` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_297`
--

DROP TABLE IF EXISTS `userinfo_297`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_297` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_297`
--

LOCK TABLES `userinfo_297` WRITE;
/*!40000 ALTER TABLE `userinfo_297` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_297` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_298`
--

DROP TABLE IF EXISTS `userinfo_298`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_298` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_298`
--

LOCK TABLES `userinfo_298` WRITE;
/*!40000 ALTER TABLE `userinfo_298` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_298` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_299`
--

DROP TABLE IF EXISTS `userinfo_299`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_299` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_299`
--

LOCK TABLES `userinfo_299` WRITE;
/*!40000 ALTER TABLE `userinfo_299` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_299` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_3`
--

DROP TABLE IF EXISTS `userinfo_3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_3` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_3`
--

LOCK TABLES `userinfo_3` WRITE;
/*!40000 ALTER TABLE `userinfo_3` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_30`
--

DROP TABLE IF EXISTS `userinfo_30`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_30` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_30`
--

LOCK TABLES `userinfo_30` WRITE;
/*!40000 ALTER TABLE `userinfo_30` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_30` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_31`
--

DROP TABLE IF EXISTS `userinfo_31`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_31` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_31`
--

LOCK TABLES `userinfo_31` WRITE;
/*!40000 ALTER TABLE `userinfo_31` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_31` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_32`
--

DROP TABLE IF EXISTS `userinfo_32`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_32` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_32`
--

LOCK TABLES `userinfo_32` WRITE;
/*!40000 ALTER TABLE `userinfo_32` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_32` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_33`
--

DROP TABLE IF EXISTS `userinfo_33`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_33` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_33`
--

LOCK TABLES `userinfo_33` WRITE;
/*!40000 ALTER TABLE `userinfo_33` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_33` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_34`
--

DROP TABLE IF EXISTS `userinfo_34`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_34` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_34`
--

LOCK TABLES `userinfo_34` WRITE;
/*!40000 ALTER TABLE `userinfo_34` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_34` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_35`
--

DROP TABLE IF EXISTS `userinfo_35`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_35` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_35`
--

LOCK TABLES `userinfo_35` WRITE;
/*!40000 ALTER TABLE `userinfo_35` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_35` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_36`
--

DROP TABLE IF EXISTS `userinfo_36`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_36` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_36`
--

LOCK TABLES `userinfo_36` WRITE;
/*!40000 ALTER TABLE `userinfo_36` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_36` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_37`
--

DROP TABLE IF EXISTS `userinfo_37`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_37` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_37`
--

LOCK TABLES `userinfo_37` WRITE;
/*!40000 ALTER TABLE `userinfo_37` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_37` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_38`
--

DROP TABLE IF EXISTS `userinfo_38`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_38` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_38`
--

LOCK TABLES `userinfo_38` WRITE;
/*!40000 ALTER TABLE `userinfo_38` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_38` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_39`
--

DROP TABLE IF EXISTS `userinfo_39`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_39` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_39`
--

LOCK TABLES `userinfo_39` WRITE;
/*!40000 ALTER TABLE `userinfo_39` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_39` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_4`
--

DROP TABLE IF EXISTS `userinfo_4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_4` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_4`
--

LOCK TABLES `userinfo_4` WRITE;
/*!40000 ALTER TABLE `userinfo_4` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_40`
--

DROP TABLE IF EXISTS `userinfo_40`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_40` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_40`
--

LOCK TABLES `userinfo_40` WRITE;
/*!40000 ALTER TABLE `userinfo_40` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_40` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_41`
--

DROP TABLE IF EXISTS `userinfo_41`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_41` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_41`
--

LOCK TABLES `userinfo_41` WRITE;
/*!40000 ALTER TABLE `userinfo_41` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_41` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_42`
--

DROP TABLE IF EXISTS `userinfo_42`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_42` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_42`
--

LOCK TABLES `userinfo_42` WRITE;
/*!40000 ALTER TABLE `userinfo_42` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_42` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_43`
--

DROP TABLE IF EXISTS `userinfo_43`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_43` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_43`
--

LOCK TABLES `userinfo_43` WRITE;
/*!40000 ALTER TABLE `userinfo_43` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_43` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_44`
--

DROP TABLE IF EXISTS `userinfo_44`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_44` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_44`
--

LOCK TABLES `userinfo_44` WRITE;
/*!40000 ALTER TABLE `userinfo_44` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_44` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_45`
--

DROP TABLE IF EXISTS `userinfo_45`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_45` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_45`
--

LOCK TABLES `userinfo_45` WRITE;
/*!40000 ALTER TABLE `userinfo_45` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_45` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_46`
--

DROP TABLE IF EXISTS `userinfo_46`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_46` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_46`
--

LOCK TABLES `userinfo_46` WRITE;
/*!40000 ALTER TABLE `userinfo_46` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_46` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_47`
--

DROP TABLE IF EXISTS `userinfo_47`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_47` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_47`
--

LOCK TABLES `userinfo_47` WRITE;
/*!40000 ALTER TABLE `userinfo_47` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_47` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_48`
--

DROP TABLE IF EXISTS `userinfo_48`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_48` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_48`
--

LOCK TABLES `userinfo_48` WRITE;
/*!40000 ALTER TABLE `userinfo_48` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_48` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_49`
--

DROP TABLE IF EXISTS `userinfo_49`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_49` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_49`
--

LOCK TABLES `userinfo_49` WRITE;
/*!40000 ALTER TABLE `userinfo_49` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_49` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_5`
--

DROP TABLE IF EXISTS `userinfo_5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_5` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_5`
--

LOCK TABLES `userinfo_5` WRITE;
/*!40000 ALTER TABLE `userinfo_5` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_50`
--

DROP TABLE IF EXISTS `userinfo_50`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_50` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_50`
--

LOCK TABLES `userinfo_50` WRITE;
/*!40000 ALTER TABLE `userinfo_50` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_50` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_51`
--

DROP TABLE IF EXISTS `userinfo_51`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_51` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_51`
--

LOCK TABLES `userinfo_51` WRITE;
/*!40000 ALTER TABLE `userinfo_51` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_51` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_52`
--

DROP TABLE IF EXISTS `userinfo_52`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_52` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_52`
--

LOCK TABLES `userinfo_52` WRITE;
/*!40000 ALTER TABLE `userinfo_52` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_52` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_53`
--

DROP TABLE IF EXISTS `userinfo_53`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_53` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_53`
--

LOCK TABLES `userinfo_53` WRITE;
/*!40000 ALTER TABLE `userinfo_53` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_53` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_54`
--

DROP TABLE IF EXISTS `userinfo_54`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_54` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_54`
--

LOCK TABLES `userinfo_54` WRITE;
/*!40000 ALTER TABLE `userinfo_54` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_54` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_55`
--

DROP TABLE IF EXISTS `userinfo_55`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_55` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_55`
--

LOCK TABLES `userinfo_55` WRITE;
/*!40000 ALTER TABLE `userinfo_55` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_55` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_56`
--

DROP TABLE IF EXISTS `userinfo_56`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_56` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_56`
--

LOCK TABLES `userinfo_56` WRITE;
/*!40000 ALTER TABLE `userinfo_56` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_56` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_57`
--

DROP TABLE IF EXISTS `userinfo_57`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_57` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_57`
--

LOCK TABLES `userinfo_57` WRITE;
/*!40000 ALTER TABLE `userinfo_57` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_57` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_58`
--

DROP TABLE IF EXISTS `userinfo_58`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_58` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_58`
--

LOCK TABLES `userinfo_58` WRITE;
/*!40000 ALTER TABLE `userinfo_58` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_58` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_59`
--

DROP TABLE IF EXISTS `userinfo_59`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_59` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_59`
--

LOCK TABLES `userinfo_59` WRITE;
/*!40000 ALTER TABLE `userinfo_59` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_59` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_6`
--

DROP TABLE IF EXISTS `userinfo_6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_6` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_6`
--

LOCK TABLES `userinfo_6` WRITE;
/*!40000 ALTER TABLE `userinfo_6` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_6` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_60`
--

DROP TABLE IF EXISTS `userinfo_60`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_60` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_60`
--

LOCK TABLES `userinfo_60` WRITE;
/*!40000 ALTER TABLE `userinfo_60` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_60` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_61`
--

DROP TABLE IF EXISTS `userinfo_61`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_61` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_61`
--

LOCK TABLES `userinfo_61` WRITE;
/*!40000 ALTER TABLE `userinfo_61` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_61` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_62`
--

DROP TABLE IF EXISTS `userinfo_62`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_62` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_62`
--

LOCK TABLES `userinfo_62` WRITE;
/*!40000 ALTER TABLE `userinfo_62` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_62` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_63`
--

DROP TABLE IF EXISTS `userinfo_63`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_63` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_63`
--

LOCK TABLES `userinfo_63` WRITE;
/*!40000 ALTER TABLE `userinfo_63` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_63` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_64`
--

DROP TABLE IF EXISTS `userinfo_64`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_64` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_64`
--

LOCK TABLES `userinfo_64` WRITE;
/*!40000 ALTER TABLE `userinfo_64` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_64` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_65`
--

DROP TABLE IF EXISTS `userinfo_65`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_65` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_65`
--

LOCK TABLES `userinfo_65` WRITE;
/*!40000 ALTER TABLE `userinfo_65` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_65` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_66`
--

DROP TABLE IF EXISTS `userinfo_66`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_66` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_66`
--

LOCK TABLES `userinfo_66` WRITE;
/*!40000 ALTER TABLE `userinfo_66` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_66` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_67`
--

DROP TABLE IF EXISTS `userinfo_67`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_67` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_67`
--

LOCK TABLES `userinfo_67` WRITE;
/*!40000 ALTER TABLE `userinfo_67` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_67` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_68`
--

DROP TABLE IF EXISTS `userinfo_68`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_68` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_68`
--

LOCK TABLES `userinfo_68` WRITE;
/*!40000 ALTER TABLE `userinfo_68` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_68` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_69`
--

DROP TABLE IF EXISTS `userinfo_69`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_69` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_69`
--

LOCK TABLES `userinfo_69` WRITE;
/*!40000 ALTER TABLE `userinfo_69` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_69` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_7`
--

DROP TABLE IF EXISTS `userinfo_7`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_7` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_7`
--

LOCK TABLES `userinfo_7` WRITE;
/*!40000 ALTER TABLE `userinfo_7` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_7` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_70`
--

DROP TABLE IF EXISTS `userinfo_70`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_70` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_70`
--

LOCK TABLES `userinfo_70` WRITE;
/*!40000 ALTER TABLE `userinfo_70` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_70` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_71`
--

DROP TABLE IF EXISTS `userinfo_71`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_71` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_71`
--

LOCK TABLES `userinfo_71` WRITE;
/*!40000 ALTER TABLE `userinfo_71` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_71` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_72`
--

DROP TABLE IF EXISTS `userinfo_72`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_72` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_72`
--

LOCK TABLES `userinfo_72` WRITE;
/*!40000 ALTER TABLE `userinfo_72` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_72` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_73`
--

DROP TABLE IF EXISTS `userinfo_73`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_73` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_73`
--

LOCK TABLES `userinfo_73` WRITE;
/*!40000 ALTER TABLE `userinfo_73` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_73` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_74`
--

DROP TABLE IF EXISTS `userinfo_74`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_74` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_74`
--

LOCK TABLES `userinfo_74` WRITE;
/*!40000 ALTER TABLE `userinfo_74` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_74` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_75`
--

DROP TABLE IF EXISTS `userinfo_75`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_75` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_75`
--

LOCK TABLES `userinfo_75` WRITE;
/*!40000 ALTER TABLE `userinfo_75` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_75` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_76`
--

DROP TABLE IF EXISTS `userinfo_76`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_76` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_76`
--

LOCK TABLES `userinfo_76` WRITE;
/*!40000 ALTER TABLE `userinfo_76` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_76` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_77`
--

DROP TABLE IF EXISTS `userinfo_77`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_77` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_77`
--

LOCK TABLES `userinfo_77` WRITE;
/*!40000 ALTER TABLE `userinfo_77` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_77` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_78`
--

DROP TABLE IF EXISTS `userinfo_78`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_78` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_78`
--

LOCK TABLES `userinfo_78` WRITE;
/*!40000 ALTER TABLE `userinfo_78` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_78` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_79`
--

DROP TABLE IF EXISTS `userinfo_79`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_79` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_79`
--

LOCK TABLES `userinfo_79` WRITE;
/*!40000 ALTER TABLE `userinfo_79` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_79` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_8`
--

DROP TABLE IF EXISTS `userinfo_8`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_8` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_8`
--

LOCK TABLES `userinfo_8` WRITE;
/*!40000 ALTER TABLE `userinfo_8` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_8` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_80`
--

DROP TABLE IF EXISTS `userinfo_80`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_80` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_80`
--

LOCK TABLES `userinfo_80` WRITE;
/*!40000 ALTER TABLE `userinfo_80` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_80` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_81`
--

DROP TABLE IF EXISTS `userinfo_81`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_81` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_81`
--

LOCK TABLES `userinfo_81` WRITE;
/*!40000 ALTER TABLE `userinfo_81` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_81` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_82`
--

DROP TABLE IF EXISTS `userinfo_82`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_82` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_82`
--

LOCK TABLES `userinfo_82` WRITE;
/*!40000 ALTER TABLE `userinfo_82` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_82` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_83`
--

DROP TABLE IF EXISTS `userinfo_83`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_83` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_83`
--

LOCK TABLES `userinfo_83` WRITE;
/*!40000 ALTER TABLE `userinfo_83` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_83` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_84`
--

DROP TABLE IF EXISTS `userinfo_84`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_84` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_84`
--

LOCK TABLES `userinfo_84` WRITE;
/*!40000 ALTER TABLE `userinfo_84` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_84` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_85`
--

DROP TABLE IF EXISTS `userinfo_85`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_85` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_85`
--

LOCK TABLES `userinfo_85` WRITE;
/*!40000 ALTER TABLE `userinfo_85` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_85` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_86`
--

DROP TABLE IF EXISTS `userinfo_86`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_86` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_86`
--

LOCK TABLES `userinfo_86` WRITE;
/*!40000 ALTER TABLE `userinfo_86` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_86` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_87`
--

DROP TABLE IF EXISTS `userinfo_87`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_87` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_87`
--

LOCK TABLES `userinfo_87` WRITE;
/*!40000 ALTER TABLE `userinfo_87` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_87` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_88`
--

DROP TABLE IF EXISTS `userinfo_88`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_88` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_88`
--

LOCK TABLES `userinfo_88` WRITE;
/*!40000 ALTER TABLE `userinfo_88` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_88` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_89`
--

DROP TABLE IF EXISTS `userinfo_89`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_89` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_89`
--

LOCK TABLES `userinfo_89` WRITE;
/*!40000 ALTER TABLE `userinfo_89` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_89` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_9`
--

DROP TABLE IF EXISTS `userinfo_9`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_9` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_9`
--

LOCK TABLES `userinfo_9` WRITE;
/*!40000 ALTER TABLE `userinfo_9` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_9` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_90`
--

DROP TABLE IF EXISTS `userinfo_90`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_90` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_90`
--

LOCK TABLES `userinfo_90` WRITE;
/*!40000 ALTER TABLE `userinfo_90` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_90` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_91`
--

DROP TABLE IF EXISTS `userinfo_91`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_91` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_91`
--

LOCK TABLES `userinfo_91` WRITE;
/*!40000 ALTER TABLE `userinfo_91` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_91` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_92`
--

DROP TABLE IF EXISTS `userinfo_92`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_92` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_92`
--

LOCK TABLES `userinfo_92` WRITE;
/*!40000 ALTER TABLE `userinfo_92` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_92` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_93`
--

DROP TABLE IF EXISTS `userinfo_93`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_93` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_93`
--

LOCK TABLES `userinfo_93` WRITE;
/*!40000 ALTER TABLE `userinfo_93` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_93` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_94`
--

DROP TABLE IF EXISTS `userinfo_94`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_94` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_94`
--

LOCK TABLES `userinfo_94` WRITE;
/*!40000 ALTER TABLE `userinfo_94` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_94` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_95`
--

DROP TABLE IF EXISTS `userinfo_95`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_95` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_95`
--

LOCK TABLES `userinfo_95` WRITE;
/*!40000 ALTER TABLE `userinfo_95` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_95` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_96`
--

DROP TABLE IF EXISTS `userinfo_96`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_96` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_96`
--

LOCK TABLES `userinfo_96` WRITE;
/*!40000 ALTER TABLE `userinfo_96` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_96` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_97`
--

DROP TABLE IF EXISTS `userinfo_97`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_97` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_97`
--

LOCK TABLES `userinfo_97` WRITE;
/*!40000 ALTER TABLE `userinfo_97` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_97` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_98`
--

DROP TABLE IF EXISTS `userinfo_98`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_98` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_98`
--

LOCK TABLES `userinfo_98` WRITE;
/*!40000 ALTER TABLE `userinfo_98` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_98` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinfo_99`
--

DROP TABLE IF EXISTS `userinfo_99`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinfo_99` (
  `uid` int(10) NOT NULL,
  `username` varchar(100) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `username1` varchar(100) DEFAULT NULL,
  `zindex` int(10) NOT NULL,
  `regdate` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinfo_99`
--

LOCK TABLES `userinfo_99` WRITE;
/*!40000 ALTER TABLE `userinfo_99` DISABLE KEYS */;
/*!40000 ALTER TABLE `userinfo_99` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-07-30 11:13:20