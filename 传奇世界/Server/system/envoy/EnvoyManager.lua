--EnvoyManager.lua
--/*-----------------------------------------------------------------
 --* Module:  EnvoyManager.lua
 --* Author:  seezon
 --* Modified: 2014年11月26日
 --* Purpose: Envoy管理器
 -------------------------------------------------------------------*/
require ("system.envoy.EnvoyServlet")
require ("system.envoy.RoleEnvoyInfo")
require ("system.envoy.EnvoyConstant")
require ("system.envoy.LuaEnvoyDAO")

--炼狱体验信息
 EnvoyExperienceInfo = class()
 local prop = Property(EnvoyExperienceInfo)
prop:accessor("roleID", 0)
prop:accessor("startTime", 0)
prop:accessor("endTime", 0)

function EnvoyExperienceInfo:__init()
end


EnvoyManager = class(nil, Singleton, Timer)

--全局对象定义
g_LuaEnvoyDAO = LuaEnvoyDAO.getInstance()
g_EnvoyServlet = EnvoyServlet.getInstance()

function EnvoyManager:__init()
	--self._roleEnvoyInfos = {} --运行时ID
	self._roleEnvoyInfoBySID = {} --数据库ID
	self._needFreshRoles = {}	--需定时刷新的role
	self._startTime = 0
	self:resetData()
	self:loadMonsterInfo()
	self._bossFreshFlag = {false, false, false} --BOSS刷新标志
	self._boss = {} --BOSS
	g_listHandler:addListener(self)

	gTimerMgr:regTimer(self, 1000, 1000)
	--进入等级
	self._needLvl = g_normalLimitMgr:getJoinLevel(ACTIVITY_NORMAL_ID.ENVOY)

	--经验buff相关
	self._buffInfo = {}
	self._buffRate = {}
	self:pareBuffData()
end

function EnvoyManager:pareBuffData()
	local records = require "data.BuffDB" 
	for _, data in pairs(records or {}) do
		local tmp = {}
		if EnvoyBuffer[1]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[1] = tmp
		elseif EnvoyBuffer[2]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[2] = tmp
		elseif EnvoyBuffer[3]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[3] = tmp
		elseif EnvoyBuffer[4]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[4] = tmp
		elseif EnvoyBuffer[5]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[5] = tmp
		elseif EnvoyBuffer[6]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[6] = tmp
		elseif EnvoyBuffer[7]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[7] = tmp
		elseif EnvoyBuffer[8]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[8] = tmp
		elseif EnvoyBuffer[9]==data.id then
			tmp._AddEXP = tonumber(data.upEXP) or 0
			tmp._AddSpace = tonumber(data.spaceTime)/1000 or 10
			self._buffInfo[9] = tmp
		end
		if table.size(self._buffInfo) == 9 then
			break
		end
	end

	local buffRateCfg = require "data.purgatory" 
	for _,v in pairs(buffRateCfg) do
		local temp = {}
		temp.time = tonumber(v.q_min)
		temp.rate = tonumber(v.beishu)
		table.insert(self._buffRate, temp)
	end
	table.sort(self._buffRate, function(lhs, rhs) return lhs.time <= rhs.time end)
end

function EnvoyManager:loadMonsterInfo()
	self._monsterInfos = {}
	local records = require "data.MonsterInfoDB"
	for i, record in pairs(records or {}) do
		self._monsterInfos[record.q_id] = record
	end
end

function EnvoyManager:getMonsterInfoPos(id)
	local info = self._monsterInfos[id]
	if info then
		return info.q_center_x,info.q_center_y
	end
	return 0,0
end

--重置变量
function EnvoyManager:resetData()
	self._openFlag = false
	self._startTime = 0
	self._bossFreshFlag = {false, false, false} --BOSS刷新标志
	self._boss = {} --BOSS
end

--玩家上线
function EnvoyManager:onPlayerLoaded(player)
	print('EnvoyManager:onPlayerLoaded()')
	if not player then
		warning('not find player')
		return
	end
	local memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find player memInfo')
		return
	end
	--上线打印db数据
	memInfo:print()
	local lastJoinTime = memInfo:getLastJoinTime()
	local now = tonumber(time.toedition("day"))
	if now ~= lastJoinTime  and memInfo:getLastJoinTime() ~= 0 then
		print('different day reset data')
		memInfo:setLastJoinTime(now)
		memInfo:setStayTime(0)
		memInfo:cast2db()
	end
end

--玩家下线
function EnvoyManager:onPlayerOffLine(player)
	if not player then
		warning('no find player')
		return
	end
	local roleSID = player:getSerialID()
	self:sendOut(roleSID)
	
	--self._roleEnvoyInfos[player:getID()] = nil --运行时ID
	self._roleEnvoyInfoBySID[roleSID] = nil --数据库ID
end

--玩家掉线
function EnvoyManager:onPlayerInactive(player)
	local roleSID = player:getSerialID()
	self:sendOut(roleSID)
end

--活动开启
function EnvoyManager:openEnvoy()
	if not self._openFlag then
		self._openFlag = true
		self._startTime = os.time()
	end
end

--活动关闭
function EnvoyManager:closeEnvoy()
	if self._openFlag then
		self:sendAllOut()
		--释放BOSS
		for _,mon in pairs(self._boss) do
			g_entityMgr:destoryEntity(mon:getID())
		end

		self._openFlag = false
		self:resetData()
	end
end

--判断参加活动的条件
function EnvoyManager:canJoin(player, floorNum)
	if not player then
		return false
	end

	if not self._openFlag then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_NOT_OPEN, 0)
		return false
	end

	if player:getScene() and player:getScene():switchLimitOut() then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_CAN_NOT_TRANS, 0)
		return false
	end

	if g_copyMgr:inCopyTeam(player:getID()) then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_IN_COPYTEAM, 0)
		return false
	end

	if player:getLevel() < self._needLvl then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_LEVEL_NOT_ENOUGH, 1, {self._needLvl})
		return false
	end

	--炼狱凭证
	if not isMatEnough(player, ENVOY_COST_MAT[math.ceil(floorNum/3)], 1) then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_MAT_NOT_ENOUGH[math.ceil(floorNum/3)], 0)
		return false
	end

	return true
end

--判断参加活动的条件
function EnvoyManager:canJoin2(player)
	if not player then
		return false
	end

	if not self._openFlag then
		return false
	end

	if player:getScene() and player:getScene():switchLimitOut() then
		return false
	end

	if g_copyMgr:inCopyTeam(player:getID()) then
		return false
	end

	if player:getLevel() < self._needLvl then
		return false
	end
	return true
end

--玩家参加重装使者
function EnvoyManager:join(roleID, floorNum , bExperience)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		warning('not find palyer')
		return false
	end

	local floor = (floorNum-1)*3 + 1
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	print('EnvoyManager:join()', roleID, roleSID, bExperience)

	if not bExperience and not self:canJoin(player, floor) then
		return false
	end

	local memInfo = self:getRoleEnvoyInfoBySID(roleSID)
	if not memInfo then
		warning('not find player info')
		return false
	end

	if not bExperience then
		--扣除道具
		local isCost = costMat(player, ENVOY_COST_MAT[math.ceil(floor/3)], 1, 48, 0)
		if not isCost then return false end
	end
	memInfo:setCurFloor(floor) --获取实际进入的层数
	g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.ENVOY)
	memInfo:setTicketNum(memInfo:getTicketNum() + 1)
	--第一次传送到重装使者一层
	if self:sendPlayer(roleID) then
		local lastJoinTime = memInfo:getLastJoinTime()
		local nowDate = tonumber(time.toedition("day"))
		if not bExperience and nowDate ~= lastJoinTime  and memInfo:getLastJoinTime() ~= 0 then
			print('different day reset data')
			memInfo:setLastJoinTime(now)
			memInfo:setStayTime(0)
		end
		local now = os.time()
		memInfo:setStartTime(now)
		local totalTime = ENVOY_ONE_TIME
		if bExperience then
			totalTime = ENVOY_EXPERIENCE_TIME
			memInfo:setExperience(true)
		else
			memInfo:setKillNum(0)
			memInfo:setKilledNum(0)
		end
		memInfo:setEndTime(now + totalTime)
		--泡点buff,体验卡不增加泡点经验
		if not bExperience then
			local buffmgr = player:getBuffMgr()
			if buffmgr then
				buffmgr:addBuff(EnvoyBuffer[floor], 0)
				print('add buff:',EnvoyBuffer[floor])
			end
		end
		self._needFreshRoles[roleSID] = memInfo
		fireProtoMessage(roleID, ENVOY_SC_JOIN_RET, "EnvoyJoinRet", {})
		g_tlogMgr:TlogHDFlow(player,4)

		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.joinEnvoy)
		g_ActivityMgr:sevenFestivalChange(roleID, ACTIVITY_ACT.ENVOY, 1)
		--活动记录
		g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.ENVOY)
	else
		--提示传送失败
		g_EnvoyServlet:sendErrMsg2Client(roleID, ENVOY_ERR_NOT_SEND_FAIL, 0)
		return false
	end
	return true
end

--玩家进入下一层
function EnvoyManager:enterNext(roleID, option)
	print('EnvoyManager:enterNext('..roleID..','..option..')')
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		warning('not find player')
		return
	end
	local memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find role envoy memInfo')
		return
	end

	local curfloor = memInfo:getCurFloor()
	--当前炼狱等级,1:初级，2：中级，3：高级
	local curMode = math.ceil(curfloor/3)
	local bExper = memInfo:getExperience()
	if option == 1 then
		if EnvoyFloorMin[curMode] <= curfloor - 1 then
			memInfo:setCurFloor(curfloor - 1)
			if not bExper then
				--泡点buff
				local buffmgr = player:getBuffMgr()
				if buffmgr then
					buffmgr:delBuff(EnvoyBuffer[curfloor])
					buffmgr:addBuff(EnvoyBuffer[curfloor - 1], 0)
				end
			end
		else
			return
		end 
	elseif option == 0 then
		print('maxfloor:',EnvoyFloorMax[curMode], 'curfloor:', curfloor)
		if EnvoyFloorMax[curMode] >= curfloor + 1 then
			memInfo:setCurFloor(curfloor + 1)
			if not bExper then
				local buffmgr = player:getBuffMgr()
				if buffmgr then
					buffmgr:delBuff(EnvoyBuffer[curfloor])
					buffmgr:addBuff(EnvoyBuffer[curfloor + 1], 0)
				end
			end
		else
			print('cur floor is max:',curfloor)
			return
		end
	end

	local sendSuccess = self:sendPlayer(roleID)

	if sendSuccess then
		--传送成功就通知客户端
		fireProtoMessage(roleID, ENVOY_SC_ENTER_NEXT_RET, "EnvoyEnterNextRet", {})
	end
end

--玩家退出重装使者
function EnvoyManager:out(roleSID)
	print('EnvoyManager:out()', roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)

	if not player then
		warning('not find player')
		return
	end

	self:sendOut(roleSID)
	fireProtoMessage(player:getID(), ENVOY_SC_OUT_RET, "EnvoyOutRet", {})
end

--获取玩家当前层数和结束时间
function EnvoyManager:getRoleInfo(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		print("not find player")
		return
	end
	local memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find role envoy memInfo')
		return
	end

	--发送结束时间和层数
	local ret = {}
	ret.floor = memInfo:getCurFloor()
	ret.endTime = memInfo:getEndTime() - os.time()
	ret.isExperience = memInfo:getExperience()
	fireProtoMessage(roleID, ENVOY_SC_GET_INFO_RET, 'EnvoyGetInfoRet', ret)
end

function EnvoyManager:again(roleID)
	print("EnvoyManager:again(roleID) again", roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return  end

	if not self._openFlag then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_NOT_OPEN, 0)
	end
	
	local memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if not memInfo then return end
	
	--不在时间范围内
	local endTime = memInfo:getEndTime()
	if endTime < os.time() then return	end
	
	local curfloor = memInfo:getCurFloor()
	
	--扣除道具
	if not isMatEnough(player, ENVOY_COST_MAT[math.ceil(curfloor/3)], 1) then
		g_EnvoyServlet:sendErrMsg2Client(player:getID(), ENVOY_ERR_MAT_NOT_ENOUGH[math.ceil(curfloor/3)], 0)
		--return false
	end	
	local isCost = costMat(player, ENVOY_COST_MAT[math.ceil(curfloor/3)], 1, 48, 0)
	if not isCost then return end
	memInfo:setTicketNum(memInfo:getTicketNum() + 1)
	memInfo:setEndTime(endTime + ENVOY_ONE_TIME)
	local ret = {}
	ret.endTime = memInfo:getEndTime() - os.time()

	fireProtoMessage(roleID, ENVOY_SC_AGAIN_RET, "EnvoyAgainRet", ret)
end

--定时器更新
function EnvoyManager:update()
	if self._startTime <= 0 then
		return
	end

	for i=1, 3 do
		local proto = g_LuaEnvoyDAO:getProto(i)
		local freshTime = tonumber(proto.q_freshTime) * 60

		if not self._bossFreshFlag[i] and os.time() > (self._startTime + freshTime) then
			self:freshMonster(proto)
			self._bossFreshFlag[i] = true
		end
	end
	
	--踢出超时玩家
	local now = os.time()
	for i, v in pairs(self._needFreshRoles) do 
		if v:getEndTime() < now then
			self:out(i)
		else
			local bExper = v:getExperience()
				if not bExper then
				--buff exp
				local curfloor = v:getCurFloor()
				local spaceTime = self._buffInfo[curfloor]._AddSpace
				if  now - v:getLastAddExpTime() >= spaceTime then
					v:setLastAddExpTime(now)
					local stayTime = now - v:getStartTime() + v:getStayTime()
					local rate = 0
					for _,v in pairs(self._buffRate) do
						if stayTime <= v.time * 60 or v.time == 9999 then
							rate = v.rate
							break
						end
					end
					local player = g_entityMgr:getPlayer(v:getRoleID())
					if not player then
						warning('not find player')
						return
					end
					local exp = self._buffInfo[curfloor]._AddEXP * rate / 100
					addExpToPlayer(player,exp,48)
					local retData = {}
					retData.type = 0
					retData.value = exp
					fireProtoMessage(player:getID(), FRAME_SC_PICKUP, 'FramePickUpRetProtocol', retData)
				end
			end
		end
	end	
end

--传送到地图某个位置
function EnvoyManager:sendPlayer(roleID)
	print('EnvoyManager:sendPlayer('..roleID..')')
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		print('not find player')
		return false
	end

	local memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if not memInfo then
		print('not find memInfo')
		return false
	end

	local sendFloor = memInfo:getCurFloor()
	if sendFloor > table.size(ENVOYMAPID) then
		sendFloor = table.size(ENVOYMAPID)
	end
	local mapID = ENVOYMAPID[sendFloor]
	if not mapID then
		print("map error", mapID)
		return false
	end

	--同一个地图不处理
	local curMapID = player:getMapID()
	if mapID == curMapID then
		print("地图传送相同", curMapID, mapID)
		return false
	end

	local proto = g_LuaEnvoyDAO:getProto(sendFloor)
	local enterPos = tostring(proto.q_enter_xy)
	local splite = string.find(enterPos, ',') 
	local x = tonumber(string.sub(enterPos, 1, splite - 1))
	local y = tonumber(string.sub(enterPos, splite + 1))
	if g_sceneMgr:posValidate(mapID, x, y) then
		if sendFloor == EnvoyFloorMin[1] or sendFloor == EnvoyFloorMin[2] or sendFloor == EnvoyFloorMin[3] then
			local position = player:getPosition()
			player:setLastMapID(player:getMapID())
			player:setLastPosX(position.x)
			player:setLastPosY(position.y)
		end
		g_sceneMgr:enterPublicScene(roleID, mapID, x, y, 1)
		return true
	end
	return false
end

--把玩家踢出活动地图，回到原始地图
function EnvoyManager:sendOut(roleSID)
	print('EnvoyManager:sendOut()', roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)

	if not player then
		warning('not find player')
		return
	end
	local roleID = player:getID()
	
	local memInfo = self:getRoleEnvoyInfoBySID(roleSID)
	--已经不在地图中的就不处理了
	local curMapID = player:getMapID()
	if not table.contains(ENVOYMAPID, curMapID) then
		return
	end

	--设置初始复活地点，防止自动复活回地图
	player:setReliveMapID(1100)
	player:setReliveX(17)
	player:setReliveY(85)
	local  sing = player:getSing()

	if memInfo then
		local bExper = memInfo:getExperience()
		--clear buff
		if not bExper then 
			local buffmgr = player:getBuffMgr()
			if buffmgr then
				print('quit scene delbuff:', EnvoyBuffer[memInfo:getCurFloor()])
				buffmgr:delBuff(EnvoyBuffer[memInfo:getCurFloor()])
			end
		
			--set stayTime
			local stayTime = os.time() - memInfo:getStartTime()
			memInfo:setStayTime(stayTime + memInfo:getStayTime())
			memInfo:cast2db()
		end
		memInfo:setExperience(false)
		
		self._needFreshRoles[roleSID] = nil

		local mapID = player:getLastMapID()
		local x = player:getLastPosX()
		local y = player:getLastPosY()
		if g_sceneMgr:posValidate(mapID, x, y) then
			player:setReliveMapID(mapID)
			player:setReliveX(x)
			player:setReliveY(y)
			if sing then
				if sing:isSinging() == true then
					sing:stopSinging()
				else
					g_sceneMgr:enterPublicScene(roleID, mapID, x, y)
				end
			else
				g_sceneMgr:enterPublicScene(roleID, mapID, x, y)
			end
		else
			--如果地图有问题就走出生点
			if sing then
				if sing:isSinging() == true then
					sing:stopSinging()
				end
			end
			g_sceneMgr:enterPublicScene(roleID, 1100, 17, 85)
		end
	else
		warning('not find memInfo')
		if sing then
			if sing:isSinging() == true then
				sing:stopSinging()
			end
		end
		g_sceneMgr:enterPublicScene(roleID, 1100, 17, 85)
	end

	local acName = g_normalLimitMgr:getActivityName(ACTIVITY_NORMAL_ID.ENVOY)
	g_logManager:writeActivities(roleSID, 2, acName, memInfo:getStartTime(), 0, 0)

	--Tlog勇闯炼狱
	g_tlogMgr:TlogYCLYFlow(player, memInfo:getCurFloor(), os.time() - memInfo:getStartTime(), 0, memInfo:getKillNum(), memInfo:getKilledNum())
	memInfo:setKilledNum(0)
	memInfo:setKillNum(0)
end

--把所有玩家踢出活动地图，回到原始地图
function EnvoyManager:sendAllOut()
	for k,v in pairs(self._needFreshRoles) do 
		local player = g_entityMgr:getPlayerBySID(k)
		if player then
			self:sendOut(k)
		end
	end
end

--[[
--切换world的通知
function EnvoyManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local memInfo = self:getRoleEnvoyInfo(roleID)
	if memInfo then
		memInfo:switchWorld(peer, dbid, mapID)
	end
end

--切换到本world的通知
function EnvoyManager:onPlayerSwitch(player, type, buff)
	if type == EVENT_ENVOY_SET then
		local memInfo = self:getRoleEnvoyInfo(player:getID())
		if not memInfo then
			local roleID = player:getID()
			local roleSID = player:getSerialID()
			memInfo = RoleEnvoyInfo()
			memInfo:setRoleID(roleID)
			memInfo:setRoleSID(roleSID) 
			self._roleEnvoyInfos[roleID] = memInfo
			self._roleEnvoyInfoBySID[roleSID] = memInfo
			memInfo:loadDBDataImpl(player, buff)
		end
	end	
end
--]]

--根据地图层次刷怪咯
function EnvoyManager:freshMonster(monsterData)
--[[
	local mapID = ENVOYMAPID[tonumber(monsterData.q_floor)]
	if not mapID then
		print("EnvoyManager:freshMonster重装使者地图错误~", mapID)
		return
	end
	
	local freshId = tonumber(monsterData.q_freshId)	--刷新ID
	local monsterID = tonumber(monsterData.q_monsterID) --怪物ID
	
	
	local scene = g_sceneMgr:getPublicScene(mapID)
	if not scene or not monsterID then
		return
	end


	local mapX = 0
	local mapY = 0
	mapX,mapY = self:getMonsterInfoPos(freshId)
	local mon = g_entityMgr:getFactory():createMonster(monsterID)
	if mon and scene:addMonsterInfoByID(mon, freshId) then
		if g_sceneMgr:enterPublicScene(mon:getID(), mapID, mapX, mapY, 1) then
			scene:addMonster(mon)
			table.insert(self._boss, mon)
			g_normalLimitMgr:sendErrMsg2Client(78, 1, {monsterData.q_floor})
		else
			print("----EnvoyManager attachEntity failed", mon and mon:getSerialID())
			g_entityMgr:destoryEntity(mon:getID())
		end
	else
		print("----EnvoyManager addCopyMonsterInfo failed", mon and mon:getSerialID())
		g_entityMgr:destoryEntity(mon:getID())
	end
	]]
end

--[[
--获取玩家数据
function EnvoyManager:getRoleEnvoyInfo(roleID)
	return self._roleEnvoyInfos[roleID]
end
--]]

--获取玩家数据通过数据库ID
function EnvoyManager:getRoleEnvoyInfoBySID(roleSID)
	return self._roleEnvoyInfoBySID[roleSID]
end

function EnvoyManager:parseEnvoyData()
	package.loaded["data.EnvoyDB"]=nil
	local tmpData = require "data.EnvoyDB"

	if tmpData then
		g_LuaEnvoyDAO._envoyFresh = {}
		for i=1, #tmpData do
			local data = tmpData[i]
			g_LuaEnvoyDAO._envoyFresh[tonumber(data.q_floor)] = data
		end
	end
end

--玩家死亡
function EnvoyManager:onPlayerDied(player, killerID)
print('EnvoyManager:onPlayerDied()')
	local killer = g_entityMgr:getPlayer(killerID)

	if killer then
		local killerInfo = self:getRoleEnvoyInfoBySID(killer:getSerialID())
		if killerInfo and not killerInfo:getExperience() then
			killerInfo:setKillNum(killerInfo:getKillNum() + 1)
		end
	end
	
	local memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if memInfo and not memInfo:getExperience() then
		memInfo:setKilledNum(memInfo:getKilledNum() + 1)
	end	
end

function EnvoyManager.loadDBData(player, cache_buf, roleSid)
	print('EnvoyManager.loadDBData()', roleSid)
	if not player then
		warning('not find player')
		return
	end

	local memInfo = g_EnvoyMgr:initRoleEnvoyInfo(player)
	if not memInfo then
		warning('not find player memInfo')
		return
	end

	if #cache_buf > 0 then
		print('memInfo load db data')
		memInfo:loadDBData(cache_buf)
	end
end

function EnvoyManager:initRoleEnvoyInfo(player)
	if not player then
		warning('not find player')
		return
	end
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	print('EnvoyManager:initRoleEnvoyInfo()', roleSID)
	local memInfo = self:getRoleEnvoyInfoBySID(roleSID)
	if not memInfo then
		memInfo = RoleEnvoyInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID) 
		self._roleEnvoyInfoBySID[roleSID] = memInfo
		--self._roleEnvoyInfos[player:getID()] = memInfo
	end
	return memInfo
end

function EnvoyManager:experienceEnvoy(roleID, mapID, xPos, yPos)
	print('EnvoyManager:experienceEnvoy()', roleID, mapID, xPos, yPos)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return false
	end

	local  memInfo = self:getRoleEnvoyInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find player memInfo')
		return false
	end

	if self:join(roleID, 1, true) then
		return true
	end

	return false
end

function EnvoyManager:inEnvoyMap(roleSID) 
	print('EnvoyManager:inEnvoyMap()')
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return false
	end

	if self._needFreshRoles[roleSID] then
		print('player in envoy')
		return true
	end
	return false
end

function EnvoyManager.getInstance()
	return EnvoyManager()
end

g_EnvoyMgr = EnvoyManager.getInstance()