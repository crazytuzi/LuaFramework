--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	道具(ItemBase)
-- 应  用:
---------------------------------------------------------------------------------------

--初始化道具列表
local tbItemTypeOrder = {
	[6]	= 1,
	[2]	= 1,
	[0]	= 2,
	[1]	= 3,
	[3]	= 4,
}

function Class_Hero:initItemList(tbMsgItem)
	self.tbItemList = {}
	self.nItemLisCount = 0
	if not tbMsgItem then return end
	for k, v in ipairs(tbMsgItem) do
		local Obj_Item = Class_Item.new()
		local nServerID = Obj_Item:initlItemData(v)
		self.tbItemList[nServerID] = Obj_Item
		self.nItemLisCount = self.nItemLisCount + 1
	end
end

--只更新世界聊天的道具喇叭
function Class_Hero:UpdataItemList(tbMsgItem)
	if not tbMsgItem then return end
	for k, v in ipairs(tbMsgItem) do
		-- local Obj_Item = Class_Item.new()
		-- local nServerID = Obj_Item:initlItemData(v)
		-- self.tbItemList[nServerID] = Obj_Item
		-- self.nItemLisCount = self.nItemLisCount + 1
		self:setItemNum(v.material_id, v.material_num)
	end
end

function Class_Hero:setItemNum(nServerID, nRemainNum)
	local Obj_Item = self.tbItemList[nServerID]
	if Obj_Item then
		if nRemainNum <= 0 then
			self.tbItemList[nServerID] = nil
			self.bSortItemAscendLock = nil
			self.bSortUseItemAscendLock = nil
			self.bSortMaterialItemAscendLock = nil
			self.bSortFragItemAscendLock = nil
			self.bSortFormulaItemAscendLock = nil
		else
			Obj_Item:setNum(nRemainNum)
		end
	end
end

function Class_Hero:addItem(tbData)
	local nServerID = tbData.drop_item_id
	local nAddNum = tbData.drop_item_num
	local Obj_Item = self.tbItemList[nServerID]
	if Obj_Item then
		local nRemainNum = Obj_Item:getNum()
		Obj_Item:setNum(nRemainNum + nAddNum)
	else
		local Obj_Item = Class_Item.new()
		local nServerID = Obj_Item:initItemDropData(tbData)
		self.tbItemList[nServerID] = Obj_Item
		self.bSortItemAscendLock = nil
		self.bSortUseItemAscendLock = nil
		self.bSortMaterialItemAscendLock = nil
		self.bSortFragItemAscendLock = nil
		self.bSortFormulaItemAscendLock = nil
	end
end

function Class_Hero:setItemByCsvIdAndStar(nCsvID, nStarLevel, nRemainNum)
	for k, v in pairs (self.tbItemList) do
		if v.nCsvID == nCsvID and v.nStarLevel == nStarLevel then
			if nRemainNum > 0 then
				v.nNum = nRemainNum
			else
				nServerID = v.nServerID
				self.tbItemList[nServerID] = nil
				self.bSortItemAscendLock = nil
				self.bSortUseItemAscendLock = nil
				self.bSortMaterialItemAscendLock = nil
				self.bSortFragItemAscendLock = nil
				self.bSortFormulaItemAscendLock = nil
			end
			break
		end
	end
end

function Class_Hero:getItemLisCount()
	return self.nItemLisCount
end

function Class_Hero:getItemNumByServId(nServerID)
	return self.tbItemList[nServerID]:getNum()
end

--获取道具数量
function Class_Hero:getItemNumByCsv(nCsvID, nStarLevel)
	for k, v in pairs (self.tbItemList) do
		if v.nCsvID == nCsvID and v.nStarLevel == nStarLevel then
			return v:getNum()
		end
	end
	return 0
end

--获取道具
function Class_Hero:getItemByCsv(nCsvID, nStarLevel)
	for k, v in pairs (self.tbItemList) do
		if v.nCsvID == nCsvID and v.nStarLevel == nStarLevel then
			return v
		end
	end
	return "无此道具"
end

--获取排好正序的所有道具列表
function Class_Hero:getItemListSortAscend()
	if not self.bSortItemAscendLock then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortItemAscendLock = true
		self.tbItemListAscendOrder = {}
		local tbUseItemListAscendOrder = self:getUseItemListSortAscend()
		for i = 1, #tbUseItemListAscendOrder do
			table.insert(self.tbItemListAscendOrder, tbUseItemListAscendOrder[i])
		end
		local tbMaterialItemListAscendOrder = self:getMaterialItemListSortAscend()
		for i = 1, #tbMaterialItemListAscendOrder do
			table.insert(self.tbItemListAscendOrder, tbMaterialItemListAscendOrder[i])
		end
		local tbFragItemListAscendOrder = self:getFragItemListSortAscend()
		for i = 1, #tbFragItemListAscendOrder do
			table.insert(self.tbItemListAscendOrder, tbFragItemListAscendOrder[i])
		end
		local tbFormulaItemListAscendOrder = self:getFormulaItemListSortAscend()
		for i = 1, #tbFormulaItemListAscendOrder do
			table.insert(self.tbItemListAscendOrder, tbFormulaItemListAscendOrder[i])
		end
	end
	
	return self.tbItemListAscendOrder
end

--可使用道具正序排序
local function sortUseItemAscendOrder(Obj_UseItemA, Obj_UseItemB)
	local nCsvIDA = Obj_UseItemA:getCsvID()
	local nCsvIDB = Obj_UseItemB:getCsvID()
	if nCsvIDA == nCsvIDB then
		local nStarLevelA = Obj_UseItemA:getStarLevel()
		local nStarLevelB = Obj_UseItemB:getStarLevel()
		if nStarLevelA == nStarLevelB then
			local nServerIDA = Obj_UseItemA:getServerId()
			local nServerIDB = Obj_UseItemB:getServerId()
			return nServerIDA < nServerIDB
		else
			return nStarLevelA > nStarLevelB
		end
	else
		return nCsvIDA < nCsvIDB
	end
end

--获取排好正序的可使用道具列表
function Class_Hero:getUseItemListSortAscend()
	if not self.bSortUseItemAscendLock then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortUseItemAscendLock = true
		self.tbUseItemListAscendOrder = {}
		for k, v in pairs (self.tbItemList) do
			if v:getCsvBase().Type == 6 or v:getCsvBase().Type == 2 or v:getCsvBase().Type == 4 then
				table.insert(self.tbUseItemListAscendOrder, v)
			end
		end
		table.sort(self.tbUseItemListAscendOrder, sortUseItemAscendOrder)
	end
	
	return self.tbUseItemListAscendOrder
end

--材料道具正序排序
local function sortMaterialItemAscendOrder(Obj_MaterialItemA, Obj_MaterialItemB)
	local nStarLevelA = Obj_MaterialItemA:getStarLevel()
	local nStarLevelB = Obj_MaterialItemB:getStarLevel()
	if nStarLevelA == nStarLevelB then
		local nCsvIDA = Obj_MaterialItemA:getCsvID()
		local nCsvIDB = Obj_MaterialItemB:getCsvID()
		if nCsvIDA == nCsvIDB then
			local nServerIDA = Obj_MaterialItemA:getServerId()
			local nServerIDB = Obj_MaterialItemB:getServerId()
			return nServerIDA < nServerIDB
		else
			return nCsvIDA > nCsvIDB
		end
	else
		return nStarLevelA > nStarLevelB
	end
end

--获取排好正序的材料道具列表
function Class_Hero:getMaterialItemListSortAscend()
	if not self.bSortMaterialItemAscendLock then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortMaterialItemAscendLock = true
		self.tbMaterialItemListAscendOrder = {}
		for k, v in pairs (self.tbItemList) do
			if v:getCsvBase().Type == 0 then
				table.insert(self.tbMaterialItemListAscendOrder, v)
			end
		end
		table.sort(self.tbMaterialItemListAscendOrder, sortMaterialItemAscendOrder)
	end
	
	return self.tbMaterialItemListAscendOrder
end

--碎片道具正序排序
local function sortFragItemAscendOrder(Obj_FragItemA, Obj_FragItemB)
	local nStarLevelA = Obj_FragItemA:getStarLevel()
	local nStarLevelB = Obj_FragItemB:getStarLevel()
	if nStarLevelA == nStarLevelB then
		local nCsvIDA = Obj_FragItemA:getCsvID()
		local nCsvIDB = Obj_FragItemB:getCsvID()
		if nCsvIDA == nCsvIDB then
			local nServerIDA = Obj_FragItemA:getServerId()
			local nServerIDB = Obj_FragItemB:getServerId()
			return nServerIDA < nServerIDB
		else
			return nCsvIDA > nCsvIDB
		end
	else
		return nStarLevelA > nStarLevelB
	end
end

--获取排好正序的碎片道具列表
function Class_Hero:getFragItemListSortAscend()
	if not self.bSortFragItemAscendLock then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortFragItemAscendLock = true
		self.tbFragItemListAscendOrder = {}
		for k, v in pairs (self.tbItemList) do
			if v:getCsvBase().Type == 1 then
				table.insert(self.tbFragItemListAscendOrder, v)
			end
		end
		table.sort(self.tbFragItemListAscendOrder, sortFragItemAscendOrder)
	end
	
	return self.tbFragItemListAscendOrder
end

--配方道具正序排序
local function sortFormulaItemAscendOrder(Obj_FormulaItemA, Obj_FormulaItemB)
	local nStarLevelA = Obj_FormulaItemA:getStarLevel()
	local nStarLevelB = Obj_FormulaItemB:getStarLevel()
	if nStarLevelA == nStarLevelB then
		local nCsvIDA = Obj_FormulaItemA:getCsvID()
		local nCsvIDB = Obj_FormulaItemB:getCsvID()
		if nCsvIDA == nCsvIDB then
			local nServerIDA = Obj_FormulaItemA:getServerId()
			local nServerIDB = Obj_FormulaItemB:getServerId()
			return nServerIDA < nServerIDB
		else
			return nCsvIDA > nCsvIDB
		end
	else
		return nStarLevelA > nStarLevelB
	end
end

--获取排好正序的配方道具列表
function Class_Hero:getFormulaItemListSortAscend()
	if not self.bSortFormulaItemAscendLock then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortFormulaItemAscendLock = true
		self.tbFormulaItemListAscendOrder = {}
		for k, v in pairs (self.tbItemList) do
			if v:getCsvBase().Type == 3 then
				table.insert(self.tbFormulaItemListAscendOrder, v)
			end
		end
		table.sort(self.tbFormulaItemListAscendOrder, sortFormulaItemAscendOrder)
	end
	
	return self.tbFormulaItemListAscendOrder
end

function Class_Hero:getItemList()
	return self.tbItemList
end
