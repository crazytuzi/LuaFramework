--------------------------------------------------------------------------------------
-- 文件名:	Class_Item.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-28 10:24
-- 版  本:	1.0
-- 描  述:	物品
-- 应  用:  
---------------------------------------------------------------------------------------

--创建CMaterialItem类
Class_Item = class("Class_Item",  function() return Class_GameObj:new() end)
Class_Item.__index = Class_Item
--初始数据 
function Class_Item:initlItemData(tbMsgItem)
	if(not tbMsgItem)then
		cclog("Class_Item:initlItemData failed")
	end
	
	self.nServerID = tbMsgItem.material_id					--材料ID
	self.nCsvID = tbMsgItem.material_config_id			--材料对应配置文件ID   ItemBase.csv
	self.nStarLevel = tbMsgItem.material_star_lv				--材料星级
	self.nNum = tbMsgItem.material_num					--材料数量
	
	self.tbCsvBase = g_DataMgr:getItemBaseCsv(self.nCsvID, self.nStarLevel)
    if not self.tbCsvBase then return end
	
	return self.nServerID
end

--初始数据
function Class_Item:initItemDropData(tbMsgItem)
	if(not tbMsgItem)then
		return
	end
	
	self.nServerID = tbMsgItem.drop_item_id					--魂魄ID
	self.nCsvID = tbMsgItem.drop_item_config_id			--材料对应配置文件ID   ItemBase.csv
	self.nStarLevel = tbMsgItem.drop_item_star_lv		--材料星级
	self.nNum = tbMsgItem.drop_item_num				--材料数量
	
	self.tbCsvBase = g_DataMgr:getItemBaseCsv(self.nCsvID, self.nStarLevel)
	
	return self.nServerID
end

--获取数量
function Class_Item:getNum()
	return self.nNum
end

--设置数量
function Class_Item:setNum(nNum)
	self.nNum = nNum
end

--获取名称
 function Class_Item:getName()
	return self.tbCsvBase["Name"]
end

--获取Icon
 function Class_Item:getIcon()
	return self.tbCsvBase["Icon"]
end