--------------------------------------------------------------------------------------
-- 文件名:	Class_Soul.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-28 10:24
-- 版  本:	1.0
-- 描  述:	物品
-- 应  用:  
---------------------------------------------------------------------------------------

--创建CSoulItem类
Class_Soul = class("Class_Soul",  function() return Class_GameObj:new() end)
Class_Soul.__index = Class_Soul

--初始数据元神
function Class_Soul:initSoulItemData(tbMsgSoul)
	if(not tbMsgSoul)then
		cclog("Class_Soul:initSoulItemData Failed")
	end
	
	self.nServerID = tbMsgSoul["soul_id"]					--元神ID
	self.nCsvID = tbMsgSoul["soul_config_id"]			--元神对应配置文件ID 
	self.nStarLevel = tbMsgSoul["soul_star_lv"]				--元神星级
	self.nNum = tbMsgSoul["soul_num"] 				--元神数量

	self.tbCsvBase = g_DataMgr:getCardSoulCsv(self.nCsvID, self.nStarLevel)

	return self.nServerID
end

--初始数据元神
function Class_Soul:initSoulDropData(tbMsgSoul)
	if(not tbMsgSoul)then
		cclog("Class_Soul:initSoulItemData Failed")
	end
	
	self.nServerID = tbMsgSoul["drop_item_id"]					--元神ID
	self.nCsvID = tbMsgSoul["drop_item_config_id"]			--元神对应配置文件ID 
	self.nStarLevel = tbMsgSoul["drop_item_star_lv"]			--元神星级
	self.nNum = tbMsgSoul["drop_item_num"]					--元神数量

	self.tbCsvBase = g_DataMgr:getCardSoulCsv(self.nCsvID, self.nStarLevel)

	return self.nServerID
end

function Class_Soul:getNum()
	return self.nNum or 0
end

function Class_Soul:setNum(nNum)
	self.nNum = math.max(nNum, 0)
end

function Class_HunPo:getMaxNum()
	return tonumber(self.tbCsvBase.MaxNum)
end

