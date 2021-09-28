--CompetitionManager.lua
--/*-----------------------------------------------------------------
 --* Module:  CompetitionManager.lua
 --* Author:  seezon
 --* Modified: 2015年1月10日
 --* Purpose: 拼战管理器
 -------------------------------------------------------------------*/
require ("system.competition.CompetitionServlet")
require ("system.competition.RoleCompetitionInfo")
require ("system.competition.CompetitionConstant")
require ("system.competition.LuaCompetitionDAO")
	
CompetitionManager = class(nil, Singleton, Timer)
--全局对象定义
g_competitionServlet = CompetitionServlet.getInstance()
g_LuaCompetitionDAO = LuaCompetitionDAO.getInstance()


function CompetitionManager:__init()
	self._roleInfos = {} --运行时ID
	self._roleInfoBySID = {} --数据库ID
	self._offlineRewardData = {}	--所有离线玩家拼战奖励
	self._reward = {[1] = 1, [2] = 2}
	self._killMonsterCount = {} --杀怪计数 用于触发拼战
	self._activenessFlagBySID = {}
	self._actived = true
	self._notifyMember = {}
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 3000)
	print("CompetitionManager Timer", self._timerID_)
end

function CompetitionManager.loadDBData(player, cache_buf, roleSID)
	g_competitionMgr:loadDBDataImpl(player, cache_buf, roleSID)
end

function CompetitionManager:loadDBDataImpl( player, cache_buf, roleSID )
	local roleID = player:getID()
	local memInfo = self:getRoleInfo(roleID)
	memInfo:loadDBDataImpl(player, cache_buf, roleSID)
	if self._actived and memInfo._isInCompetition > 0 or memInfo:getRewardId() > 0 then  
		table.insert(self._notifyMember,memInfo)
		--memInfo:notifyClient()
	end
end

--切换world的通知
function CompetitionManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local memInfo = self:getRoleInfo(roleID)
	if memInfo then
		memInfo:switchWorld(peer, dbid, mapID)
	end
end

--切换到本world的通知
function CompetitionManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_COMPETITION_SETS then
		local roleID = player:getID()
		local roleSID = player:getSerialID()
		local memInfo = self:getRoleInfo(roleID)	
		local cache_buf = luabuf:popLString()
		memInfo:loadDBDataImpl(player, cache_buf)
	end	
end

--玩家下线
function CompetitionManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleInfoBySID(roleSID)
	if not memInfo then
		return
    end
    memInfo:cast2db()
	if memInfo then
		self._roleInfos[roleID] = nil
		self._roleInfoBySID[roleSID] = nil
		self._killMonsterCount[roleID] = nil
	end
end

--掉线登陆
function CompetitionManager:onActivePlayer(player)
	local memInfo = self:getRoleInfoBySID(player:getSerialID()) 
	if not memInfo then
		return
    end
	memInfo:notifyClient()
end

--定时器更新
function CompetitionManager:update()
	self:checkAllCompetition()
	for i = #self._notifyMember, 1,-1 do
		local member = self._notifyMember[i]
		if member then 
			member:notifyClient()
			table.remove(self._notifyMember, i)
		end
		
	end
end

--检查所有拼战
function CompetitionManager:checkAllCompetition()
	for k,v in pairs(self._roleInfoBySID or {}) do
		if v._endTime ~= 0 then 
			local curTime = os.time()
			if curTime > v._endTime then
				v:dealCompetition()
			end
		end
		--测试需求
		--v:checkCompetitionActive()
	end
end

function CompetitionManager:checkCompetitionActive(roleSID,sourceType,index)
	print(" sourceType " .. sourceType)
	local memInfo = self._roleInfoBySID[roleSID]
	if memInfo and self._actived then 
		if sourceType == ComepetitionSourceType.Activiness then
			local flag = self:getActivessFlag(roleSID)
			if not flag[index] then 
				flag[index] = true
			else
				return
			end
			print(flag[index])
		end
		memInfo:checkCompetitionActive()
	end
end

function CompetitionManager:getActivessFlag(roleSID)
	local memInfo = self._roleInfoBySID[roleSID]
	local timeStamp = time.toedition("day")

	if not self._activenessFlagBySID[roleSID] then
		self._activenessFlagBySID[roleSID] = {[1] = false,[2] = false,[3] = false,[4] = false}
	end

	if tonumber(timeStamp) >= memInfo:getTimeStamp() then
		self._activenessFlagBySID[roleSID] = {[1] = false,[2] = false,[3] = false,[4] = false}
	end
	return self._activenessFlagBySID[roleSID]
end

--领取拼战奖励
function CompetitionManager:pickReward(roleID)
	print(" CompetitionManager:pickReward")
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local memInfo = self:getRoleInfo(roleID)
	if not memInfo then
		return
	end

	local rewardId = memInfo:getRewardId()

	if rewardId > 0 then
		local proto = g_LuaCompetitionDAO:getRewardDB(rewardId)
		if proto then
			local dropID = tonumber(proto.q_mat)
			local soucetype = rewardId == 1 and 68 or 69
			local isInBag = rewardByDropID(player:getSerialID(), dropID, 33, soucetype)
			local retData = {isInBag = isInBag}
			fireProtoMessage(roleID,COMPETITION_SC_PICK_REWARD_RET,"CompetitionPickRewardRetProtocol",retData)
		end
		memInfo:setRewardId(0)
		memInfo:cast2db()
	else
		-- g_competitionServlet:sendErrMsg2Client(roleID, COMPETITION_ERR_NO_REWARD, 0)
		return 
	end
end

--检测杀怪 计数
function CompetitionManager:onMonsterKill(monSID, roleID, monID, mapID)
	if not self._killMonsterCount[roleID] then
		self._killMonsterCount[roleID] = 1
	else
		self._killMonsterCount[roleID] = self._killMonsterCount[roleID] + 1
		if self._killMonsterCount[roleID] == KILLMONSTERCOUNT then
			self._killMonsterCount[roleID] = nil
			local player = g_entityMgr:getPlayer(roleID)
			if player then 
				self:checkCompetitionActive(player:getSerialID(),ComepetitionSourceType.KILLMONSTER)
			end
		end
	end
end

--应战
function CompetitionManager:accept(roleID)
	local memInfo = self:getRoleInfo(roleID)
	if not memInfo then
		return
	end

	memInfo:accept()
end

function CompetitionManager:closeFight()
	for i,v in pairs(self._roleInfoBySID) do
		if v._isInCompetition == 1 then 
			v:dealCompetition()
		end
	end
	-- body
end

function CompetitionManager:parseCompetitionData()
	package.loaded["data.CompetitionDB"]=nil
	local tmpData = require "data.CompetitionDB"

	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if g_LuaCompetitionDAO._staticRewards[data.q_id] then
				table.deepCopy1(data, g_LuaCompetitionDAO._staticRewards[data.q_id])
			else
				g_LuaCompetitionDAO._staticRewards[data.q_id] = data
			end
		end
	end
end

--获取玩家数据
function CompetitionManager:getRoleInfo(roleID)
	local memInfo = self._roleInfos[roleID]
	if not memInfo then
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			memInfo = RoleCompetitionInfo(roleID, player:getSerialID())			
			self._roleInfos[roleID] = memInfo
			self._roleInfoBySID[player:getSerialID()] = memInfo
		end
	end
	return self._roleInfos[roleID]
end

--获取玩家数据通过数据库ID
function CompetitionManager:getRoleInfoBySID(roleSID)
	local memInfo = self._roleInfoBySID[roleSID]
	if not memInfo then 
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			memInfo = RoleCompetitionInfo(player:getID(), roleSID)
			self._roleInfos[player:getID()] = memInfo
			self._roleInfoBySID[roleSID] = memInfo
		end
	end

	return self._roleInfoBySID[roleSID]
end

function CompetitionManager.getInstance()
	return CompetitionManager()
end

g_competitionMgr = CompetitionManager.getInstance()