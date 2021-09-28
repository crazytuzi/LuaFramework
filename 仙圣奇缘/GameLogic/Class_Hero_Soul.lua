--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

--初始元神列表
function Class_Hero:initSoulItem(tbData)
	self.tbSoulList = {}
	self.nSoulListCount = 0
	if not tbData then return end
	for k, v in ipairs(tbData) do
		local Obj_Soul = Class_Soul.new()
		local nServerID = Obj_Soul:initSoulItemData(v)
		self.tbSoulList[nServerID] = Obj_Soul
		self.nSoulListCount = self.nSoulListCount + 1
	end
end

function Class_Hero:delSoul(nServerID)
	local Obj_Soul = self.tbSoulList[nServerID]
	if Obj_Soul then
		self.tbSoulList[nServerID] = nil
		self.bSortSoulLockAscend = nil
		self.bSortSoulLockDescend = nil
		self.nSoulListCount = math.max(self.nSoulListCount - 1, 0)
	end
end

function Class_Hero:setSoul(nServerID, nRemainNum)
	local Obj_Soul = self.tbSoulList[nServerID]
	if Obj_Soul then
		if nRemainNum > 0 then
			Obj_Soul:setNum(nRemainNum)
		else
			self.tbSoulList[nServerID] = nil
			self.bSortSoulLockAscend = nil
			self.bSortSoulLockDescend = nil
			self.nSoulListCount = math.max(self.nSoulListCount - 1, 0)
		end
	end
end

function Class_Hero:addSoul(tbData)

	local nServerID = tbData.drop_item_id
	local nAddNum = tbData.drop_item_num
	local Obj_Soul = self.tbSoulList[nServerID]
	if Obj_Soul then
		local num = Obj_Soul:getNum()
		Obj_Soul:setNum(num + nAddNum)
	else
		local Obj_Soul = Class_Soul.new()
		local nServerID = Obj_Soul:initSoulDropData(tbData)
		self.tbSoulList[nServerID] = Obj_Soul
	end
	
	self.bSortSoulLockAscend = nil
	self.bSortSoulLockDescend = nil
	self.nSoulListCount = self.nSoulListCount + 1
end

--元神正序排序
local function sortSoulAscendOrder(Obj_SoulA, Obj_SoulB)
	local nClassA = Obj_SoulA:getCsvBase().Class
	local nClassB = Obj_SoulB:getCsvBase().Class
	if nClassA == nClassB then
		local nStarLevelA = Obj_SoulA:getStarLevel()
		local nStarLevelB = Obj_SoulB:getStarLevel()
		if nStarLevelA == nStarLevelB then
			local nLevelA = Obj_SoulA:getCsvBase().Level
			local nLevelB = Obj_SoulB:getCsvBase().Level
			if nLevelA == nLevelB then
				local nCsvIDA = Obj_SoulA:getCsvID()
				local nCsvIDB = Obj_SoulB:getCsvID()
				if nCsvIDA == nCsvIDB then
					local nServerIDA = Obj_SoulA:getServerId()
					local nServerIDB = Obj_SoulB:getServerId()
					return nServerIDA < nServerIDB
				else
					return nCsvIDA < nCsvIDB
				end
			else
				return nLevelA < nLevelB
			end
		else
			return nStarLevelA < nStarLevelB
		end
	else
		return nClassA > nClassB
	end
end

--元神反序排序
local function sortSoulDescendOrder(Obj_SoulA, Obj_SoulB)
	local nClassA = Obj_SoulA:getCsvBase().Class
	local nClassB = Obj_SoulB:getCsvBase().Class
	if nClassA == nClassB then
		local nStarLevelA = Obj_SoulA:getStarLevel()
		local nStarLevelB = Obj_SoulB:getStarLevel()
		if nStarLevelA == nStarLevelB then
			local nLevelA = Obj_SoulA:getCsvBase().Level
			local nLevelB = Obj_SoulB:getCsvBase().Level
			if nLevelA == nLevelB then
				local nCsvIDA = Obj_SoulA:getCsvID()
				local nCsvIDB = Obj_SoulB:getCsvID()
				if nCsvIDA == nCsvIDB then
					local nServerIDA = Obj_SoulA:getServerId()
					local nServerIDB = Obj_SoulB:getServerId()
					return nServerIDA < nServerIDB
				else
					return nCsvIDA < nCsvIDB
				end
			else
				return nLevelA > nLevelB
			end
		else
			return nStarLevelA > nStarLevelB
		end
	else
		return nClassA < nClassB
	end
end

--获取排好正序的元神列表
function Class_Hero:getSoulListSortAscend()
	if not self.tbSoulListAscendOrder or not self.bSortSoulLockAscend then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortSoulLockAscend = true
		self.tbSoulListAscendOrder = {}
		for k, v in pairs (self.tbSoulList) do
			table.insert(self.tbSoulListAscendOrder, v)
		end
		table.sort(self.tbSoulListAscendOrder, sortSoulAscendOrder)
	end
	
	return self.tbSoulListAscendOrder
end

--获取排好反序的元神列表
function Class_Hero:getSoulListSortDescend()
	if not self.tbSoulListDescendOrder or not self.bSortSoulLockDescend then	--排序过一次之后上锁，当重新删除或新增的时候把锁打开
		self.bSortSoulLockDescend = true
		self.tbSoulListDescendOrder = {}
		for k, v in pairs (self.tbSoulList) do
			table.insert(self.tbSoulListDescendOrder, v)
		end
		table.sort(self.tbSoulListDescendOrder, sortSoulDescendOrder)
	end
	
	return self.tbSoulListDescendOrder
end

function Class_Hero:getDescendSoulByIndex(nIndex)
	if not self.tbSoulListDescendOrder or not self.bSortSoulLockDescend then
		self:getSoulListSortDescend()
	end
    return self.tbSoulListDescendOrder[nIndex]
end

function Class_Hero:getDescendSoulListCount()
	if not self.tbSoulListDescendOrder or not self.bSortSoulLockDescend then
		self:getSoulListSortDescend()
	end
    return #self.tbSoulListDescendOrder
end

function Class_Hero:getSoulListCount()
	return self.nSoulListCount
end
