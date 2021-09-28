--------------------------------------------------------------------------------------
-- 文件名:	Class_HunPo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-26 11:24
-- 版  本:	1.0
-- 描  述:	物品
-- 应  用:  
---------------------------------------------------------------------------------------

--创建CSoulItem类
Class_HunPo = class("Class_HunPo",  function() return Class_GameObj:new() end)
Class_HunPo.__index = Class_HunPo

--初始数据
function Class_HunPo:initHunPoData(tbMsgHunPo)
	if(not tbMsgHunPo)then
		return
	end
	
	self.nServerID = tbMsgHunPo["god_id"]					--魂魄ID
	self.nCsvID = tbMsgHunPo["god_config_id"]		--魂魄对应配置文件ID  CardBase.csv
	self.nStarLevel = tbMsgHunPo["god_starLv"]			--魂魄对应星等 
	self.nNum = tbMsgHunPo["god_num"]				--魂魄数量
	self.tbCsvBase = g_DataMgr:getCardHunPoCsv(self.nCsvID)
	
	return self.nServerID
end

--初始数据
function Class_HunPo:initHunPoDataDrop(tbMsgHunPo)
	if(not tbMsgHunPo)then
		return
	end
	
	self.nServerID = tbMsgHunPo["drop_item_id"]					--魂魄ID
	self.nCsvID = tbMsgHunPo["drop_item_config_id"]			--魂魄对应配置文件ID  CardBase.csv
	self.nStarLevel = tbMsgHunPo["drop_item_star_lv"]				--魂魄对应星等 
	self.nNum = tbMsgHunPo["drop_item_num"]					--魂魄数量	
	self.tbCsvBase = g_DataMgr:getCardHunPoCsv(self.nCsvID)
	
	return self.nServerID
end

function Class_HunPo:getStarLevel()
	return self.tbCsvBase.CardStarLevel
end

function Class_HunPo:getNum()
	return self.nNum or 0
end

function Class_HunPo:setNum(nNum)
	self.nNum = math.max(nNum, 0)
end

--获取伙伴信息
function Class_HunPo:getCardBase()
	
	return g_DataMgr:getCardBaseCsv(self.nCsvID, self.tbCsvBase.CardStarLevel)
end

function Class_HunPo:getMaxNum()
	return tonumber(self.tbCsvBase.MaxNum)
end

function Class_HunPo:getExChangeNum()
	return tonumber(self.tbCsvBase.NeedYuanShenNum)
end

function Class_HunPo:checkExChange()
	local nNeedYuanShenNum = tonumber(self.tbCsvBase.NeedYuanShenNum)
	if(nNeedYuanShenNum > self.nNum)then
		return false
	else
		return true
	end
end