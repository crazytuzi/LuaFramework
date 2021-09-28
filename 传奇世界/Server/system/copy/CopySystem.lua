--CopySystem.lua

--if CopySystem then
--	g_eventMgr:removeEventListener(CopySystem.getInstance())
--end

CopySystem = class(EventSetDoer, Singleton)

function CopySystem:__init()
	self._doer = {
		[COPY_CS_ENTERCOPY] = CopySystem.reqDoEnterCopy,
		[COPY_CS_STARTPROGRESS] = CopySystem.doStartProgress,
		[COPY_CS_PROGRESSALL] = CopySystem.doProgressAll,
		[COPY_CS_EXITCOPY] = CopySystem.doExitBook,
		[COPY_CS_GETPROREWARDLIST] = CopySystem.doGetproRewardList,
		[COPY_CS_GETPROREWARD]	= CopySystem.doGetProReward,
		[COPY_CS_GETFRIENDDATA] = CopySystem.doGetFriendData,
		[COPY_CS_CREATECOPYTEAM] = CopySystem.doCreateCopyTeam,
		[COPY_CS_JOINCOPYTEAM] = CopySystem.doJoinCopyTeam,
		[COPY_CS_LEAVECOPYTEAM] = CopySystem.doLeaveCopyTeam,
		[COPY_CS_REMOVECOPYMEM] = CopySystem.doRemoveCopyMem,
		[COPY_CS_AUTOJOIN] = CopySystem.doAutoJoin,
		[COPY_CS_READY] = CopySystem.doReady,
		[COPY_CS_GETTEAMDATA] = CopySystem.doGetTeamData,
		[COPY_CS_OPENMULTIWIN] = CopySystem.doOpenMultiWin,
		--[COPY_CS_CLEARFRITIME] = CopySystem.doClearFriTime,
		[COPY_SS_SETFASTTIME] = CopySystem.doSetFastTime,
		[COPY_CS_GETCOPYSTARPRIZE] = CopySystem.doGetTowerCopyStarPrize,
		[COPY_CS_GETCOPYTOWERDATA] = CopySystem.doGetTowerCopyData,
		[COPY_CS_OPENNEWSINGLECOPY] = CopySystem.doOpenNewSingleCopy,                  --新增屠龙传说副本数据查询
		[COPY_CS_RESETTOWERCOPY] = CopySystem.doResetTowerCopy,
		[COPY_CS_TOWER_PROGRESS_CONTROL] = CopySystem.doCtrlTowerCopyProgress,
		[COPY_CS_REQ_MULTICOPY_LV] = CopySystem.doRetMultiCopyLevel,
		[COPY_CS_REQ_MULTICOPY_GETALLTEAM] = CopySystem.doRetMultiCopyAllTeam,
		[COPY_CS_TEAMCHALLENGE_MULTICOPY] = CopySystem.doTeamChanllengeReq,
		[COPY_CS_ANSWER_ATTEND_MULTICOPY] = CopySystem.answerAttendMultiCopy,
		[COPY_CS_SINGLEINSTANCE_DATA] = CopySystem.getSingleInstsData,
		[COPY_CS_RANDOM_DAILY_SINGLEINST] = CopySystem.reqRandomDailySingleInst,
		[COPY_CS_FINISH_SINGLEINST] = CopySystem.reqFinishSingleInst,
		[COPY_CS_ENTER_SINGLEINSTANCE] = CopySystem.doEnterSingleInst,
		[COPY_CS_CANCEL_ENTERCOPY] = CopySystem.doCancelEnterCopy,
		--[COPY_CS_OPENCOPYWIN] = CopySystem.doOpenCopyWin,
		--[COPY_CS_GETCOPYDATA] = CopySystem.doGetCopyData,

		--[COPY_CS_RECCURRPROREWARD]	= CopySystem.doRecCurrProReward,
		--[COPY_CS_RECSPECREWARD] = CopySystem.doRecSpecReward,
		--[COPY_CS_RESETGUARD] = CopySystem.doResetGuard,
		
		--[COPY_CS_CLEARPROTIME] = CopySystem.doClearProTime,
		--[COPY_CS_VIPRESTCOPYCD]  = CopySystem.doVipResetCopyCD,
		--[COPY_CS_GETMULTIDATA]	= CopySystem.doGetMultiData,

		--[COPY_CS_GETHURTRANK] = CopySystem.doGetHurtRank,

		--[COPY_CS_CLEARINNERCD] = CopySystem.doClearInnerCD,
		
		--[COPY_CS_GETGUARDDATA] = CopySystem.doGetGuardCopyData,
		--[COPY_CS_GUARDCOPY_ACTION] = CopySystem.doGuardCopyAction,
		
		--[COPY_CS_GUARDCOPY_AFTERDRAW] = CopySystem.doAfterGuardDrawCard,
		
	}
end

function CopySystem:fireMessage(mesID, roleID, eventID, eCode, paramCnt, params)
	local ret = {}
	local paramlist = {}
	ret.eventId = eventID
	ret.eCode = eCode
	ret.mesId = mesID
	for i=1, paramCnt do
		table.insert(paramlist,params[i])
	end
	ret.param = paramlist
	fireProtoMessage(roleID, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

local MonsterPos = 
{
	-1,0,  -1,1,  0,1,   1,1,   1,0,   1,-1,   0,-1,  -1,-1, 
	-2,0,  -2,1,  -2,2,  -1,2,  0,2,   1,2,    2,2,   2,1,  2,0,  2,-1,  2,-2,  1,-2,  0,-2,  -1,-2,  -2,-2,  -2,-1,
	-3,0,  -3,1,  -3,2,  -3,3,  -2,3,  -1,3,   0,3,   1,3,  2,3,  3,3,   3,2,   3,1,   3,0,   3,-1,   3,-2,    3,-3,
	2,-3,  1,-3,  0,-3,  -1,-3, -2,-3, -3,-3,  -3,-2, -3,-1
}

local MonsterRandomPos = 
{
	{-1,0},  {-1,1},  {0,1},   {1,1},   {1,0},   {1,-1},   {0,-1},  {-1,-1}, 
	{-2,0},  {-2,1},  {-2,2},  {-1,2},  {0,2},   {1,2},    {2,2},   {2,1},  {2,0}, {2,-1},  {2,-2},  {1,-2},  {0,-2},  {-1,-2},  {-2,-2},  {-2,-1},
	{-3,0},  {-3,1},  {-3,2},  {-3,3},  {-2,3},  {-1,3},   {0,3},   {1,3},  {2,3},  {3,3},   {3,2},   {3,1},   {3,0},   {3,-1},   {3,-2},    {3,-3},
	{2,-3},  {1,-3},  {0,-3},  {-1,-3}, {-2,-3}, {-3,-3},  {-3,-2}, {-3,-1}
}


local getOpenWinData = function(roleID)
end

--新增屠龙传说副本数据查新
local getOpenNewSingleCopy = function(roleID)
	local nowTime = os.time()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	--print("getOpenNewSingleCopy roleid",roleID)
	if copyPlayer then
		--local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_OPENNEWSINGLECOPYRET)
		local ret = {}
		ret.copyDailyCounts = {}
		ret.copyRatingTimes = {}
		if not copyPlayer:getDBdataload() then
			g_copySystem:fireMessage(COPY_CS_OPENNEWSINGLECOPY, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end

		local allCDData = copyPlayer:getCopyCDCount()
		local singleData = {}
		for mainID, count in pairs(allCDData) do
			--如果在新CD内则只清除CD数
			if copyPlayer:getLastEnterTime(mainID) ~= 0 and nowTime - copyPlayer:getLastEnterTime(mainID) >= ONE_DAY_SEC then
				copyPlayer:clearEnterCDCount(mainID)
			else
				local proto = g_copyMgr:getProto(mainID)
				if proto and proto:getCopyType() == CopyType.NewSingleCopy then
					singleData[mainID] = count
					--print("getOpenNewSingleCopy push copy count",mainID,count)
				end
			end
		end
		--[[buffer:pushShort(table.size(singleData))
		for mainID, count in pairs(singleData) do
			buffer:pushShort(mainID)
			buffer:pushChar(count)
		end]]
		
		for mainID, count in pairs(singleData) do
			local copyDailyCounts = {}
			copyDailyCounts.copyID = mainID
			copyDailyCounts.count = count
			table.insert(ret.copyDailyCounts,copyDailyCounts)
		end
		local singleTab = copyPlayer:getAllRatingTime()
		local copyTime = {}
		for mainID, rateTime in pairs(singleTab) do
			local proto = g_copyMgr:getProto(mainID)
			if proto and proto:getCopyType() == CopyType.NewSingleCopy then
				copyTime[mainID] = rateTime
				--print("getOpenNewSingleCopy push copy time",mainID,rateTime)
			end
		end
		--[[buffer:pushShort(table.size(copyTime))
		for mainID, rateTime in pairs(copyTime) do
			buffer:pushShort(mainID)
			buffer:pushChar(rateTime)
		end]]
		
		for mainID, rateTime in pairs(copyTime) do
			local copyTimes = {}
			copyTimes.copyID = mainID
			copyTimes.time = rateTime
			table.insert(ret.copyRatingTimes,copyTimes)
		end

		--g_engine:fireLuaEvent(roleID, buffer)	
		fireProtoMessage(roleID, COPY_SC_OPENNEWSINGLECOPYRET, 'CopyDailyDataProtocol', ret)
	end
end

function CopySystem:doTeamChanllengeReq(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then
		return
	end
	local req, err = protobuf.decode("MultiCopyTeamChallengeProtocol" , buffer)
	if not req then
		print('CopySystem:doTeamChanllengeReq '..tostring(err))
		return
	end
	local copyLevel = req.copyLevel
	local team = g_TeamPublic:getTeam(player:getTeamID())
	local res = 0
	local teamMembers = {}
	if not team then
		res = 1
		g_copySystem:fireMessage(COPY_CS_OPENNEWSINGLECOPY, roleID, EVENT_COPY_SETS, COPY_MULTI_TEAMCHANLLENGE_NO_TEAM, 0)
		return
	else
		g_TeamPublic:onSetTeamTarget(sid,copyLevel+4)
		team:setNeedBattle(-1)
		teamMembers = team:getOnLineMems()
		teamnum = #teamMembers
		if not g_TeamPublic:isTeamLeader(sid) then
			res = 1
			g_copySystem:fireMessage(COPY_CS_OPENNEWSINGLECOPY, roleID, EVENT_COPY_SETS, COPY_MULTI_TEAMCHANLLENGE_NOT_LEADER, 0)
			return
		end
	end
	for _,memberId in pairs(teamMembers) do
		local member = g_entityMgr:getPlayerBySID(memberId)
		if member then
			local level = member:getLevel()
			local info = {}
			local errorCode = 0
			local copyPlayer = g_copyMgr:getCopyPlayer(member:getID())
			if level < 34 then
				errorCode = 1
			elseif copyPlayer and (copyPlayer:getCurCopyInstID()>0 or member:getMapID()>=6000) then
				errorCode = 2
			elseif copyPlayer and copyPlayer:getCurrentMultiCopyLevel()<copyLevel then
				errorCode = 3
			end
			if errorCode > 0 then
				g_TeamPublic:onRemoveMember(player,memberId)
				local errorMsgId = 0
				if errorCode == 1 then
					errorMsgId = COPY_MULTI_TEAMCHANLLENGE_LOW_LEVEL
				elseif errorCode == 2 then
					errorMsgId = COPY_MULTI_TEAMCHANLLENGE_ALREADY_IN_COPY
				elseif errorCode == 3 then
					errorMsgId = COPY_MULTI_TEAMCHANLLENGE_TOO_HARD
				end
				--send some warning msg
				self:fireMessage(0, member:getID(), EVENT_COPY_SETS, errorMsgId, 0)
			else
				local ret = {}
				ret.copyId = copyLevel
				fireProtoMessage(member:getID(),COPY_SC_REQUEST_ATTEND_MULTICOPY,"MultiCopyLeaderQuestAttendProtocol",ret)
			end
		end
	end
	--ret.result = res
	--fireProtoMessage(roleID,COPY_SC_TEAMCHALLENGE_RES_MULTICOPY,"MultiCopyTeamChanllengeResProtocol",ret)
end

function CopySystem:answerAttendMultiCopy(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then
		return
	end
	
	
	local teamid = player:getTeamID()
	local team = g_TeamPublic:getTeam(teamid)
	if not team then
		return
	end
	local req, err = protobuf.decode("MultiCopyAnswerAttendProtocol" , buffer)
	if not req then
		print('CopySystem:answerAttendMultiCopy '..tostring(err))
		return
	end
	local answer = req.answer
	local leaderSid = team:getLeaderID()

	if answer == 1 then
		local ret = {}
		ret.roleSid = sid
		ret.answer = answer
		fireProtoMessageBySid(leaderSid,COPY_SC_ANSWER_ATTEND_MULTICOPY,"MultiCopyAnswerToLeaderProtocol",ret)
	else
		g_TeamPublic:onLeaveTeam(player)
	end
end


function CopySystem:doRetMultiCopyLevel(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then
		return
	end
	local ret = {}
	ret.currentLv = copyPlayer:getCurrentMultiCopyLevel()
	ret.todayPassLvs = {}
	for i=1,3 do
		if time.toedition("day") ~= copyPlayer:getMultiGuardTime(i) then
			copyPlayer:resetMultiGuardCnt(i)
		end
		if copyPlayer:getMultiGuardCnt(i)>=5 then
			table.insert(ret.todayPassLvs,i)
		end
	end
	fireProtoMessage(roleID,COPY_SC_MULTICOPY_LV,"MultiCopyLvProtocol",ret)
end

function CopySystem:doRetMultiCopyAllTeam(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then
		return
	end

	local req, err = protobuf.decode("ReqMultiCopyAllTeamDataProtocol" , buffer)
	if not req then
		print('CopySystem:doRetMultiCopyAllTeam '..tostring(err))
		return
	end

	self:getAllCopyTeamData(roleID, req.copyId)

end

function CopySystem:doResetTowerCopy(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local ret = 0
	if g_copyMgr:getTowerCopySwitch()==0 then 
		return 
	end
	--copyPlayer:checkResetTower()
	if copyPlayer:getTowerCopyResetNum()>0 then
		ret = -1
	elseif copyPlayer:getTowerCopyProgress()==1 then
		ret = -2
	else
		copyPlayer:setTowerCopyProgress(1)
		copyPlayer:setTowerCopyResetNum(copyPlayer:getTowerCopyResetNum()+1)
		ret = 0
	end
	local retStr = {}
	retStr.roleId = roleID
	retStr.result = ret
	fireProtoMessage(roleID, COPY_SC_RESETTOWERCOPY, 'CopyResetTowerCopyRetProtocol', retStr)
	copyPlayer:setUpdateCopyCnt(true)
end


function CopySystem:doOpenNewSingleCopy(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	if g_copyMgr:getSingleCopySwitch()==0 then return end
	getOpenNewSingleCopy(roleID)
end
function CopySystem:getSingleInstsData(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then 
		return 
	end
	
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		copyPlayer:sendSingleInstData()
	end
end

function CopySystem:doAfterGuardDrawCard(buffer1)
	return
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local gBook = GuardBook()
	gBook:AfterDrawCard(roleID)]]
end

--塞奖励给玩家
local pushReward = function(roleID, rewards1, t)
	local player = g_entityMgr:getPlayer(roleID)
	if player then	
		local rewards = rewards1[2]
		player:setMoney(player:getMoney() + (rewards[ITEM_MONEY_ID] and rewards[ITEM_MONEY_ID].num or 0))
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 1, 58, player:getMoney(), rewards[ITEM_MONEY_ID] and rewards[ITEM_MONEY_ID].num or 0, 1)
		player:setBindIngot(player:getBindIngot() + (rewards[ITEM_BIND_INGOT_ID] and rewards[ITEM_BIND_INGOT_ID].num or 0))
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 4, 58, player:getBindIngot(), rewards[ITEM_BIND_INGOT_ID] and rewards[ITEM_BIND_INGOT_ID].num or 0, 1)
		player:setIngot(player:getIngot() + (rewards[ITEM_INGOT_ID] and rewards[ITEM_INGOT_ID].num or 0))
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, 58, player:getIngot(), rewards[ITEM_INGOT_ID] and rewards[ITEM_INGOT_ID].num or 0, 1)
		if player:getXP() + (rewards[ITEM_EXP_ID] and rewards[ITEM_EXP_ID].num or 0) > 100000000 then
			print("-----too much exp", player:getSerialID(), player:getXP() + (rewards[ITEM_EXP_ID] or 0))
		end
		--player:setXP(player:getXP() + (rewards[ITEM_EXP_ID] or 0))
		--Tlog[PlayerExpFlow]
		addExpToPlayer(player,(rewards[ITEM_EXP_ID] and rewards[ITEM_EXP_ID].num or 0),58)

		player:setVital(player:getVital() + (rewards[ITEM_VITAL_ID] and rewards[ITEM_VITAL_ID].num or 0))
		g_logManager:writeMoneyChange(player:getSerialID(), '0', 5, 58, player:getVital(), rewards[ITEM_VITAL_ID] and rewards[ITEM_VITAL_ID].num or 0, 1)
		rewards[ITEM_BIND_MONEY_ID] = nil
		rewards[ITEM_MONEY_ID] = nil
		rewards[ITEM_BIND_INGOT_ID] = nil
		rewards[ITEM_INGOT_ID] = nil
		rewards[ITEM_EXP_ID] = nil
		rewards[ITEM_VITAL_ID] = nil
		local tmpnt = table.size(rewards)
		local itemMgr = player:getItemMgr()
		local emptySlot = itemMgr:getEmptySize()

		if tmpnt <= emptySlot then
			for itemID, count in pairs(rewards) do
 				itemMgr:addBagItem(itemID, count.num, count.bind)
			end
		else
			--发邮件
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			local emailConfigId = 34	--包裹满时发邮件
			email:setDescId(emailConfigId)
			for itemID, count in pairs(rewards) do
				email:insertProto(itemID, count.num, count.bind)
			end

			offlineMgr:recvEamil(player:getSerialID(), email)
			g_copySystem:fireMessage(0, roleID, EVENT_COPY_SETS, COPY_MSG_SEND_EMAIL, 0)
		end
	end
end

function CopySystem:enterNextTower(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if not player or player:getHP() <= 0 then return end
	local copyInstid = player:getCopyID()
	local copyBook = g_copyMgr:getCopyBookById(copyInstid)
	if not copyBook then
		self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_TOWER_HIGHER, 0)
		return
	end
	local proto = g_copyMgr:getProto(copyBook:getNextCopy())
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local ret,eCode = self:canEnterCopy(copyPlayer,player,proto:getCopyID())
	if not ret then
		self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, eCode, 0)
		return
	end
	local newBook = TowerBook(roleID, copyBook:getNextCopy(), proto)
	newBook:setCurrInsId(copyInstid)
	copyPlayer:setCurrentCopyID(copyBook:getNextCopy())
	local player = copyPlayer:getRole()
	player:setHP(player:getMaxHP())
	for mapID, scene in pairs(copyBook:getAllScene() or {}) do
		newBook:addScene(mapID, scene)
		local pScene = g_sceneMgr:getById(scene)
		g_sceneMgr:cleanSceneMapItem(pScene)
	end
	newBook:setSumExp(copyBook:getSumExp())
	--release(copyBook)
	g_sceneMgr:enterLocalScene(roleID, proto:getEnterPos()[1], proto:getEnterPos()[2])
	--刷新怪物
	g_copySystem:flushMonster(newBook, 1)
	--实例ID不变
	g_copyMgr._towerCopy[copyInstid] = newBook
	--通知前端
	--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_DONEXTCIRCLE)
	buffer:pushChar(CopyType.TowerCopy)
	buffer:pushShort(newBook:getCurrCircle())
	buffer:pushInt(newBook:getRemainTime())
	g_engine:fireLuaEvent(roleID, buffer)]]
	local ret = {}
	ret.copyType = CopyType.TowerCopy
	ret.curCircle = newBook:getCurrCircle()
	ret.remainTime = newBook:getRemainTime()
	fireProtoMessage(roleID, COPY_SC_DONEXTCIRCLE, 'DoNextCircleProtocol', ret)
end

function CopySystem:enterNextCopy(roleID)
	return
	--[[local player = g_entityMgr:getPlayer(roleID)
	if not player or player:getHP() <= 0 then return end
	local copyInstid = player:getCopyID()
	local copyBook = g_copyMgr:getCopyBookById(copyInstid)
	if not copyBook then
		return
	end
	local proto = g_copyMgr:getProto(copyBook:getNextCopy())
	local pricessId = copyBook:getStatueID()
	local statue = g_entityMgr:getMonster(pricessId)
	if statue then 
		statue:setMaxHP(proto:getStatueHP())
		statue:setHP(proto:getStatueHP())
	end
	
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local newBook = GuardBook(roleID, copyBook:getNextCopy(), proto)
	newBook:setCurrInsId(copyInstid)
	copyPlayer:setCurrentCopyID(copyBook:getNextCopy())
	local player = copyPlayer:getRole()
	player:setHP(player:getMaxHP())
	newBook:setStatueID(copyBook:getStatueID())
	for mapID, scene in pairs(copyBook:getAllScene() or {}) do
		newBook:addScene(mapID, scene)
	end
	newBook:setSumExp(copyBook:getSumExp())
	release(copyBook)
	g_sceneMgr:enterLocalScene(roleID, proto:getStatuePos()[1], proto:getStatuePos()[2])
	--g_sceneMgr:enterLocalScene(pricessId, proto:getStatuePos()[1], proto:getStatuePos()[2])
	
	--刷新怪物
	g_copySystem:flushMonster(newBook, 1)
	--实例ID不变
	g_copyMgr._guardCopy[copyInstid] = newBook
	--通知前端
	local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_DONEXTCIRCLE)
	buffer:pushChar(CopyType.GuardCopy)
	buffer:pushShort(newBook:getCurrCircle())
	buffer:pushInt(newBook:getRemainTime())
	g_engine:fireLuaEvent(roleID, buffer)]]
end

--多人本判断
function CopySystem:multiBaseVerify(copyPlayer, player, proto, needBattle)

	print(">>>>>>>levelinfo>>>>>>",player:getLevel(),proto:getLevel())
	if copyPlayer:getCurCopyInstID() > 0 then
		return false, COPY_ERR_IS_IN_COPY
	elseif player:getLevel() < proto:getLevel() then
		return false, COPY_ERR_LEVEL_LOWER
	elseif copyPlayer:getCurrentMultiCopyLevel()<proto.data.mainID then
		return false, COPY_MULTI_LOWER_TYPE
	--elseif player:getbattle() < needBattle then
	--	return false, COPY_ERR_UNFULL_BATTLE
	else
		return true
	end
end

--获取副本队伍数据
function CopySystem:getCopyTeamData(copyTeam, roleID)
	--[[local allCopyMem = copyTeam:getAllMems()
	local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_GETTEAMDATARET)
	buffer:pushInt(copyTeam:getTeamID())
	buffer:pushInt(copyTeam:getCopyID())
	buffer:pushInt(copyTeam:getNeedBattle())
	buffer:pushChar(#allCopyMem)
	for i=1, #allCopyMem do
		local memPlayer = g_entityMgr:getPlayer(allCopyMem[i])
		if memPlayer then
			buffer:pushInt(allCopyMem[i])
			buffer:pushString(memPlayer:getName())
			buffer:pushInt(memPlayer:getbattle())
			buffer:pushBool(copyTeam:getMemState(allCopyMem[i]) == true and true or false)
			buffer:pushChar(memPlayer:getSchool())
			buffer:pushChar(memPlayer:getSex())
		else
			buffer:pushInt(0)
			buffer:pushString("")
			buffer:pushInt(0)
			buffer:pushBool(false)
			buffer:pushChar(1)
			buffer:pushChar(1)
			print("-----CopySystem:doJoinCopyTeam出错了 ", i, allCopyMem[i], debug.traceback())
		end
	end

	if roleID then
		g_engine:fireLuaEvent(roleID, buffer)
	else
		for i=1, #allCopyMem do
			g_engine:fireLuaEvent(allCopyMem[i], buffer)
		end
	end]]
	local allCopyMem = copyTeam:getAllMember()
	local ret = {}
	ret.teamId = copyTeam:getTeamID()
	ret.copyId = copyTeam:getCopyID()
	ret.createTime = copyTeam:getCreateTime()
	ret.memNum = #allCopyMem
	ret.info = {}

	for i=1, #allCopyMem do
		local memPlayer = g_entityMgr:getPlayerBySID(allCopyMem[i])
		local teaminfo = {}
		if memPlayer then
			teaminfo.memberId = allCopyMem[i]
			teaminfo.memberName = memPlayer:getName()
			teaminfo.memberBattle = memPlayer:getbattle()
			teaminfo.memberStatus = copyTeam:getMemState(allCopyMem[i]) == true and true or false
			teaminfo.memberSchool = memPlayer:getSchool()
			teaminfo.memberSex = memPlayer:getSex()
		else
			teaminfo.memberId = 0
			teaminfo.memberName = ""
			teaminfo.memberBattle = 0
			teaminfo.memberStatus = false
			teaminfo.memberSchool = 1
			teaminfo.memberSex = 1
		end
		table.insert(ret.info,teaminfo)
	end

	if roleID then
		fireProtoMessage(roleID, COPY_SC_GETTEAMDATARET, 'CopyGetTeamDataRetProtocol', ret)
		self:getAllCopyTeamData(roleID, copyTeam:getCopyID())
	else
		for i=1, #allCopyMem do
			fireProtoMessage(allCopyMem[i], COPY_SC_GETTEAMDATARET, 'CopyGetTeamDataRetProtocol', ret)
		end
	end
	--退出成功刷所有队伍
	

	--重刷数据给所有Opens
	local copyID = copyTeam:getCopyID()
	local ret = {}
	local allCopyTeams = g_copyMgr:getMultiCopyTeams(copyID)
	local tmp = {}
	for k, v in pairs(allCopyTeams) do
		local team = g_TeamPublic:getTeam(v)
		if team and not team:getInCopy() then
			tmp[k] = team
		end
	end
	ret.copyId = copyID
	ret.teamNum = table.size(tmp)
	ret.info = {}
	
	for k, v in pairs(tmp) do
		local teaminfo = {}
		teaminfo.teamId = v:getTeamID()
		teaminfo.leaderName = v:getLeaderName()
		teaminfo.createTime = v:getCreateTime()
		teaminfo.memberCnt = v:getMemCount()
		teaminfo.leaderBattle = v:getLeaderBattle()
		table.insert(ret.info,teaminfo)
	end
	local allOpens = g_copyMgr:getAllOpenMultiWin()
	for rid, _ in pairs(allOpens) do
		fireProtoMessage(rid, COPY_SC_GETALLTEAMDATA, 'CopyGetAllTeamDataProtocol', ret)
	end
end

function CopySystem:doGetCopyMemPos(roleID)
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		if copyPlayer:getCopyTeamID() > 0 and copyPlayer:getCurCopyInstID() > 0 then
			local copyTeam = g_copyMgr:getCopyTeam(copyPlayer:getCopyTeamID())
			local allCopyMems = copyTeam:getAllMember()
			local data = {}
			for i=1, #allCopyMems do
				local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
				if roleID ~= player:getID() then
					local pos = memPlayer:getPosition()
					table.insert(data, {pos.x, pos.y, id, memPlayer:getName()})
				end
			end
			if #data > 0 then
				local ret = {}
				ret.bTag = true
				ret.num = #data
				ret.infos = {}
				for i=1, #data do
					local info = {}
					info.posX = data[i][1]
					info.posY = data[i][2]
					info.mapId = data[i][3]
					info.name = data[i][4]
					table.insert(ret.infos,info)
				end
				fireProtoMessage(roleID, TEAM_SC_GETTEAMPOSINFO , 'TeamGetTeamPosInfoProtocol', ret)
			end
			local multiCopy = g_copyMgr:getCopyBookById(copyPlayer:getCurCopyInstID())
			local allPosMon = multiCopy:getAllPosMon()
			data = {}
			for k, _ in pairs(allPosMon) do
				local tmpMon = g_entityMgr:getMonster(k)
				if tmpMon then
					local pos = tmpMon:getPosition()
					table.insert(data, {pos.x, pos.y, k, tmpMon:getName()})
				end
			end
			if #data > 0 and #data<=8 then
				local ret = {}
				ret.bTag = false
				ret.num = #data
				ret.infos = {}
				for i=1, #data do
					local info = {}
					info.posX = data[i][1]
					info.posY = data[i][2]
					info.mapId = data[i][3]
					info.name = data[i][4]
					table.insert(ret.infos,info)
				end
				fireProtoMessage(roleID, TEAM_SC_GETTEAMPOSINFO , 'TeamGetTeamPosInfoProtocol', ret)
			end
			g_copyMgr:addSynMemPosInfo(roleID)
		else
			g_copyMgr:removeSynMemPosInfo(roleID)
		end
	end
end

--所有副本队伍数据
function CopySystem:getAllCopyTeamData(roleID, copyID)
	local ret = {}
	local allCopyTeams = g_copyMgr:getMultiCopyTeams(copyID)

	local tmp = {}
	for _, v in pairs(allCopyTeams) do
		local team = g_TeamPublic:getTeam(v)
		if team and not team:getInCopy() then
			table.insert(tmp,team)
		end
	end
	--[[local sortFun = function(a, b)
		if a:getMemCnt() > b:getMemCnt() then
			return true
		elseif a:getCreateTime() < b:getCreateTime() then 
			return true
		elseif a:getTeamID() < b:getTeamID() then
			return true
		else
			return false
		end
	end
	table.sort(tmp, sortFun)]]
	ret.copyId = copyID
	ret.teamNum = table.size(tmp)
	ret.info = {}
	for _, v in pairs(tmp) do
		local teaminfo = {}
		teaminfo.teamId = v:getTeamID()
		teaminfo.leaderName = v:getLeaderName()
		teaminfo.createTime = v:getCreateTime()
		teaminfo.memberCnt = v:getMemCount()
		teaminfo.leaderBattle = v:getLeaderBattle()
		table.insert(ret.info,teaminfo)
	end
	
	fireProtoMessage(roleID, COPY_SC_GETALLTEAMDATA, 'CopyGetAllTeamDataProtocol', ret)

end

--元宝清除内置CD
function CopySystem:doClearInnerCD(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local copyID = buffer:popInt() 
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		local proto = g_copyMgr:getProto(copyID)
		if proto then
			local pType = proto:getCopyType()
			local nt = os.time()
			local oldingot = player:getIngot() 
			if pType == CopyType.SingleCopy then
				local innercd = copyPlayer:getSingleInnerTime(copyID)
				local dif = proto:getInnerCD() - nt + innercd
				if dif > 0 then
					local needIngot = math.floor(dif/300)*INNER_PER_INGOT
					if needIngot == 0 then needIngot = INNER_PER_INGOT end
					if oldingot >= needIngot then
						player:setIngot(oldingot - needIngot)
						g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, 6, player:getIngot(), (-1) * needIngot)
						g_PayRecord:Record(player:getID(), -needIngot,  CURRENCY_INGOT, 17)
						--充值成就
						g_achieveSer:costIngot(player:getSerialID(), needIngot)

						copyPlayer:setSingleInnerTime(copyID)
						local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_CLEARINNERCDRET)
						buffer:pushInt(copyID)
						g_engine:fireLuaEvent(roleID, buffer)
						self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_MSG_CLEAR_INNER_CD, 0)
					else
						self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_ENOUGH_INGOT, 0)
					end
				else
					self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_INNERCD, 0)
				end
			elseif pType == CopyType.TowerCopy then
				local innercd = copyPlayer:getTowerInnerTime()
				
				local dif = innercd-nt
				if dif <= 0 then
					--不需要
					self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_INNERCD, 0)
					if innercd ~= 0 and not copyPlayer:getCanTower() then
						copyPlayer:setCanTower(true)
					end
				elseif copyPlayer:getTowerInnerTime() > 0 then
					local needIngot = math.floor(dif/300)*INNER_PER_INGOT
					if needIngot == 0 then needIngot = INNER_PER_INGOT end
					if oldingot >= needIngot then
						player:setIngot(oldingot - needIngot)
						g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, 6, player:getIngot(), (-1) * needIngot)
						g_PayRecord:Record(player:getID(), -needIngot,  CURRENCY_INGOT, 17)
						--充值成就
						g_achieveSer:costIngot(player:getSerialID(), needIngot)

						copyPlayer:addTowerInnerTime(-4000)
						local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_CLEARINNERCDRET)
						buffer:pushInt(copyID)
						g_engine:fireLuaEvent(roleID, buffer)
						self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_MSG_CLEAR_INNER_CD, 0)
					else
						self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_ENOUGH_INGOT, 0)
					end
				else
					self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_INNERCD, 0)
				end
			else 
				self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_INNERCD, 0)
			end
		else
			self:fireMessage(COPY_CS_CLEARINNERCD, roleID, EVENT_COPY_SETS, COPY_ERR_INVALIDCOPY, 0)
		end
	end]]
end

function CopySystem.doClearFriTimeByYuanbao(roleSID, payRet, money, itemId, itemCount, callBackContext)
	local context = unserialize(callBackContext)
	local friSID = context.playerSid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return TPAY_FAILED end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then return TPAY_FAILED end
	local relationInfo = g_relationMgr:getRoleRelationInfo(roleID)
	if not relationInfo then return TPAY_FAILED end

	g_achieveSer:costIngot(player:getSerialID(), money)

	copyPlayer:addFriInviteData(friSID, os.time()-HELP_CD_TIME, true)
	g_copySystem:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_CLEAR_CALL_CD, 0)

	local result = {}
	local allFriend = relationInfo:getAllFriend()
	for friSID1, friInfo in pairs(allFriend) do
		if g_relationMgr:isFriendEachOther(roleID, friSID1) then
			result[friSID1] = friInfo
		end
	end

	local ret = {}
	ret.friendNum = table.size(result)
	local nowTime = os.time()
	ret.info = {}
	local fInfo = {}
	for friSID, friInfo in pairs(result) do
		fInfo.friendSid = friSID
		fInfo.friendSchool = friInfo.school
		fInfo.friendName = friInfo.name
		fInfo.friendLevel = friInfo.level
		fInfo.friendBattle = friInfo.fightAbility
		fInfo.friendSex = friInfo.sex or 1
		local inviteData = copyPlayer:getInviteData(friSID)
		if inviteData then
			local difTime = nowTime - inviteData
			if difTime >= HELP_CD_TIME then
				fInfo.remainCD = 0
			else
				fInfo.remainCD = HELP_CD_TIME - difTime
			end
		else
			fInfo.remainCD = 0
		end
		fInfo.needIngot = copyPlayer:getFriInviteCnt(friSID)*CALL_PER_INGOT
		table.insert(ret.info,fInfo)
	end
	fireProtoMessage(player:getID(), COPY_SC_GETFRIENDDATARET, 'CopyGetFriendDataRetProtocol', ret)
	return TPAY_SUCESS
end


function CopySystem:doClearFriTime(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("CopyClearFriendTimeProtocol" , buffer)
	if not req then
		return
	end
	local friSID = req.friendSid
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and player then
		local relationInfo = g_relationMgr:getRoleRelationInfo(roleID)
		if relationInfo then
			local friend = relationInfo:getFriend(friSID)
			if friend then
				if g_relationMgr:isFriendEachOther(roleID, friSID) then
					local inviteData = copyPlayer:getInviteData(friSID)
					local difTime = os.time() - inviteData
					if difTime < HELP_CD_TIME then
						local callCnt = copyPlayer:getFriInviteCnt(friSID)
						local needIngot = callCnt*CALL_PER_INGOT
						
						if isIngotEnough(player, needIngot) then
							--请求扣元宝
							local context = {playerSid = friSID}
							local ret = g_tPayMgr:TPayScriptUseMoney(player, needIngot, 53, "Clear Friend CD", 0, 0, "CopySystem.doClearFriTimeByYuanbao", serialize(context)) 
							if ret ~= 0 then
								g_copySystem:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_SYSTEM_BUSY, 0)
								return 
							else
								return
							end
						else
							self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_ENOUGH_INGOT, 0)
						end
					else
						self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_FRI_NOT_IN_CALLCD, 0)
					end
				else
					self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTHIS_FRIEND, 1, {friend.name})
				end
			else
				self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTYOUR_FRIEND, 0)
			end
		else
			self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTYOUR_FRIEND, 0)
		end
	end

end


--元宝清除援护时间
--[[function CopySystem:doClearFriTime(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("CopyClearFriendTimeProtocol" , buffer:popString())
	if not req then
		print('CopySystem:doClearFriTime '..tostring(err))
		return
	end
	local friSID = req.friendSid
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and player then
		local relationInfo = g_relationMgr:getRoleRelationInfo(roleID)
		if relationInfo then
			local friend = relationInfo:getFriend(friSID)
			if friend then
				if g_relationMgr:isFriendEachOther(roleID, friSID) then
					local inviteData = copyPlayer:getInviteData(friSID)
					local difTime = os.time() - inviteData
					if difTime < HELP_CD_TIME then
						local callCnt = copyPlayer:getFriInviteCnt(friSID)
						local needIngot = callCnt*CALL_PER_INGOT
						local ningot = player:getIngot() 
						if ningot >= needIngot then
							player:setIngot(ningot - needIngot)
							g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, 6, player:getIngot(), (-1) * needIngot)
							g_PayRecord:Record(player:getID(), -needIngot,  CURRENCY_INGOT, 17)
							--充值成就
							g_achieveSer:costIngot(player:getSerialID(), needIngot)

							copyPlayer:addFriInviteData(friSID, os.time()-HELP_CD_TIME, true)
							self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_CLEAR_CALL_CD, 0)

							local result = {}
							local allFriend = relationInfo:getAllFriend()
							for friSID1, friInfo in pairs(allFriend) do
								if g_relationMgr:isFriendEachOther(roleID, friSID1) then
									result[friSID1] = friInfo
								end
							end

							local ret = {}
							ret.friendNum = table.size(result)
							local nowTime = os.time()
							ret.info = {}
							local fInfo = {}
							for friSID, friInfo in pairs(result) do
								fInfo.friendSid = friSID
								fInfo.friendSchool = friInfo.school
								fInfo.friendName = friInfo.name
								fInfo.friendLevel = friInfo.level
								fInfo.friendBattle = friInfo.fightAbility
								fInfo.friendSex = friInfo.sex or 1
								local inviteData = copyPlayer:getInviteData(friSID)
								if inviteData then
									local difTime = nowTime - inviteData
									if difTime >= HELP_CD_TIME then
										fInfo.remainCD = 0
									else
										fInfo.remainCD = HELP_CD_TIME - difTime
									end
								else
									fInfo.remainCD = 0
								end
								fInfo.needIngot = copyPlayer:getFriInviteCnt(friSID)*CALL_PER_INGOT
								table.insert(ret.info,fInfo)
							end
							fireProtoMessage(player:getID(), COPY_SC_GETFRIENDDATARET, 'CopyGetFriendDataRetProtocol', ret)
						else
							self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_ENOUGH_INGOT, 0)
						end
					else
						self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_FRI_NOT_IN_CALLCD, 0)
					end
				else
					self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTHIS_FRIEND, 1, {friend.name})
				end
			else
				self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTYOUR_FRIEND, 0)
			end
		else
			self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTYOUR_FRIEND, 0)
		end
	end
end]]

function CopySystem:doOpenMultiWin(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	--local roleID = buffer:popInt()
	local req, err = protobuf.decode("CopyOpenMultiWinProtocol" , buffer)
	if not req then
		print('CopySystem:doOpenMultiWin '..tostring(err))
		return
	end
	local flag = req.flag
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		if not flag then
			g_copyMgr:removeOpenMultiWin(roleID)
		end
	end
end

function CopySystem:doSetFastTime(buffer1)
	local params = buffer1:getParams()
	local buffer, serverId = params[1], params[2]
	local copyID = buffer:popInt()
	local school = buffer:popInt()
	local useTime = buffer:popInt()
	local roleSID = buffer:popInt()
	local name = buffer:popString()
	local rolePower = buffer:popInt()
	
	g_copyMgr:setFastestRecord2(copyID, school, useTime, roleSID, name,rolePower)
end

function CopySystem:doGetTowerCopyStarPrize(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("CopyGetStarPrizeProtocol" , buffer)
	if not req then
		print('CopySystem:doGetTowerCopyStarPrize '..tostring(err))
		return
	end
	local levelNum = req.prizeIndex
	if g_copyMgr:getTowerCopySwitch()==0 then return end
	self:getCopyLevelPrize(roleID,levelNum)
end

function CopySystem:getCopyLevelPrize(playerID,levelNum)
	if g_copyMgr:getTowerCopySwitch()==0 then return end
	local copyPlayer = g_copyMgr:getCopyPlayer(playerID)
	local player = g_entityMgr:getPlayer(playerID)
	local roleSId = player:getSerialID()
	if not copyPlayer or not player then 
		if not copyPlayer then 
			print("No Copy Player")
		end
		if not player then
			print("No Player")
		end
		return 
	end
	--local starCount = copyPlayer:calPlayerCopyStarCount()
	local maxLayer = copyPlayer:getMaxTowerLayer()
	local maxProto = g_copyMgr:getProto(maxLayer)
	local maxTowerLevel = maxProto:getCopyLayer()
	print("CopySystem:getCopyLevelPrize",maxTowerLevel,levelNum)
	if maxTowerLevel<levelNum then
		print("not enough levels")
		--!需要提示获得的星数不够
		return 
	end
	local getprizeTag = copyPlayer:getCopyStarPrize(levelNum)
	if getprizeTag~=0 then
		print("already get prize")
		--!需要提示已经领取过这个奖励
		return 
	end
	local proto = g_copyMgr:getProto(COPY_TOWER_FIRST)--星级奖励记录在第一层的配置里
	local rewardID = 0
	for v,k in pairs(proto:getCopyStarPrize()) do
		if v==levelNum then
			rewardID = k
			break
		end
	end
	if rewardID==0 then
		print("none prize")
		--!需要提示领取的奖励信息不存在
		return 
	end
	copyPlayer:setCopyStarPrize(levelNum)
	print(playerID.." Got Prize Success!  "..rewardID)
	local ret,rewardData = rewardByDropID(player:getSerialID(), rewardID, 11,53)
	--[[local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_GETCOPYSTARPRIZE_RET)
	buffer:pushInt(playerID)
	buffer:pushInt(nStarCount)
	g_engine:fireLuaEvent(playerID, buffer)]]
	local ret = {}
	ret.roleId = playerID
	ret.prizeIndex = levelNum
	fireProtoMessage(playerID, COPY_SC_GETCOPYSTARPRIZE_RET, 'CopyGetStarPrizeRetProtocol', ret)
	
end

function CopySystem:testdoGetTowerCopyData(playerID)
	local player = g_entityMgr:getPlayerBySID(playerID)
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if g_copyMgr:getTowerCopySwitch()==0 then return end
	if copyPlayer  then
		--副本数据
		local ret = {}
		local allTowerProto = g_copyMgr:getTowerProtos()
		ret.copyNum = table.size(allTowerProto)
		ret.info = {}
		for copyID, proto in pairs(allTowerProto) do
			local copyinfo = {}
			copyinfo.copyId = copyID
			copyinfo.useTime = copyPlayer and copyPlayer:getRatingTime(copyID) or 0
			copyinfo.info = {}
			local fastData = g_copyMgr:getFastestRecord(copyID, player:getSchool()) or {}
			if #fastData > 0 then
				copyinfo.info.useTime = fastData[1]
				copyinfo.info.name = fastData[3]
				copyinfo.info.battle = fastData[4]
			else
				copyinfo.info.useTime = 0
				copyinfo.info.name = ""
				copyinfo.info.battle = 0
			end
			local star = copyPlayer:getRatingStar(copyID)
			copyinfo.getStarNum = star
			table.insert(ret.info,copyinfo)
		end
		local towerId = COPY_TOWER_FIRST
		while towerId<=COPY_TOWER_LAST do
			local rateStar = copyPlayer:getRatingStar(towerId)
			if rateStar>0 then
				maxProgress = towerId
			else
				break
			end
			towerId = towerId + 1
		end
		local proto = allTowerProto[COPY_TOWER_FIRST]
		local starPrizes = proto:getCopyStarPrize()
		ret.starPrizeNum = table.size(starPrizes)
		ret.starPrizeInfo = {}
		for k,v in pairs(starPrizes) do
			local starprize = {}
			starprize.starIndex = k
			starprize.starNum = copyPlayer:getCopyStarPrize(k)
			table.insert(ret.starPrizeInfo,starprize)
		end
		local protoMax = g_copyMgr:getProto(copyPlayer:getMaxTowerLayer())
		if protoMax then
			ret.maxLayer = protoMax:getCopyLayer()
		else
			ret.maxLayer = 0
		end
		ret.curLayer = copyPlayer:getTowerCopyProgress()
		ret.resetNum = copyPlayer:getTowerCopyResetNum()
		if copyPlayer:getNowProgressCopyId() then
			ret.nowProgress = copyPlayer:getNowProgressCopyId().copyId
			ret.nowProgressLeftTime  = copyPlayer:getNowProgressCopyId().duraTime-(os.time()-copyPlayer:getNowProgressCopyId().startTime)
			if ret.nowProgressLeftTime<=0 then
				ret.nowProgressLeftTime = 0
			end
			
		end
		ret.maxCanProgressCopy = maxProgress
		fireProtoMessage(roleID, COPY_SC_GETCOPYTOWERDATA_RET, 'CopyGetTowerDataRetProtocol', ret)
	end
end

function CopySystem:doGetTowerCopyData(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
	if g_copyMgr:getTowerCopySwitch()==0 then return end
	if copyPlayer and player then
		copyPlayer:checkResetTower()
		--副本数据
		local ret = {}
		local allTowerProto = g_copyMgr:getTowerProtos()
		ret.copyNum = table.size(allTowerProto)
		ret.info = {}
		local maxProgress = 0
		for copyID, proto in pairs(allTowerProto) do
			local copyinfo = {}
			copyinfo.copyId = copyID
			copyinfo.useTime = copyPlayer and copyPlayer:getRatingTime(copyID) or 0
			copyinfo.info = {}
			local fastData = g_copyMgr:getFastestRecord(copyID, player:getSchool()) or {}
			if #fastData > 0 then
				copyinfo.info.useTime = fastData[1]
				copyinfo.info.name = fastData[3]
				copyinfo.info.battle = fastData[4]
			else
				copyinfo.info.useTime = 0
				copyinfo.info.name = ""
				copyinfo.info.battle = 0
			end
			local star = copyPlayer:getRatingStar(copyID)
			copyinfo.getStarNum = star
			table.insert(ret.info,copyinfo)
		end
		local towerId = COPY_TOWER_FIRST
		while towerId<=COPY_TOWER_LAST do
			local rateStar = copyPlayer:getRatingStar(towerId)
			if rateStar>0 then
				maxProgress = towerId
			else
				break
			end
			towerId = towerId + 1
		end
		local proto = allTowerProto[COPY_TOWER_FIRST]
		local starPrizes = proto:getCopyStarPrize()
		ret.starPrizeNum = table.size(starPrizes)
		ret.starPrizeInfo = {}
		for k,v in pairs(starPrizes) do
			local starprize = {}
			starprize.starIndex = k
			starprize.starNum = copyPlayer:getCopyStarPrize(k)
			table.insert(ret.starPrizeInfo,starprize)
		end
		local protoMax = g_copyMgr:getProto(copyPlayer:getMaxTowerLayer())
		if protoMax then
			ret.maxLayer = protoMax:getCopyLayer()
		else
			ret.maxLayer = 0
		end
		ret.curLayer = copyPlayer:getTowerCopyProgress()
		ret.resetNum = copyPlayer:getTowerCopyResetNum()
		if copyPlayer:getNowProgressCopyId().copyId~=nil and copyPlayer:getNowProgressCopyId().copyId>0 then
			ret.nowProgress = copyPlayer:getNowProgressCopyId().copyId
			ret.nowProgressLeftTime  = copyPlayer:getNowProgressCopyId().duraTime-(os.time()-copyPlayer:getNowProgressCopyId().startTime)
			if ret.nowProgressLeftTime<=0 then
				ret.nowProgressLeftTime = 0
			end
			
		end
		ret.maxCanProgressCopy = maxProgress
		fireProtoMessage(roleID, COPY_SC_GETCOPYTOWERDATA_RET, 'CopyGetTowerDataRetProtocol', ret)

		if table.size(copyPlayer:getProRewards())> 0 then
			local ret = {}
			fireProtoMessage(roleID, COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
		end
	end
end

function CopySystem:doGetGuardCopyData(buffer1)
	return
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local guardBook = GuardBook()
	guardBook:CheckCurStatus(roleID)]]
end

function CopySystem:doGuardCopyAction(buffer1)
	return
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local actionID = buffer:popShort()

	local guardBook = GuardBook()
	guardBook:StartGuard(roleID,actionID)]]
end


--排行
function CopySystem:doGetHurtRank(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		local copyTeamID = copyPlayer:getCopyTeamID()
		local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
		if copyTeam then
			local hurts = copyTeam:getHurts()
			local hurtsTmp = {}
			for rid, hurt in pairs(hurts) do
				local copyMemPlayer = g_entityMgr:getPlayer(rid)
				if copyMemPlayer then 
					table.insert(hurtsTmp, {copyMemPlayer:getName(), hurt})
				else
					print("----CopySystem:doGetHurtRank err ",rid)
				end
			end
			table.sort(hurtsTmp, function(a,b) return a[2] > b[2] end)
			local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_GETHURTRANKRET)
			buffer:pushChar(#hurtsTmp)
			for i=1, #hurtsTmp do
				buffer:pushString(hurtsTmp[i][1])
				buffer:pushInt(hurtsTmp[i][2])
			end
			g_engine:fireLuaEvent(roleID, buffer)
		end
	end]]
end

--准备与否
function CopySystem:doReady(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	--local ready = buffer:popBool()
	local req, err = protobuf.decode("CopyTeamReadyProtocol" , buffer)
	if not req then
		print('CopySystem:doReady '..tostring(err))
		return
	end
	local ready = req.ready
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and player then
		local copyTeamID = copyPlayer:getCopyTeamID()
		local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
		if copyTeam then
			if copyTeam:hasMem(roleID) then
				copyTeam:changeState(roleID, ready)
				self:getCopyTeamData(copyTeam)
			else
				self:fireMessage(COPY_CS_READY, targetID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_COPY_TEAM, 0)	
			end
		else
			self:fireMessage(COPY_CS_READY, targetID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_COPY_TEAM, 0)	
		end
	end
end

--快速加入
 function CopySystem:doAutoJoin(buffer1)
 	local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("CopyAutoJoinTeamProtocol" , buffer)
	if not req then
		print('CopySystem:doAutoJoin '..tostring(err))
		return
	end
	local copyID = req.copyId
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		local proto = g_copyMgr:getProto(copyID)
		if not proto then
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_ERR_INVALIDCOPY, 0)
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)	
			return
		end
		if copyPlayer:getCurCopyInstID() > 0 then
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_ERR_IS_IN_COPY, 0)	
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)	
			return
		elseif proto:getLevel() > player:getLevel() then
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_ERR_LEVEL_LOWER, 0)
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)		
			return
		elseif copyPlayer:getCopyTeamID() > 0 then
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_ERR_HAS_COPY_TEAM, 0)
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)		
			return
		elseif copyPlayer:getCurrentMultiCopyLevel()<proto.data.mainID then
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_MULTI_LOWER_COPYLEVEL, 0)
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)		
			return 
		end

		local allCopyTeams = g_copyMgr:getMultiCopyTeams(copyID)
		if allCopyTeams and table.size(allCopyTeams) > 0 then
			local subCopyTeams = {}
			for copyTeamID, copyTeam in pairs(allCopyTeams) do
				if copyTeam:getMemCount() < copyTeam:getMaxMemCnt() and not copyTeam:getInCopy()  then
					table.insert(subCopyTeams, copyTeam)	
				end
			end 
			local sortFun = function(a, b)
				if a:getMemCount() > b:getMemCount() then
					return true
				elseif a:getMemCount() < b:getMemCount() then
					return false
				end
				if a:getCreateTime() < b:getCreateTime() then 
					return true
				elseif a:getCreateTime() > b:getCreateTime() then 
					return false
				end
				if a:getTeamID() < b:getTeamID() then
					return true 
				else
					return false
				end
			end
			table.sort(subCopyTeams, sortFun)
			for i=1, #subCopyTeams do
				local copyTeam = subCopyTeams[i]
				local leader = g_entityMgr:getPlayerByName(copyTeam:getLeaderName())
				if leader then
					local realTeamId = leader:getTeamID()
					if player:getTeamID()==0 then
						g_TeamPublic:memJoinTeamBySID(realTeamId, sid)
					elseif player:getTeamID()~=realTeamId then
						self:fireMessage(COPY_CS_JOINCOPYTEAM, roleID, EVENT_COPY_SETS, COPY_ERR_HAS_COPY_TEAM, 0)
						return
					end
				end
				--if player:getbattle() >= copyTeam:getNeedBattle() then
				copyTeam:addCopyMem(roleID)
				copyPlayer:setCopyTeamID(copyTeam:getTeamID())
				--然后推送副本队伍数据
				self:getCopyTeamData(copyTeam)

				g_copyMgr:removeOpenMultiWin(roleID)

				

				local ret = {}
				ret.copyId = copyID
				ret.teamNum = table.size(subCopyTeams)
				ret.info = {}
				local teaminfo = {}
				for k, v in pairs(subCopyTeams) do
					teaminfo.teamId = v:getTeamID()
					teaminfo.leaderName = v:getLeaderName()
					teaminfo.createTime = v:getCreateTime()
					teaminfo.memberCnt = v:getMemCount()
					teaminfo.leaderBattle = v:getLeaderBattle()
					table.insert(ret.info,teaminfo)
				end
				local allOpens = g_copyMgr:getAllOpenMultiWin()
				for rid, _ in pairs(allOpens) do
					fireProtoMessage(rid, COPY_SC_GETALLTEAMDATA, 'CopyGetAllTeamDataProtocol', ret)
				end
				self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,true)	
				return
				--end
			end
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)	
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_MEET_COPYTEAM, 0)
		else
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_AUTOJOIN,false)	
			self:fireMessage(COPY_CS_AUTOJOIN, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_MEET_COPYTEAM, 0)	
		end
	end
 end

--开除
function CopySystem:doRemoveCopyMem(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("CopyRemoveTeamMemberProtocol" , buffer)
	if not req then
		print('CopySystem:doRemoveCopyMem '..tostring(err))
		return
	end
	local targetID = req.targetId
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and player then
		local copyTeamID = copyPlayer:getCopyTeamID()
		local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
		if copyTeam then
			if not copyTeam:hasMem(targetID) then
				self:fireMessage(COPY_CS_REMOVECOPYMEM, roleID, EVENT_COPY_SETS, COPY_ERR_TARGET_NOT_IN_TEAM, 0)
				self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_KICKMEMBER,false)	
			elseif copyTeam:getLeaderName() == player:getName() then
				copyTeam:removeCopyMem(targetID)
				local target = g_copyMgr:getCopyPlayer(targetID)
				if target then
					target:setCopyTeamID(0)
				end
				--提示被踢出者
				self:fireMessage(0, targetID, EVENT_COPY_SETS, COPY_MSG_LEAVECOPY_TEAM, 0)	
				self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_KICKMEMBER,true)
				self:MultiCopyOperResult(targetID,COPY_MULTI_OPERATOR_BEKICKED,true)
				local ret = {}
				ret.teamId = copyTeam:getTeamID()
				ret.copyId = copyTeam:getCopyID()
				ret.createTime = copyTeam:getCreateTime()
				ret.memNum = 0
				ret.info = {}
				fireProtoMessage(targetID, COPY_SC_GETTEAMDATARET, 'CopyGetTeamDataRetProtocol', ret)
				--退出成功刷所有队伍
				self:getAllCopyTeamData(targetID, copyTeam:getCopyID())

				--重刷数据给所有Opens
				local copyID = copyTeam:getCopyID()
				local ret = {}
				local allCopyTeams = g_copyMgr:getMultiCopyTeams(copyID)
				local tmp = {}
				for k, v in pairs(allCopyTeams) do
					if not v:getInCopy() then
						tmp[k] = v
					end
				end
				ret.copyId = copyID
				ret.teamNum = table.size(tmp)
				ret.info = {}
				local teaminfo = {}
				for k, v in pairs(tmp) do
					teaminfo.teamId = v:getTeamID()
					teaminfo.leaderName = v:getLeaderName()
					teaminfo.createTime = v:getCreateTime()
					teaminfo.memberCnt = v:getMemCount()
					teaminfo.leaderBattle = v:getLeaderBattle()
					table.insert(ret.info,teaminfo)
				end
				local allOpens = g_copyMgr:getAllOpenMultiWin()
				for rid, _ in pairs(allOpens) do
					fireProtoMessage(rid, COPY_SC_GETALLTEAMDATA, 'CopyGetAllTeamDataProtocol', ret)
				end
				g_copyMgr:addOpenMultiWin(targetID)

				--同步原来的所有队员刷数据
				self:getCopyTeamData(copyTeam)
				local target = g_entityMgr:getPlayer(targetID)
				g_TeamPublic:onRemoveMember(player,target:getSerialID())
			else
				self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_KICKMEMBER,false)	
				self:fireMessage(COPY_CS_REMOVECOPYMEM, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_COPY_LEADER, 0)	
			end
		else
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_KICKMEMBER,false)	
			self:fireMessage(COPY_CS_REMOVECOPYMEM, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_COPY_TEAM, 0)
		end
	end]]
end

function CopySystem:leadcopyTeam(roleID,player)
	--[[local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and player and copyPlayer:getCurrentCopyID() == 0 then
		local copyTeamID = copyPlayer:getCopyTeamID()
		local copyTeam = g_TeamPublic:getTeam(g_copyMgr:getCopyTeam(copyTeamID))
		if copyTeam then
			copyPlayer:setCopyTeamID(0)
			--copyTeam:removeCopyMem(roleID)
			local copyID = copyTeam:getCopyID()
			
			if copyTeam:getMemCount() > 0 then
				--换队长
				if copyTeam:getLeaderName() == player:getName() then
					local newLeader = g_entityMgr:getPlayerBySID(copyTeam:getAllMember()[1])
					copyTeam:setLeaderName(newLeader:getName())
					copyTeam:setMemState(newLeader:getID(), true)
					g_TeamPublic:onChangeLeader(player:getSerialID(),newLeader:getSerialID())
				end
				--同步原来的所有队员刷数据
				self:getCopyTeamData(copyTeam)
				g_TeamPublic:onLeaveTeam(player)
			else
				g_TeamPublic:onLeaveTeam(player)
				g_TeamPublic:disbandTeam(player:getTeamID())
				g_copyMgr:disBandCopyTeam(copyTeam:getTeamID())
			end

			--重刷数据给所有Opens
			local ret = {}
			local allCopyTeams = g_copyMgr:getMultiCopyTeams(copyID)
			local tmp = {}
			for k, v in pairs(allCopyTeams) do
				local team = g_TeamPublic:getTeam(v)
				if team and not team:getInCopy() then
					tmp[k] = team
				end
			end
			ret.copyId = copyID
			ret.teamNum = table.size(tmp)
			ret.info = {}
			local teaminfo = {}
			for k, v in pairs(tmp) do
				teaminfo.teamId = v:getTeamID()
				teaminfo.leaderName = v:getLeaderName()
				teaminfo.createTime = v:getCreateTime()
				teaminfo.memberCnt = v:getMemCount()
				teaminfo.leaderBattle = v:getLeaderBattle()
				table.insert(ret.info,teaminfo)
			end
			local allOpens = g_copyMgr:getAllOpenMultiWin()
			for rid, _ in pairs(allOpens) do
				fireProtoMessage(rid, COPY_SC_GETALLTEAMDATA, 'CopyGetAllTeamDataProtocol', ret)
			end
			g_copyMgr:addOpenMultiWin(roleID)
			--退出成功刷所有队伍	
			self:getAllCopyTeamData(roleID, copyID)
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_LEAVETEAM,true)
		else
			
			self:fireMessage(COPY_CS_LEAVECOPYTEAM, roleID, EVENT_COPY_SETS, COPY_ERR_NOT_IN_COPY_TEAM, 0)
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_LEAVETEAM,false)
		end
	end]]
end


--离开
function CopySystem:doLeaveCopyTeam(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	--local roleID = buffer:popInt()
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	self:leadcopyTeam(roleID,player)]]
end

function CopySystem:MultiCopyOperResult(roleId,oper,result)
	print("CopySystem:MultiCopyOperResult",roleId,oper,result)
	local ret = {}
	ret.operation = oper;
	ret.result = result
	fireProtoMessage(roleId,COPY_SC_OPER_RES_MULTICOPY,"MultiCopyOperResProtocol",ret)
end


--创建副本队伍
function CopySystem:doCreateCopyTeam(buffer1)
	
end

--加入副本队伍
function CopySystem:doJoinCopyTeam(buffer1)
	
end

function CopySystem:doGetTeamData(buffer1)
	
end

function CopySystem:doGetMultiData(buffer1)
	
end

function CopySystem:doVipResetCopyCD(buffer1)
end

--花元宝直接扫荡完成
function CopySystem:doClearProTime(buffer1)
	
end

--获取好友列表
function CopySystem:doGetFriendData(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and copyPlayer:getCurCopyInstID()<=0 then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_GETFRIENDDATA, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local relationInfo = g_relationMgr:getRoleRelationInfo(roleID)
		if relationInfo then
			local result = {}
			local allFriend = relationInfo:getAllFriend()
			for friSID, friInfo in pairs(allFriend) do
				if g_relationMgr:isFriendEachOther(roleID, friSID) then
					result[friSID] = friInfo
				end
			end
			local ret = {}
			ret.friendNum = table.size(result)
			local nowTime = os.time()
			ret.info = {}
			for friSID, friInfo in pairs(result) do

				local friendPlayer = g_entityMgr:getPlayerBySID(friSID)
				if friendPlayer then
					local friendCopyPlayer = g_copyMgr:getCopyPlayer(friendPlayer:getID())
					if friendCopyPlayer and friendCopyPlayer:getCurCopyInstID()<=0 then
						local fInfo = {}
						fInfo.friendSid = friSID
						fInfo.friendSchool = friInfo.school
						fInfo.friendName = friInfo.name
						fInfo.friendLevel = friInfo.level
						fInfo.friendBattle = friInfo.fightAbility
						fInfo.friendSex = friInfo.sex or 1
						local inviteData = copyPlayer:getInviteData(friSID)
						if inviteData then
							local difTime = nowTime - inviteData
							if difTime >= HELP_CD_TIME then
								fInfo.remainCD = 0
							else
								fInfo.remainCD = HELP_CD_TIME - difTime
							end
						else
							fInfo.remainCD = 0
						end
						fInfo.needIngot = copyPlayer:getFriInviteCnt(friSID)*CALL_PER_INGOT
						fInfo.isOnline = true
						table.insert(ret.info,fInfo)
					end
				else
					local fInfo = {}
					fInfo.friendSid = friSID
					fInfo.friendSchool = friInfo.school
					fInfo.friendName = friInfo.name
					fInfo.friendLevel = friInfo.level
					fInfo.friendBattle = friInfo.fightAbility
					fInfo.friendSex = friInfo.sex or 1
					local inviteData = copyPlayer:getInviteData(friSID)
					if inviteData then
						local difTime = nowTime - inviteData
						if difTime >= HELP_CD_TIME then
							fInfo.remainCD = 0
						else
							fInfo.remainCD = HELP_CD_TIME - difTime
						end
					else
						fInfo.remainCD = 0
					end
					fInfo.needIngot = copyPlayer:getFriInviteCnt(friSID)*CALL_PER_INGOT
					fInfo.isOnline = false
					table.insert(ret.info,fInfo)
				end
			end
			fireProtoMessage(player:getID(), COPY_SC_GETFRIENDDATARET, 'CopyGetFriendDataRetProtocol', ret)
		end
	else
		print("----CopySystem:doGetFriendData 找不到copyPlayer")
	end
end




function CopySystem:doResetGuardByNPC(roleID)
	--[[local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player)
		g_copyMgr:addCopyPlayer(roleID, copyPlayer)
	end
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_RESETGUARD, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local ecode = 0
		local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_RESETGUARDRET)
		if copyPlayer:getLastGuardLayer() == -1 then
			buffer:pushBool(false)
			g_engine:fireLuaEvent(roleID, buffer)
			ecode = COPY_ERR_NONEED_RESET
		elseif os.time() - copyPlayer:getResetGuardTime() <= ONE_DAY_SEC then
			local resetnum = copyPlayer:getResetGuardNum()
			if 1 <= resetnum then
				buffer:pushBool(false)
				g_engine:fireLuaEvent(roleID, buffer)
				ecode = COPY_ERR_RESETGUARD_USEUP
			else
				local idx = resetnum
				local proto = g_copyMgr:getProto(COPY_GUARD_STARTID_1)
				local needIngot = 0
				local oldingot = player:getIngot()
				if oldingot-needIngot >= 0 then
					player:setIngot(oldingot-needIngot)
					g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, 6, player:getIngot(), (-1) * needIngot)
					buffer:pushBool(true)
					g_engine:fireLuaEvent(roleID, buffer)
					copyPlayer:setResetGuardTime(os.time())
					copyPlayer:setLastGuardLayer(-1)
					ecode = COPY_MSG_RESETGUARD_SUCCEED
				else
					ecode = COPY_ERR_NOT_ENOUGH_INGOT
					buffer:pushBool(false)
					g_engine:fireLuaEvent(roleID, buffer)
				end
			end
		elseif os.time() - copyPlayer:getResetGuardTime() > ONE_DAY_SEC then
			getOpenWinData(roleID)
			local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_RESETGUARDRET)
			buffer:pushBool(true)
			g_engine:fireLuaEvent(roleID, buffer)
			ecode = COPY_MSG_RESETGUARD_SUCCEED
			copyPlayer:setResetGuardTime(os.time())
			copyPlayer:setLastGuardLayer(-1)
		end
		self:fireMessage(COPY_CS_RESETGUARD, roleID, EVENT_COPY_SETS, ecode, 0)
	else
		print("----CopySystem:doResetGuard 找不到copyPlayer")
	end]]
end

--重置守护副本CD
function CopySystem:doResetGuard(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_RESETGUARD, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local ecode = 0
		local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_RESETGUARDRET)
		if copyPlayer:getLastGuardLayer() == -1 then
			buffer:pushBool(false)
			g_engine:fireLuaEvent(roleID, buffer)
			ecode = COPY_ERR_NONEED_RESET
		elseif os.time() - copyPlayer:getResetGuardTime() <= ONE_DAY_SEC then
			local resetnum = copyPlayer:getResetGuardNum()
			if 1 <= resetnum then
				buffer:pushBool(false)
				g_engine:fireLuaEvent(roleID, buffer)
				ecode = COPY_ERR_RESETGUARD_USEUP
			else
				local idx = resetnum
				local proto = g_copyMgr:getProto(COPY_GUARD_STARTID_1)
				local needIngot = proto:getResetting()[idx]
				local oldingot = player:getIngot()
				if oldingot-needIngot >= 0 then
					player:setIngot(oldingot-needIngot)
					g_logManager:writeMoneyChange(player:getSerialID(), '0', 3, 6, player:getIngot(), (-1) * needIngot)
					buffer:pushBool(true)
					g_engine:fireLuaEvent(roleID, buffer)
					copyPlayer:setResetGuardTime(os.time())
					copyPlayer:setLastGuardLayer(-1)
					ecode = COPY_MSG_RESETGUARD_SUCCEED
				else
					ecode = COPY_ERR_NOT_ENOUGH_INGOT
					buffer:pushBool(false)
					g_engine:fireLuaEvent(roleID, buffer)
				end
			end
		elseif os.time() - copyPlayer:getResetGuardTime() > ONE_DAY_SEC then
			getOpenWinData(roleID)
			local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_RESETGUARDRET)
			buffer:pushBool(true)
			g_engine:fireLuaEvent(roleID, buffer)
			ecode = COPY_MSG_RESETGUARD_SUCCEED
			copyPlayer:setResetGuardTime(os.time())
			copyPlayer:setLastGuardLayer(-1)
		end
		self:fireMessage(COPY_CS_RESETGUARD, roleID, EVENT_COPY_SETS, ecode, 0)
	else
		print("----CopySystem:doResetGuard 找不到copyPlayer")
	end]]
end

--领取守护副本特殊奖励
function CopySystem:doRecSpecReward(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local copyID = buffer:popShort()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	if copyPlayer and player then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_RECSPECREWARD, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local specReward = copyPlayer:getGuardSpecReward()
		if table.include(specReward, copyID) then
			local proto = g_copyMgr:getProto(copyID)
			if not proto then return end
			local itemMgr = player:getItemMgr()
			local rewardID = proto:getSpecReward()
			local ecode = 0
			local rewardData = itemMgr:addItemByDropList(Item_BagIndex_Bag, rewardID, 19,ecode)	--普通奖励
			if rewardData ~= "-1" then
				local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_RECSPECREWARDRET)
				buffer:pushShort(proto:getCopyLayer())
				g_engine:fireLuaEvent(roleID, buffer)
				self:fireMessage(COPY_CS_RECSPECREWARD, roleID, EVENT_COPY_SETS, COPY_MSG_REC_SPEC_REWARD, 0)
				--移除
				table.removeValue(specReward, copyID)
				copyPlayer:setSyncFlag(true)
			end			
		else
			self:fireMessage(COPY_CS_RECSPECREWARD, roleID, EVENT_COPY_SETS, COPY_ERR_NO_THIS_SPECREWARD, 0)
		end
	else
		print("----CopySystem:doRecSpecReward 找不到copyPlayer")
	end]]
end

--是否领取当前扫荡的守护副本奖励
function CopySystem:doRecCurrProReward(buffer1)
	--[[local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local sign = buffer:popBool()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_RECCURRPROREWARD, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local data = copyPlayer:getCurrProReward()
		if data[2] then
			if sign then
				pushReward(roleID, {0, data[2]}, t)
				self:fireMessage(COPY_CS_RECCURRPROREWARD, roleID, EVENT_COPY_SETS, COPY_MSG_RECV_PRO_REWARD, 0)
			else
				copyPlayer:addProReward(data[1], 0, data[2])
				self:fireMessage(COPY_CS_RECCURRPROREWARD, roleID, EVENT_COPY_SETS, COPY_MSG_REFUSE_PRO_REWARD, 0)
			end
			copyPlayer:clearCurProReward()
		end
	else
		print("----CopySystem:doRecCurrProReward 找不到copyPlayer")
	end]]
end

--领取某一项扫荡的奖励
function CopySystem:doGetProReward(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("GetProRewardProtocol" , buffer)
	if not req then
		print('CopySystem:doGetProReward '..tostring(err))
		return
	end
	--local roleID = buffer:popInt()
	local getTime = req.getTime
	local copyID = req.copyID
	local copyType = req.copyType
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_GETPROREWARD, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local allReward = copyPlayer:getProRewards()
		if getTime == 0 then
			--等于0表示领取全部
			for t, rewardData in pairs(allReward) do
				--local result = rewardData[2]
				for k, v in pairs(rewardData or {}) do
					if copyType==CopyType.TowerCopy then
						if k>=COPY_TOWER_FIRST and k<=COPY_TOWER_LAST then
							pushReward(roleID, {k,v}, t)
						end
					elseif copyType==CopyType.NewSingleCopy then
						if k>=COPPY_SINGLE_FIRST and k<=COPPY_SINGLE_LAST then
							pushReward(roleID, {k,v}, t)
						end
					end
				end
			end
			--清空
			copyPlayer:clearProRewards()

			local ret = {}
			ret.getTime = 0
			fireProtoMessage(player:getID(), COPY_SC_GETPROREWARDRET, 'GetProRewardretProtocol', ret)
		else
			if allReward[getTime] and allReward[getTime][copyID] then	
				local rewardData = allReward[getTime]
				local result = rewardData[copyID]

				pushReward(roleID, {copyID, result}, getTime)
				rewardData[copyID] = nil
				if table.size(rewardData) == 0 then
					copyPlayer:delProReward(getTime)
				end
				copyPlayer:setSyncProFlag(true)
				local ret = {}
				ret.getTime = getTime
				ret.copyId = copyID
				fireProtoMessage(player:getID(), COPY_SC_GETPROREWARDRET, 'GetProRewardretProtocol', ret)
			else
				self:fireMessage(COPY_CS_GETPROREWARD, roleID, EVENT_COPY_SETS, COPY_ERR_NO_THIS_REWARD, 0)
			end
		end
	else
		print("----CopySystem:doGetProReward 找不到copyPlayer")
	end
end

--获取扫荡奖励列表
function CopySystem:doGetproRewardList(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_GETPROREWARDLIST, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		g_copyMgr:doSendProReward(copyPlayer)
	else
		print("----CopySystem:doGetproRewardList 找不到copyPlayer")
	end	
end

function CopySystem:doGetCopyData(buffer1)
	
end

--打开副本大厅界面
function CopySystem:doOpenCopyWin(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	getOpenWinData(roleID)
end

function CopySystem:doExitBook(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("ExitCopyProtocol" , buffer)
	if not req then
		print('CopySystem:doExitBook '..tostring(err))
		return
	end
	
	local str_moni_sha_mapid = player:getKV(moni_shou_sha_mapid_key)
	if str_moni_sha_mapid ~= '' then
		player:clearWhoCanSeeMe()		
		g_sceneMgr:enterPublicScene(player:getID(), player:getLastMapID(), player:getLastPosX(), player:getLastPosY())
		player:setKV(moni_shou_sha_mapid_key,'')
		return
	end
	
	str_moni_sha_mapid = player:getKV(moni_gong_sha_mapid_key)
	if str_moni_sha_mapid ~= '' then		
		player:clearWhoCanSeeMe()	
		g_sceneMgr:enterPublicScene(player:getID(), player:getLastMapID(), player:getLastPosX(), player:getLastPosY())
		player:setKV(moni_gong_sha_mapid_key,'')
		return
	end
	
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer and player and copyPlayer:getCurCopyInstID() > 0 then
		--将守护副本奖励添加到扫荡奖励列表
		--g_copyMgr:doGuardReward(copyPlayer)
		--用完要清空
		local copy = g_copyMgr:getCopyBookById(copyPlayer:getCurCopyInstID())
		if copy then
			if copy:getStatus() == CopyStatus.Active then
				local proto = g_copyMgr:getProto(copyPlayer:getCurrentCopyID())
				g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 1, 0, 1,copy:getStartTime())
				
				local copyType = proto:getCopyType()
				if copyType == CopyType.NewSingleCopy then
					g_tlogMgr:TlogTLCSFlow(player, copy:getTakeTime(), 0, proto:getCopyID())
				elseif copyType == CopyType.TowerCopy then
					g_tlogMgr:TlogTTTFlow(player, proto:getCopyLayer(), 0, copy:getTakeTime(), 0, 0)
				end
			end
			copyPlayer:clearGuardReward()
			g_copyMgr:dealExitCopy(player, copyPlayer,true)
		
			if table.size(copyPlayer:getProRewards()) ~= 0 then
				--告诉前端有奖励可领
				local ret = {}
				fireProtoMessage(player:getID(), COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
			end
		else
			print("exit can not find copy",copyPlayer:getCurrentCopyID())
		end
		
		self:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
	else
		print("-----CopySystem:doExitBook, why can't find copyPlayer")
	end
end

--一键扫荡
--pType:扫荡类型
function CopySystem:doProgressAll(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	local roleID = player:getID()
	local req, err = protobuf.decode("ProgressAllCopyProtocol" , buffer)
	if not req then
		print('CopySystem:doProgressAll '..tostring(err))
		return
	end

	local pType = req.copyType
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	
	if g_copyMgr:getTowerCopySwitch()==0 and pType == CopyType.TowerCopy then return end
	if g_copyMgr:getSingleCopySwitch()==0 and pType == CopyType.NewSingleCopy then return end
	if copyPlayer and player then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		if copyPlayer:getProgressSingleTime() > 0 then
			self:fireMessage(COPY_CS_PROGRESSALL, roleID, EVENT_COPY_SETS, COPY_ERR_IS_IN_PROGRESS, 0)
			return
		end
		g_copyMgr:doProgressAll(player, pType)
	else
		print("-----CopySystem:doProgressAll, why can't find copyPlayer")
	end
end

--扫荡单人副本[屠龙传说]
function CopySystem:doStartProgress(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local req, err = protobuf.decode("StartProgressCopyProtocol" , buffer)
	if not req then
		print('CopySystem:doStartProgress '..tostring(err))
		return
	end
	local  copyID = req.copyId
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()	
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if g_copyMgr:getSingleCopySwitch()==0 then return end
	if copyPlayer and player then
		if not copyPlayer:getDBdataload() then
			self:fireMessage(COPY_CS_STARTPROGRESS, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
			return
		end
		local ret, eCode = self:canEnterCopy(copyPlayer, player, copyID)
		if not ret and eCode then
			self:fireMessage(COPY_CS_STARTPROGRESS, roleID, EVENT_COPY_SETS, eCode, 0)
			return
		end
		local proto = g_copyMgr:getProto(copyID)
		if not proto then
			self:fireMessage(COPY_CS_STARTPROGRESS, roleID, EVENT_COPY_SETS, COPY_ERR_INVALIDCOPY, 0)
			return
		end

		--配置能不能扫荡
		--if not proto:getAutoProgress() then
		--	self:fireMessage(COPY_CS_STARTPROGRESS, roleID, EVENT_COPY_SETS, COPY_ERR_CANNOT_PROGRESS, 0)
		--	return
		--end
		--if copyPlayer:getProgressSingleTime() > 0 then
		--	self:fireMessage(COPY_CS_STARTPROGRESS, roleID, EVENT_COPY_SETS, COPY_ERR_IS_IN_PROGRESS, 0)
		--	return
		--end

		--评级判断[是否通关过]
		local fastTime = copyPlayer:getRatingTime(copyID)
		--if fastTime == 0 or fastTime > proto:getRatingTime()[1] then
		if fastTime == 0 then
			self:fireMessage(COPY_CS_STARTPROGRESS, roleID, EVENT_COPY_SETS, COPY_ERR_NEED_COMPLETED, 0)
			return
		end
		if proto:getCopyType() == CopyType.TowerCopy then
			fastTime = 0
			--copyPlayer:setTowerCnt(copyPlayer:getTowerCnt()+1,false)
				copyPlayer:setTowerCopyProgress(copyPlayer:getTowerCopyProgress()+1)
		end
		
		--g_copyMgr:addProgressCopy(player, copyID, fastTime)
		--copyPlayer:addEnterCopyCount(copyID)
		--local buffer = LuaEventManager:instance():getLuaRPCEvent(COPY_SC_STARTPROGRESSRET)
		--buffer:pushShort(copyID)
		--buffer:pushShort(fastTime)
		--g_engine:fireLuaEvent(roleID, buffer)
		
		--直接发奖励
		local data = {}
		local rewardTab = proto:getRewardID()
		local prizeTime = g_ActivityMgr:finishCopy(player:getID(), proto:getCopyID())
		for pi=1, prizeTime do
			local rewardData = dropString(player:getSchool(), player:getSex(), rewardTab[1])
			if #rewardData == 0 then
				print("doStartProgress dropString no rewardData",player:getSerialID(),copyID)
			end

			for i=1, #rewardData do
				local tmpresult = rewardData[i]
				local tmpNum = 0
				if data[tmpresult.itemID] ~= nil then 
					tmpNum = data[tmpresult.itemID].num 
				end
				data[tmpresult.itemID] = {}
				data[tmpresult.itemID].num = tmpNum + tmpresult.count
				data[tmpresult.itemID].bind = tmpresult.bind
			end
		end
		
		copyPlayer:addProReward(os.time(), copyID, data)	
		--告诉前端有奖励可领

		local ret = {}
		fireProtoMessage(player:getID(), COPY_SC_NOTIFYPROREWARD, 'NotityProRewardProtocol', ret)
		--直接发奖励
		--local rewardTab = proto:getRewardID()
		--local full, rewardData = rewardByDropID(player:getSerialID(), rewardTab[1], NEWSINGLECOPY_SD_EMAIL, 108)
		--local rewards = unserialize(rewardData)

		--计算CD
		copyPlayer:addEnterCopyCount(copyID)

		getOpenNewSingleCopy(roleID)

		--副本扫荡成功返回
		ret.copyId = copyID
		fireProtoMessage(player:getID(), COPY_SC_PROGRESSCOPY_RET, 'CopyProgressCopyRetProtocol', ret)
		g_logManager:writeCopyInfo(player:getSerialID(), proto:getCopyType(), proto:getCopyID(),proto:getName(),proto:getCopyLayer(), 2, 0, 2,os.time())
		g_tlogMgr:TlogTLCSFlow(player, 0, 1, proto:getCopyID())
		--g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.TULONG, 1)
		g_normalMgr:activeness(player:getID(),ACTIVENESS_TYPE.TULONG)
	else
		print("-----CopySystem:doStartProgress, why can't find copyPlayer")
	end
end

function CopySystem:onKillMultiCopyMon(player, copy)
	local copyTeam = g_copyMgr:getCopyTeam(copy:getPlayerID())
	print("CopySystem:onKillMultiCopyMon")
	if copyTeam then
		local allCopyMems = copyTeam:getAllMember()
		for i=1, #allCopyMems do
			local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
			local memCopyPlayer = g_copyMgr:getCopyPlayer(player:getID())
			if player and memCopyPlayer then
				memCopyPlayer:addMultiGuardCnt(copy:getCopyID())
			else
				print("------CopySystem:onKillMultiCopyMon err ", i, allCopyMems[i], copyTeam:getTeamID(), copy:getCopyID())
			end 
		end
		self:writeMultiCopyRec(copyTeam, copy, 2)
	else
		print("------CopySystem:onKillMultiCopyMon failed ",player:getSerialID(), copy:getCopyID())
	end
end

function CopySystem:writeMultiCopyRec(copyTeam, copy, result)
	local recTeam = {0,0,0,0}
	
	local proto = g_copyMgr:getProto(copy:getCopyID())
	local leaderName = copyTeam:getLeaderName()
	local leader = g_entityMgr:getPlayerByName(leaderName)
	leaderId =  leader and leader:getSerialID() or 0

	local allCopyMems = copyTeam:getAllMember()
	local start = 1
	for i=1, #allCopyMems do
		local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
		if not (player:getSerialID() == leaderId) then
			recTeam[start] = player:getSerialID()
			start = start + 1
		end
	end

	g_logManager:writeMultipleWard(copy:getCopyID(), proto:getName() or "", copyTeam:getTeamID(), leaderId, result, copy:getStartTime(), recTeam[1],result, recTeam[2],result, recTeam[3],result, recTeam[4],result)
end

function CopySystem:notifyMonsterNum(copyTeamID, monSID,copyBook)
	local copyTeam = g_copyMgr:getCopyTeam(copyTeamID)
	if copyTeam then
		local allCopyMems = copyTeam:getAllMember()
		local ret = {}
		ret.monsterSid = monSID
		ret.copyId = 0
		ret.monsters = {}


		for _,v in pairs(copyBook:getKilledMonsters()) do
			local info = {}
			info.monsterSid = v.mid
			info.monsterNum = v.num
			table.insert(ret.monsters,info)
		end
		for i=1, #allCopyMems do
			fireProtoMessageBySid(allCopyMems[i], COPY_SC_ONMONSTERKILL, 'CopyOnMonsterKillProtocol', ret)
		end
	end
end

function CopySystem:onMonsterKill(monSID, roleID, monID)
	local monster = g_entityMgr:getMonster(monID)
	if monster then
		local copyInstId = monster:getOwnCopyID()
		local copy = g_copyMgr:getCopyBookById(copyInstId)

		if monster:GetTempId() ~= 0 then
			roleID = monster:GetTempId()
		end

		--守护副本雕像被打死了
		if monSID == 9001 or monSID == 9002 then
			if copy and copy:getStatus() == CopyStatus.Active then
				--副本失败
				copy:copyFailed()
				--添加待回滚怪物的副本
				g_copyMgr:addRollBackCopy(copyInstId)
			end
		--通天塔 通天教主不能被打死	
		elseif monSID ~= 379 then
			--如果MonSID是骨卫的ID 那么如果在副本中roleID肯定是怪物ID，所以不会有问题
			local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
			local player = g_entityMgr:getPlayer(roleID)
			if copyPlayer and player then
				if player:getMapID() ~= monster:getMapID() then return end
				local currInstId = copyPlayer:getCurCopyInstID()
				local copy = g_copyMgr:getCopyBookById(currInstId)
				if copy and copy:getStatus() == CopyStatus.Active then
					copy:addKilledMonster(monSID)
					local curCopyID = copyPlayer:getCurrentCopyID()
					local proto = g_copyMgr:getProto(curCopyID)
					if proto then
						if proto:getCopyType() == CopyType.ArenaThree then
							copy:OnMonsterDead(monSID, roleID, monID)
						else
							copy:changeMonsterNum(-1)
						end 
						
						--print("Current MonsterNum",copy:getMonsterNum())
						copy:removePosMon(monID)
						--多人本同步数量
						if proto:getCopyType() == CopyType.MultiCopy then
							self:notifyMonsterNum(copyPlayer:getCopyTeamID(), monSID,copy)
						end

						--屠龙传说同步数量
						if proto:getCopyType() == CopyType.NewSingleCopy or proto:getCopyType() == CopyType.SingleGuard then
							copy:notifyMonsterNum(monSID)
						end
						--是否已经清光了所有怪物
						if copy:getMonsterNum() <= 0 then
							local curCircle = copy:getCurrCircle()
							if curCircle >= proto:getMaxCircle() then
								--副本已经打完了
								local inSingleInst = copy:onFinishCopy(copyPlayer)
								--通知任务系统
								g_taskMgr:NotifyListener(player, "onJoinCopy", proto:getCopyType())
								local newTime = copy:getPeriod()-copy:getRemainTime()
								local ratetime = copyPlayer:getRatingTime(curCopyID)
								local ratingTab = proto:getRatingTime()
								
								--副本奖励
								if proto:getCopyType() ~= CopyType.TowerCopy then
									if not inSingleInst then
										copy:doReward(newTime)
									end
								else
									copy:doGiveAllReward(roleID,curCopyID,newTime,ratetime)
								end
								if proto:getCopyType() == CopyType.MultiCopy then
									--多人本单独列出来处理
									--self:onKillMultiCopyMon(player, copy)
									return 
								end
								
								--屠龙传说弹出结束倒计时通知
								if proto:getCopyType() == CopyType.NewSingleCopy then
									self:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_EXIT_COUNT_DOWN, 1, {tostring(NEWSINGLECOPY_OUT_TIME)})
								end

								if newTime < ratetime or ratetime == 0 then
									--通关时间更新
									--新增屠龙传说剧情副本
									if proto:getAutoProgress() or proto:getCopyType() == CopyType.TowerCopy or proto:getCopyType() == CopyType.NewSingleCopy then
										copyPlayer:setRatingTime(curCopyID, newTime, ratetime)
									end
									--最快纪录计算
									if proto:getCopyType() ~= CopyType.GuardCopy and proto:getCopyType() ~= CopyType.NewSingleCopy then
										local school = copyPlayer:getRole():getSchool()
										local record = g_copyMgr:getFastestRecord(curCopyID, school)
										if record then
											if record[1] > newTime then
												--[[local school = copyPlayer:getRole():getSchool()
												local msgID = 54
												if school == 1 then msgID = 54
												elseif school == 2 then msgID = 55
												elseif school == 3 then msgID = 56
												end
												g_normalLimitMgr:sendErrMsg2Client(msgID, 2, {player:getName(), proto:getCopyLayer()})]]
												g_copyMgr:setFastestRecord(curCopyID, school, newTime, player:getSerialID(), player:getName(),player:getbattle()) 
												
											elseif record[1] == newTime then
												--爬塔第一名成就计算 +1 计算成就等于也算
												if proto:getCopyType() == CopyType.TowerCopy then
													g_achieveSer:setfastTower(player:getSerialID(), curCopyID)
													
												elseif proto:getAutoProgress() then
													--剧情本
													g_achieveSer:setfastSingle(player:getSerialID(), curCopyID)
												end
											end
										else
											--[[local school = copyPlayer:getRole():getSchool()
											local msgID = 54
											if school == 1 then msgID = 54
											elseif school == 2 then msgID = 55
											elseif school == 3 then msgID = 56
											end
											g_normalLimitMgr:sendErrMsg2Client(msgID, 2, {player:getName(), proto:getCopyLayer()})]]
											g_copyMgr:setFastestRecord(curCopyID, school, newTime, player:getSerialID(), player:getName(),player:getbattle()) 
										end
									end
								end


								
								if proto:getCopyType() ~= CopyType.GuardCopy and proto:getCopyType() ~= CopyType.ArenaThree  then
									--增加CD
									copyPlayer:addEnterCopyCount(proto:getMainID())
									if proto:getCopyType() == CopyType.TowerCopy then
										--增加爬塔公共计数
										local towerCnt = copyPlayer:getTowerCnt()
										copyPlayer:setTowerCnt(towerCnt+1)
										local maxTower = copyPlayer:getMaxTowerLayer()
										local maxProto = g_copyMgr:getProto(maxTower)
										if not maxProto or proto:getCopyLayer() > maxProto:getCopyLayer() then
											copyPlayer:setMaxTowerLayer(curCopyID)
										end
										--end
										--更新通过星数
										local star = 0
										local startimelist = proto:getRatingTime()
										if newTime<=startimelist[3] then star = 1 end
										if newTime<=startimelist[2] then star = 2 end
										if newTime<=startimelist[1] then star = 3 end
										if copyPlayer:getRatingStar(curCopyID)<star then 
											copyPlayer:setRatingStar(curCopyID,star)
											
										end
										copyPlayer:setTowerCopyProgress(copyPlayer:getTowerCopyProgress()+1)
										--end
										--活跃度
										if copyPlayer:getTowerCopyActivePrize() == 0 then
											g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.TOWER)
										end
										--copyPlayer:addTowerInnerTime(proto:getInnerCD())
									else
										if not proto:getAutoProgress() then
											copyPlayer:setSingleInnerTime(proto:getMainID(), os.time())
										end
									end
								elseif proto:getCopyType() ~= CopyType.ArenaThree then
									--修改层数
									--copyPlayer:setLastGuardLayer(proto:getNextCopy())
									local maxLayerID = copyPlayer:getMaxGuardLayer()
									local maxProto = g_copyMgr:getProto(maxLayerID)
									if maxLayerID == 0 or proto:getCopyLayer() > maxProto:getCopyLayer() then
										--更新最高层数记录
										copyPlayer:setMaxGuardLayer(curCopyID)
										--成就判断、勇闯天关
										g_achieveSer:doneCopy(player:getSerialID(), 6, proto:getCopyLayer())
									end
									copyPlayer:setLastGuardTime(os.time())
								end

								--守护需要倒计时用
								copy:setFinishTime(os.time())
							else
								copy:setMonsClearTime(os.time())
							end
						end
					end
				end
			end
		end
	end
	
end

--召唤好友
function CopySystem:callFriend(target)
	if target then
		local friMon
		local err = 0
		local school = target:getSchool()
		if school == 1 then
			--战士
			friMon = g_entityFct:createMonster(7001)
			if friMon then
				friMon:setName(target:getName())
				friMon:setMinAT(target:getMinAT())
				friMon:setMaxAT(target:getMaxAT())
				local skillMgr = friMon:getSkillMgr()
				skillMgr:learnSkill(1004, err)
				skillMgr:learnSkill(1006, err)
			end
		elseif school == 2 then
			--法师
			friMon = g_entityFct:createMonster(7002)
			if friMon then
				friMon:setName(target:getName())
				friMon:setMinMT(target:getMinMT())
				friMon:setMaxMT(target:getMaxMT())
				local skillMgr = friMon:getSkillMgr()
				skillMgr:learnSkill(2002, err)
				skillMgr:learnSkill(2004, err)
			end
		elseif school == 3 then
			--道士
			friMon = g_entityFct:createMonster(7003)
			if friMon then
				friMon:setName(target:getName())
				friMon:setMinDT(target:getMinDT())
				friMon:setMaxDT(target:getMaxDT())
				local skillMgr = friMon:getSkillMgr()
				skillMgr:learnSkill(3002, err)
				skillMgr:learnSkill(3004, err)
			end
		end
		if friMon then
			friMon:setMaxHP(target:getMaxHP())
			friMon:setHP(friMon:getMaxHP())
			friMon:setMaxMP(10000)
			friMon:setMP(10000)
			friMon:setLevel(target:getLevel())
			friMon:setMinDF(target:getMinDF())
			friMon:setMaxDF(target:getMaxDF())
			friMon:setMinMF(target:getMinMF())
			friMon:setMaxMF(target:getMaxMF())
			friMon:setHit(target:getHit())
			friMon:setDodge(target:getDodge())
			friMon:setHost(target:getID())
			friMon:setMoveSpeed(170)
			return friMon
		end
	end
end

--能否召唤好友援护
function CopySystem:canCallFriend(copyPlayer, friSID)
	local roleID = copyPlayer:getRole():getID()
	local inviteData = copyPlayer:getInviteData(friSID)
	local difTime = os.time() - inviteData
	if difTime >= HELP_CD_TIME then
		local relationInfo = g_relationMgr:getRoleRelationInfo(roleID)
		if relationInfo then
			local friend = relationInfo:getFriend(friSID)
			if friend then
				if g_relationMgr:isFriendEachOther(roleID, friSID) then
					if math.abs(friend.level - copyPlayer:getRole():getLevel()) > HELP_LEVEL_LIMIT then
						self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_CALL_FRI_LEVELLIMT, 1, {tostring(friend.level)})
						return
					end
					if friend.level < COPY_HELP_LEVEL_LIMIT then
						self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_CALL_FRI_LEVELTOLOW, 1, {tostring(friend.level)})
						return
					end
					local target = g_entityMgr:getPlayerBySID(friSID)
					if target then
						--在线
						return true, target
					else
						--好友不在线需要取离线数据
						g_entityDao:loadRelationData(roleID, friend.name, friSID)
						return true
					end
				else
					self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTHIS_FRIEND, 1, {friend.name})
					return false
				end
			else
				self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTYOUR_FRIEND, 0)
				return false
			end
		else
			self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_NOTYOUR_FRIEND, 0)
			return false
		end
	else	
		self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_CALL_FRI_INCD, 0)
		return false
	end
end

function CopySystem:setCopyTeamInfo(copyPlayer,player,proto)
	local copyID = proto:getCopyID()
	local roleID = player:getID()
	local realTeamId = player:getTeamID()
	local realTeam = g_TeamPublic:getTeam(realTeamId)
	g_copyMgr:createCopyTeam(roleID, copyID,realTeam)
	realTeam:setMaxMemCnt(#realTeam:getOnLineMems())
	realTeam:setLeaderName(player:getName())
	realTeam:setCreateTime(os.time())
	realTeam:setLeaderBattle(player:getbattle())
end

function CopySystem:enterMultiCopy(copyPlayer, player, proto)
	local copyID = proto:getCopyID()
	local roleID = player:getID()
	local realTeamId = player:getTeamID()
	local realTeam = g_TeamPublic:getTeam(realTeamId)
	if realTeam == nil then
		g_TeamPublic:onCreateTeam(player)
		realTeamId = player:getTeamID()
		realTeam = g_TeamPublic:getTeam(realTeamId)
	end
	self:setCopyTeamInfo(copyPlayer,player,proto)
	local result = true
	local eCode = 0
	local team = g_TeamPublic:getTeam(player:getTeamID())
	if not team then
		result = false
		eCode = COPY_ERR_NOT_IN_COPY_TEAM
	elseif team:getLeaderName() ~= player:getName() then
		result = false
		eCode = COPY_ERR_NOT_COPY_LEADER
	elseif team:getInCopy() then
		result = false
		eCode = COPY_ERR_TEAM_IN_COPY
	elseif player:getLevel()<proto:getLevel() then
		result = false
		eCode = COPY_ERR_LEVEL_LOWER
	end
	if not result then
		self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, eCode, 0)
		self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,false)
		return
	end
	local allCopyMems = team:getAllMember()
	for i=1, #allCopyMems do
		local member = g_entityMgr:getPlayerBySID(allCopyMems[i])
		local memCopyPlayer = g_copyMgr:getCopyPlayer(member:getID())
		result,eCode = self:_verifyMultiCopy(memCopyPlayer, member, proto)
		if not result then
			g_TeamPublic:onRemoveMember(player,allCopyMems[i])
		end
	end

	local newBook = g_copyMgr:createCopy(realTeamId, copyID)
	--创建场景
	if newBook and newBook:createBookScene(proto:getMapID()) then
		local statue = g_entityFct:createMonster(9002)
		if not statue then return end
		statue:setOwnCopyID(newBook:getCurrInsId())
		newBook:setStatueID(statue:getID())
		statue:setMaxHP(proto:getStatueHP())
		statue:setHP(proto:getStatueHP())
		newBook:getScene(proto:getMapID()):attachEntity(statue:getID(), proto:getStatuePos()[1], proto:getStatuePos()[2])
		
		local enterPos = proto:getEnterPos()
		local allCopyMems = realTeam:getAllMember()
		statue:setCampID(player:getTeamID())
		for i=1, #allCopyMems do
			local memPlayer = g_entityMgr:getPlayerBySID(allCopyMems[i])
			if memPlayer then
				local memCopyPlayer = g_copyMgr:getCopyPlayer(memPlayer:getID())
				if memCopyPlayer then
					g_entityMgr:destoryEntity(memPlayer:getPetID())
					if time.toedition("day") ~= memCopyPlayer:getMultiGuardTime(proto:getCopyID()) then
						memCopyPlayer:resetMultiGuardCnt(proto:getCopyID())
					end
					memPlayer:setCampID(player:getTeamID())
					local petid = memPlayer:getPetID()
					if petid>0 then
						g_entityMgr:destoryEntity(petid)
					end
					local mapid = memPlayer:getMapID()
					if memCopyPlayer:getCurCopyInstID() <= 0 and (mapid < 6000 or mapid > 7000) then
						if enterPos[i%4+1] and memCopyPlayer:enterCopy(newBook:getCurrInsId(), copyID, enterPos[i%4+1]) then
							memCopyPlayer:setCopyTeamID(realTeamId)
							local ret = {}
							ret.msgType = COPY_MSG_ENTERCOPY
							ret.copyId = copyID
							ret.curCircle = newBook:getCurrCircle()
							ret.remainTime = 0
							fireProtoMessage(memPlayer:getID(), COPY_SC_ENTERCOPY, 'EnterCopyRetProtocol', ret)
							local ret1 = {}
							ret1.statueHp = proto:getStatueHP()
							fireProtoMessage(memPlayer:getID(), COPY_SC_NOTIFYSTATUEHP, 'CopyNotifyStatueHpProtocol', ret1)
							
							if memPlayer then
								memPlayer:setPattern(0)
							end
							--通知任务目标
							g_taskMgr:NotifyListener(memPlayer, "onEnterCopy", CopyType.MultiCopy)
							self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,true)

						else
							self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,false)
							if memCopyPlayer:getRole() then
								print("-----enter multicopy err: ", realTeam:getTeamID(), memCopyPlayer:getRole():getSerialID(), i, toString(enterPos[i]))
							end
						end
					else
						print("enter copy error now!!")
						--self:leadcopyTeam(memPlayer:getID(),memPlayer)
					end
				else
					self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,false)
					print("----enter multicopy not player: ",i)
				end
			end
		end
		newBook:setStartTime()
		realTeam:setInCopy(true)
	else
		self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,false)
		print("---enter multicopy failed: ", player:getSerialID(), copyID)
	end
end





function CopySystem:doCtrlTowerCopyProgress(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]

	local req, err = protobuf.decode("CopyTowerProgressCtrlProtocol" , buffer)
	if not req then
		print('CopySystem:doCtrlTowerCopyProgress '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local ctrlType = req.ctrlType 
	if ctrlType==1 then
	--停止扫荡
		g_copyMgr:stopProgressTowerCopy(player)
	elseif ctrlType==2 then
	--立即完成
		g_copyMgr:doProgressAllTowerByIngot(player)
	end
end

TOWERPOSITION_X = 89
TOWERPOSITION_Y = 89
TOWERMAP = 3100

TULONGPOSITION_X = 128
TULONGPOSITION_Y = 123
TULONGMAP = 2100

MULTIPOSITION_X = 84
MULTIPOSITION_Y = 68
MULTIMAP = 3100

local function getPosByTrivialCopyID(copyID)
	if copyID == 7001 then
		return 2100, 184, 113
	elseif copyID == 7002 then
		return 2100, 184, 113
	end
end

function CopySystem:isVaildDisToNpc(player, copyType, copyID, enterType)
	if not player then return false end
	if enterType == CopyEnter.SingleInstNoCheck then
		return true
	end

	local mapId = player:getMapID()
	local pos = player:getPosition()
	local mapid = 0
	local x = 0
	local y = 0

	if enterType == CopyEnter.SingleInst then
		mapid, x, y = TULONGMAP, TULONGPOSITION_X, TULONGPOSITION_Y
	elseif copyType == CopyType.NewSingleCopy then
		mapid, x, y = TULONGMAP, TULONGPOSITION_X, TULONGPOSITION_Y
	elseif copyType == CopyType.TowerCopy then
		mapid, x, y = TOWERMAP, TOWERPOSITION_X, TOWERPOSITION_Y
	elseif copyType == CopyType.MultiCopy then
		mapid, x, y = MULTIMAP, MULTIPOSITION_X, MULTIPOSITION_Y
	elseif copyType == CopyType.TrivialCopy then
		mapid, x, y = getPosByTrivialCopyID(copyID)
	end
	local dis = math.max(math.abs(pos.x - x), math.abs(pos.y - y))
	if mapId ~= mapid or dis > REWARD_NPC_OPT_DISTANCE then
		print("distance > max distance to NPC")
		return false
	end

	return true
end

moni_shou_sha_mapid_key = '__moni_shou_sha_mapid'
moni_gong_sha_mapid_key = '__moni_gong_sha_mapid'

function CopySystem:reqDoEnterCopy(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]

	local req, err = protobuf.decode("EnterCopyProtocol" , buffer)
	if not req then
		print('CopySystem:doEnterCopy '..tostring(err))
		return
	end
	local copyID = req.copyId
	local friSID = req.friendId
	local isInCopy = req.isInCopy

	local player = g_entityMgr:getPlayerBySID(sid)
	if not player or player:getHP() <= 0 then 
		return 
	end

	self:doEnterCopyImpl(player, copyID, CopyEnter.Normal, isInCopy)
end

--进入副本
function CopySystem:doEnterCopyImpl(player, copyID, enterType, isInCopy)
	print("===doEnterCopyImpl ", player:getID(), copyID, enterType, isInCopy)
	local roleID = player:getID()
	isInCopy = isInCopy or 0

	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not copyPlayer then
		copyPlayer = CopyPlayer(player:getID())
		g_copyMgr:addCopyPlayer(roleID, copyPlayer)
	end

	if not copyPlayer:getDBdataload() then
		self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, COPY_ERR_DATAIN_LOADING, 0)
		return
	end
	
	if copyID == 6007 then
		g_entityMgr:destoryEntity(player:getPetID())
		player:addWhoCanSeeMe(player:getID())
		local str_moni_sha_mapid = player:getKV(moni_gong_sha_mapid_key)
		if isInCopy == 0 then
			player:setLastMapID(player:getMapID())
			player:setLastPosX(player:getPosition().x)
			player:setLastPosY(player:getPosition().y)
			g_sceneMgr:enterPublicScene(player:getID(), 5018, 22,23)
			player:setKV(moni_gong_sha_mapid_key, '5018')
			copyPlayer:setCurrentCopyID(6007)
		else
			if str_moni_sha_mapid == '5018' then
				g_sceneMgr:enterPublicScene(player:getID(), 5019, 22,23)
				player:setKV(moni_gong_sha_mapid_key, '5019')
			end
		end	
		return
	end
	
	if copyID == 6008 then
		g_entityMgr:destoryEntity(player:getPetID())
		local str_moni_sha_mapid = player:getKV(moni_shou_sha_mapid_key)
		player:addWhoCanSeeMe(player:getID())
		if isInCopy == 0 then
			player:setLastMapID(player:getMapID())
			player:setLastPosX(player:getPosition().x)
			player:setLastPosY(player:getPosition().y)
			g_sceneMgr:enterPublicScene(player:getID(), 2118, 22,23)
			player:setKV(moni_shou_sha_mapid_key, '2118')
			copyPlayer:setCurrentCopyID(6008)
		else
			if str_moni_sha_mapid == '2118' then
				g_sceneMgr:enterPublicScene(player:getID(), 2119, 122,94)
				player:setKV(moni_shou_sha_mapid_key, '2119')
			elseif str_moni_sha_mapid == '2119' then
				g_sceneMgr:enterPublicScene(player:getID(), 2134, 21,22)
				player:setKV(moni_shou_sha_mapid_key, '2134')
			elseif str_moni_sha_mapid == '2134' then
				g_sceneMgr:enterPublicScene(player:getID(), 2135, 119,92)
				player:setKV(moni_shou_sha_mapid_key, '2135')
			end
		end
		return
	end
	

	if not player:getScene() or player:getScene():switchLimitOut() then
		self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_FRAME_SETS, COPY_ERR_TRANS_LIMIT, 0)
		return
	end
	local ret, eCode = self:canEnterCopy(copyPlayer, player, copyID)
	if not ret then
		if eCode then
			self:fireMessage(COPY_CS_ENTERCOPY, roleID, EVENT_COPY_SETS, eCode, 0)
			return
		end
		local proto = g_copyMgr:getProto(copyID)
		if proto and proto:getCopyType()==MultiCopy then
			self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,false)
			return
		end
	end

	if copyID>=COPY_TOWER_FIRST and copyID<=COPY_TOWER_LAST then
		local isInCopy = isInCopy
		if isInCopy == 1 then self:enterNextTower(roleID) return end
	end
	
	local proto = g_copyMgr:getProto(copyID)
	if g_copyMgr:getSingleCopySwitch()==0 and proto:getCopyType() == CopyType.NewSingleCopy then return end
	if g_copyMgr:getTowerCopySwitch()==0 and proto:getCopyType() == CopyType.TowerCopy then return end

	if not self:isVaildDisToNpc(player, proto:getCopyType(), copyID, enterType) then
		return
	end
	if proto:getCopyType() == CopyType.MultiCopy then
		self:enterMultiCopy(copyPlayer, player, proto)
		return
	end

	local newBook = g_copyMgr:createCopy(roleID, copyID)
	--创建场景
	if newBook and newBook:createBookScene(proto:getMapID()) then
		if copyPlayer:enterCopy(newBook:getCurrInsId(), copyID, proto:getEnterPos()) then
			print("enterCopy sucess ", copyID)
			g_entityMgr:destoryEntity(player:getPetID())
			if proto:getCopyType() == 3 then
				local statue = g_entityFct:createMonster(9001)
				if not statue then return end
				statue:setOwnCopyID(newBook:getCurrInsId())
				statue:setMaxHP(proto:getStatueHP())
				statue:setHP(proto:getStatueHP())
				newBook:setStatueID(statue:getID())
				statue:setHost(roleID)
				newBook:getScene(proto:getMapID()):attachEntity(statue:getID(), proto:getStatuePos()[1], proto:getStatuePos()[2])
				local scene = statue:getScene()
				scene:addMonster(statue)
			end
			if proto:getCopyType() == CopyType.SingleGuard then
				local statue = g_entityFct:createMonster(9002)
				if not statue then return end
				statue:setOwnCopyID(newBook:getCurrInsId())
				newBook:setStatueID(statue:getID())
				statue:setMaxHP(proto:getStatueHP())
				statue:setHP(proto:getStatueHP())
				newBook:getScene(proto:getMapID()):attachEntity(statue:getID(), proto:getStatuePos()[1], proto:getStatuePos()[2])
				newBook:setOldPkMode(player:getPattern())
				newBook:setOldCampId(player:getCampID())				
				player:setCampID(player:getID())
				statue:setCampID(player:getID())

				local enterPos = proto:getEnterPos()
				local petid = player:getPetID()
				if petid > 0 then
					g_entityMgr:destoryEntity(petid)
				end

				local ret1 = {}
				ret1.statueHp = proto:getStatueHP()
				fireProtoMessage(player:getID(), COPY_SC_NOTIFYSTATUEHP, 'CopyNotifyStatueHpProtocol', ret1)
				player:setPattern(0)
				self:MultiCopyOperResult(roleID,COPY_MULTI_OPERATOR_ENTERCOPY,true)

				newBook:setStartTime()
			end
			if proto:getCopyType() == CopyType.ArenaThree or proto:getCopyType() == CopyType.SingleGuard then
				newBook:OnCopyInit(player)
			else
				self:flushMonster(newBook, 1)
			end	

			local ret = {}
			ret.msgType = COPY_MSG_ENTERCOPY
			ret.copyId = copyID
			ret.curCircle = newBook:getCurrCircle()
			ret.remainTime = newBook:getRemainTime()
			fireProtoMessage(player:getID(), COPY_SC_ENTERCOPY, 'EnterCopyRetProtocol', ret)
			
			--通知任务目标
			g_taskMgr:NotifyListener(player, "onEnterCopy", proto:getCopyType())
			--新增屠龙传说单人副本 进入副本时加入协助怪物
			if proto:getCopyType() == CopyType.NewSingleCopy then
				local assistMon = proto:getAssistMon()
				if assistMon and assistMon[1] > 0 then
					print("----NewSingleCopy call assistMon", assistMon[1],assistMon[2])
					local scene = player:getScene()
					local pos = player:getPosition()
					local monnum = 0
					for i=1,assistMon[1] do
						monnum = monnum + 2
						local monster = g_entityFct:createMonster(assistMon[2])
						if monster and scene then
							if scene:attachEntity(monster:getID(),pos.x+MonsterPos[monnum-1], pos.y+MonsterPos[monnum-1]) then
								monster:setHost(roleID)
								scene:addMonster(monster)
							else
								print("----NewSingleCopy call assistMon attachEntity failed", monster and monster:getSerialID())
								g_entityMgr:destoryEntity(monster:getID())
							end
						end
					end
				end
			end 
		else
			print("-----enter copy scene err",roleID, copyID)
			--通知进入副本失败
		end
	else
		print("---create copy scene failed",roleID, copyID)
	end	
end

function CopySystem:canEnterCopy(copyPlayer, player, copyID)
	if not player then return end
	local proto = g_copyMgr:getProto(copyID)
	if not proto then
		print(copyID)
		return false, COPY_ERR_INVALIDCOPY
	end
	if g_copyMgr:getSingleCopySwitch()==0 and proto:getCopyType() == CopyType.NewSingleCopy then return false, COPY_ERR_NOT_OPENTIME end
	if g_copyMgr:getTowerCopySwitch()==0 and proto:getCopyType() == CopyType.TowerCopy then return false, COPY_ERR_NOT_OPENTIME end

	if player:getType() ~= eClsTypePlayer then
		return false, COPY_ERR_INVALIDPLAYER
	end

	if proto:getCopyType() ~= CopyType.MultiCopy then
		return self:_verifyPlayerState(copyPlayer, player, proto)
	end

	--[[if proto:getCopyType() == CopyType.MultiCopy then
		return self:_verifyMultiCopy(copyPlayer, player, proto)
	else
		return self:_verifyPlayerState(copyPlayer, player, proto)
	end]]
end

function CopySystem:_verifyMultiCopy(memCopyPlayer, member, proto)	
	return self:multiBaseVerify(memCopyPlayer, member, proto)
end

function CopySystem:_verifyPlayerState(copyPlayer, player, proto)
	local playerID = player:getID()
	local copyID = proto:getCopyID()
	if not proto then return end
	if proto:getLevel() > player:getLevel() then
		return false, COPY_ERR_LEVEL_LOWER
	end
	
	--有副本队伍
	if copyPlayer:getCopyTeamID() > 0 then
		return false, COPY_ERR_IN_COPYTEAM
	end
	local copyType = proto:getCopyType()

	if copyPlayer:getCurCopyInstID() > 0 and copyType~=CopyType.TowerCopy then
		return false, COPY_ERR_IS_IN_COPY
	end
	local mainID = proto:getMainID()
	--这个副本是否正在扫荡
	if g_copyMgr:isProgressingSingle(player:getSerialID(), copyID) then
		return false, COPY_ERR_THIS_BOOK_IN_PRO
	end
	if copyType == CopyType.SingleCopy then
		local openTime = proto:getOpenTime()
		local nowTime = os.time()
		if openTime then
			local weekday = tonumber(os.date("%w",nowTime))
			local hour = tonumber(os.date("%H",nowTime))
			if openTime[weekday] then
				if hour < openTime[weekday] then
					return false, COPY_ERR_NOT_OPENTIME
				end
			else
				return false, COPY_ERR_NOT_OPENTIME
			end
		end

		local enterTime = copyPlayer:getLastEnterTime(mainID)
		if enterTime ~= 0 and nowTime - enterTime < ONE_DAY_SEC then
			if copyPlayer:getEnterCopyCount(mainID) >= proto:getCDCount() and proto:getCDCount() ~= 0 then
				return false, COPY_ERR_INCD
			end
		else
			--清空副本CD次数
			copyPlayer:clearEnterCDCount(copyID)
			return true
		end
		if not proto:getAutoProgress() then
			local innertime = copyPlayer:getSingleInnerTime(mainID)
			if innertime ~= 0 then
				if nowTime-innertime < proto:getInnerCD() then
					return false, COPY_ERR_IN_INNER_CD
				else
					copyPlayer:setSingleInnerTime(mainID)
				end
			end
		end
	elseif copyType == CopyType.TowerCopy then
		--校验最高层数
		local maxLayer = copyPlayer:getMaxTowerLayer()
		local maxProto = g_copyMgr:getProto(maxLayer)
		if maxLayer == 0 and proto:getCopyLayer() ~= 1 then
			return false, COPY_ERR_TOWER_HIGHER
		elseif maxProto and proto:getCopyLayer() > maxProto:getCopyLayer() + 1 then
			return false, COPY_ERR_TOWER_HIGHER
		elseif proto:getCopyLayer() ~= copyPlayer:getTowerCopyProgress() then
			return false, COPY_ERR_TOWER_HIGHER
		end

		if copyPlayer:getCurCopyInstID() > 0 and copyPlayer:getCurrentCopyID() == proto:getCopyID() then
			print(">>>>>>>enter tower repeated!!!!>>>>>>>>>>>")
			return false, COPY_ERR_TOWER_HIGHER
		end

		local nowTime = os.time()
		local innertime = copyPlayer:getTowerInnerTime()
		if nowTime < innertime and not copyPlayer:getCanTower() then
			return false, COPY_ERR_IN_INNER_CD
		end
		if nowTime - copyPlayer:getLastTowerTime() < ONE_DAY_SEC then
			local enterTime = copyPlayer:getLastEnterTime(mainID)
			if enterTime ~= 0 and nowTime - enterTime < ONE_DAY_SEC then
			--取消每关单独次数限制
			--[[
				if copyPlayer:getEnterCopyCount(mainID) >= proto:getCDCount() and proto:getCDCount() ~= 0 then
					return false, COPY_ERR_INCD
				end
				]]
			else
				--清空副本CD次数
				copyPlayer:clearEnterCDCount(copyID)
				return true
			end
		else
			copyPlayer:setTowerCnt(0)
			return true
		end
	elseif copyType == CopyType.GuardCopy then
		local lastGuardLayer = copyPlayer:getLastGuardLayer()
		--检验是否是正确的守护层数
		if lastGuardLayer == 0 then
			if copyPlayer:getResetGuardNum() > 0 then
				return false, COPY_ERR_SEE_U_TOMORROW_GUARD
			else
				return false, COPY_ERR_NEED_RESET_GUARD
			end
		else
			if lastGuardLayer ~= -1 and lastGuardLayer ~= copyID then
				return false, COPY_ERR_GUARD_NO_EQUAL
			end

			if copyPlayer:getIsProgressGuard() then
				return false, COPY_ERR_THIS_BOOK_IN_PRO
			end
		end
	--新增屠龙传说剧情副本
	elseif copyType == CopyType.NewSingleCopy then
		local enterTime = copyPlayer:getLastEnterTime(mainID)
		local nowTime = os.time()
		if enterTime ~= 0 and nowTime - enterTime < ONE_DAY_SEC then
			if copyPlayer:getEnterCopyCount(mainID) >= proto:getCDCount() and proto:getCDCount() ~= 0 then
				return false, COPY_ERR_INCD
			end
		else
			copyPlayer:clearEnterCDCount(copyID)
			return true
		end
	end
	return true
end

--mondata格式：{{}, {}}
local MonInfoSwitch = {[1] = 8003, [2]=8001, [3] = 8002, [4] = 8004}
local NewMonInfoSwitch = {[1] = 8001, [2]=8002, [3] = 8003, [4] = 8004}
local flushMonster1 = function(mondata, copyType, copy, scene, currCircle, campID,playerid)
	local monnum = 0
	local monposnum = #MonsterRandomPos
	for i=1, #mondata do
		local tmpdata = mondata[i]
		local position = {x=tmpdata[4], y=tmpdata[5]}
		for j=1, tmpdata[3]  do	

			--monnum = monnum + 2
			monnum = math.random(1, monposnum)
			if tmpdata[3] == 1 then
				monnum = 1
			end

			local pMonInfoID = 8004
			local hasBoss = false
			local proto = copy:getPrototype()
			--通天塔副本特殊处理
			if copyType == CopyType.NewSingleCopy then
				pMonInfoID = NewMonInfoSwitch[currCircle] or 8001
				if proto:getCopyID() == 6005 and currCircle == 4 then
					hasBoss = true
				end
			else
				pMonInfoID = MonInfoSwitch[copyType] or 8003
			end
			--local proto = copy:getPrototype()
			if copyType == CopyType.TowerCopy then
				if currCircle==1 then
					pMonInfoID = 8008
				elseif currCircle==2 then
					pMonInfoID = 8009
				else
					pMonInfoID = 8010
				end
			end
			local mon = g_entityMgr:getFactory():createMonster(tmpdata[2])
	
			if mon and scene:addCopyMonsterInfo(mon, pMonInfoID) then
				--if scene:attachEntity(mon:getID(), position.x+MonsterPos[monnum-1], position.y+MonsterPos[monnum]) then
				if scene:attachEntity(mon:getID(), position.x+MonsterRandomPos[monnum][1], position.y+MonsterRandomPos[monnum][2]) then
					scene:addMonster(mon)
					--添加副本怪物计数
					copy:changeMonsterNum(1)
					copy:addPosMon(mon:getID())	
					if copyType == 3 or copyType == 4 or copyType == CopyType.SingleGuard then
						--守护副本设置怪物属于哪个副本 并且拥有的雕像ID
						mon:setStatueID(copy:getStatueID())
						if campID then
							mon:setCampID(campID)
							mon:SetTempId(playerid)
						end
					end
					if hasBoss == true then
						copy:setBossID(mon:getID())
						print('NewSingleCopy setBossID',mon:getSerialID(),mon:getID())
					end
				end
			end
		end
	end
end

function CopySystem:flushMultiCopyMonster(copyTeam,copy, currCircle,round)
	if not copyTeam then
		return
	end
	local proto = copy:getPrototype()
	local id1 = 0
	local id2 = 0
	local id3 = 0
	local id4 = 0
	local monsterList = {}
	local teamNum = copyTeam:getOnLineCnt()
	local lastIds = copy:getLastFlushRoad()
	if lastIds[1]==0 or (lastIds[1]>0 and round==1) then
		if teamNum <= 3 then
			id1 = math.random(1,4)
			copy:setLastFlushRoad(id1,0,0,0)
			monsterList = proto:getMonstersById(id1)
		elseif teamNum > 3 and teamNum <= 5 then
			id1 = math.random(1,4)
			monsterList = proto:getMonstersById(id1)
			id2 = math.random(1,4)
			if id2==id1 then
				id2 = (id1 + 1) % 4
				if id2==0 then
					id2 = 1
				end
			end 
			copy:setLastFlushRoad(id1,id2,0,0)
			monsterList = table.join(proto:getMonstersById(id1),proto:getMonstersById(id2))
		elseif teamNum > 5 and teamNum <= 7 then
			idx = math.random(1,4)
			if idx == 1 then
				copy:setLastFlushRoad(2,3,4,0)
				id1 = 2
				id2 = 3
				id3 = 4
			elseif idx == 2 then
				copy:setLastFlushRoad(1,3,4,0)
				id1 = 1
				id2 = 3
				id3 = 4
			elseif idx == 3 then
				copy:setLastFlushRoad(1,2,4,0)
				id1 = 1
				id2 = 2
				id3 = 4
			elseif idx == 4 then
				copy:setLastFlushRoad(1,2,3,0)
				id1 = 1
				id2 = 2
				id3 = 3
			end
			for i=1,4 do
				if i ~= idx then
					monsterList = table.join(monsterList,proto:getMonstersById(i))
				end
			end
		elseif teamNum > 7 and teamNum <= 10 then
			copy:setLastFlushRoad(1,2,3,4)
			for i=1,4 do
				monsterList = table.join(monsterList,proto:getMonstersById(i))
			end
			id1 = 1
			id2 = 2
			id3 = 3
			id4 = 4
		end
	else
		id1 = lastIds[1]
		id2 = lastIds[2]
		id3 = lastIds[3]
		id4 = lastIds[4]
		for i=1,4 do
			if lastIds[i]>0 then
				monsterList = table.join(monsterList,proto:getMonstersById(lastIds[i]))
			end
		end
	end
	copy:setCurrentCircle(currCircle)
	copy:setRoad1(id1)
	copy:setRoad2(id2)
	copy:setRoad3(id3)
	copy:setRoad4(id4)

	if round==1 then
		local ret = {}
		ret.currCircle = currCircle
		ret.flushRoad1 = id1
		ret.flushRoad2 = id2
		ret.flushRoad3 = id3
		ret.flushRoad4 = id4
		if copyTeam then
			print("get copyteam")
			local allCopyMems = copyTeam:getAllMember()
			for i=1, #allCopyMems do
				print("notify flush roads",allCopyMems[i])
				local player = g_entityMgr:getPlayerBySID(allCopyMems[i])
				local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
				ret.currentPrizeStage = copyPlayer:getMultiGuardCnt(proto:getCopyID())
				fireProtoMessageBySid(allCopyMems[i], COPY_SC_MULTICOPY_FLUSH_ROAD, 'MultiCopyFlushRoadProtocol', ret)

			end
		end
	end

	if proto then
		local monsters = {}
		for _, mondata in ipairs(monsterList or {}) do
			if mondata[1] == currCircle  and mondata[6] == round then --过滤波数
				table.insert(monsters, mondata)
			end
		end
		--开始刷怪
		local mapID = proto:getMapID()
		local scene = copy:getScene(mapID)
		if scene then
			flushMonster1(monsters, proto:getCopyType(), copy, scene, currCircle)
		end
	end
end


function CopySystem:flushMonster(copy, currCircle)
	local proto = copy:getPrototype()
	if proto then
		local monsters = {}
		for _, mondata in ipairs(proto:getMonsters() or {}) do
			if mondata[1] == currCircle then --过滤波数
				table.insert(monsters, mondata)
			end
		end
		print("flushMonster ", proto:getMapID())
		--开始刷怪
		local mapID = proto:getMapID()
		local scene = copy:getScene(mapID)
		if scene then
			flushMonster1(monsters, proto:getCopyType(), copy, scene, currCircle)
		end
	end
end

function CopySystem:flushSingleGuardCopyMonster(player, copy, currCircle, round, campID)
	print("$$$$flushSingleGuardCopyMonster", player:getID(), currCircle, round)
	local proto = copy:getPrototype()
	local id1 = 0
	local id2 = 0
	local id3 = 0
	local id4 = 0
	local monsterList = {}
	local lastIds = copy:getLastFlushRoad()
	if lastIds[1]==0 or (lastIds[1]>0 and round==1) then
		id1 = math.random(1,4)
		copy:setLastFlushRoad(id1,0,0,0)
		monsterList = proto:getMonstersById(id1)
	else
		id1 = lastIds[1]
		id2 = lastIds[2]
		id3 = lastIds[3]
		id4 = lastIds[4]
		for i=1,4 do
			if lastIds[i]>0 then
				monsterList = table.join(monsterList,proto:getMonstersById(lastIds[i]))
			end
		end
	end

	copy:setCurrentCircle(currCircle)
	copy:setRoad1(id1)
	copy:setRoad2(id2)
	copy:setRoad3(id3)
	copy:setRoad4(id4)

	if round == 1 then
		local ret = {}
		ret.currCircle = currCircle
		ret.flushRoad1 = id1
		ret.flushRoad2 = id2
		ret.flushRoad3 = id3
		ret.flushRoad4 = id4
		fireProtoMessage(player:getID(), COPY_SC_MULTICOPY_FLUSH_ROAD, 'MultiCopyFlushRoadProtocol', ret)
	end

	if proto then
		local monsters = {}
		for _, mondata in ipairs(monsterList or {}) do
			if mondata[1] == currCircle  and mondata[6] == round then --过滤波数
				table.insert(monsters, mondata)
			end
		end
		--开始刷怪
		local mapID = proto:getMapID()
		local scene = copy:getScene(mapID)
		if scene then
			flushMonster1(monsters, proto:getCopyType(), copy, scene, currCircle, campID,player:getID())
		end
	end
end

function CopySystem:reqRandomDailySingleInst(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then 
		return 
	end
	
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		copyPlayer:randomDailySingleInst()
	end
end

function CopySystem:reqFinishSingleInst(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then 
		return 
	end

	local req, err = protobuf.decode("FinishSingleInstProtocol" , buffer)
	if not req then
		print('CopySystem.reqFinishSingleInst '..tostring(err))
		return
	end
	print("reqFinishSingleInst:", req.instID)
	local roleID = player:getID()
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if copyPlayer then
		copyPlayer:reqFinishSingleInst(req.instID)
	end
end
function CopySystem:doEnterSingleInst(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then 
		return 
	end
	
	local req, err = protobuf.decode("EnterSingleInstProtocol" , buffer)
	if not req then
		print('CopySystem.doEnterSingleInst '..tostring(err))
		return
	end

	local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
	if not copyPlayer then
		return
	end

	if player:getTeamID() > 0 then
		copyPlayer:sendErrToClient(COPY_ERR_SINGLEINST_IS_IN_TEAM)
		return
	end

	local ret, proto, params = copyPlayer:canEnterSingleInst(player, req.instID, true)
	if not ret then
		print(player:getSerialID(), " cannot enter SingleInst ",req.instID, "error:", proto)
		copyPlayer:sendErrToClient(proto, params)
		return
	end

	print(player:getSerialID(), "start doEnterSingleInst ", req.instID)
	if proto:getData().simulate ~= 1 and isUnusualSingleInst(proto:getData().class) then
		return self:doEnterUnusualCopyImpl(player, proto)
	end
	self:doEnterCopyImpl(player, proto:getData().copyID, CopyEnter.SingleInst)
end
function CopySystem:doEnterSingleInstTest(tbl)
	local sid = tbl[1]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then 
		return 
	end

	local copyPlayer = g_copyMgr:getCopyPlayer(player:getID())
	if not copyPlayer then
		return
	end

	print(player:getSerialID(), "start doEnterSingleInstTest")

	local ret, proto = copyPlayer:canEnterSingleInst(player, tbl[2], true)
	if not ret then
		print("cannot enter single inst:"..tbl[2])
		copyPlayer:sendErrToClient(proto)
		return
	end

	if proto:getData().simulate ~= 1 and isUnusualSingleInst(proto:getData().class) then
		return self:doEnterUnusualCopyImpl(player, proto)
	end
	
	self:doEnterCopyImpl(player, proto:getData().copyID, CopyEnter.SingleInst)
end

--特殊类型不走副本流程，调用该副本提供的进入接口
function CopySystem:doEnterUnusualCopyImpl(player, proto)
	print(player:getSerialID(), " doEnterUnusualCopyImpl:", proto:getData().copyID)
	if proto:getData().class == SINGLE_INST_MINE_CLASS then
		g_digMineSimulation:enterCopy(player:getID(), proto:getData().id)
	elseif proto:getData().class == SINGLE_INST_ESCORT_CLASS then
		g_VirtualEscorMgr:enter(player:getSerialID(), proto:getData().id)
	else
		print("unknown type:", proto:getData().class)
	end
end

--Directly enter without check,only open to other modules.
function CopySystem:enterSingleInstByCopyID(roleID, copyID)
	local player = g_entityMgr:getPlayer(roleID)
	local copyPlayer = g_copyMgr:getCopyPlayer(roleID)
	if not player or not copyPlayer then
		print("can not find player or copyplayer", roleID)
		return
	end

	print("start enterSingleInstByCopyID:", copyID, "player:", player:getSerialID())

	local instID = g_copyMgr:getSingleInstIDByCopyID(copyID)
	local ret, proto, params = copyPlayer:canEnterSingleInst(player, instID, false)
	if not ret then
		print("cannot enter single inst:"..instID)
		copyPlayer:sendErrToClient(proto, params)
		return
	end

	if proto:getData().simulate ~= 1 and isUnusualSingleInst(proto:getData().class) then
		return self:doEnterUnusualCopyImpl(player, proto)
	end
	return self:doEnterCopyImpl(player, copyID, CopyEnter.SingleInstNoCheck)
end

function CopySystem:doCancelEnterCopy(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then 
		return 
	end
	local realTeamId = player:getTeamID()
	local realTeam = g_TeamPublic:getTeam(realTeamId)
	if realTeam then
		realTeam:setNeedBattle(0)
	end
end

function CopySystem.getInstance()
	return CopySystem()
end

g_eventMgr:addEventListener(CopySystem.getInstance())
g_copySystem = CopySystem.getInstance()