--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	魂魄数据
-- 应  用:
---------------------------------------------------------------------------------------

--初始化魂魄列表
function Class_Hero:initHunPoList(tbData)
	self.tbHunPoList = {}
	local tbHunPoList = tbData.godinfo
	if(tbHunPoList)then
		for i = 1, #tbHunPoList do
			local tbHunPo = tbHunPoList[i]
			local Obj_HunPo = Class_HunPo.new()
			local nServerID = Obj_HunPo:initHunPoData(tbHunPo)
			self.tbHunPoList[nServerID] = Obj_HunPo
		end
	end
end

--获取魂魄的策划表格配置
function Class_Hero:getHunPoObj(nCsvID)
	for key, value in pairs(self.tbHunPoList) do
		if value.nCsvID == nCsvID  then
			return value
		end
	end
	return nil
end

--获取魂魄数据
function Class_Hero:getHunPoObjByServID(nServerID)
	if self.tbHunPoList[nServerID] then
		return self.tbHunPoList[nServerID]
	end
	return nil
end

--删除魂魄
function Class_Hero:delHunPo(nServerID, nSubNum)
	local Obj_HunPo = self.tbHunPoList[nServerID]
	if Obj_HunPo then
		local nRemainNum = math.max(0, Obj_HunPo:getNum() - nSubNum)
		if(nRemainNum <= 0)then
			self.tbHunPoList[nServerID] = nil
			self.bSortHunPoLock = nil
		else
			Obj_HunPo:setNum(nRemainNum)
		end
	end
end

--增加魂魄
function Class_Hero:addHunPo(tbData)
	local nServerID = tbData.drop_item_id
	local nAddNum = tbData.drop_item_num
	local Obj_HunPo = self.tbHunPoList[nServerID]
	if Obj_HunPo then
		local nRemainNum = Obj_HunPo:getNum()
		Obj_HunPo:setNum(nRemainNum + nAddNum)
	else
		local Obj_HunPo = Class_HunPo.new()
		local nServerID = Obj_HunPo:initHunPoDataDrop(tbData)
		self.tbHunPoList[nServerID] = Obj_HunPo
		self.bSortHunPoLock = nil
	end
end

--更新魂魄
function Class_Hero:setHunPoNum(nServerID, nRemainNum)
	local Obj_HunPo = self.tbHunPoList[nServerID]
	if Obj_HunPo then
		if nRemainNum > 0 then
			Obj_HunPo:setNum(nRemainNum)
		else
			self.tbHunPoList[nServerID] = nil
			self.bSortHunPoLock = nil
		end
	end
end

--魂魄排序
local function sortHunPoAscendOrder(Obj_HunPoA, Obj_HunPoB)
	local nStarLevelA = Obj_HunPoA:getCsvBase().CardStarLevel
	local nStarLevelB = Obj_HunPoB:getCsvBase().CardStarLevel
	if nStarLevelA == nStarLevelB then
		local nCsvIDA = Obj_HunPoA:getCsvID()
		local nCsvIDB = Obj_HunPoB:getCsvID()
		return nCsvIDA < nCsvIDB
	else
		return nStarLevelA > nStarLevelB
	end
end

--获取排好序的魂魄列表
function Class_Hero:getHunPoListSortAscend()
	if not self.bSortHunPoLock then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortHunPoLock = true
		self.tbHunPoListAscendOrder = {}
		for k, v in pairs (self.tbHunPoList) do
			table.insert(self.tbHunPoListAscendOrder, v)
		end
		table.sort(self.tbHunPoListAscendOrder, sortHunPoAscendOrder)
	end
	
	return self.tbHunPoListAscendOrder
end