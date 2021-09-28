--RoleCompetitionInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleCompetitionInfo.lua
 --* Author:  seezon
 --* Modified: 2015年1月10日
 --* Purpose: Implementation of the class RoleCompetitionInfo
 -------------------------------------------------------------------*/

RoleCompetitionInfo = class()

local prop = Property(RoleCompetitionInfo)
prop:accessor("roleSID", "")
prop:accessor("roleID", 0)
prop:accessor("timeStamp", 0)--玩家的时间戳
prop:accessor("activeTimeStamp", 0)--拼战激活时间
prop:accessor("rewardId", 0)--玩家拼战奖励ID
prop:accessor("competitionIndex", 0)--玩家拼战数据索引
prop:accessor("competitionType", 0)--玩家拼战类型
prop:accessor("hasOffReward", 0)--有离线奖励


function RoleCompetitionInfo:__init(roleID, roleSID)
	prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)
	self._remainTime = self:getMaxGiveTime()    --玩家能拼战的次数
	self._endTime = 0
	self._isFirst = 1
	self._playerSIDTb = {}
	self._isInCompetition = 0
	self._activenessFlag = {}
end

--保存到数据库
function RoleCompetitionInfo:cast2db()	
	local cache_buf = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_COMPETITION, cache_buf, #cache_buf)
end

--保存到数据库
function RoleCompetitionInfo:writeObject()
	local datas = {}
	datas.remainTime = self._remainTime
	datas.endTime = self._endTime
	datas.playerSIDTb = serialize(self._playerSIDTb)
	datas.rewardId = self:getRewardId()
	datas.tamp = self:getTimeStamp()
	datas.isInCompetition = self._isInCompetition
	datas.activeTime = self:getActiveTimeStamp()
	return protobuf.encode("CompetitionProtocol", datas)
end

function RoleCompetitionInfo:loadDBDataImpl(player, cache_buf)
	if #cache_buf > 0 then
		local data = protobuf.decode("CompetitionProtocol", cache_buf)
		self._remainTime = data.remainTime
		self._endTime = data.endTime
		self._playerSIDTb = unserialize(data.playerSIDTb) or {}
		self:setRewardId(data.rewardId) 
		self:setTimeStamp(data.tamp)
		self._isInCompetition = data.isInCompetition or 0
		self:setActiveTimeStamp(data.activeTime)
	end
end

--切换world的通知
function RoleCompetitionInfo:switchWorld(peer, dbid, mapID)
	local cache_buf = self:writeObject()

	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_COMPETITION_SETS)
	--具体数据跟在后面
	luaBuf:pushLString(cache_buf,#cache_buf)
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)

	--print("switchWorld")
	--print("time" ..self._endTime,"isfirst" ..self._isFirst,"isInCompetition"..self._isInCompetition)
end

--刷新时间戳
function RoleCompetitionInfo:freshTimeStamp()
	local stamp = tonumber(time.toedition("day") + 1)
	self:setTimeStamp(stamp)
	self:setRemainGiveTime(self:getMaxGiveTime())
	self:cast2db()
end

--获取拼战的次数
function RoleCompetitionInfo:getRemainGiveTime()
    local timeStamp = time.toedition("day")
    if tonumber(timeStamp) < self:getTimeStamp() then
	    return self._remainTime
    else
	    --过期的时间戳要刷新
	    self:freshTimeStamp()
	    return self:getMaxGiveTime()
    end
end

--获取拼战的数据
function RoleCompetitionInfo:getCompetitionData()
	local roleSID = self:getRoleSID()
	local player = g_entityMgr:getPlayerBySID(roleSID)
	self._playerSIDTb = {}
	local itemMgr = player:getItemMgr()
	table.insert(self._playerSIDTb, {roleSID=roleSID, main = true, roleName=player:getName(), sex = player:getSex(), school=player:getSchool(), weaponID = itemMgr:getWeaponID(), clothID = itemMgr:getClothID(), wingID=player:getCurWingID(), value=player:getbattle()}) 
	local rand = math.floor(math.rand(1,100))
	local allPlayer = g_entityMgr:getCompetitionPlayer(roleSID, rand, 1)
	for i,v in pairs(allPlayer or {}) do
		local citemMgr = v:getItemMgr()
		table.insert(self._playerSIDTb, {roleSID=v:getSerialID(), main = false, roleName=v:getName(), sex = v:getSex(), school=v:getSchool(), weaponID = citemMgr:getWeaponID(), clothID = citemMgr:getClothID(), wingID=v:getCurWingID(), value=v:getbattle()}) 
	end
	

end

--设置拼战的次数
function RoleCompetitionInfo:setRemainGiveTime(remainTime)
    self._remainTime = remainTime
end

--获取玩家最多能拼战的次数
function RoleCompetitionInfo:getMaxGiveTime()
    local maxTime = COMPETITION_DAILY_TIME
    return maxTime
end

--刷新新的拼战时间
function RoleCompetitionInfo:freshNewTime()
	--print("RoleCompetitionInfo:freshNewTime")
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end

	if player:getLevel() < 20 then
		return
	end

	player:setIsInCompetition(0)
	self._playerSIDTb = {}
	self._endTime = 0
	self:setRewardId(0)
	self:cast2db()
    local activeTime = os.time() + COMPETITION_NEXT_ACTIVE_TIME
	if self:getRemainGiveTime() == self:getMaxGiveTime() then
		activeTime = os.time() + COMPETITION_NEXT_ACTIVE_TIME
	end

	self:setActiveTimeStamp(activeTime)
	
	--没有次数了就不拼战
	if self:getRemainGiveTime() <= 0 then
		self:setActiveTimeStamp(0)
	end
end

--检查是否激活拼战
function RoleCompetitionInfo:checkCompetitionActive(first)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end

	if player:getIsInCompetition() > 0 or self:getRewardId() == 1 or self:getRewardId() == 2 or self:getRemainGiveTime() <= 0  or self._isInCompetition == 1 then
		return
	end

	if player:getCopyID() > 0 or player:getScene():getManorWarID() > 0 then 
		return
	end

	if os.time() < self:getActiveTimeStamp() then 
		return
	end

	--屏蔽非新手比拼
	if player:getLevel() < COMPETITION_MIN_LEVEL then
		return
	end

	if self._endTime == 0 then
		self:addNewCompetition()
	end
end


--新增一个比拼
function RoleCompetitionInfo:addNewCompetition(roleSID)
	--print("RoleCompetitionInfo:addNewCompetition")
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())

	if not player then
		return
	end

	--筛选拼战对手
	self:getCompetitionData()
	--print("NUM = " ..table.size(self._playerSIDTb))
	--玩家不足就先不拼战，时间往后调整
	if table.size(self._playerSIDTb) <= 1 then
		--self:freshNewTime()
		self._playerSIDTb = {}
		return
	end
	self:setActiveTimeStamp(os.time() + COMPETITION_NEXT_ACTIVE_TIME)
	self._endTime = os.time() + COMPETITION_ONCE_TIME
	self:notifyCompetitionStar()
	self:setRemainGiveTime(self:getRemainGiveTime() - 1)
	self:cast2db()

	--发起人要扣除一次次数
	--print("RoleCompetitionInfo:addNewCompetition   EnD")
end

function RoleCompetitionInfo:notifyClient()
	--有没领取的奖励
	if self:getRewardId() > 0 then
			self:notifyClientReward()
	else
		--有未完成的比赛
		if self._isInCompetition > 0 and os.time() < self._endTime then
			self:notifyCompetitionStar()
		-- else
		-- 	self:freshNewTime()
		end
	end
end

--通知客户端领奖
function RoleCompetitionInfo:notifyClientReward()
	if self:getRewardId() <= 0 then
		return
	end
	local retData = {
					rewardId = self:getRewardId(),
					rank = self:getRewardId()
					}
	fireProtoMessage(self:getRoleID(),COMPETITION_SC_NOTIFY_REWARD,"CompetitionNotifyRewardProtocol",retData)
end

--通知拼战人员比赛开始
function RoleCompetitionInfo:notifyCompetitionStar()
	--print("RoleCompetitionInfo:notifyCompetitionStar")
	--print("isInCompetition = " .. self._isInCompetition)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end

	local reward = g_competitionMgr._reward
	local playerSIDTb = self._playerSIDTb
	local remainTime = math.abs(self._endTime - os.time())

	local SroleSID = playerSIDTb[1].roleSID
	local DroleSID = playerSIDTb[2].roleSID
	local releationInfo = g_relationMgr._roleRelationInfoBySID[SroleSID]
	local isFriend = false
	if releationInfo then 
		local friend = releationInfo:getFriend(DroleSID)
		isFriend = friend and true or false
	end
	
	local isFirst = 0
	if self._isInCompetition == 0 then 
		isFirst = 1
	else
		isFirst = 0
	end
	local rewardNum = table.size(reward)
	local tReward = {}
	for k,v in ipairs(reward) do
		table.insert(tReward,v)
	end

    local playerNum = table.size(playerSIDTb)
	local playerData = {}
	for _,v in ipairs(playerSIDTb) do
		local data = {
						roleName = v.roleName,
						school = v.school,
						sex = v.sex,
						weaponID = v.weaponID,
						clothID = v.clothID,
						wingID = v.wingID,
						value = v.value,
					}
		table.insert(playerData,data)
	end

	local retData = {
					isFriend = isFriend,
					remainTime = remainTime,
					isFirst = isFirst,
					rewardNum = rewardNum,
					tReward = tReward,
					playerNum = playerNum,
					playerData = playerData,
					}
	fireProtoMessage(self:getRoleID(),COMPETITION_SC_NOTIFY_COMPETITION,"CompetitionNotifyStarProtocol",retData)

	player:setIsInCompetition(1)
	self._isInCompetition = 1
end


function RoleCompetitionInfo:getCompetitionFreshData()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end

	self:updatePlayerValue()
	local playerSIDTb = self._playerSIDTb
	local playerNum = table.size(playerSIDTb)

	local playerData = {}
	for i,v in pairs(playerSIDTb) do
		local data = {
							roleName = v.roleName,
							value = v.value,
							}
		table.insert(playerData,data)
	end

	local retData = {
					playerNum = playerNum,
					playerData = playerData,
					}
	fireProtoMessage(self:getRoleID(),COMPETITION_SC_GET_COMPETITION_DATA_RET,"CompetitionGetDataRetProtocol",retData)
end

--玩家更新拼战数据
function RoleCompetitionInfo:updatePlayerValue()
  	local playerSIDTb = self._playerSIDTb
	if playerSIDTb then
		for _,v in pairs(playerSIDTb) do
			if v.main then
				local player = g_entityMgr:getPlayerBySID(v.roleSID)
				v.value = player:getbattle()
			end
		end
	end
end

--处理拼战结果
function RoleCompetitionInfo:dealCompetition()
	--print("RoleCompetitionInfo:dealCompetition")
	--先刷新在线玩家的最新数据
	local playerSIDTb = self._playerSIDTb
	self:updatePlayerValue()
	--平局处理
	if table.size(self._playerSIDTb) < 2 then
		return
	end
	local reward = g_competitionMgr._reward
	--处理不同名次的玩家

	local rewardId = self._playerSIDTb[1].value > self._playerSIDTb[2].value and 1 or 2
	local rId = g_competitionMgr._actived and reward[rewardId] or 3
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	-- if player then
	--通知玩家领取奖励
	self:setRewardId(rId)
	self:cast2db()
	if player then 
		self:notifyClientReward()
	end
	self._endTime = 0
	self._playerSIDTb ={}
	player:setIsInCompetition(0)
	self._isInCompetition = 0
	--print("dealCompetition end")
end


--同步时间
function RoleCompetitionInfo:synTime()
	local retData = {time = math.abs(self._endTime - os.time())}
	fireProtoMessage(self:getRoleID(),COMPETITION_SC_SYN_TIME_RET,"CompetitionSynTimeRetProtocol",retData)
	-- body
end
