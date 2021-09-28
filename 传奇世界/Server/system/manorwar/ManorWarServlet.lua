--ManorWarServlet.lua

ManorWarServlet = class(EventSetDoer, Singleton)

function ManorWarServlet:__init()
	self._doer = {
			[MANORWAR_CS_ENTERMANORWAR]	=		ManorWarServlet.doEnterManorWar,
			[MANORWAR_CS_PICKUPBANNER] =		ManorWarServlet.doPickUpBanner,
			[MANORWAR_CS_SIMPLEWARINFO] =		ManorWarServlet.doSimpleWarInfo,
			[MANORWAR_CS_GETALLREWARDINFO] = 	ManorWarServlet.doGetAllRewardInfo,
			[MANORWAR_CS_GETOWNFACTION] = 	ManorWarServlet.doGetOwnFaction,
			[MANORWAR_CS_PICKREWARD] = 			ManorWarServlet.doPickReward,
			[MANORWAR_CS_SENDOUT] = 			ManorWarServlet.doSendOut,
			[MANORWAR_CS_GET_LEADERINFO] = 	ManorWarServlet.doGetLeaderInfo,
			}
end

--给客户端发送错误提示的接口
function ManorWarServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_MANORWAR_SETS, errId, paramCount, params)
end

--获取领地奖励信息
function ManorWarServlet:doGetAllRewardInfo(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetAllRewardInfoProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doGetAllRewardInfo '..tostring(err))
		return
	end

	local roleSID = dbid
	local manorID = req.manorID


	g_manorWarMgr:getAllRewardInfo(roleSID, manorID)
end

function ManorWarServlet:doGetOwnFaction(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetOwnFactionProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doGetOwnFaction '..tostring(err))
		return
	end

	local roleSID = dbid
	g_manorWarMgr:getOwnFaction(roleSID)
end


--领取领地奖励
function ManorWarServlet:doPickReward(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("PickManorRewardProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doPickReward '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local manorID = req.manorID
	
	g_manorWarMgr:pickMonorReward(roleSID, manorID)
end

--传出王城地图
function ManorWarServlet:doSendOut(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ManorSendOutProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doSendOut '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	g_manorWarMgr:sendOut(player:getID())
end


--战况
function ManorWarServlet:doSimpleWarInfo(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("SimpleWarInfoProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doSimpleWarInfo '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local manorId = req.manorID

	if g_manorWarMgr:isManorActing(manorId) then
		g_manorWarMgr:writeManorInfo(roleSID, manorId)
	end

end
function ManorWarServlet:doGetLeaderInfo(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ManorGetLeaderInfoProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doGetLeaderInfo '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local manorId = req.manorID
	
	if not player then
		return
	end

	local manorInfo = g_manorWarMgr:getManorInfo(manorId)
	if not manorInfo then
		return
	end

	local factionID = manorInfo.factionID

	local faction = g_factionMgr:getFaction(factionID)
	local sex = 1
	local school = 1
	local name = ""
	if faction then
		local leader = faction:getMember(faction:getLeaderID())
		if leader then
			sex = leader:getSex()
			school = leader:getSchool()
			name = faction:getLeaderName()
		end 
	end

	local ret = {}
	ret.sex = sex
	ret.school = school
	ret.name = name
	fireProtoMessage(player:getID(), MANORWAR_SC_GET_LEADERINFO_RET, 'ManorGetLeaderInfoRetProtocol', ret)

end

--夺旗
function ManorWarServlet:doPickUpBanner(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("PickUpBannerProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doPickUpBanner '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	
	if player then
		local roleID = player:getID()
		local manorID = g_manorWarMgr:getManorIdByPlayer(player)
		if not g_manorWarMgr:isManorActing(manorID) then
			self:sendErrMsg2Client(roleID, MANOR_ERR_BANNER_NOTOPEN, 0)
			return
		end
		local manorProto = g_manorWarMgr:getManorProto(manorID)
		if not manorProto then 
			self:sendErrMsg2Client(roleID, MANOR_ERR_NO_MANORCONFIG, 0)
			return
		end
		if player:getFactionID() == 0  then
			self:sendErrMsg2Client(roleID, MANOR_ERR_NOT_LEADER, 0)
			return
		end

		local manorInfo = g_manorWarMgr:getManorInfo(manorID)
		if manorInfo.over then
			--提前结束
			self:sendErrMsg2Client(roleID, MANOR_ERR_MANORWAR_HAS_OVER, 0)
		elseif g_entityMgr:getPlayerBySID(manorInfo.bannerOwner) then
			--有人正在扛旗
			self:sendErrMsg2Client(roleID, MANOR_ERR_BANNERHAS_OWNER, 0)
		else
			local faction = g_factionMgr:getFaction(player:getFactionID())
			if not faction then
				return
			end

			if not isNearPos(player, manorProto:getMapID(), manorInfo.bannerPosX, manorInfo.bannerPosY) then
				return
			end

			if dbid == faction:getLeaderID() or dbid == faction:getAssLeaderID() then
				local factionMoney = faction:getMoney()
				if factionMoney >= manorProto:getBannerMoney() then
					faction:setMoney(factionMoney - manorProto:getBannerMoney())
					faction:NotifyFactionInfo()
					--夺旗数据记录处理
					g_manorWarMgr:changeBannerState(player, manorProto)
					--夺旗BUFF
					local buffmgr = player:getBuffMgr()
					buffmgr:addBuff(MANOR_BANNER_BUFFID, 0)
					--旗帜消失
					local banner = g_entityMgr:getMonster(manorInfo.bannerID)
					if banner then
						banner:quitScene()
					end

					player:notifyProp(PLAYER_BANNER, "1")
					self:sendErrMsg2Client(roleID, MANOR_PRIVITE_MSG, 1, {manorProto:getName()})
				else 
					self:sendErrMsg2Client(roleID, MANOR_ERR_NO_ENOUGHMONEY, 1, {manorProto:getBannerMoney()})
				end
			else
				self:sendErrMsg2Client(roleID, MANOR_ERR_NOT_LEADER, 0)
			end
		end
	end
end

--进入领地战场
function ManorWarServlet:doEnterManorWar(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("EnterManorWarProtocol" , pbc_string)
	if not req then
		print('ManorWarServlet:doEnterManorWar '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local manorID = req.manorID
	
	if player then
		local roleID = player:getID()
		if player:getFactionID() == 0  then
			self:sendErrMsg2Client(roleID, MANOR_ERR_NO_FACTION, 0)
				return
		else
			local faction = g_factionMgr:getFaction(player:getFactionID())
			if not faction then
				self:sendErrMsg2Client(roleID, MANOR_ERR_NO_FACTION, 0)
				return
			end
		end

		if player:getScene():switchLimitOut() then
			self:sendErrMsg2Client(roleID, MANOR_ERR_CAN_NOT_TRANS, 0)
			return
		end

		local manorProto = g_manorWarMgr:getManorProto(manorID)
		local manorInfo = g_manorWarMgr:getManorInfo(manorID)
		if not manorProto or not manorInfo then
			return
		end

		if not g_manorWarMgr:isManorActing(manorID) then
			self:sendErrMsg2Client(roleID, MANOR_ERR_NOT_FIT_MANOR, 0)
			return
		end

		local levelLimit = manorProto:getLevel() or 1 
		if player:getLevel() < levelLimit then
			self:sendErrMsg2Client(roleID, MANOR_ERR_LEVEL_NOT_ENOUGH, 0)
			return
		end


		if manorID == MANOR_MAINCITYWAR and not g_manorWarMgr:canJoinZhongZhou(roleSID) then
			self:sendErrMsg2Client(roleID, MANOR_ERR_CAN_NOT_JOIN_ZHONGZHOU, 0)
			return
		end

		local manorMapID = manorProto:getMapID()
		local suc, x, y = getRandPosInMap(manorMapID)
		if not suc then
			x = manorProto:getBannerPos()[1] or 1
			y = manorProto:getBannerPos()[2] or 2
		end

		if manorID ~= MANOR_MAINCITYWAR then
			g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.joinManorWar, 1)
			g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.MANOR_WAR)
		else
			g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.joinZhongzhouWar, 1)
			g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.CENTER_WAR)
		end

		if player:getMapID() == manorMapID then
			self:sendErrMsg2Client(roleID, MANOR_ERR_IN_MANOR, 0)
		else
			if g_sceneMgr:posValidate(manorMapID, x, y) then
				g_sceneMgr:enterPublicScene(player:getID(), manorMapID, x, y)
				
				g_manorWarMgr:setEnterTime(roleSID)	--记录进入领地战时间，用来记日志
				local factionID = player:getFactionID()
				local scene = g_sceneMgr:getPublicScene(manorMapID)

				if not scene then
					return
				end

				manorInfo.roles[roleSID] = manorInfo.roles[roleSID] or 0
				manorInfo.logRoles[roleSID] = factionID

				local ret = {}
				ret.factionID = manorInfo.factionID
				ret.manorID = manorID
				ret.facName = manorInfo.facName
				local player = g_entityMgr:getPlayerBySID(roleSID)
				if player then
					fireProtoMessage(player:getID(), MANORWAR_SC_NOTIFYOCCUPYFACTION, 'NotifyOccupyFactionProtocol', ret)
				end

				--记录日志
				local player = g_entityMgr:getPlayerBySID(roleSID)
				if player then
					player:setPattern(2)
					local manorType = 1
					if manorID == MANOR_MAINCITYWAR then
						manorType = 2
					end

					local facName = ""
					local faction = g_factionMgr:getFaction(factionID)
					if faction then
						facName = faction:getName()
					end
					g_tlogMgr:TlogHegemonyFlow(player, manorType, factionID, facName)
				end
			else
				g_sceneMgr:enterPublicScene(player:getID(), 1100, 21, 100)
			end
		end
	end
end


function ManorWarServlet.getInstance()
	return ManorWarServlet()
end

g_eventMgr:addEventListener(ManorWarServlet.getInstance())