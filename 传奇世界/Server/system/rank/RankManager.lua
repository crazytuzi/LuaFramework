--RankManager.lua
--/*-----------------------------------------------------------------
--* Module:  RankManager.lua
--* Author:  HE Ningxu
--* Modified: 2014年9月22日
--* Purpose: Implementation of the class RankManager
-------------------------------------------------------------------*/

require ("system.rank.RankServlet")
require ("system.rank.RankConstant")

RankManager = class(nil, Singleton, Timer)

function RankManager:__init()
	self._lastWeekOnOne = {} 	--上周魅力榜第一名的玩家
	self._sortFlag = {}			--是否需要重新排序
	self._rank = {}				--排行数据
	self._rankCopy = {}			--排行榜数据的拷贝,存放实时改变的排行数据
	self._changeTimeTick = {}	--排行数据更新时间戳有改变的玩家

	self._worldNO1 = {[1] = {[1] = {},[2] = {}}, [2] = {[1] = {},[2] = {}}, [3] = {[1] = {},[2] = {}}}
	self._worldTimeStamp = {}		-- 记录天下第一变更时间
	g_listHandler:addListener(self)
end

function RankManager:initialize()
	for _, tab in pairs(RANK_TYPR) do
		self._rank[tab] = {}
		self._rankCopy[tab] = {}
		g_entityDao:loadRankData(tab)
	end
	g_entityMgr:clearRankRole()
	self._timeTick = 0

	gTimerMgr:regTimer(self, 5000, 5000)
	print("RankManager TimeID:",self._timerID_)
end

--数据库加载回调
function RankManager.onLoadRankData(roleSID, name, rank, value, timeTick, ext)
	local school = math.mod(rank, 10)
	rank = math.floor(rank / 10)
	local tab = math.mod(rank, 10)
	rank = math.floor(rank / 10)
	local data = {roleSID, name, school, value, timeTick, ext}
	g_RankMgr._rank[tab][rank] = data
	g_RankMgr._rankCopy[tab][rank] = data
end

function RankManager.onLoadRankFaction(rank, factionID, name, level, battle, timeTick)
	local data = {factionID = factionID, name = name, level = level, battle = battle, timeTick = timeTick}
	g_RankMgr._rank[RANK_TYPR.RANK_FACTION][rank] = data
	g_RankMgr._rankCopy[RANK_TYPR.RANK_FACTION][rank] = data
end

function RankManager:onPlayerLoaded(player)
	if self._worldNO1[player:getSchool()][player:getSex()].dbid == player:getSerialID() then
		local sex = player:getSex() == 1 and "男" or "女"
		local school = player:getSchool() == 1 and "战士" or player:getSchool() == 2 and "法师" or "道士"
		local pre = sex .. school  
		self:sendErrMsg2Client(70,2,{pre,player:getName()})
	end
end

--等级改变
function RankManager:onLevelChanged(player)
	local data = {player:getSerialID(), player:getName(), player:getSchool(), player:getLevel(), os.time(), player:getXP()}
	self:syncChangeUser(RANK_TYPR.RANK_LEVEL, data)
end

--行会数据改变
function RankManager:factionChanged(factionID, name, level, battle)
	local data = {factionID = factionID, name = name, level = level, battle = battle, timeTick = os.time()}
	self:syncChangeUser(RANK_TYPR.RANK_FACTION, data)
end

--恶人数据改变
function RankManager:pkChaneged(player)
	local data = {player:getSerialID(), player:getName(), player:getSchool(), player:getPK(), os.time(), 0}
	self:syncChangeUser(RANK_TYPR.RANK_PK, data)
end

--魅力值改变
function RankManager:onGlamourChanged(player)
	local data = {player:getSerialID(), player:getName(), player:getSchool(), player:getGlamour(), os.time(), 0}
	self:syncChangeUser(RANK_TYPR.RANK_GLAMOUR, data)
end

--魅力值改变(离线玩家)
function RankManager:onGlamourChanged2(roleSID, name, school, glamour, sex, level)
	local data = {roleSID, name, school, glamour, os.time(), 0}
	self:syncChangeUser(RANK_TYPR.RANK_GLAMOUR, data)
end

--玩家经验改变
function RankManager:onExpChanged(player)
	local data = {player:getSerialID(), player:getName(), player:getSchool(), player:getLevel(), os.time(), player:getXP()}
	self:syncChangeUser(-1, data)
end

function RankManager:syncChangeUser(tab, rankUser)
	local roleSID = rankUser[1] or rankUser.factionID
	self._changeTimeTick[roleSID * 10 + tab] = os.time()
	if tab == -1 then
		--等级榜内的玩家经验改变重新排序
		for rank, data in pairs(self._rankCopy[RANK_TYPR.RANK_LEVEL]) do
			if data[1] == roleSID then
				self._rankCopy[RANK_TYPR.RANK_LEVEL][rank] = rankUser
				self:setSortFlag(RANK_TYPR.RANK_LEVEL, true)
				break
			end
		end
		return
	end
	if tab == RANK_TYPR.RANK_PK and rankUser[4] == 0 then
		self:deleteRankTableUser(RANK_TYPR.RANK_PK, roleSID)
		return
	end
	for rank, data in pairs(self._rankCopy[tab] or {}) do
		if (data[1] or data.factionID) == roleSID then
			self._rankCopy[tab][rank] = rankUser
			self:setSortFlag(tab, true)
			return
		end
	end
	local lastData = nil	--榜单最后一名数据
	if self._rankCopy[tab] and #self._rankCopy[tab] > 0 then
		local rank = #self._rankCopy[tab]
		if rank > 100 then
			rank = 100
		end
		lastData = self._rankCopy[tab][rank]
	end
	if #self._rank[tab] >= 100 and lastData then
		--是否参与排序的有效数据(在榜单满且排名值没达到此榜单最后一名不参与排序)
		if tab == RANK_TYPR.RANK_LEVEL then
			if rankUser[4] < lastData[4] then
				return
			elseif rankUser[4] == lastData[4] and rankUser[6] <= lastData[6] then
				return
			end
		elseif tab == RANK_TYPR.RANK_GLAMOUR or tab == RANK_TYPR.RANK_PK then
			if rankUser[4] < lastData[4] then
				return
			end
		elseif tab == RANK_TYPR.RANK_FACTION then
			if rankUser.level < lastData.level then
				return
			elseif rankUser.level == lastData.level and rankUser.battle <= lastData.battle then
				return
			end
		end
	end
	table.insert(self._rankCopy[tab], rankUser)
	self:setSortFlag(tab, true)
end

-- 玩家删除
function RankManager:onPlayerDelete(roleSID)
	for _, tab in pairs(RANK_TYPR) do
		self:deleteRankTableUser(tab, roleSID)
	end
	for i,v in ipairs(self._worldNO1) do
		for j,k in ipairs(v) do
			if k.dbid == roleSID then
			self._worldNO1[i][j] = {}
			updateCommonData(COMMON_DATA_ID_WORLD_NO1, self._worldNO1)
			self:sysNO1()
			self:getNO1Data()
			end
		end
	end
end

--删除行会
function RankManager:onFactionDelete(factionID)
	self:deleteRankTableUser(RANK_TYPR.RANK_FACTION, factionID)
end

--删除某个榜单里的玩家排名
function RankManager:deleteRankTableUser(tab, roleSID)
	for rank, data in pairs(self._rankCopy[tab] or {}) do
		if (data[1] or data.factionID) == roleSID then
			-- 删除榜单玩家数据后重新整理内存中榜单排名
			local copyData = {}
			newRank = 0
			for _, rankUser in pairs(self._rankCopy[tab]) do
				if (rankUser[1] or rankUser.factionID) ~= roleSID then
					newRank = newRank + 1
					copyData[newRank] = rankUser
				end
			end
			self._rank[tab] = copyData
			self._rankCopy[tab] = copyData
			break
		end
	end
end

--内存榜单重排序
function RankManager:rankSort(tab)
	--榜单数据大于两条的时候才进行排序
	if table.size(self._rankCopy[tab]) >= 2 then
		--{roleSID, name, school, value, timeTick, ext}
		function sortfunction2(a, b)
			if a and b then
				if a[4] == b[4] then
					if a[5] == b[5] then
						return false
					else
						return a[5] < b[5]
					end
				else
					return a[4] > b[4]
				end
			else
				return false
			end
		end
		function sortfunction3(a, b)
			if a and b then
				if a[4] == b[4] then
					if a[6] == b[6] then
						if a[5] == b[5] then
							return false
						else
							return a[5] < b[5]
						end
					else
						return a[6] > b[6]
					end
				else
					return a[4] > b[4]
				end
			else
				return false
			end
		end
		function sortFaction(a, b)
			if a and b then
				if a.level == b.level then
					if a.battle == b.battle then
						if a.timeTick == b.timeTick then
							return false
						else
							return a.timeTick < b.timeTick
						end
					else
						return a.battle > b.battle
					end
				else
					return a.level > b.level
				end
			else
				return false
			end
		end
		if tab == RANK_TYPR.RANK_LEVEL then
			table.sort(self._rankCopy[RANK_TYPR.RANK_LEVEL], sortfunction3)
		elseif tab == RANK_TYPR.RANK_FACTION then
			table.sort(self._rankCopy[RANK_TYPR.RANK_FACTION], sortFaction)
		elseif tab == RANK_TYPR.RANK_PK then
			table.sort(self._rankCopy[RANK_TYPR.RANK_PK], sortfunction2)
		elseif tab == RANK_TYPR.RANK_GLAMOUR then
			table.sort(self._rankCopy[RANK_TYPR.RANK_GLAMOUR], sortfunction2)
		end
	end
end

function RankManager:setSortFlag(tab, flag)
	self._sortFlag[tab] = flag
end

function RankManager:getSotFlag(tab)
	return self._sortFlag[tab] or false
end

function RankManager:update()
	local now = os.time()
	if onSall(RANK_GLAMOUR_TRAILER_TIME, now) then
		g_RankMgr:sendErrMsg2Client(RANK_GLAMOUR_TRAILER, 0, {})
	end
	if onSall(RANK_GLAMOUR_REFRESH_TIME, now) then
		self:calcGlamourRank()
	end
	if now - self._timeTick >= 60 then
		for _, tab in pairs(RANK_TYPR) do
			if self:getSotFlag(tab) then
				self:rankSort(tab)
				--维护榜单,删除多余数据
				for i = #self._rankCopy[tab], 100, -1 do
					if tab == RANK_TYPR.RANK_GLAMOUR and i <= 150 then
						break
					elseif i <= 100 then
						break
					end
					table.remove(self._rankCopy[tab], i)
				end
				self._rank[tab] = table.deepCopy1(self._rankCopy[tab])
				self:setSortFlag(tab, false)
			end
		end
		self._timeTick = now
	end
	for data, timeTick in pairs(self._changeTimeTick) do
		if now - timeTick > 300 then
			local roleSID, tab = math.floor(data / 10), math.mod(data, 10)
			if tab ~= RANK_TYPR.RANK_FACTION or (tab == RANK_TYPR.RANK_FACTION and now - timeTick > 600) then
				self:whiteRankTimeTick(roleSID, tab, timeTick)
				self._changeTimeTick[data] = nil
			end
		end
	end
end

--更新玩家榜单时间戳
function RankManager:whiteRankTimeTick(roleSID, tab, timeTick)
	if roleSID and tab and timeTick then
		if tab == RANK_TYPR.RANK_LEVEL then
			g_entityDao:updateRankData(roleSID, "level", timeTick)
		elseif tab == RANK_TYPR.RANK_PK then
			g_entityDao:updateRankData(roleSID, "pk", timeTick)
		elseif tab == RANK_TYPR.RANK_GLAMOUR then
			g_entityDao:updateRankData(roleSID, "glamour", timeTick)
		elseif tab == RANK_TYPR.RANK_FACTION then
			g_entityDao:updateRankData(roleSID, "faction", timeTick)
		end
	end
end

--结算本周魅力排行榜
function RankManager:calcGlamourRank()
	local noOneData = self._rank[RANK_TYPR.RANK_GLAMOUR][1]	-- 本周获得魅力值第一的玩家
	if noOneData then
		noOneData[8] = os.time()		--用于万人迷称号获得时间
		self:sendErrMsg2Client(RANK_GLAMOUR_NO_ONE, 1, {noOneData[2]})
		local lastWeekOnOne = {}
		table.insert(lastWeekOnOne, noOneData)
		updateCommonData(LAST_WEEK_GLAMOUR_NO_ONE, lastWeekOnOne)
		self._rank[RANK_TYPR.RANK_GLAMOUR] = {}
		self._rankCopy[RANK_TYPR.RANK_GLAMOUR] = {}

		local oldGlamourSID
		if #self._lastWeekOnOne > 0 then
			oldGlamourSID = self._lastWeekOnOne[1][1]
		end

		local newGlamourSID
		self._lastWeekOnOne = lastWeekOnOne
		if #self._lastWeekOnOne > 0 then
			newGlamourSID = self._lastWeekOnOne[1][1]
		end

		g_achieveMgr:glamourRankNotify(oldGlamourSID, newGlamourSID)

		g_entityDao:resetGlamourData()
		g_SpillFlowerPublic:ClearOffGiveFlowerGlamour()
		local ret = {
			name = noOneData[2],
			glamour = noOneData[4],
		}
		fireProtoMessageBySid(noOneData[1], RANK_SC_GLAMOUR_RET, 'RankGlamourRet', ret)
	end
	g_relationMgr:clearAllGlamour()
end

function RankManager:setLastWeekOnOne(lastWeekOnOne)
	self._lastWeekOnOne = unserialize(lastWeekOnOne)
end

--获取万人迷ID及获得时间
function RankManager:getGlamourTimeAndID()
	if #self._lastWeekOnOne > 0 then
		return self._lastWeekOnOne[1][1], self._lastWeekOnOne[1][8]
	end
end

--获取万人迷名字及魅力值
function RankManager:getGlamourData()
	if #self._lastWeekOnOne > 0 then
		return self._lastWeekOnOne[1][2], self._lastWeekOnOne[1][4]
	end
	return "", 0
end

function RankManager:getGlamour()
	return self._lastWeekOnOne[1]
end

function RankManager:getRankData(tab)
	return self._rank[tab]
end

function RankManager:worldNO1(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	local Lv1 = 0
	for i ,rankUser in pairs(self._rank[RANK_TYPR.RANK_LEVEL]) do 
		if rankUser[3] == player:getSchool() and rankUser[6] == player:getSex() then
			Lv1 = rankUser[4]
			break
		end
	end

	if player:getLevel() < 46 then 
		self:sendErrMsg2Client(-1,0,{},roleID)
		return
	end
	
	if self._worldNO1[player:getSchool()][player:getSex()].dbid and self._worldNO1[player:getSchool()][player:getSex()].dbid == player:getSerialID() then
		self:sendErrMsg2Client(-3,0,{},roleID)
		return
	end

	if self._worldTimeStamp[player:getSerialID()] and os.time() < self._worldTimeStamp[player:getSerialID()]  + 2 * 60 * 60 then
		self:sendErrMsg2Client(-5,0,{},roleID)
		return
	end

	if player:getLevel() < Lv1 then
		self:sendErrMsg2Client(-2,0,{},roleID)
		return
	end

	if self._worldNO1[player:getSchool()][player:getSex()].Lv and self._worldNO1[player:getSchool()][player:getSex()].Lv > player:getLevel() then 
		self:sendErrMsg2Client(-2,0,{},roleID)
		return
	end

	if self._worldNO1[player:getSchool()][player:getSex()].Lv and self._worldNO1[player:getSchool()][player:getSex()].exp 
	and self._worldNO1[player:getSchool()][player:getSex()].Lv == player:getLevel() and self._worldNO1[player:getSchool()][player:getSex()].exp >= player:getXP() then
		self:sendErrMsg2Client(-2,0,{},roleID)
		return
	end

	self._worldTimeStamp[player:getSerialID()] = os.time()

	--改玩家为天下第一
	self._worldNO1[player:getSchool()][player:getSex()].dbid = player:getSerialID()
	self._worldNO1[player:getSchool()][player:getSex()].name = player:getName()
	self._worldNO1[player:getSchool()][player:getSex()].Lv = player:getLevel()
	self._worldNO1[player:getSchool()][player:getSex()].exp = player:getXP()

	self:sendErrMsg2Client(-4,0,{},roleID)
	self:getNO1Data()
	updateCommonData(COMMON_DATA_ID_WORLD_NO1, self._worldNO1)
	self:sysNO1()
end

function RankManager:getNO1Data(roleID)
	local retData = {name = {}}
	local data = self._worldNO1
	for i,v in ipairs(data) do
		for i,v in ipairs(v) do
			local name = v.name or ""
			table.insert(retData.name,name)
		end
	end
	if roleID then 
		fireProtoMessage(roleID, RANK_SC_GET_NO1_DATA, "RankGetNo1RetProtocol", retData)
	else
		boardProtoMessage(RANK_SC_GET_NO1_DATA, "RankGetNo1RetProtocol", retData)
	end
end

function RankManager:sysNO1()
	g_entityMgr:clearRankRole()
	for i,v in ipairs(self._worldNO1) do
		for i,v in ipairs(v) do
			if v.dbid then 
			g_entityMgr:addRankRole(v.dbid)
			end
		end
	end
end

function RankManager:onLoadWorldNO1(data)
	self._worldNO1 = unserialize(data)
	for i,v in ipairs(self._worldNO1) do
		for i,v in ipairs(v) do
			if v.dbid then 
			g_entityMgr:addRankRole(v.dbid)
			end
		end
	end
end

-- 通过GM命令统计本周魅力榜
function RankManager:GMupdateGlamous()
	self:calcGlamourRank()
end

function RankManager:test()
	g_entityDao:loadRankData(1, 1)
end

function RankManager:sendErrMsg2Client(errId, paramCount, params,roleID)
	local ret = {}
	ret.eventId = EVENT_PUSH_MESSAGE
	ret.eCode = errId
	ret.mesId = 0
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	if roleID then 
		fireProtoSysMessage(g_RankServlet:getCurEventID(), roleID, EVENT_RANK_SETS, errId, paramCount, params)
	else
		boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
	end
end

function RankManager.getInstance()
	return RankManager()
end

g_RankMgr = RankManager.getInstance()
g_RankMgr:initialize()