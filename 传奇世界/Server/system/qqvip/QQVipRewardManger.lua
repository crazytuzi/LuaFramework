--QQVipRewardManger.lua
--/*-----------------------------------------------------------------
 --* Module:  QQVipRewardManger.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月8日
 -------------------------------------------------------------------*/

require ("system.qqvip.QQVipRewardServlet")
require ("system.qqvip.RoleQQVipRewardInfo")
require ("system.qqvip.QQVipRewardConstant")
--require ("system.qqvip.LuaQQVipRewardDAO")

QQVipRewardManger = class(nil, Singleton)

--全局对象定义
--g_LuaQQVipRewardDAO = LuaQQVipRewardDAO.getInstance()
g_QQVipRewardServlet = QQVipRewardServlet.getInstance()

function QQVipRewardManger:__init()
	self._roleQQVipRewardInfoBySID = {}

	g_listHandler:addListener(self)
end

function QQVipRewardManger:getQQVipRewardInfo(roleSID)
	print('QQVipRewardManger:getQQVipRewardInfo()')
	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning("not find player memInfo")
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning("not find player ")
		return
	end

	local ret = {}
	ret.info = {}

	local QQNoviceReward = {}
	QQNoviceReward.type = 1
	QQNoviceReward.status = self:getRewardStatus(player, memInfo:getQQVipNoviceReward(), 1)
	table.insert(ret.info, QQNoviceReward)
	local QQDailyReward = {}
	QQDailyReward.type = 2
	QQDailyReward.status = self:getRewardStatus(player, memInfo:getQQVipDailyReward(), 2)
	table.insert(ret.info, QQDailyReward)
	local QQVipChargeReward = {}
	QQVipChargeReward.type = 3
	QQVipChargeReward.status = self:getRewardStatus(player, memInfo:getQQVipChargeReward(), 3)
	table.insert(ret.info, QQVipChargeReward)
	local SVipNoviceReward = {}
	SVipNoviceReward.type = 4
	SVipNoviceReward.status = self:getRewardStatus(player, memInfo:getSVipNoviceReward(), 4)
	table.insert(ret.info, SVipNoviceReward)
	local SVipDailyReward = {}
	SVipDailyReward.type = 5
	SVipDailyReward.status = self:getRewardStatus(player, memInfo:getSVipDailyReward(), 5)
	table.insert(ret.info, SVipDailyReward)
	local SVipChargeReward = {}
	SVipChargeReward.type = 6
	SVipChargeReward.status = self:getRewardStatus(player, memInfo:getSVipChargeReward(), 6)
	table.insert(ret.info, SVipChargeReward)

	for _,v in pairs(ret.info) do
		print('type:',v.type, ' can received:',v.status)
	end

	fireProtoMessage(player:getID(), QQVIP_SC_REWARD_INFO, 'QQVipRewardInfoResult', ret)
end

function QQVipRewardManger:getRewardStatus(player, num, index)
	print('QQVipRewardManger:getRewardStatus()')
	if not player then
		warning('not find player')
		return 0
	end
	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find player memInfo')
		return 0
	end
	local status = 0
	if 0 < index and index <= 3 then
		local isQQVip = player:getQQVipStatus()
		if isQQVip == 1 then
			if num >= QQVIP_REWARD_COUNT[index] then
				status =  2
			else
				status = 1
			end
		end
		if index == 3 then
			if memInfo:getQQVipChargeRecord() <= 0 then
				status = 0
			end
		end
	end

	if 4 <= index and index <= 6 then
		local isSVip = player:getSVipStatus()
		if isSVip == 1 then
			if num >= QQVIP_REWARD_COUNT[index] then
				status =  2
			else
				status = 1
			end
		end
		if index == 6 then
			if memInfo:getSVipChargeRecord() <= 0 then
				status = 0
			end
		end
	end 
	return status
end

function QQVipRewardManger.onQQVipInfoChange(roleSID)
	self:getQQVipRewardInfo(roleSID)
end

function QQVipRewardManger:getReward(roleSID, id)
	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning("not find player memInfo")
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning("not find player ")
		return
	end
	print("QQVipRewardManger:getReward()", 'roleSID:', roleSID, 'QQRewardType:', id)
	local data = {}
	data.ret = 0
	if 0 < id and id <= 3  then
		if player:getQQVipStatus() == 1 then
			if  self:getRewawrdInfoByID(player, id) then
				self:updateRewardInfo(player, id)
				g_entityMgr:dropItemToEmail2(roleSID, QQVIP_REWARD_DROP_ID[id], player:getSex(), player:getSchool(), QQVIP_EMAIL_DESCID[id], QQVIP_EMIAL_SOURCE)
				data.ret = 1
			else
				g_QQVipRewardServlet:sendErrMsg2Client(player:getID(), QQVIPREWARD_RECEIVED, 0)
			end
		else
			--不是QQ会员
			g_QQVipRewardServlet:sendErrMsg2Client(player:getID(), QQVIPREWARD_NOT_QQVIP, 0)
		end
	elseif 4 <= id and id <= 8 then
		if player:getSVipStatus() == 1 then
			if self:getRewawrdInfoByID(player, id) then
				self:updateRewardInfo(player, id)
				g_entityMgr:dropItemToEmail2(roleSID, QQVIP_REWARD_DROP_ID[id], player:getSex(), player:getSchool(), QQVIP_EMAIL_DESCID[id], QQVIP_EMIAL_SOURCE)
				data.ret = 1
			else
				g_QQVipRewardServlet:sendErrMsg2Client(player:getID(), QQVIPREWARD_RECEIVED, 0)
			end
		else
			g_QQVipRewardServlet:sendErrMsg2Client(player:getID(), QQVIPREWARD_NOT_SVIP, 0)
		end
	end
	print('get reward ret:', data.ret)
	if data.ret == 1 then
		fireProtoMessage(player:getID(), QQVIP_SC_GET_REWARD, 'QQVipGetRewardResult', data)
		g_QQVipRewardServlet:sendErrMsg2Client(player:getID(), QQVIPREWARD_RECEIVE_SUCCESS, 0)
	end
end

function QQVipRewardManger:finishCharge(roleSID, chargeType, accessToken)
	print('QQVipRewardManger:finishCharge()', 'charteType: ', tonumber(chargeType))
	local chargeID = tonumber(chargeType)

	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning('not find memInfo')
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return
	end

	local moveSys = g_entityMgr:getMoveSystem()
	if not moveSys then
		warning('get moveSys failed')
		return
	end

	local query = false
	local flag = nil
	if chargeID == 1 or chargeID == 2 then
		query = true
		flag = "qq_vip"
		memInfo:setQQVipChargeRecord(memInfo:getQQVipChargeRecord() + 1)
		memInfo:cast2db()
	elseif chargeID == 3 or chargeID == 4 then
		query = true
		flag = "qq_svip"
		memInfo:setSVipChargeRecord(memInfo:getSVipChargeRecord() + 1)
		memInfo:cast2db()
	end

	if query then
		moveSys:queryQQFriendsVipInfo(player, flag, accessToken)
	end
end

function QQVipRewardManger.loadDBData(player, cache_buf, roleSid)
	print('QQVipRewardManger.loadDBData()', roleSid)
	if not player then
		warning('not find player')
		return
	end
	local memInfo = g_QQVipRewardMgr:getRoleQQVipInfo(player)
	if #cache_buf > 0 then
		print('memInfo load db data')
		memInfo:loadQQVipReardData(cache_buf)
	end
end

function QQVipRewardManger:getRoleQQVipInfo(player)
	if not player then
		warning('not find player')
		return
	end
	local roleSID = player:getSerialID()
	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		memInfo = RoleQQVipRewardInfo()
		memInfo:setRoleSID(roleSID)
		self._roleQQVipRewardInfoBySID[roleSID] = memInfo
	end
	return memInfo
end

function QQVipRewardManger:getRewawrdInfoByID(player,id)
	if not player then
		warning('not find player')
		return 
	end

	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find player info')
		return
	end
	print("QQVipRewardManger:getRewawrdInfoByID()", 'roleSID:', player:getSerialID(), 'QQRewardType:', id)
	if id == 1 then
		return memInfo:getQQVipNoviceReward() < QQVIP_REWARD_COUNT[1]
	elseif id == 2 then
		return memInfo:getQQVipDailyReward() < QQVIP_REWARD_COUNT[2]
	elseif id == 3 then
		return memInfo:getQQVipChargeReward() < QQVIP_REWARD_COUNT[3] and memInfo:getQQVipChargeRecord() > 0
	elseif id == 4 then
		return memInfo:getSVipNoviceReward() < QQVIP_REWARD_COUNT[4]
	elseif id == 5 then
		return memInfo:getSVipDailyReward() < QQVIP_REWARD_COUNT[5]
	elseif id == 6 then
		return memInfo:getSVipChargeReward() < QQVIP_REWARD_COUNT[6] and memInfo:getSVipChargeRecord() > 0
	end	
	return false
end

function QQVipRewardManger:updateRewardInfo(player,id)
	if not player then
		warning('not find player')
		return 
	end

	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find player info')
		return
	end
	print('QQVipRewardManger:updateRewardInfo()', id)
	if id == 1 then
		memInfo:setQQVipNoviceReward(memInfo:getQQVipNoviceReward() + 1)
	elseif id == 2 then
		memInfo:setQQVipDailyReward(memInfo:getQQVipDailyReward() + 1)
	elseif id == 3 then
		memInfo:setQQVipChargeReward(memInfo:getQQVipChargeReward() + 1)
		memInfo:setQQVipChargeRecord(memInfo:getQQVipChargeRecord() - 1)
	elseif id == 4 then
		memInfo:setSVipNoviceReward(memInfo:getSVipNoviceReward() + 1)
	elseif id == 5 then
		memInfo:setSVipDailyReward(memInfo:getSVipDailyReward() + 1)
	elseif id == 6 then
		memInfo:setSVipChargeReward(memInfo:getSVipChargeReward() + 1)
		memInfo:setSVipChargeRecord(memInfo:getSVipChargeRecord() - 1)
	else
		return
	end
	memInfo:cast2db()
end

function QQVipRewardManger:onPlayerLoaded(player)
	print('QQVipRewardManger:onPlayerLoaded()')
	local roleSID = player:getSerialID()
	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		print('not memInfo')
		return
	end

	local lastFrestTime = memInfo:getLastFreshTime()
	local now = tonumber(time.toedition("day"))
	--print('player load lastFrestTime:', lastFrestTime)
	if now ~= lastFrestTime then
		memInfo:freshDay()
	end

	local month = tonumber(time.toedition("month"))
	local lastFreshChargeTime = memInfo:getLastFreshChargeRewardTime()
	if month ~= lastFreshChargeTime then
		memInfo:freshChargeRewardTime()
	end
end

--玩家下线
function QQVipRewardManger:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		return
	end
	self._roleQQVipRewardInfoBySID[roleSID] = nil
end

--0点刷新
function QQVipRewardManger:onFreshDay()
	for roleSID,info in pairs(self._roleQQVipRewardInfoBySID) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player then
			info:freshDay()
		end
	end

	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		return
	end
	local month = tonumber(time.toedition("month"))
	local lastFreshChargeTime = memInfo:getLastFreshChargeRewardTime()
	if month < lastFreshChargeTime then
		memInfo:freshChargeRewardTime()
	end
end

function QQVipRewardManger:getPlayerInfoBySID(roleSID)
	return self._roleQQVipRewardInfoBySID[roleSID]
end

function QQVipRewardManger.getInstance()
	return QQVipRewardManger()
end

g_QQVipRewardMgr = QQVipRewardManger.getInstance()
