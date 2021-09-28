local changeTeamNode = function(toTeam)
	if G_MAINSCENE and G_TEAM_INFO then
		G_MAINSCENE:changeTeamNode(toTeam)
	end
	Event.Dispatch(EventName.ChangeTeamNode)
end

local changeRed = function(teamNode,hpTab)	
	for i = 1,#G_TEAM_INFO.team_data do
		for j = 1,#hpTab do
			if G_MAINSCENE and G_TEAM_INFO.team_data[i] and hpTab[j] and G_TEAM_INFO.team_data[i].roleId == hpTab[j][1] and teamNode.bar[i] then
				teamNode.bar[i]:setPercentage(hpTab[j][2])
				G_TEAM_INFO.team_data[i].curHP = hpTab[j][2]
				break
			end
		end
	end
end

local onGetTeamInfo = function(luabuffer)-------------------------------------------
	--cclog("onGetTeamInfo\n\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("TeamGetTeamInfoRetProtocol", luabuffer)
	G_TEAM_INFO.has_team = t.hasTeam
	--cclog("has_team"..tostring(G_TEAM_INFO.has_team))
	local layer=nil
	if G_TEAM_INFO.has_team==true then
		G_TEAM_INFO.teamID = t.teamId
		G_TEAM_INFO.memCnt = t.memCnt or 0
		cclog("memCnt"..G_TEAM_INFO.memCnt)
		if not G_TEAM_INFO.team_data then
			G_TEAM_INFO.team_data = {}
		end
		for i=1,G_TEAM_INFO.memCnt do
			G_TEAM_INFO.team_data[i]={}
			G_TEAM_INFO.team_data[i].roleId = t.infos[i].roleSid
			G_TEAM_INFO.team_data[i].name = t.infos[i].name
			G_TEAM_INFO.team_data[i].roleLevel = t.infos[i].roleLevel
			G_TEAM_INFO.team_data[i].sex = t.infos[i].sex
			G_TEAM_INFO.team_data[i].school = t.infos[i].school
			G_TEAM_INFO.team_data[i].actived = t.infos[i].actived   --0不在线 1在线
			G_TEAM_INFO.team_data[i].windId = t.infos[i].wingId
			G_TEAM_INFO.team_data[i].weaponId = t.infos[i].weapon
			G_TEAM_INFO.team_data[i].closeId = t.infos[i].upperBody
			G_TEAM_INFO.team_data[i].curHP = t.infos[i].curHP
			G_TEAM_INFO.team_data[i].factionName = t.infos[i].factionName
			G_TEAM_INFO.team_data[i].isFactionSame = t.infos[i].roleSid ~= userInfo.currRoleStaticId and t.infos[i].factionName ~= "" and t.infos[i].factionName == MRoleStruct:getAttr(PLAYER_FACTIONNAME)
		end
		G_TEAM_INFO.hurtAdd = t.memCount1
		G_TEAM_INFO.expAdd = t.memCount2
		G_TEAM_INFO.teamTarget = t.teamTarget
	end

	if G_MAINSCENE and G_MAINSCENE.base_node then
		if g_EventHandler["teamup"] then
			local teamupLayer = g_EventHandler["teamup"] --G_MAINSCENE.base_node:getChildByTag(104)
			if teamupLayer then
				teamupLayer:changeStatus()
			end
		elseif g_EventHandler["nearPlayer"] then
			local nearPlayer = g_EventHandler["nearPlayer"]
			if nearPlayer then
				nearPlayer:changeMem()
			end
		end
		G_MAINSCENE:updateTeamQuickEntry()
	end
	changeTeamNode()
end

local onCreateTeam = function(luabuffer)---------------------------------------------
	cclog("onCreateTeam\n\n\n")
	G_TEAM_INFO.has_team = true
	local t = g_msgHandlerInst:convertBufferToTable("TeamCreateTeamRetProtocol", luabuffer)
	G_TEAM_INFO.teamID = t.teamId
	G_TEAM_INFO.teamTarget = t.teamTarget or 1
	G_TEAM_INFO.memCnt = 1
	if not G_TEAM_INFO.team_data then
		G_TEAM_INFO.team_data = {}
	end
	local tab = t.leaderInfo
	G_TEAM_INFO.team_data[1] = {}
	G_TEAM_INFO.team_data[1].roleId = tab.roleSid		--t.roleSid
	G_TEAM_INFO.team_data[1].name = tab.name		--t.name
	G_TEAM_INFO.team_data[1].roleLevel = tab.roleLevel		--t.roleLevel
	G_TEAM_INFO.team_data[1].sex = tab.sex			--t.sex
	G_TEAM_INFO.team_data[1].school = tab.school		--t.school
	G_TEAM_INFO.team_data[1].actived = tab.actived
	G_TEAM_INFO.team_data[1].windId = tab.wingId		--t.wingId
	G_TEAM_INFO.team_data[1].weaponId = tab.weapon		--t.weapon
	G_TEAM_INFO.team_data[1].closeId = tab.upperBody		--t.upperBody
	G_TEAM_INFO.team_data[1].curHP = tab.curHP
	G_TEAM_INFO.team_data[1].factionName = tab.factionName or MRoleStruct:getAttr(PLAYER_FACTIONNAME)
	G_TEAM_INFO.team_data[1].isFactionSame = tab.roleSid ~= userInfo.currRoleStaticId and tab.factionName ~= "" and tab.factionName == MRoleStruct:getAttr(PLAYER_FACTIONNAME)

	G_TEAM_INFO.hurtAdd = 0
	G_TEAM_INFO.expAdd = 0	
	cclog("~~~~~~~~~~~~~"..tostring(G_MAINSCENE))
	if G_MAINSCENE and G_MAINSCENE.base_node then
		if g_EventHandler["teamup"] then
			local teamupLayer = g_EventHandler["teamup"] -- G_MAINSCENE.base_node:getChildByTag(104)
			if teamupLayer then
				teamupLayer:changeStatus()
			end
		elseif g_EventHandler["nearPlayer"] then
			local nearPlayer = g_EventHandler["nearPlayer"]
			if nearPlayer then
				nearPlayer:changeMem()
			end
		end
		G_MAINSCENE:updateTeamQuickEntry()
	end
	changeTeamNode()

	Event.Dispatch(EventName.OnCreateTeamRet)
end

local onTeamMemLeave = function(luabuffer)----------------------------------------
	cclog("onTeamMemLeave\n\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("TeamRemoveMemberRetProtocol", luabuffer)
	local isRemove = t.bLeave
	local memId = t.roleSid
	local eCodeId = t.eCode
	G_TEAM_INFO.hurtAdd = t.memberCount1
	G_TEAM_INFO.expAdd = t.memberCount2
	
	if not G_TEAM_INFO.memCnt then
		G_TEAM_INFO.memCnt = 0
	end
	if memId == userInfo.currRoleStaticId or G_TEAM_INFO.memCnt <= 0 then
		cclog("team data reset")
		G_TEAM_INFO.team_data={}
		G_TEAM_INFO.has_team = false
		G_TEAM_INFO.teamID = 0
		G_TEAM_INFO.memCnt = 0
		G_TEAM_INFO.hurtAdd = 0
		G_TEAM_INFO.expAdd = 0
	else
		for i=1,G_TEAM_INFO.memCnt do
			if G_TEAM_INFO.team_data[i].roleId == memId then
				table.remove(G_TEAM_INFO.team_data,i)
				break
			end
		end
		if G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt > 0 then
			G_TEAM_INFO.memCnt=G_TEAM_INFO.memCnt-1
		end
	end
	if G_MAINSCENE and G_MAINSCENE.base_node then
		if g_EventHandler["teamup"] then
			local teamupLayer = g_EventHandler["teamup"]--G_MAINSCENE.base_node:getChildByTag(104)
			if teamupLayer then
				teamupLayer:changeStatus()
			end
		elseif g_EventHandler["nearPlayer"] then
			local nearPlayer = g_EventHandler["nearPlayer"]
			if nearPlayer then
				nearPlayer:changeMem()
			end
		end
		G_MAINSCENE:updateTeamQuickEntry()
	end
	changeTeamNode()
end

local onTeamBeOperated = function(luabuffer)
	cclog("onTeamBeOperated\n\n\n")

	local t = g_msgHandlerInst:convertBufferToTable("TeamInviteTeamRetProtocol", luabuffer)
	local sourceId = t.roleId
	local teamId = t.teamId
	local isInvite = t.isInvite
	local nickName = t.name
	cclog(nickName..sourceId.."teamID"..teamId..tostring(isInvite))
	if isInvite then
		cclog(nickName.."邀请您加入队伍")
		local time = os.time()
		-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_ANSWER_INVITE,"iiib",sourceId, userInfo.currRoleStaticId, teamId, true)
		if G_TEAM_INVITE then
			table.insert(G_TEAM_INVITE,{["sourceId"] = sourceId,["teamId"] = teamId,["nickName"] = nickName,["time"] = time})
			G_MAINSCENE:ShowTeamInvite(1)
		end
	else
		-- if G_TEAM_APPLYRED then
		-- 	G_TEAM_APPLYRED[1] = true
		-- 	if G_TEAM_APPLYRED[2] then
		-- 		G_TEAM_APPLYRED[2]:setVisible(true)
		-- 	end
		-- 	G_MAINSCENE:refreshTeamRedDot(true)
		-- end
		cclog(nickName.."申请加入队伍")
		if getGameSetById(GAME_SET_TEAM_IN) == 1 then  --getGameSetById(GAME_SET_TEAM) == 1 then--getLocalRecordByKey(3,"allowTeam",true) then
			print("申请加入队伍")
			-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_ANSWER_APPLY,"iiib",userInfo.currRoleStaticId, sourceId, teamId, true  )
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_ANSWER_APPLY, "TeamAnswerApplyProtocol", {["tRoleId"] = sourceId, ["teamId"] = teamId, ["bAnswer"] = true})
		elseif G_TEAM_APPLYRED then
			G_TEAM_APPLYRED[1] = true
			if G_TEAM_APPLYRED[2] then
				G_TEAM_APPLYRED[2]:setVisible(true)
			end
			G_MAINSCENE:refreshTeamRedDot(true)		
		end
	end
end

local onTeamNewMem = function(luabuffer)-------------------------------------------
	cclog("onTeamNewMem\n\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("TeamAddNewMemberProtocol", luabuffer)
	local teamId = t.sTeamId
	G_TEAM_INFO.hurtAdd = t.hurtAdd
	G_TEAM_INFO.expAdd = t.expAdd
	-- print(teamId,memId,nickName,roleLevel,sex,"1111111222222222222222222222223333333333333333333")
	if memId ~= userInfo.currRoleStaticId and G_TEAM_INFO.teamID and G_TEAM_INFO.teamID == teamId then
		if G_TEAM_INFO.memCnt == nil or (G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt < 0) then
			G_TEAM_INFO.memCnt = 0
		end
		G_TEAM_INFO.memCnt=G_TEAM_INFO.memCnt+1
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt] = {}
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].roleId = t.info.roleSid
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].name = t.info.name 
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].roleLevel = t.info.roleLevel
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].sex = t.info.sex
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].school = t.info.school 
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].actived = t.info.actived 
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].windId = t.info.wingId
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].weaponId = t.info.weapon
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].closeId = t.info.upperBody
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].curHP = t.info.curHP
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].factionName = t.info.factionName
		G_TEAM_INFO.team_data[G_TEAM_INFO.memCnt].isFactionSame = t.info.roleSid ~= userInfo.currRoleStaticId and t.info.factionName ~= "" and t.info.factionName == MRoleStruct:getAttr(PLAYER_FACTIONNAME)
	end
	if G_MAINSCENE and G_MAINSCENE.base_node then
		if g_EventHandler["teamup"] then
			local teamupLayer = g_EventHandler["teamup"] --G_MAINSCENE.base_node:getChildByTag(104)
			if teamupLayer then
				teamupLayer:changeStatus()
				-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_GET_AOUNDPLAYER,"i",userInfo.currRoleId)
				-- g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_AOUNDPLAYER, "TeamGetAroundPlayerProtocol", {aroundType = 1})
			end
		elseif g_EventHandler["nearPlayer"] then
			local nearPlayer = g_EventHandler["nearPlayer"]
			if nearPlayer then
				nearPlayer:changeMem()
			end
		end
		G_MAINSCENE:updateTeamQuickEntry()
	end
	changeTeamNode()
end

local onJoinTeam = function(luabuffer)----------------------------------------------
	cclog("onJoinTeam\n\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("TeamJoinTeamRetProtocol", luabuffer)
	local teamID = t.teamId
	local isJoin = t.hasTeam
	if isJoin then
		G_TEAM_INFO.has_team = true
		G_TEAM_INFO.teamID = teamID
		G_TEAM_INFO.memCnt = t.memCnt
		cclog("memCnt"..G_TEAM_INFO.memCnt)
		if not G_TEAM_INFO.team_data then
			G_TEAM_INFO.team_data = {}
		end
		for i=1,G_TEAM_INFO.memCnt do
			G_TEAM_INFO.team_data[i]={}
			G_TEAM_INFO.team_data[i].roleId = t.infos[i].roleSid
			G_TEAM_INFO.team_data[i].name = t.infos[i].name
			G_TEAM_INFO.team_data[i].roleLevel = t.infos[i].roleLevel
			G_TEAM_INFO.team_data[i].sex = t.infos[i].sex
			G_TEAM_INFO.team_data[i].school = t.infos[i].school
			G_TEAM_INFO.team_data[i].actived = t.infos[i].actived   --0不在线 1在线
			G_TEAM_INFO.team_data[i].windId = t.infos[i].wingId
			G_TEAM_INFO.team_data[i].weaponId = t.infos[i].weapon
			G_TEAM_INFO.team_data[i].closeId = t.infos[i].upperBody
			G_TEAM_INFO.team_data[i].curHP = t.infos[i].curHP
			G_TEAM_INFO.team_data[i].factionName = t.infos[i].factionName
			G_TEAM_INFO.team_data[i].isFactionSame = t.infos[i].roleSid ~= userInfo.currRoleStaticId and t.infos[i].factionName ~= "" and t.infos[i].factionName == MRoleStruct:getAttr(PLAYER_FACTIONNAME)
		end
		G_TEAM_INFO.hurtAdd = t.hurtAdd
		G_TEAM_INFO.expAdd = t.expAdd
		G_TEAM_INFO.teamTarget = t.teamTarget or 1
		if G_MAINSCENE and G_MAINSCENE.base_node then
			if g_EventHandler["teamup"] then
				local teamupLayer = g_EventHandler["teamup"]--G_MAINSCENE.base_node:getChildByTag(104)
				if teamupLayer then
					teamupLayer:changeStatus()
				end
			elseif g_EventHandler["nearPlayer"] then
				local nearPlayer = g_EventHandler["nearPlayer"]
				if nearPlayer then
					nearPlayer:changeMem()
					if nearPlayer.parent:getParent() then
						nearPlayer.parent:getParent():changePage(1)
					end
				end				
			end
			G_MAINSCENE:updateTeamQuickEntry()
			G_MAINSCENE:ShowTeamInvite(2)
		end
	else
		if G_MAINSCENE and G_MAINSCENE.base_node then
			G_MAINSCENE:ShowTeamInvite(3)
		end 
	end
	changeTeamNode(true)
end

local onTeamLeaderChange = function(luabuffer)---------------------------------------------------
	cclog("onTeamLeaderChange\n\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("ChangeLeaderRetProtocol", luabuffer)
	local leaderId = t.leaderSid
	local eCode = t.eCodeId
	local isHaveApplyList = t.hasApply
	if G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt > 0 then
		for i=1,G_TEAM_INFO.memCnt do
			if G_TEAM_INFO.team_data[i].roleId == leaderId then
				local data = G_TEAM_INFO.team_data[i]
				table.remove(G_TEAM_INFO.team_data,i)
				table.insert(G_TEAM_INFO.team_data,1,data)
				break
			end
		end
	end
	if G_MAINSCENE and G_MAINSCENE.base_node and (g_EventHandler["teamup"] or g_EventHandler["nearPlayer"]) then
		if g_EventHandler["teamup"] then 
			local teamupLayer = g_EventHandler["teamup"] --G_MAINSCENE.base_node:getChildByTag(104)
			if teamupLayer then
				teamupLayer:changeStatus()
			end
			-- if userInfo.currRoleStaticId == leaderId and isHaveApplyList then
			-- 	if G_TEAM_APPLYRED and G_TEAM_APPLYRED[2] then
			-- 		G_TEAM_APPLYRED[1] = true
			-- 		G_TEAM_APPLYRED[2]:setVisible(true)
			-- 	end
			-- 	G_MAINSCENE:refreshTeamRedDot(true)
			-- end
		elseif g_EventHandler["nearPlayer"] then
			local nearPlayer = g_EventHandler["nearPlayer"]
			if nearPlayer then
				nearPlayer:changeMem()
			end
		end
		if userInfo.currRoleStaticId == leaderId and isHaveApplyList then
			if G_TEAM_APPLYRED and G_TEAM_APPLYRED[2] then
				G_TEAM_APPLYRED[1] = true
				G_TEAM_APPLYRED[2]:setVisible(true)
			end
			G_MAINSCENE:refreshTeamRedDot(true)
		elseif userInfo.currRoleStaticId ~= leaderId and G_TEAM_APPLYRED and G_TEAM_APPLYRED[1] then
			G_TEAM_APPLYRED[1] = false
			if G_TEAM_APPLYRED[2] then
				G_TEAM_APPLYRED[2]:setVisible(false)
			end
			G_MAINSCENE:refreshTeamRedDot(false)
		end
	elseif userInfo.currRoleStaticId == leaderId and isHaveApplyList then
		G_TEAM_APPLYRED[1] = true
		G_MAINSCENE:refreshTeamRedDot(true)
	elseif userInfo.currRoleStaticId ~= leaderId and G_TEAM_APPLYRED[1] then
		G_TEAM_APPLYRED[1] = false
		G_MAINSCENE:refreshTeamRedDot(false)
	end	
	changeTeamNode()
end

local isRed = function(luabuffer)
	cclog("onTeamisRed\n\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("TeamApplyIsNullProtocol", luabuffer)
	local teamID = t.teamId
	local red = t.isNull
	if red and G_TEAM_APPLYRED then
		if (G_TEAM_INFO.teamID == teamID or (not G_TEAM_INFO.has_team) ) and G_TEAM_APPLYRED[2] then
			G_TEAM_APPLYRED[2]:setVisible(false)
			G_TEAM_APPLYRED[1] = false
			G_MAINSCENE:refreshTeamRedDot(false)
		elseif G_TEAM_INFO.teamID == teamID then
			G_TEAM_APPLYRED[1] = false
			G_MAINSCENE:refreshTeamRedDot(false)
		end
	end
end

local changeTarget = function(luabuffer)
	
	cclog("changeTarget\n\n")
	local t = g_msgHandlerInst:convertBufferToTable("TeamNoticeInfo", luabuffer)	
	if G_TEAM_INFO and G_TEAM_INFO.has_team and G_TEAM_INFO.teamID == t.teamID then
		local infoType = t.infoType
		if infoType == 1 then
			if g_EventHandler["teamup"] then
				local teamupLayer = g_EventHandler["teamup"]
				teamupLayer:changeT(t.infoData)
			end
		elseif infoType == 2 then
			local teamNode = g_EventHandler["teamNode"]
			if teamNode then
				local memHP = t.memHP
				local hpTab = {}
				for i=1,#memHP do
					hpTab[i] = {t.memHP[i].roleSID,t.memHP[i].curHP}
				end
				changeRed(teamNode,hpTab)
			end
		end
	end
end

-- local captainStatus = function(luabuffer)
-- 	cclog("captainStatus\n\n\n")
-- 	local t = g_msgHandlerInst:convertBufferToTable("TeamAutoAddProtocol", luabuffer)
-- 	G_TEAM_CAPTAIN = {}
-- 	G_TEAM_CAPTAIN = {
-- 		teamID = t.teamId,
-- 		leaderID = t.leaderSid,
-- 		isAutoAdd = t.autoInvited,
-- 	}
-- 	if G_MAINSCENE and G_MAINSCENE.base_node and g_EventHandler["teamup"] then
-- 		local teamupLayer = g_EventHandler["teamup"]--G_MAINSCENE.base_node:getChildByTag(104)
-- 		if teamupLayer then
-- 			teamupLayer:changeSelect()
-- 		end
-- 	end
-- end

--[[
// COPY_SC_REQUEST_ATTEND_MULTICOPY 13083
message MultiCopyLeaderQuestAttendProtocol
{
	optional int32 copyId = 1;
}
]]
local funcScheduleEntry = nil
local scheduler = cc.Director:getInstance():getScheduler()
local function stopSchedule( ... )
	-- body
	if funcScheduleEntry then
		scheduler:unscheduleScriptEntry(funcScheduleEntry)
		funcScheduleEntry = nil
	end
end

--是否参加多人守卫，不参加就发送离队协议
local function answerCaptain( strBuffer )
	-- body
	if GetTeamCtr():isCaptain() then
		return
	end
	print("answerCaptain")
	local t = g_msgHandlerInst:convertBufferToTable("MultiCopyLeaderQuestAttendProtocol", strBuffer)
	local nCopyId = t.copyId

	GetMultiPlayerCtr():setRealCopyId(nCopyId)


	local oMyTeam = GetTeamCtr():convert2TeamObj(G_TEAM_INFO)
	if not oMyTeam then
		return
	end
	--倒计时
	local nTime = 10 --秒
	

	

	local function funcOk()
		stopSchedule()
		GetTeamNetCtr():answerCaptain(true)
	end
	local function funcCancel( ... )
		-- body
		stopSchedule()
		GetTeamNetCtr():answerCaptain(false)
	end

	local strCopyName = nil
	if nCopyId == 1 then
		strCopyName = "普通难度"
	elseif nCopyId == 2 then
		strCopyName = "困难难度"
	else
		strCopyName = "地狱难度"
	end
	--title,text,yesCallback,noCallback,yesText,noText,hasClose,countDownTime,theTime,theTimePos
	local strContent = string.format("队长 %s 发起了挑战（%s）的多人守卫副本，是否参与？", oMyTeam:getLeaderName(), strCopyName)
	local uiNode,__,___,____,uiCancelLabel = MessageBoxYesNoEx(nil, strContent, funcOk, funcCancel, nil, nil, false)
	local function countDown( ... )
		-- body
		uiCancelLabel:setString(string.format("取消(%d)", nTime))
		nTime = nTime - 1
		if nTime <= 0 then
			if uiNode.funcNo then
				uiNode.funcNo()
			end
			-- funcCancel()
		end
	end
	stopSchedule()
	funcScheduleEntry = scheduler:scheduleScriptFunc(countDown, 1, false)
end

--[[
// COPY_SC_ANSWER_ATTEND_MULTICOPY 13085
message MultiCopyAnswerToLeaderProtocol
{
	optional int32 roleSid = 1;
	optional int32 answer = 2;
}
]]
local function captainCatch( strBuffer )
	-- body
	local t = g_msgHandlerInst:convertBufferToTable("MultiCopyAnswerToLeaderProtocol", strBuffer)

	local nRoleSid = t.roleSid
	local nAnswer = t.answer
	GetTeamCtr():tagReady(nRoleSid, nAnswer)
end

g_msgHandlerInst:registerMsgHandler(TEAM_SC_GET_TEAMINFO_RET, onGetTeamInfo)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_CREATE_TEAM_RET, onCreateTeam)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_REMOVE_MEMBER_RET, onTeamMemLeave)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_ADD_NEW_MEMBER, onTeamNewMem)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_INVITE_TEAM_RET, onTeamBeOperated)--别人申请我的队伍 或者 别人邀请我加入队伍
g_msgHandlerInst:registerMsgHandler(TEAM_SC_JOIN_TEAM, onJoinTeam)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_CHANGE_LEADER_RET, onTeamLeaderChange)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_TEAM_APPLY_ISNULL, isRed)
g_msgHandlerInst:registerMsgHandler(TEAM_SC_NOTICE_TEAMINFO,changeTarget)
g_msgHandlerInst:registerMsgHandler(COPY_SC_REQUEST_ATTEND_MULTICOPY, answerCaptain)
g_msgHandlerInst:registerMsgHandler(COPY_SC_ANSWER_ATTEND_MULTICOPY, captainCatch)
-- g_msgHandlerInst:registerMsgHandler(TEAM_SC_TEAM_AUTOADD, captainStatus)