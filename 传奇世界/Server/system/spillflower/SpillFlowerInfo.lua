--SpillFlowerInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  SpillFlowerInfo.lua
 --* Author:  liucheng
 --* Modified: 2016年3月2日
 --* Purpose: Implementation of the class SpillFlowerInfo
 -------------------------------------------------------------------*/
require "system.spillflower.SpillFlowerConstant"
 
SpillFlowerInfo = class()

local prop = Property(SpillFlowerInfo)
prop:accessor("UID")
prop:accessor("SID")

function SpillFlowerInfo:__init(UID, SID)
	prop(self, "UID", UID)
	prop(self, "SID", SID)
	
	self._remainGiveTime = {0,0,0,0}    --玩家能赠花的次数
	self._flowerRecords = {}
	self._timeTick = time.toedition("day")
end

function SpillFlowerInfo:getGiveTime(Type)
	if Type>4 or Type<=0 then return nil end
	local curTick = time.toedition("day")

	if curTick~=self._timeTick then
		self._timeTick = curTick
		self._remainGiveTime = {0,0,0,0}
	end
	
	if self._remainGiveTime then
		return self._remainGiveTime[Type]
	end
	
	return nil
end

function SpillFlowerInfo:setGiveTime(Type,value)
	if Type>4 or Type<=0 then return end
	if self._remainGiveTime then
		self._remainGiveTime[Type] = tonumber(value)
	end
	
	self:cast2DB()
end

function SpillFlowerInfo:addFlowerRecord(RoleName, tRoleName, giveStyle, giveNum, tick)
	local record = {}
	record.tick = tick
	record.Name = RoleName
	record.tName = tRoleName
	record.giveType = giveStyle
	record.giveNum = giveNum
	table.insert(self._flowerRecords, record)
	local tbNum = table.size(self._flowerRecords)
	--超过10条记录要删除多余的
	if tbNum > SPILLFLOWER_MAX_RECORD then
		table.remove(self._flowerRecords, 1)
	end
	
	self:cast2DB()
end

function SpillFlowerInfo:sendFlowerRecord()
	if self._flowerRecords then
		local Num = table.size(self._flowerRecords)		
		local sortFunc = function(a, b) return a.tick < b.tick end
		table.sort(self._flowerRecords, sortFunc)
		
		local player = g_entityMgr:getPlayerBySID(self:getSID())
		if not player then return end

		local retData = {}
		retData.recordCount = Num
		retData.recordInfo = {}
		for _,v in ipairs(self._flowerRecords) do
			local recordTmp = {}
			recordTmp.timeTick = v.tick
			recordTmp.sendName = v.Name
			recordTmp.receiveName = v.tName
			recordTmp.giveType = v.giveType
			recordTmp.giveNum = v.giveNum
			table.insert(retData.recordInfo,recordTmp)
		end
		fireProtoMessage(player:getID(),RELATION_SC_FLOWERRECORD_RET,"GetFlowerRecordRetProtocol",retData)
	end
end

function SpillFlowerInfo:loadDBData(data)
	if data then
		if data.t then
			local curTick = time.toedition("day")
			if curTick~=data.t then
				self._timeTick = curTick
				self._remainGiveTime = {0,0,0,0}
			else
				if data.g then
					self._remainGiveTime = data.g
				end
			end
		end
		
		if data.r then
			self._flowerRecords = data.r
		end
		
		local player = g_entityMgr:getPlayer(self:getUID())
		if not player then return end
		player:setTotalGlamour(data.allGlamour or 0)
	end
end

function SpillFlowerInfo:cast2DB()
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
	local roleSID = player:getSerialID()

	local dbStr = {t=self._timeTick,g=self._remainGiveTime,r=self._flowerRecords,allGlamour=player:getTotalGlamour()}
	local cache_buf = serialize(dbStr)
	g_engine:savePlayerCache(roleSID, FIELD_GIVEFLOWER, cache_buf, #cache_buf)	
end

function SpillFlowerInfo:switchOut(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_SPILLFLOWER_SETS)
	--具体数据跟在后面
	local arrowTimetick = g_SpillFlowerMgr:getUserArrowInfo(self:getSID())
	luaBuf:pushInt(arrowTimetick)
	luaBuf:pushInt(self._timeTick)
	luaBuf:pushString(serialize(self._remainGiveTime))
	luaBuf:pushString(serialize(self._flowerRecords))

	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

function SpillFlowerInfo:switchIn(luabuf)
	if luabuf:size() > 0 then
		local arrowTimetick = luabuf:popInt()		
		self._timeTick = luabuf:popInt()
		self._remainGiveTime = unserialize(luabuf:popString())
		self._flowerRecords = unserialize(luabuf:popString())
		g_SpillFlowerMgr:setUserArrowInfo(self:getSID(),arrowTimetick)
	end
end

function SpillFlowerInfo:dealOffData(dataTmp)
	if dataTmp then
		local player = g_entityMgr:getPlayerBySID(self:getSID())
		if not player then return end

		local data = unserialize(dataTmp)
		if data then
			if data.allGlamous and data.allGlamous>0 then
				local totalGlamourTmp = player:getTotalGlamour()
				player:setTotalGlamour(totalGlamourTmp + data.allGlamous)
			end

			if data.glamous and data.glamous>0 then
				local glamourTmp = player:getGlamour()
				player:setGlamour(glamourTmp + data.glamous)
			end

			if data.record then
				if table.size(data.record)>0 then
					table.sort(data.record, function(a,b) return a.tick < b.tick end)
				end

				for i=1,table.size(data.record) do
					local recordTmp = data.record[i]
					if recordTmp then
						self:addFlowerRecord(recordTmp.Name,recordTmp.tName,recordTmp.giveType,recordTmp.giveNum,recordTmp.tick)
					end
				end
			end
			self:cast2DB()			
		end
	end
end