--------------------------------------------------------------------------------------
-- 文件名:	Class_GameObj.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	物品
-- 应  用:  基类
---------------------------------------------------------------------------------------

--创建CEquip类
Class_GameObj = class("Class_GameObj")
Class_GameObj.__index = Class_GameObj

--获取物品服务端ID
function Class_GameObj:getServerId()
	return self.nServerID
end

--获取物品配置ID
function Class_GameObj:getCsvID()
	return self.nCsvID
end

--获取物品所属ID
function Class_GameObj:getOwnerID()
	return self.nOwnerID or 0
end

--获取物品等级
function Class_GameObj:getLevel()
	return self.nLevel
end

--获取物品星等级
function Class_GameObj:getStarLevel()
	return self.nStarLevel
end

--获取物品基本数据表
--装备、伙伴等继承CItem的类需要重载该函数
function Class_GameObj:getCsvBase()
	return self.tbCsvBase
end

--获取物品基本数据表
--装备、伙伴等继承CItem的类需要重载该函数
function Class_GameObj:setItemBase()
	self.tbCsvBase = g_DataMgr:getItemBaseCsv(self.nCsvID, self.nStarLevel)
end

--debug 物品信息
function Class_GameObj:debugString()
	ccclog(self.nServerID.." Class_GameObj:debugString "..self.nCsvID)
end


