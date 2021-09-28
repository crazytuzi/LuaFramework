--TreasureRoleInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  TreasureRoleInfo.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月11日
 -------------------------------------------------------------------*/

TreasureRoleInfo = class()

local prop = Property(TreasureRoleInfo)
prop:accessor("roleSID", 0)
prop:accessor("JoinCount", 0)
prop:accessor("LastFreshTime", 0)
prop:accessor("treasureMapID", 0)
prop:accessor("startTime", 0)
prop:accessor("endTime", 0)
prop:accessor("usedTime", 0)
prop:accessor("Experience", false)

function RoleQQVipRewardInfo:__init()
end

function TreasureRoleInfo:loadTreasureData(cache_buf)
	if #cache_buf > 0 then
		local datas,err = protobuf.decode("TreasureInfoProtocol", cache_buf)
		if not datas then
			print("TreasureRoleInfo:loadTreasureData", err)
			return
		end
		--print('load db data', datas.joinCount, datas.lastFreshTime, datas.usedTime)
		self:setJoinCount(datas.joinCount)
		self:setLastFreshTime(datas.lastFreshTime)
		self:setUsedTime(datas.usedTime)
	end
end

function TreasureRoleInfo:cast2db()
	local treasureInfo = {}
	treasureInfo.joinCount = self:getJoinCount()
	if self:getLastFreshTime() == 0 then
		local lastFreshTime = time.toedition("day")
		self:setLastFreshTime(tonumber(lastFreshTime))
	end
	treasureInfo.lastFreshTime = self:getLastFreshTime()
	treasureInfo.usedTime = self:getUsedTime()
	local cache_buf = protobuf.encode("TreasureInfoProtocol", treasureInfo)
	print('joinCount:', treasureInfo.joinCount,'lastFreshTime:', treasureInfo.lastFreshTime, 'usedTime:', treasureInfo.usedTime)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_TREASURE, cache_buf, #cache_buf)
end

function TreasureRoleInfo:freshDay()

	self:setJoinCount(0)
	self:setUsedTime(0)
	local lastFreshTime = time.toedition("day")
	self:setLastFreshTime(tonumber(lastFreshTime))
	self:cast2db()
end

function TreasureRoleInfo:print()
	print("roleSID", self:getRoleSID())
	print("JoinCount", self:getJoinCount())
	print("LastFreshTime", self:getLastFreshTime())
	print("treasureMapID", self:getTreasureMapID())
	print("startTime", self:getStartTime())
	print("endTime", self:getEndTime())
	print("usedTime", self:getUsedTime())
end
