-- TimeDungeonData
require("app.cfg.time_dungeon_chapter_info")
require("app.cfg.time_dungeon_stage_info")
require("app.cfg.time_dungeon_info")
require("app.cfg.time_dungeon_reduce_info")


local TimeDungeonData = class("TimeDungeonData")

STATUS = {
	TIME_OUT = 1, --现在及未来都没有活动
	CURRENT = 2,  --现在就有活动
	FUTURE = 3,   --未来有活动
}
TimeDungeonData.STATUS = STATUS

---
-- @type DungeonTypeInfo
-- @field number _nTypeId 副本类型id
-- @field number _nStartTime 开始时间戳
-- @field number _nEndTime 结束时间戳

---
-- 当前关卡的信息，只保存当前关卡
-- @type DungeonInfo
-- @field number _nId 副本Id (1~36，6种副本*6种难度)
-- @field number _nTime 副本初始化时间戳
-- @field number _nIndex 当前副本索引（1~8）
-- @field number _nBuffId 鼓舞ID

function TimeDungeonData:ctor()

	-- 发布限时挑战活动时，可能会有连续的几种副本，比如1天一种，连续6天
	self._tDungeonTypeInfoList = nil
	-- 当前要被挑战的关起信息
	self._tCurDungeonInfo = nil
	-- 当前攻打的关卡的信息
	self._tAttackStageInfo = {
		_nStageId = 1,
		_nStageIndex = 1,
	}
	-- 当前鼓舞Buff字符串
	self._tCurInspireAttr = {
		_szAttackAttr = "",
		_szLifeAttr = "",
	}

end

-- msgBuff为cs.proto中定义的TimeDungeonInfo结构的数组
function TimeDungeonData:storeDungeonInfoList(msgBuff)
	self._tDungeonTypeInfoList = {}
	if msgBuff then
		for key, val in ipairs(msgBuff) do
			local tInfo = {}
			tInfo._nTypeId = val.type_id
			tInfo._nStartTime = val.start_time
			tInfo._nEndTime = val.end_time
			self._tDungeonTypeInfoList[tInfo._nTypeId] = tInfo
		end
	end

	local hasDungeon, nChapterId, nEndTime = self:currentTimeHasDungeon()
	if hasDungeon then
		G_HandlersManager.timeDungeonHandler:sendGetTimeDungeonInfo()
	end
end

function TimeDungeonData:storeDungeonInfoListWithFlush(msgBuff)
	self._tDungeonTypeInfoList = {}
	if msgBuff then
		for key, val in ipairs(msgBuff) do
			local tInfo = {}
			tInfo._nTypeId = val.type_id
			tInfo._nStartTime = val.start_time
			tInfo._nEndTime = val.end_time
			self._tDungeonTypeInfoList[tInfo._nTypeId] = tInfo
		end
	end

	local hasDungeon, nChapterId, nEndTime = self:currentTimeHasDungeon()
	if hasDungeon then
		G_HandlersManager.timeDungeonHandler:sendGetTimeDungeonInfo()
	else
		-- 发一个事件，检查当前还有没有活动，没有就把玩家T到征战界面, 主要应对把活动结束时间提前了
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_DUNGEON_CHECK_HAS_DUNGEON, nil, false)
	end
end

function TimeDungeonData:getDungeonTypeInfoList()
	return self._tDungeonTypeInfoList
end

-- 表示当前类型副本的当前关卡的信息
-- msgBuff为cs.proto中UserTimeDungeonInfo结构数据
function TimeDungeonData:updateCurDungeonInfo(msgBuff)
	if not self._tCurDungeonInfo then
		self._tCurDungeonInfo = {}
	end
	if msgBuff then
		local tInfo = {}
		tInfo._nId = msgBuff.id
		tInfo._nTime = msgBuff.time
		tInfo._nIndex = msgBuff.dungeon_index
		tInfo._nBuffId = msgBuff.buff_id
		self._tCurDungeonInfo = tInfo
	end
end

function TimeDungeonData:getCurDungeonInfo()
	return self._tCurDungeonInfo
end

-- 当前攻打的关卡的nStageId和nStageIndex
function TimeDungeonData:setAttackStageInfo(nStageId, nStageIndex)
	self._tAttackStageInfo._nStageId = nStageId
	self._tAttackStageInfo._nStageIndex = nStageIndex
end

function TimeDungeonData:getAttackStageInfo()
	return self._tAttackStageInfo
end

function TimeDungeonData:storeBattleResult(buff)
	self._tBattleResult = buff
end

function TimeDungeonData:getBattleResult()
	return self._tBattleResult
end

function TimeDungeonData:storeCurInspireAttr(szAttackAttr, szLifeAttr)
	self._tCurInspireAttr._szAttackAttr = szAttackAttr or ""
	self._tCurInspireAttr._szLifeAttr = szLifeAttr or ""
end

-- 伤害加成 
function TimeDungeonData:getCurAttackAttr()
	return self._tCurInspireAttr._szAttackAttr
end

-- 伤害减免
function TimeDungeonData:getCurLifeAttr()
	return self._tCurInspireAttr._szLifeAttr
end

-- 当前时间是否有限时挑战开启
function TimeDungeonData:hasDungeonOpened()
	
end

-- 是否打通了1到8关
function TimeDungeonData:isPassDungeon()
	if not self._tCurDungeonInfo then
		return true
	end
	if self._tCurDungeonInfo._nIndex == 0 then
		return true
	else	
		return false
	end
end

-- 判断当前有没有活动
function TimeDungeonData:currentTimeHasDungeon()
	if not self._tDungeonTypeInfoList then
		return false, nil, nil
	end

	-- 当前时间戳
	local nCurTime = G_ServerTime:getTime()
--	__Log("-- nCurTime = %d", nCurTime)
	for key, val in pairs(self._tDungeonTypeInfoList) do
		local tDungeonTypeInfo = val
		if tDungeonTypeInfo._nStartTime <= nCurTime and nCurTime < tDungeonTypeInfo._nEndTime then
		--	__Log("-- tDungeonTypeInfo._nTypeId = %d", tDungeonTypeInfo._nTypeId)
			return true, tDungeonTypeInfo._nTypeId, tDungeonTypeInfo._nEndTime
		end
	end

	return false, nil, nil
end

-- 判断当前活动是否打通关了
function TimeDungeonData:isFinishDungeon()
	local hasDungeon, nChapterId, nEndTime = self:currentTimeHasDungeon()
	if not hasDungeon then
		return true
	end
	return self:isPassDungeon()
end


-- 获取活动状态
function TimeDungeonData:getDungeonStatus()
	-- time out
	if not self._tDungeonTypeInfoList then
		return {_nStatus = STATUS.TIME_OUT}
	end

	-- 当前时间戳
	local nCurTime = G_ServerTime:getTime()
	local exitDungeon = false
	for key, val in pairs(self._tDungeonTypeInfoList) do
		local tDungeonTypeInfo = val
		if nCurTime < tDungeonTypeInfo._nEndTime then
			exitDungeon = true
			break
		end
	end

	if not exitDungeon then
		return {_nStatus = STATUS.TIME_OUT}
	else	
		local hasDungeon, nChapterId, nEndTime = self:currentTimeHasDungeon()
		if hasDungeon then
			-- 当前时间就有活动
			-- 掉落物品名称
			local szChapterName = ""
			local szMainProductName = ""
			local tChapterTmpl = time_dungeon_chapter_info.get(nChapterId or 1)
			if tChapterTmpl then
				local nType = tChapterTmpl.item_type
				local nValue = tChapterTmpl.item_value
				local nSize = 1
				local tGoods = G_Goods.convert(nType, nValue, nSize)
				szChapterName = tChapterTmpl.name
				szMainProductName = tGoods.name
			end

			local tData = {}
			tData._nStatus = STATUS.CURRENT
			tData._nChapterId = nChapterId
			tData._nEndTime = nEndTime
			tData._szMainProductName = szMainProductName
			tData._szChapterName = szChapterName

			return tData
		else
			-- 未来时间有活动,找到最近的一个活动
			local tFutureDungeonList = {}
			local nStarTime = 0
			for key, val in pairs(self._tDungeonTypeInfoList) do
				local tDungeonTypeInfo = val
				if nCurTime < tDungeonTypeInfo._nStartTime then
					table.insert(tFutureDungeonList, tDungeonTypeInfo)
				end
			end
			local function comp(typeInfo1, typeInfo2)
				if type(typeInfo1) ~= "table" or type(typeInfo2) ~= "table" then
					return false
				end
				return typeInfo1._nStartTime < typeInfo2._nStartTime
			end
			table.sort(tFutureDungeonList, comp)
			local tFutureDungeon = tFutureDungeonList[1]

			local szChapterName = ""
			local szMainProductName = ""
			local tChapterTmpl = time_dungeon_chapter_info.get(tFutureDungeon._nTypeId or 1)
			if tChapterTmpl then
				local nType = tChapterTmpl.item_type
				local nValue = tChapterTmpl.item_value
				local nSize = 1
				local tGoods = G_Goods.convert(nType, nValue, nSize)
				szChapterName = tChapterTmpl.name
				szMainProductName = tGoods.name
			end

			local tData = {}
			tData._nStatus = STATUS.FUTURE
			tData._nChapterId = tFutureDungeon._nTypeId
			tData._nStartTime = tFutureDungeon._nStartTime
			tData._nEndTime = tFutureDungeon._nEndTime
			tData._szMainProductName = szMainProductName
			tData._szChapterName = szChapterName

			return tData
		end
	end

end

return TimeDungeonData