--MasterServlet.lua
--/*-----------------------------------------------------------------
--* Module:  MasterServlet.lua
--* Author:  Andy
--* Modified: 2016年02月16日
--* Purpose: Implementation of the class MasterServlet
-------------------------------------------------------------------*/

MasterServlet = class(EventSetDoer, Singleton)

function MasterServlet:__init()
	self._doer = {
		[APPRENTICE_CS_REQ]				= MasterServlet.apprenticeReq,
		[MASTER_CS_REFUSE_REQ]			= MasterServlet.masterRefuseReq,
		[MASTER_CS_AGREE_REQ]			= MasterServlet.masterAgreeReq,
		[MASTER_CS_REQ]					= MasterServlet.masterReq,
		[APPRENTICE_CS_REFUSE_REQ]		= MasterServlet.apprenticeRefuseReq,
		[APPRENTICE_CS_AGREE_REQ]		= MasterServlet.apprenticeAgreeReq,
		[APPRENTICE_CS_RECOMMEND_LIST]	= MasterServlet.apprenticeRecommendList,
		[APPRENTICE_CS_APPLY]			= MasterServlet.apprenticeApply,
		[MASTER_CS_INFORMATION]			= MasterServlet.masterInformation,
		[APPRENTICE_CS_REWARD]			= MasterServlet.apprenticeReward,
		[APPRENTICE_CS_BETRAY]			= MasterServlet.apprenticeBetray0,
		[APPRENTICE_CS_FINISH]			= MasterServlet.apprenticeFinish,
		[MASTER_CS_APPLY_LIST]			= MasterServlet.masterApplyList,
		[MASTER_CS_INITIATIVE_APPLY]	= MasterServlet.masterInitiative,
		[MASTER_CS_DELETE_APPLY]		= MasterServlet.masterDeleteApply0,
		[MASTER_CS_GET_POSITION]		= MasterServlet.masterGetPosition,
		[MASTER_CS_FINISH]				= MasterServlet.masterFinish,
		[MASTER_CS_EXPEL]				= MasterServlet.masterExpel0,
		[MASTER_CS_SET_WORD]			= MasterServlet.masterSetWord,
		[MASTER_CS_GET_EXPERIENCE]		= MasterServlet.masterGetExperience,
		[APPRENTICE_CS_INFORMATION]		= MasterServlet.apprenticeInformation,
		[MASTER_CS_PROFESSION]			= MasterServlet.masterProfession,
		[MASTER_CS_OFFLINE_PUNISH]		= MasterServlet.masterOfflinePunish,
		[APPRENTICE_CS_OFFLINE_PUNISH]	= MasterServlet.apprenticeOfflinePunish,
		[APPRENTICE_CS_SEARCH]			= MasterServlet.apprenticeSearch,
		[MASTER_CS_GET_WORD]			= MasterServlet.masterGetWord,
		[MASTER_CS_ISSUE_TASK]			= MasterServlet.masterIssueTask,
		[MASTER_CS_ISSUE_TASK2]			= MasterServlet.masterIssueTask2,
	}
end

--拜师请求
function MasterServlet:apprenticeReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ApprenticeReq")
	if not req then return end
	local name = req.name
	local masterSID = g_masterMgr:getPlayerSIDByName(name)
	local master = g_entityMgr:getPlayerBySID(masterSID)
	if self:checkApprenticeReq(dbid, masterSID, true) and master then
		local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
		local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
		playerInfo:addMasterRep(masterSID)
		masterInfo:addApprenticeRep(dbid)
		local ret = {}
		ret.name = g_masterMgr:getPlayerNameBySID(dbid)
		ret.roleSID = dbid
		fireProtoMessage(master:getID(), MASTER_SC_REQ_RET, "MasterRet", ret)
	end
end

function MasterServlet:checkApprenticeReq(roleSID, masterSID, checkCooling)
	local flag = 0		--是否满足条件
	--判断徒弟自身条件
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		local cdTime = playerInfo:getApprenticeCD() 
		if cdTime ~= 0 and os.time() - cdTime <= APPRENTICE_PUNISH_CD then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_PUNISH_CD3, 0, {})
		elseif checkCooling and os.time() - playerInfo:getRefuseTime(masterSID) < MASTER_COOLING_TIME then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_COOLING_TIME, 0, {})
		elseif playerInfo:getMasterSID() == masterSID then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_IS_YOUR_MASTER, 0, {})
		elseif #playerInfo:getMasterSID() > 0 then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_APPRENTICE_OTHER, 0, {})
		elseif APPRENTICE_MIN_LEVEL > playerInfo:getLevel() or playerInfo:getLevel() > APPRENTICE_MAX_LEVEL then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_ERROR_LEVEL, 0, {})
		else
			flag = flag + 1
		end
	end
	if flag == 1 then
		--判断对方师傅条件
		local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
		if masterInfo then
			local cdTime = masterInfo:getMasterCD()
			if cdTime ~= 0 and os.time() - cdTime <= MASTER_PUNISH_CD then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_PUNISH_CD2, 0, {})
			elseif masterInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_APPRENTICE_MAX2, 0, {})
			elseif masterInfo:getLevel() < MASTER_MIN_LEVEL then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_LESS_LEVEL2, 0, {})
			elseif checkCooling and not masterInfo:getInitiative() then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_NO_INITIALTIVE, 0, {})
			else
				flag = flag + 1
			end
		end
	end
	if flag == 2 then
		return true
	end
	return false
end

--师傅拒绝拜师请求
function MasterServlet:masterRefuseReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterRefuse")
	if not req then return end
	g_masterMgr:sendErrMsg2Client(req.roleSID, MASTER_ERR_APPRENTICE_FAIL, 0, {})
	local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(req.roleSID)
	if apprenticeInfo then
		apprenticeInfo:addRefuseList(dbid)
	end
end

--师傅同意拜师请求
function MasterServlet:masterAgreeReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterAgree")
	if not req then return end
	local apprenticeSID = req.roleSID
	local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(apprenticeSID)
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo and apprenticeInfo and playerInfo:isApprenticeReqUser(apprenticeSID) and apprenticeInfo:isMasterReqUser(dbid) then
		if playerInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_APPRENTICE_MAX2, 0, {})
			return
		end
		if not self:checkMasterReq(dbid, apprenticeSID) then
			return
		end
		if #apprenticeInfo:getMasterSID() == 0 then
			playerInfo:setTotalApprentice(playerInfo:getTotalApprentice() + 1)
			playerInfo:addApprentice(apprenticeSID)
			apprenticeInfo:setMasterSID(dbid)
			apprenticeInfo:setFinalMaster(dbid)
			apprenticeInfo:setFinalName(playerInfo:getName())
			apprenticeInfo:setNowProfession(MASTER_PROFESSION.APPRENTICE)
			g_masterMgr:addOffLineRelated(apprenticeSID, dbid)
			g_masterMgr:addOffLineRelated(dbid, apprenticeSID)
			g_masterMgr:pushExperience(dbid, 4, os.time(), apprenticeInfo:getName())
			g_masterMgr:pushExperience(apprenticeSID, 1, os.time(), playerInfo:getName())
			g_masterMgr:setDoubleXP(apprenticeSID, dbid)
			--删除申请的其他师傅的申请信息
			local applyMasters = apprenticeInfo:getApplyMasterList()
			for applyMasterSID, _ in pairs(applyMasters) do
				apprenticeInfo:deleteApplyMaster(applyMasterSID)
				local applyMaster = g_masterMgr:getPlayerInfoBySID2(applyMasterSID)
				if applyMaster then
					applyMaster:deleteApplyApprentice(apprenticeSID)
					applyMaster:cast2DB()
				else
					local offLineInfo = g_masterMgr:getOffLineInfo(applyMasterSID)
					if offLineInfo then
						offLineInfo:addRemoveApplyApprentice(apprenticeSID)
						offLineInfo:castOffLine2DB()
					end
				end
			end
			apprenticeInfo:cast2DB()
			--徒弟满后删除其他的申请人
			if playerInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
				for sid, _ in pairs(playerInfo:getApplyApprenticeList() or {}) do
					self:masterDeleteApply(dbid, sid)
				end
			end

			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_MASTER_SUCCESS, 0, {})
			g_masterMgr:sendErrMsg2Client(apprenticeSID, MASTER_ERR_APPRENTICE_SUCCESS, 0, {})
			fireProtoMessageBySid(dbid, MASTER_SC_REQ_SUCCESS, "MasterReqSuccess", {})
			fireProtoMessageBySid(apprenticeSID, MASTER_SC_REQ_SUCCESS, "MasterReqSuccess", {})
		elseif apprenticeInfo:getMasterSID() == dbid then
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_HAS_RELEATION, 0, {})
			g_masterMgr:sendErrMsg2Client(apprenticeSID, MASTER_ERR_HAS_RELEATION, 0, {})
		end
	end
end

--收徒请求
function MasterServlet:masterReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterReq")
	if not req then return end
	local apprenticeSID = g_masterMgr:getPlayerSIDByName(req.name)
	local apprentice = g_entityMgr:getPlayerBySID(apprenticeSID)
	if self:checkMasterReq(dbid, apprenticeSID, true) and apprentice then
		local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
		local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(apprenticeSID)
		playerInfo:addApprenticeRep(apprenticeSID)
		apprenticeInfo:addMasterRep(dbid)
		local ret = {}
		ret.name = g_masterMgr:getPlayerNameBySID(dbid)
		ret.roleSID = dbid
		fireProtoMessage(apprentice:getID(), APPRENTICE_SC_REQ_RET, "ApprenticeRet", ret)
	end
end

function MasterServlet:checkMasterReq(roleSID, apprenticeSID, checkCooling)
	local flag = 0		--是否满足条件
	--判断师傅自身条件
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		local cdTime = playerInfo:getMasterCD()
		if cdTime ~= 0 and os.time() - cdTime <= MASTER_PUNISH_CD then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_PUNISH_CD, 0, {})
		elseif checkCooling and os.time() - playerInfo:getRefuseTime2(apprenticeSID) < MASTER_COOLING_TIME then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_COOLING_TIME2, 0, {})
		elseif playerInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_APPRENTICE_MAX, 0, {})
		elseif playerInfo:getLevel() < MASTER_MIN_LEVEL then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_LESS_LEVEL, 0, {})
		else
			flag = flag + 1
		end
	end
	if flag == 1 then
		--判断对方徒弟条件
		local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(apprenticeSID)
		if apprenticeInfo then
			local cdTime = apprenticeInfo:getApprenticeCD() 
			if cdTime ~= 0 and os.time() - cdTime <= APPRENTICE_PUNISH_CD then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_PUNISH_CD4, 0, {})
			elseif apprenticeInfo:getMasterSID() == roleSID then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_IS_YOUR_APPRENTICE, 0, {})
			elseif #apprenticeInfo:getMasterSID() > 0 then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_APPRENTICE_OTHER2, 0, {})
			elseif APPRENTICE_MIN_LEVEL > apprenticeInfo:getLevel() or apprenticeInfo:getLevel() > APPRENTICE_MAX_LEVEL then
				g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_ERROR_LEVEL2, 0, {})
			else
				flag = flag + 1
			end
		end
	end
	if flag == 2 then
		return true
	end
	return false
end

--徒弟拒绝收徒请求
function MasterServlet:apprenticeRefuseReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ApprenticeRefuse")
	if not req then return end
	g_masterMgr:sendErrMsg2Client(req.roleSID, MASTER_ERR_MASTER_FAIL, 0, {})
	local masterInfo = g_masterMgr:getPlayerInfoBySID2(req.roleSID)
	if masterInfo then
		masterInfo:addRefuseList2(dbid)
	end
end

--徒弟同意收徒请求
function MasterServlet:apprenticeAgreeReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ApprenticeAgree")
	if not req then return end
	local masterSID = req.roleSID
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
	if playerInfo and masterInfo and playerInfo:isMasterReqUser(masterSID) and masterInfo:isApprenticeReqUser(dbid) then
		if masterInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_APPRENTICE_MAX, 0, {})
			return
		end
		if not self:checkApprenticeReq(dbid, masterSID) then
			return
		end
		if #playerInfo:getMasterSID() == 0 then
			masterInfo:setTotalApprentice(masterInfo:getTotalApprentice() + 1)
			masterInfo:addApprentice(dbid)
			playerInfo:setMasterSID(masterSID)
			playerInfo:setFinalMaster(masterSID)
			playerInfo:setFinalName(masterInfo:getName())
			playerInfo:setNowProfession(MASTER_PROFESSION.APPRENTICE)
			g_masterMgr:addOffLineRelated(masterSID, dbid)
			g_masterMgr:addOffLineRelated(dbid, masterSID)
			g_masterMgr:pushExperience(dbid, 1, os.time(), masterInfo:getName())
			g_masterMgr:pushExperience(masterSID, 4, os.time(), playerInfo:getName())
			g_masterMgr:setDoubleXP(dbid, masterSID)
			--删除申请的其他师傅的申请信息
			local applyMasters = playerInfo:getApplyMasterList()
			for applyMasterSID, _ in pairs(applyMasters) do
				playerInfo:deleteApplyMaster(applyMasterSID)
				local applyMaster = g_masterMgr:getPlayerInfoBySID2(applyMasterSID)
				if applyMaster then
					applyMaster:deleteApplyApprentice(dbid)
					applyMaster:cast2DB()
				else
					local offLineInfo = g_masterMgr:getOffLineInfo(applyMasterSID)
					if offLineInfo then
						offLineInfo:addRemoveApplyApprentice(dbid)
						offLineInfo:castOffLine2DB()
					end
				end
			end
			playerInfo:cast2DB()
			--徒弟满后删除其他的申请人
			if masterInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT then
				for sid, _ in pairs(masterInfo:getApplyApprenticeList() or {}) do
					self:masterDeleteApply(masterSID, sid)
				end
			end

			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_APPRENTICE_SUCCESS, 0, {})
			g_masterMgr:sendErrMsg2Client(masterSID, MASTER_ERR_MASTER_SUCCESS, 0, {})
			fireProtoMessageBySid(dbid, MASTER_SC_REQ_SUCCESS, "MasterReqSuccess", {})
			fireProtoMessageBySid(masterSID, MASTER_SC_REQ_SUCCESS, "MasterReqSuccess", {})
		elseif playerInfo:getMasterSID() == masterSID then
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_HAS_RELEATION, 0, {})
			g_masterMgr:sendErrMsg2Client(masterSID, MASTER_ERR_HAS_RELEATION, 0, {})
		end
	end
end

--请求推荐师傅列表
function MasterServlet:apprenticeRecommendList(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "ApprenticeRecommend")
	self:pushRecommendList(dbid)
end

function MasterServlet:pushRecommendList(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local cd, lists = 0, {}
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		local apprenticeCD = playerInfo:getApprenticeCD()
		if apprenticeCD ~= 0 and os.time() - apprenticeCD < APPRENTICE_PUNISH_CD then
			cd = APPRENTICE_PUNISH_CD - (os.time() - apprenticeCD)
		end
		local applyList = playerInfo:getApplyMasterList()
		local randomMaster = g_masterMgr:randomMaster(applyList)
		for _, master in pairs(applyList) do
			local list = {}
			list.roleSID = master.roleSID
			list.name = master.name
			list.level = master.level
			list.school = master.school
			list.isOnline = g_masterMgr:isOnline(master.roleSID)
			list.flag = 2
			table.insert(lists, list)
		end
		for _, master in pairs(randomMaster) do
			local list = {}
			list.roleSID = master.roleSID
			list.name = master.name
			list.level = master.level
			list.school = master.school
			list.isOnline = g_masterMgr:isOnline(master.roleSID)
			list.flag = 1
			table.insert(lists, list)
		end
	end
	local ret = {}
	ret.cd = cd
	ret.list = lists
	fireProtoMessage(player:getID(), APPRENTICE_SC_RECOMMEND_LIST_RET, "ApprenticeRecommendRet", ret)
end

--申请拜师
function MasterServlet:apprenticeApply(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ApprenticeApply")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req then
		warning("require param nil.")
		return
	end
	if not player then
		warning("player nil. dbid:" .. dbid)
		return
	end
	local operator, masterSID, name, school, level = req.flag, req.roleSID, req.name, req.school, req.level
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo then
		if operator == 1 then
			if table.size(playerInfo:getApplyMasterList()) >= APPRENTICE_APPLY_MAX_COUNT then
				g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_APPLY_MAX_COUNT, 0, {})
				local ret = {}
				ret.roleSID = masterSID
				ret.flag = operator
				fireProtoMessage(player:getID(), APPRENTICE_SC_APPLY_RET, "ApprenticeApplyRet", ret)
				return
			end
			local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
			if masterInfo then
				if masterInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT or masterInfo:getApprenticeApplyCount() > MASTER_APPLY_MAX_COUNT then
					local ret = {}
					ret.roleSID = masterSID
					ret.flag = operator
					fireProtoMessage(player:getID(), APPRENTICE_SC_APPLY_RET, "ApprenticeApplyRet", ret)
					return
				end
				masterInfo:addApplyApprentice(dbid)
				masterInfo:cast2DB()
				g_masterMgr:addOffLineRelated(dbid, masterSID)
				g_masterMgr:addOffLineRelated(masterSID, dbid)
			else
				local offLineInfo = g_masterMgr:getOffLineInfo(masterSID)
				if offLineInfo and table.size(offLineInfo:getApplyApprenticeList()) < APPRENTICE_MAX_COUNT then
					offLineInfo:addApplyApprentice(dbid)
				end
			end
			playerInfo:addApplyMaster(masterSID, name, school, level)
			playerInfo:cast2DB()
			operator = 2
			g_masterMgr:sendErrMsg2Client(masterSID, MASTER_ERR_APPRENTICE_APPLY, 1, {playerInfo:getName()})
		elseif operator == 2 then
			self:apprenticeDeleteApply(dbid, masterSID)
			operator = 1
			g_masterMgr:sendErrMsg2Client(masterSID, MASTER_ERR_CANCEL_APPLY, 1, {playerInfo:getName()})
		end
	end
	local ret = {}
	ret.roleSID = masterSID
	ret.flag = operator
	fireProtoMessage(player:getID(), APPRENTICE_SC_APPLY_RET, "ApprenticeApplyRet", ret)
end

--徒弟删除拜师申请
function MasterServlet:apprenticeDeleteApply(roleSID, masterSID)
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		playerInfo:deleteApplyMaster(masterSID)
		playerInfo:cast2DB()
	end
	local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
	if masterInfo then
		masterInfo:deleteApplyApprentice(roleSID)
		masterInfo:cast2DB()
	else
		local offLineInfo = g_masterMgr:getOffLineInfo(masterSID)
		if offLineInfo then
			offLineInfo:addRemoveApplyApprentice(roleSID)
		end
	end
end

--请求师徒界面中师傅的数据
function MasterServlet:masterInformation(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "MasterInformation")
	self:pushMasterInformation(dbid)
end

function MasterServlet:pushMasterInformation(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	local initiative, lists = true, {}
	if playerInfo then
		local now = os.time()
		initiative = playerInfo:getInitiative()
		local apprentices = playerInfo:getApprentice()
		for _, apprenticeSID in pairs(apprentices) do
			local offLineInfo = g_masterMgr:getOffLineInfo(apprenticeSID)
			if offLineInfo then
				local isOnline = 0
				if offLineInfo:getLevel() >= MASTER_MIN_LEVEL then
					isOnline = -1
				elseif not g_masterMgr:isOnline(apprenticeSID) then
					isOnline = now - offLineInfo:getOffLine()
				end
				local list = {}
				list.roleSID = apprenticeSID
				list.name = offLineInfo:getName()
				list.battle = offLineInfo:getBattle()
				list.level = offLineInfo:getLevel()
				list.school = offLineInfo:getSchool()
				list.finishTask = offLineInfo:getTaskFinish()
				list.isOnline = isOnline
				table.insert(lists, list)
			end
		end
	end
	local hasTask = true
	local offLineInfo = g_masterMgr:getOffLineInfo(roleSID)
	if offLineInfo then
		hasTask = not offLineInfo:getTaskIssue()
	end
	local ret = {}
	ret.initiative = initiative
	ret.list = lists
	ret.hasTask = hasTask
	fireProtoMessage(player:getID(), MASTER_SC_INFORMATION_RET, "MasterInformationRet", ret)
end

--徒弟领取师徒任务奖励
function MasterServlet:apprenticeReward(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "ApprenticeReward")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then return end
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	local offLineInfo = g_masterMgr:getOffLineInfo(dbid)
	if playerInfo and playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE and offLineInfo then
		local timeTick = time.toedition("day")
		if timeTick == offLineInfo:getTaskRewardTime() then
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_REWARD_FINISH, 0, {})
			return
		end
		local exp, money, bindIngot = g_masterMgr:getTaskReward(offLineInfo:getTaskID())
		if exp > 0 then
			--player:setXP(player:getXP() + exp)
			--Tlog[PlayerExpFlow]
			addExpToPlayer(player, exp, 202)
		end
		if money > 0 then
			player:setMoney(player:getMoney() + money)
			g_logManager:writeMoneyChange(dbid, "", 1, 202, player:getMoney(), money, 1)
		end
		if bindIngot > 0 then
			player:setBindIngot(player:getBindIngot() + bindIngot)
			g_logManager:writeMoneyChange(dbid, "", 4, 202, player:getBindIngot(), bindIngot, 1)
		end
		g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_REWARD_SUCCESS, 0, {})
		offLineInfo:setTaskID(0)
		offLineInfo:setTaskRewardTime(timeTick)
		offLineInfo:castOffLine2DB()
		self:pushApprenticeInformation(dbid)
	end
end

--徒弟叛师
function MasterServlet:apprenticeBetray0(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "ApprenticeBetray")
	self:apprenticeBetray(dbid)
end

function MasterServlet:apprenticeBetray(roleSID, isDelete)
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		if playerInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
			local now = os.time()
			g_masterMgr:setDoubleXP(roleSID, 0)
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_APPRENTICE_BETRAY, 0, {})
			g_masterMgr:pushExperience(roleSID, 2, now, "")
			local masterSID = playerInfo:getMasterSID()
			local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
			if masterInfo and g_masterMgr:isOnline(masterSID) then
				masterInfo:setTotalBetray(masterInfo:getTotalBetray() + 1)
				masterInfo:deleteApperntice(playerInfo:getRoleSID())
				masterInfo:cast2DB()
				self:pushMasterInformation(masterSID)
				g_masterMgr:sendErrMsg2Client(masterSID, MASTER_ERR_APPRENTICE_BETRAY2, 1, {playerInfo:getName()})
				playerInfo:setApprenticeCD(now)
				g_masterMgr:pushExperience(masterSID, 7, now, playerInfo:getName())
			else
				local offLineInfo = g_masterMgr:getOffLineInfo(masterSID)
				if offLineInfo then
					offLineInfo:addRemoveApprentice(playerInfo:getRoleSID())
					if now - offLineInfo:getOffLine() < MASTER_OFFLINE_TIME then
						playerInfo:setApprenticeCD(now)
					end
					offLineInfo:addExperience(7, now, playerInfo:getName())
				end
			end
			playerInfo:setNowProfession(MASTER_PROFESSION.NOTHING)
			playerInfo:setMasterSID("")
			g_masterMgr:removeOffLineRelated(roleSID, masterSID)
			g_masterMgr:removeOffLineRelated(masterSID, roleSID)
			if not isDelete then
				playerInfo:cast2DB()
			end
		elseif playerInfo:getNowProfession() == MASTER_PROFESSION.CAN_MASTER then
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_CANNOT_BETRAY, 0, {})
		end
	end
end

--徒弟出师
function MasterServlet:apprenticeFinish(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "ApprenticeFinish")
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo then
		if playerInfo:getLevel() >= MASTER_MIN_LEVEL and playerInfo:getNowProfession() == MASTER_PROFESSION.CAN_MASTER then
			playerInfo:apprenticeFinish()
			self:pushMasterInformation(dbid)
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_BECOME_MASTER, 0, {})
		end
	end
end

--获取拜师申请列表
function MasterServlet:masterApplyList(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "MasterApplyList")
	self:pushMasterApplyList(dbid)
end

function MasterServlet:pushMasterApplyList(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		local apprenticeList = playerInfo:getApplyApprenticeList()
		local lists = {}
		for _, apprentice in pairs(apprenticeList) do
			local list = {}
			list.roleSID = apprentice.roleSID
			list.name = apprentice.name
			list.level = apprentice.level
			list.school = apprentice.school
			list.isOnline = g_masterMgr:isOnline(apprentice.roleSID)
			table.insert(lists, list)
		end
		local ret = {}
		ret.list = lists
		fireProtoMessage(player:getID(), MASTER_SC_APPLY_LIST_RET, "MasterApplyListRet", ret)
	end
end

--设置是否接受主动拜师
function MasterServlet:masterInitiative(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterInitiative")
	if not req then return end
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo then
		playerInfo:setInitiative(req.initiative)
		playerInfo:cast2DB()
	end
end

--删除拜师申请
function MasterServlet:masterDeleteApply0(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterDeleteApply")
	if not req then return end
	local apprenticeSID = req.roleSID
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo then
		local apprenticeName = ""
		local applyApprentice = playerInfo:getApplyApprentice(apprenticeSID)
		if applyApprentice then
			apprenticeName = applyApprentice.name
		end
		g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_DELETE_APPLY, 1, {apprenticeName})
		playerInfo:deleteApplyApprentice(apprenticeSID)
		playerInfo:cast2DB()
		self:masterDeleteApply(dbid, apprenticeSID)
		g_masterMgr:sendErrMsg2Client(apprenticeSID, MASTER_ERR_DELETE_APPLY2, 1, {g_masterMgr:getPlayerNameBySID(dbid)})
		self:pushMasterApplyList(dbid)
	end
end

--师傅删除拜师申请
function MasterServlet:masterDeleteApply(roleSID, apprenticeSID)
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		playerInfo:deleteApplyApprentice(apprenticeSID)
		playerInfo:cast2DB()
	end
	local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(apprenticeSID)
	if apprenticeInfo then
		apprenticeInfo:deleteApplyMaster(roleSID)
		apprenticeInfo:cast2DB()
	else
		local offLineInfo = g_masterMgr:getOffLineInfo(apprenticeSID)
		if offLineInfo then
			offLineInfo:addRemoveApplyMaster(roleSID)
		end
	end
end

--获取徒弟的坐标
function MasterServlet:masterGetPosition(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "MasterGetPosition")
	if not player or not req then return end
	local apprenticeSID, mapID, x, y = req.roleSID, 0 , 0, 0
	local apprentice = g_entityMgr:getPlayerBySID(apprenticeSID)
	if apprentice then
		local position = apprentice:getPosition()
		mapID, x, y = apprentice:getMapID(), position.x, position.y
		local buff = LuaEventManager:instance():getLuaRPCEvent(MASTER_SC_GET_POSITION_RET)
		--徒弟不在公共地图不允许传送
		if not table.include(MASTER_COMMON_MAP_ID, mapID) then
			mapID = 0
		end
	end
	local ret = {}
	ret.mapID = mapID
	ret.x = x
	ret.y = y
	fireProtoMessage(player:getID(), MASTER_SC_GET_POSITION_RET, "MasterGetPositionRet", ret)
end

--徒弟可出师,师傅端出师
function MasterServlet:masterFinish(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterFinish")
	if not req then return end
	local apprenticeSID = req.roleSID
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if not playerInfo then
		return
	end
	local apprentices = playerInfo:getApprentice()
	if table.contains(apprentices, apprenticeSID) then
		playerInfo:setTotalFinish(playerInfo:getTotalFinish() + 1)
		playerInfo:deleteApperntice(apprenticeSID)
		playerInfo:cast2DB()
		self:pushMasterInformation(dbid)
		g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_BECOME_MASTER, 0, {})
		local player = g_entityMgr:getPlayerBySID(dbid)
		if player then
			player:setVital(player:getVital() + MASTER_FINISH_REWARD_VITAL)
			g_logManager:writeMoneyChange(dbid, "", 5, 202, player:getVital(), MASTER_FINISH_REWARD_VITAL, 1)
			g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_REWARD_SUCCESS, 0, {})
		end
		g_achieveSer:achieveNotify(dbid, AchieveNotifyType.studentOut, 1)
	end
end

--驱逐弟子
function MasterServlet:masterExpel0(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "MasterExpel")
	if not req then return end
	local apprenticeSID = req.roleSID
	self:masterExpel(dbid, apprenticeSID)
end

function MasterServlet:masterExpel(roleSID, apprenticeSID, isDelete)
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	if playerInfo then
		if not table.contains(playerInfo:getApprentice(), apprenticeSID) then
			return
		end
		playerInfo:deleteApperntice(apprenticeSID)
		playerInfo:setTotalExpel(playerInfo:getTotalExpel() + 1)
		local now = os.time()
		local apprenticeInfo = g_masterMgr:getPlayerInfoBySID2(apprenticeSID)
		if apprenticeInfo and apprenticeInfo:getNowProfession() == MASTER_PROFESSION.APPRENTICE then
			g_masterMgr:setDoubleXP(apprenticeSID, 0)
			apprenticeInfo:setNowProfession(MASTER_PROFESSION.NOTHING)
			apprenticeInfo:setMasterSID("")
			apprenticeInfo:cast2DB()
			self:pushRecommendList(apprenticeSID)
			g_masterMgr:sendErrMsg2Client(apprenticeInfo:getRoleSID(), MASTER_ERR_MASTER_EXPEL, 1, {playerInfo:getName()})
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_MASTER_EXPEL2, 1, {apprenticeInfo:getName()})
			g_masterMgr:pushExperience(apprenticeSID, 3, now, playerInfo:getName())
			g_masterMgr:pushExperience(roleSID, 5, now, apprenticeInfo:getName())
			playerInfo:setMasterCD(now)
			g_masterMgr:releaseMasterUser(roleSID)
		else
			local offLineInfo = g_masterMgr:getOffLineInfo(apprenticeSID)
			if offLineInfo then
				offLineInfo:setExpel(true)
				offLineInfo:castOffLine2DB()
				if now - offLineInfo:getOffLine() < APPRENTICE_OFFLINE_TIME then
					playerInfo:setMasterCD(now)
					g_masterMgr:releaseMasterUser(roleSID)
				end
				g_masterMgr:pushExperience(roleSID, 5, now, offLineInfo:getName())
			end
			g_masterMgr:sendErrMsg2Client(roleSID, MASTER_ERR_MASTER_EXPEL2, 1, {offLineInfo:getName()})
		end
		g_masterMgr:removeOffLineRelated(roleSID, apprenticeSID)
		g_masterMgr:removeOffLineRelated(apprenticeSID, roleSID)
		if not isDelete then
			playerInfo:cast2DB()
			self:pushMasterInformation(roleSID)
		end
	end
end

--设置师尊教诲
function MasterServlet:masterSetWord(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "MasterSetWord")
	if not req then return end
	local word = req.word
	local offLineInfo = g_masterMgr:getOffLineInfo(dbid)
	if offLineInfo then
		if #word / 3 > 100 then
			return
		end
		offLineInfo:setWord(word)
		offLineInfo:castOffLine2DB()
		g_masterMgr:sendErrMsg2Client(dbid, MASTER_ERR_SETWORD_SUCCESS, 0, {})
	end
end

--获取经历数据
function MasterServlet:masterGetExperience(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	-- self:decodeProto(pbc_string, "MasterGetExperience")
	if not player then return end
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	local totalApprentice, totalExpel, totalFlower, totalFinish, totalBetray, finalMaster, finalName, finishTime = 0, 0, 0, 0, 0, 0, "", 0
	if playerInfo then
		totalApprentice = playerInfo:getTotalApprentice()
		totalExpel = playerInfo:getTotalExpel()
		totalFlower = playerInfo:getTotalFlower()
		totalFinish = playerInfo:getTotalFinish()
		totalBetray = playerInfo:getTotalBetray()
		finalMaster = playerInfo:getFinalMaster()
		finalName = playerInfo:getFinalName()
		finishTime = playerInfo:getFinishTime()
	end
	local ret = {}
	ret.totalApprentice = totalApprentice
	ret.totalExpel = totalExpel
	ret.totalFlower = totalFlower
	ret.totalFinish = totalFinish
	ret.totalBetray = totalBetray
	ret.finalMaster = finalMaster
	ret.finalName = finalName
	ret.finishTime = finishTime
	fireProtoMessage(player:getID(), MASTER_SC_GET_EXPERIENCE_RET, "MasterGetExperienceRet", ret)
end

--请求师徒界面中徒弟的数据
function MasterServlet:apprenticeInformation(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "ApprenticeInformation")
	self:pushApprenticeInformation(dbid)
end

function MasterServlet:pushApprenticeInformation(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(roleSID)
	local offLineInfo = g_masterMgr:getOffLineInfo(roleSID)
	if playerInfo and offLineInfo then
		local masterOffLineInfo = g_masterMgr:getOffLineInfo(playerInfo:getMasterSID())
		if not masterOffLineInfo then return end
		local taskState = 1		--1：尚未发布 2：已发布 3：达成
		if masterOffLineInfo:getTaskIssue() then
			taskState = 2
		end
		if offLineInfo:getTaskFinish() then
			taskState = 3
		end
		local ret = {}
		ret.roleSID = masterOffLineInfo:getRoleSID()
		ret.name = masterOffLineInfo:getName()
		ret.level = masterOffLineInfo:getLevel()
		ret.school = masterOffLineInfo:getSchool()
		ret.isOnline = g_masterMgr:isOnline(masterOffLineInfo:getRoleSID())
		ret.taskState = taskState
		ret.taskID = g_masterMgr:getSelfTaskID(roleSID)
		ret.now = offLineInfo:getTaskProgress()
		fireProtoMessage(player:getID(), APPRENTICE_SC_INFORMATION_RET, "ApprenticeInformationRet", ret)
	end
end

--判断当前的师徒类型
function MasterServlet:masterProfession(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	-- self:decodeProto(pbc_string, "MasterProfession")
	if not player then return end
	local nowProfession = 3
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo then
		nowProfession = playerInfo:getNowProfession()
	end
	local ret = {}
	ret.nowProfession = nowProfession
	fireProtoMessage(player:getID(), MASTER_SC_PROFESSION_RET, "MasterProfessionRet", ret)
end

--获取师傅离线时间是否超过惩罚时间
function MasterServlet:masterOfflinePunish(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	-- self:decodeProto(pbc_string, "MasterOfflinePunish")
	if not player then return end
	local punish = false
	local playerInfo = g_masterMgr:getPlayerInfoBySID2(dbid)
	if playerInfo then
		local masterSID = playerInfo:getMasterSID()
		if g_masterMgr:isOnline(masterSID) then
			punish = true
		else
			local offLineInfo = g_masterMgr:getOffLineInfo(masterSID)
			if offLineInfo and os.time() - offLineInfo:getOffLine() < MASTER_OFFLINE_TIME then
				punish = true
			end
		end
	end
	local ret = {}
	ret.punish = punish
	fireProtoMessage(player:getID(), MASTER_SC_OFFLINE_PUNISH_RET, "MasterOfflinePunishRet", ret)
end

--获取徒弟离线时间是否超过惩罚时间
function MasterServlet:apprenticeOfflinePunish(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "ApprenticeOfflinePunish")
	if not req or not player then return end
	local punish = false
	local offLineInfo = g_masterMgr:getOffLineInfo(req.roleSID)
	if g_masterMgr:isOnline(req.roleSID) then
		punish = true
	elseif offLineInfo then
		local offTime = offLineInfo:getOffLine()
		if os.time() - offTime < APPRENTICE_OFFLINE_TIME then
			punish = true
		end
	end
	local ret = {}
	ret.punish = punish
	fireProtoMessage(player:getID(), APPRENTICE_SC_OFFLINE_PUNISH_RET, "ApprenticeOfflinePunishRet", ret)
end

--搜索师傅
function MasterServlet:apprenticeSearch(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "ApprenticeSearch")
	if not req or not player then return end
	local masterSID = g_masterMgr:getPlayerSIDByName(req.name)
	local flag, roleSID, masterName, school, level = 1, 0, "", 0, 0
	local masterInfo = g_masterMgr:getPlayerInfoBySID2(masterSID)
	if g_masterMgr:isOnline(masterSID) and masterInfo then
		local cdTime = masterInfo:getMasterCD()
		if (cdTime ~= 0 and os.time() - cdTime <= MASTER_PUNISH_CD) or masterInfo:getApprenticeCount() >= APPRENTICE_MAX_COUNT or
		masterInfo:getLevel() < MASTER_MIN_LEVEL then
			flag = 2
		elseif not masterInfo:getInitiative() then
			flag = 4
		else
			local master = g_entityMgr:getPlayerBySID(masterSID)
			if master then
				flag = 3
				roleSID = master:getSerialID()
				masterName = master:getName()
				school = master:getSchool()
				level = master:getLevel()
			end
		end
	end
	local ret = {}
	ret.flag = flag
	ret.roleSID = roleSID
	ret.name = masterName
	ret.school = school
	ret.level = level
	fireProtoMessage(player:getID(), APPRENTICE_SC_SEARCH_RET, "ApprenticeSearchRet", ret)
end

--获取师傅教诲
function MasterServlet:masterGetWord(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "MasterGetWord")
	if not req or not player then return end
	local masterSID = req.roleSID
	--师傅ID为0代表获取自己的教诲
	if masterSID == 0 then
		masterSID = dbid
	end
	local word = ""
	local offLineInfo = g_masterMgr:getOffLineInfo(masterSID)
	if offLineInfo then
		word = offLineInfo:getWord()
	end
	local ret = {}
	ret.word = word
	fireProtoMessage(player:getID(), MASTER_SC_GET_WORD_RET, "MasterGetWordRet", ret)
end

--任务发布
function MasterServlet:masterIssueTask(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "MasterIssueTask")
	local ret = {}
	ret.taskID = g_masterMgr:getSelfTaskID()
	fireProtoMessageBySid(dbid, MASTER_CS_ISSUE_TASK_RET, "MasterIssueTaskRet", ret)
end

--确认发布任务
function MasterServlet:masterIssueTask2(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "MasterIssueTask2")
	local offLineInfo = g_masterMgr:getOffLineInfo(dbid)
	local timeTick = time.toedition("day")
	if offLineInfo and offLineInfo:getTaskIssueTime() ~= timeTick then
		offLineInfo:setTaskIssue(true)
		offLineInfo:setTaskIssueTime(timeTick)
		offLineInfo:setUpdateDB(true)
		self:pushMasterInformation(dbid)
	end
end

function MasterServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! MasterServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function MasterServlet.getInstance()
	return MasterServlet()
end

g_masterSer = MasterServlet.getInstance()
g_eventMgr:addEventListener(MasterServlet.getInstance())