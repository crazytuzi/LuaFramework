--RoleQQVipRewardInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleQQVipRewardInfo.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月8日
 -------------------------------------------------------------------*/

 RoleQQVipRewardInfo = class()

 local prop = Property(RoleQQVipRewardInfo)
prop:accessor("roleSID", "")
prop:accessor("roleID", 0)
prop:accessor("QQVipNoviceReward", 0)
prop:accessor("QQVipDailyReward", 0)
prop:accessor("QQVipChargeReward", 0)
prop:accessor("SVipNoviceReward", 0)
prop:accessor("SVipDailyReward", 0)
prop:accessor("SVipChargeReward", 0)
prop:accessor("QQVipChargeRecord", 0)
prop:accessor("SVipChargeRecord", 0)
prop:accessor("LastFreshTime", 0)
prop:accessor("LastFreshChargeRewardTime", 0)

function RoleQQVipRewardInfo:__init()

end

function RoleQQVipRewardInfo:cast2db()
	local cache_buff = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_QQVIP_INFO, cache_buff, #cache_buff)
	print('RoleQQVipRewardInfo:cast2db()')
	--self:printInfo()
end

function RoleQQVipRewardInfo:writeObject()
	local rewardInfo = {}
	rewardInfo.QQVipNoviceReward = self:getQQVipNoviceReward()
	rewardInfo.QQVipDailyReward = self:getQQVipDailyReward()
	rewardInfo.QQVipChargeReward = self:getQQVipChargeReward()
	rewardInfo.SVipNoviceReward = self:getSVipNoviceReward()
	rewardInfo.SVipDailyReward = self:getSVipDailyReward()
	rewardInfo.SVipChargeReward = self:getSVipChargeReward()
	rewardInfo.QQVipChargeRecord = self:getQQVipChargeRecord()
	rewardInfo.SVipChargeRecord = self:getSVipChargeRecord()
	if  self:getLastFreshTime() == 0 then
		local lastFrestTime = time.toedition("day")
		self:setLastFreshTime(lastFrestTime)
	end
	rewardInfo.LastFreshTime = self:getLastFreshTime()
	if self:getLastFreshChargeRewardTime() == 0 then
		if self:getSVipChargeRecord() ~= 0 or self:getQQVipChargeRecord() ~= 0 then
			local lastFrestTime = time.toedition("month")
			self:setLastFreshChargeRewardTime(lastFrestTime)
		end
	end
	rewardInfo.LastFreshChargeRewardTime = self:getLastFreshChargeRewardTime()

	return protobuf.encode("QQVipRewardProtocol", rewardInfo)
end

function RoleQQVipRewardInfo:loadQQVipReardData(cache_buf)
	print('RoleQQVipRewardInfo:loadQQVipReardData()')
	if #cache_buf > 0 then
		local datas,err = protobuf.decode("QQVipRewardProtocol", cache_buf)
		if not datas then
			print("RoleQQVipRewardInfo:loadQQVipReardData", err)
			return
		end
		--打印数据库数据
		-- print( ' QQVipNoviceReward:', datas.QQVipNoviceReward, 
		-- 	' QQVipDailyReward:',datas.QQVipDailyReward,
		-- 	' QQVipChargeReward:',datas.QQVipChargeReward,
		-- 	' SVipNoviceReward:',datas.SVipNoviceReward,
		-- 	' SVipDailyReward:',datas.SVipDailyReward,
		-- 	' SVipChargeReward:',datas.SVipChargeReward,
		-- 	' QQVipChargeRecord:',datas.QQVipChargeRecord,
		-- 	' SVipChargeRecord:',datas.SVipChargeRecord,
		-- 	' LastFreshTime:',datas.LastFreshTime,
		-- 	' LastFreshChargeRewardTime:',datas.LastFreshChargeRewardTime
		-- 	)

		self:setQQVipNoviceReward(datas.QQVipNoviceReward)
		self:setQQVipDailyReward(datas.QQVipDailyReward)
		self:setQQVipChargeReward(datas.QQVipChargeReward)
		self:setSVipNoviceReward(datas.SVipNoviceReward)
		self:setSVipDailyReward(datas.SVipDailyReward)
		self:setSVipChargeReward(datas.SVipChargeReward)
		self:setQQVipChargeRecord(datas.QQVipChargeRecord)
		self:setSVipChargeRecord(datas.SVipChargeRecord)
		self:setLastFreshTime(datas.LastFreshTime)
		self:setLastFreshChargeRewardTime(datas.LastFreshChargeRewardTime)
	end
end

function RoleQQVipRewardInfo:freshDay()
	if self:notFreshRewardInfo() then
		return
	end
	self:setQQVipDailyReward(0)
	self:setSVipDailyReward(0)
	local lastFrestTime = time.toedition("day")
	self:setLastFreshTime(tonumber(lastFrestTime))
	self:cast2db()
end

function RoleQQVipRewardInfo:notFreshRewardInfo()
	if self:getLastFreshTime() == 0 then
		return true
	end
	if self:getSVipDailyReward() == 0 and self:getQQVipDailyReward() == 0 then
		return true
	end
end

function RoleQQVipRewardInfo:notFreshChargeInfo()
	if self:getLastFreshChargeRewardTime() == 0 then
		return true
	end

	if self:getSVipChargeRecord() == 0 and self:getQQVipChargeRecord() == 0 then
		return true
	end
end

function RoleQQVipRewardInfo:freshChargeRewardTime()
	if self:notFreshChargeInfo() then
		return
	end
	self:setQQVipChargeReward(0)
	self:setSVipChargeReward(0)
	self:setQQVipChargeRecord(0)
	self:setSVipChargeRecord(0)
	local lastFrestTime = time.toedition("month")
	self:setLastFreshChargeRewardTime(lastFrestTime)
	self:cast2db()
end

function RoleQQVipRewardInfo:printInfo()
	print( ' QQVipNoviceReward:', self:getQQVipNoviceReward(), 
			' QQVipDailyReward:',self:getQQVipDailyReward(),
			' QQVipChargeReward:',self:getQQVipChargeReward(),
			' SVipNoviceReward:',self:getSVipNoviceReward(),
			' SVipDailyReward:',self:getSVipDailyReward(),
			' SVipChargeReward:',self:getSVipChargeReward(),
			' QQVipChargeRecord:',self:getQQVipChargeRecord(),
			' SVipChargeRecord:',self:getSVipChargeRecord(),
			' LastFreshTime:',self:getLastFreshTime(),
			' LastFreshChargeRewardTime:',self:getLastFreshChargeRewardTime()
			)
end
