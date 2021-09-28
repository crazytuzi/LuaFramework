--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	卡牌技能和丹药业务层逻辑
-- 应  用:
---------------------------------------------------------------------------------------

--获取伙伴镶嵌异兽信息
function Class_Card:getFateIdList()
	return self.tbFateIdList
end

--通过位置获取伙伴镶嵌异兽信息
function Class_Card:getFateIDByPos(nPos)
	if(not nPos)then
		return nil
	end

	return self.tbFateIdList[nPos]
end

--根据名ID判断异兽是否被镶嵌
function Class_Card:IsHaveFate(nFateID)
	for i=1, #self.tbFateIdList do
		if self.tbFateIdList[i] == nFateID then
			return true
		end
	end
	return false
end

--根据异兽ID获取异兽被镶嵌的位置
function Class_Card:getFatePosIndex(nFateID)
	for i=1, #self.tbFateIdList do
		if self.tbFateIdList[i] == nFateID then
			return i
		end
	end
end

--获取异兽空位
function Class_Card:getEmptyFatePosIndex()
	local nReleaseCount = self:getFateReleasePosCount()
	for nPosIndex = 1, nReleaseCount do
		if not self.tbFateIdList[nPosIndex] or self.tbFateIdList[nPosIndex] <= 0 then
			return nPosIndex
		end
	end
end

--设置某种类型的ID
function Class_Card:setFatePosIndexInType(nFateType, nPosIndex)
	self.tbFatePosIndexInType[nFateType] = nPosIndex
end

--判断某种类型的异兽是否已装备
function Class_Card:checkFateTypeIsInLay(nFateType)
	return self.tbFatePosIndexInType[nFateType] > 0
end

--获取已解锁的异兽槽数量
function Class_Card:getFateReleasePosCount()
	local CSV_CardFateRelease = g_DataMgr:getCsvConfig("CardFateRelease")
	for k, v in ipairs(CSV_CardFateRelease) do
		if (self:getLevel() < tonumber(v.RealeaseLevel)) then
			return k - 1
		end
	end
	return 8
end

--判断某个异兽槽是否有可镶嵌的异兽
function Class_Card:checkIsCanEquipFateByPosIndex(nPosIndex)
	if self.nLevel < g_DataMgr:getCardFateReleaseCsvLevel(nPosIndex) then return false end
	
	local nFateID = self:getFateIDByPos(nPosIndex)
	if nFateID > 0 then return false end
	for nFateType = 1, 16 do
		if not self:checkFateTypeIsInLay(nFateType) then
			if g_Hero:getFateUnDressedAmmountByType(nFateType) > 0 then
				return true
			end
		end
	end
	
	return false
end

--判断某种类型的异兽是否被镶嵌、及其镶嵌的位置
function Class_Card:checkFateTypeIsInLayWithPosIndex(nFateType)
	return self.tbFatePosIndexInType[nFateType] > 0, self.tbFatePosIndexInType[nFateType]
end

--设置某个异兽位置镶嵌的异兽ID
function Class_Card:setFateID(nPos, nServerID)
	if(not nPos or not nServerID)then
		return
	end
	self.tbFateIdList[nPos] = nServerID
end

--命力,即获取镶嵌的所有经验总和
function Class_Card:getFateExp()
	local nFateExp = 0
	for i=1, #self.tbFateIdList do
		if self.tbFateIdList[i] > 0 then
			local tbFateInfo = g_Hero:getFateInfoByID(self.tbFateIdList[i])
			if tbFateInfo then
				local CSV_CardFate = tbFateInfo:getCardFateCsv()
				nFateExp = nFateExp + CSV_CardFate.AddExp + tbFateInfo.nFateExp
			end
		end
	end
	return nFateExp
end
