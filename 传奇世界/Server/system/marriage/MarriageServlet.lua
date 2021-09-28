--MarriageServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageServlet.lua
 --* Author:  goddard
 --* Modified: 2016年8月11日
 --* Purpose: 婚姻消息接口
 -------------------------------------------------------------------*/

require ("system.marriage.MarriageConstant")

 MarriageServlet = class(EventSetDoer, Singleton)

function MarriageServlet:__init()
	self._doer = {
			[MARRIAGE_CS_TOUR] = MarriageServlet.reqTour,
			[MARRIAGE_CS_TOUR_TASK_GIVEUP] = MarriageServlet.reqTourTaskGiveUp,
			[MARRIAGE_CS_TOUR_ANSWER] = MarriageServlet.tourAnswer,
			[MARRIAGE_CS_RECV_TASK] = MarriageServlet.recvTask,
			[MARRIAGE_CS_TOUR_TIMEOUT] = MarriageServlet.tourReqTimeout,
			[MARRIAGE_CS_TOUR_CUR_TASK] = MarriageServlet.curTask,
			[MARRIAGE_CS_TOUR_GIVEUP] = MarriageServlet.reqTourGiveUp,
			[MARRIAGE_CS_TOUR_OPT] = MarriageServlet.tourOpt,
			[MARRIAGE_CS_TOUR_TASK_FINISH] = MarriageServlet.taskFinish,
			[MARRIAGE_CS_ENTER_CEREMONY] = MarriageServlet.enterCeremony,
			[MARRIAGE_CS_ENTER_CEREMONY_CANCEL] = MarriageServlet.enterCeremonyCancel,
			[MARRIAGE_CS_QUIT_CEREMONY_BEFORE_POINT] = MarriageServlet.quitCeremonyBeforePoint,
			[MARRIAGE_CS_CEREMONY_FINI] = MarriageServlet.ceremonyFini,
			[MARRIAGE_CS_REQ_START_WEDDING] = MarriageServlet.reqStartWedding,
			[MARRIAGE_CS_WEDDING_INVITATION] = MarriageServlet.reqWeddingInvitation,
			[MARRIAGE_CS_ENTER_WEDDING_VENUE] = MarriageServlet.reqEnterWeddingVenue,
			[MARRIAGE_CS_WEDDING_INVITATION_INFO] = MarriageServlet.reqWeddingInvitationVenue,
			[MARRIAGE_CS_WEDDING_GUEST_LIST] = MarriageServlet.reqWeddingGuestList,
			[MARRIAGE_CS_WEDDING_SEND_BONUS] = MarriageServlet.reqWeddingSendBonus,
			[MARRIAGE_CS_WEDDING_KICKOUT] = MarriageServlet.reqWeddingKickout,
			[MARRIAGE_CS_WEDDING_AMBIENCE] = MarriageServlet.reqWeddingAmbience,
			[MARRIAGE_CS_WEDDING_ON_THE_CAR] = MarriageServlet.reqWeddingOnTheCar,
			[MARRIAGE_CS_WEDDING_UNDER_THE_CAR] = MarriageServlet.reqWeddingUnderTheCar,
			[MARRIAGE_CS_WEDDING_VENUE_INFO] = MarriageServlet.reqWeddingVenueInfo,
			[MARRIAGE_CS_WEDDING_PLAY] = MarriageServlet.reqWeddingPlay,
			[MARRIAGE_CS_WEDDING_BONUS_INFO] = MarriageServlet.reqWeddingBonusInfo,
			[MARRIAGE_CS_WEDDING_VENUE_TIME_INFO] = MarriageServlet.reqWeddingVenueTimeInfo,
	}
end

function MarriageServlet:isSameScreen(pos, otherPos)
	return math.abs(pos.x - otherPos.x) < 12 and math.abs(pos.y - otherPos.y) < 12
end

function MarriageServlet:checkTourContion(player, otherer)
	local marriageID = player:getMarriageID()
	local otherMarriageID = otherer:getMarriageID()
	if otherMarriageID ~= marriageID then
		if g_marriageMgr:getMarriageInfo(marriageID) or g_marriageMgr:getMarriageInfo(otherMarriageID) then
			return MarriageErrorCode.HasTourErr
		end
		player:setMarriageID("")
		otherer:setMarriageID("")
	else
		local marriage = g_marriageMgr:getMarriageInfo(marriageID)
		if not marriage then
			player:setMarriageID("")
			otherer:setMarriageID("")
		else
			if not marriage:canStartTour() then
				return MarriageErrorCode.StartTourErr
			end
		end
	end
	if (not 1 == player:getSex()) or (not 2 == otherer:getSex()) then
		return MarriageErrorCode.TourGenderErr
	end
	if player:getLevel() < MARRIAGE_MIN_LEVEL or otherer:getLevel() < MARRIAGE_MIN_LEVEL then
		return MarriageErrorCode.TourLevelErr
	end
	
	local mapid = player:getMapID()
	local otherMapid = otherer:getMapID()
	if mapid ~= otherMapid then
		return MarriageErrorCode.TourNotSameScreen
	end
	local pos = player:getPosition()
	local otherPos = otherer:getPosition()
	if not self:isSameScreen(pos, otherPos) then
		return MarriageErrorCode.TourNotSameScreen
	end
	return 0
end

--玩家客户端请求巡礼
function MarriageServlet:reqTour(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageTourReq" , pbc_string)
	if not req then
		print('MarriageServlet:reqTour '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local ret = {}
	ret.res = MarriageErrorCode.ErrorReqTour

	local teamId = player:getTeamID()
	local team = g_TeamPublic:getTeam(teamId)
	if not team then
		ret.res = MarriageErrorCode.TourNotTeam
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		return
	end
	local members = g_TeamPublic:getTeamAllMemByTeamID(teamId)
	if not members then
		ret.res = MarriageErrorCode.TourTeamErr
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		return
	end
	if 2 ~= table.size(members) then
		ret.res = MarriageErrorCode.TourTeamErr
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		return
	end

	local femaleSID = nil
	for _, id in pairs(members) do
		if id ~= roleSID then
			femaleSID = id
			break
		end
	end

	local otherer = g_entityMgr:getPlayerBySID(femaleSID)
	if not otherer then
		ret.res = MarriageErrorCode.TourTeamErr
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		return
	end

	local errCode = self:checkTourContion(player, otherer)
	if 0 ~= errCode then
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		return
	end
	local rtn = {}
	fireProtoMessage(player:getID(), MARRIAGE_SC_TOUR, 'MarriageTourRtn', rtn)
	local ask = {}
	ask.maleSID = player:getSerialID()
	fireProtoMessage(otherer:getID(), MARRIAGE_SC_TOUR_ASK, 'MarriageTourAsk', ask) --询问女方是否同意开启巡礼
end

--女方回答巡礼请求
function MarriageServlet:tourAnswer(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageTourAnswer" , pbc_string)
	if not req then
		print('MarriageServlet:MarriageTourAnswer '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local ret = {}
	ret.res = 1
	local maleSID = req.maleSID
	local male = g_entityMgr:getPlayerBySID(maleSID)
	if not male then
		fireProtoMessage(player:getID(), MARRIAGE_SC_TOUR_RESULT, 'MarriageTourResult', ret)
	end
	if 0 ~= req.res then
		fireProtoMessage(male:getID(), MARRIAGE_SC_TOUR_RESULT, 'MarriageTourResult', ret)
		return
	end
	local marriageID = player:getMarriageID()
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		marriage = g_marriageMgr:createNewMarriage(maleSID, roleSID, male, player)
	end
	if marriage and marriage:canStartTour() then
		marriage:setStatus(MarriageStatus.UnMarried)
		marriage:startTour()
		ret.res = 0
		fireProtoMessage(player:getID(), MARRIAGE_SC_TOUR_RESULT, 'MarriageTourResult', ret)
		fireProtoMessage(male:getID(), MARRIAGE_SC_TOUR_RESULT, 'MarriageTourResult', ret)
		player:setMarriageID(marriage:getMarriageID())
		male:setMarriageID(marriage:getMarriageID())
		local teamID = player:getTeamID()
		g_teamMgr:setSpeTeam(teamID, true)
	end
end

--玩家请求放弃巡礼任务
function MarriageServlet:reqTourTaskGiveUp(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageTourTaskGiveUpReq" , pbc_string)
	if not req then
		print('MarriageServlet:reqTourTaskGiveUp '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end

	marriage:giveUpTask()

	local ret = {}
	local maleSID = marriage:getMaleSID()
	local male = g_entityMgr:getPlayerBySID(maleSID)
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_TOUR_TASK_GIVEUP, 'MarriageTourTaskGiveUp', ret)
	end
	local femaleSID = marriage:getFemaleSID()
	local female = g_entityMgr:getPlayerBySID(femaleSID)
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_TOUR_TASK_GIVEUP, 'MarriageTourTaskGiveUp', ret)
	end
end

--玩家放弃巡礼
function MarriageServlet:reqTourGiveUp(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageTourGiveUpReq" , pbc_string)
	if not req then
		print('MarriageServlet:reqTourGiveUp '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local ret = {}
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		fireProtoMessage(player:getID(), MARRIAGE_SC_TOUR_GIVEUP, 'MarriageTourGiveUp', ret)
		local female = g_entityMgr:getPlayerBySID(req.femaleSID)
		if female then
			fireProtoMessage(female:getID(), MARRIAGE_SC_TOUR_GIVEUP, 'MarriageTourGiveUp', ret)
		end
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		fireProtoMessage(player:getID(), MARRIAGE_SC_TOUR_GIVEUP, 'MarriageTourGiveUp', ret)
		local female = g_entityMgr:getPlayerBySID(req.femaleSID)
		if female then
			fireProtoMessage(female:getID(), MARRIAGE_SC_TOUR_GIVEUP, 'MarriageTourGiveUp', ret)
		end
		player:setMarriageID("")
		return
	end
	local maleSID = marriage:getMaleSID()
	local male = g_entityMgr:getPlayerBySID(maleSID)
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_TOUR_GIVEUP, 'MarriageTourGiveUp', ret)
		male:setMarriageID("")
	end
	local femaleSID = marriage:getFemaleSID()
	local female = g_entityMgr:getPlayerBySID(femaleSID)
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_TOUR_GIVEUP, 'MarriageTourGiveUp', ret)
		female:setMarriageID("")
	end
	g_marriageMgr:deleteMarriage(marriageID)
	local teamID = player:getTeamID()
	g_teamMgr:setSpeTeam(teamID, true)
end

--玩家请求接收新任务
function MarriageServlet:recvTask(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSRecvTask" , pbc_string)
	if not req then
		print('MarriageServlet:recvTask '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	local ret, taskId = marriage:recvTask()
	local config = g_marriageMgr:findTaskConfig(taskId)
	if not ret or not config then
		local err = {}
		err.res = MarriageErrorCode.TourRecvTaskNoMore
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', err)
		return
	end
	local ret = {}
	ret.taskType = config.q_type
	ret.taskStep = config.q_step
	local maleSID = marriage:getMaleSID()
	local male = g_entityMgr:getPlayerBySID(maleSID)
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_TASK, 'MarriageSCTask', ret)
	end
	local femaleSID = marriage:getFemaleSID()
	local female = g_entityMgr:getPlayerBySID(femaleSID)
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_TASK, 'MarriageSCTask', ret)
	end
end

--玩家请求巡礼超时
function MarriageServlet:tourReqTimeout(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageReqTourTimeout" , pbc_string)
	if not req then
		print('MarriageServlet:tourReqTimeout '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	local ret = {}
	local maleSID = marriage:getMaleSID()
	local male = g_entityMgr:getPlayerBySID(maleSID)
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_TOUR_TIMEOUT, 'MarriageRtnTourTimeout', ret)
	end
	local femaleSID = marriage:getFemaleSID()
	local female = g_entityMgr:getPlayerBySID(femaleSID)
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_TOUR_TIMEOUT, 'MarriageRtnTourTimeout', ret)
	end
	g_marriageMgr:deleteMarriage(marriageID)
end

--玩家开始采集
function MarriageServlet:tourOpt(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageTourOpt" , pbc_string)
	if not req then
		print('MarriageServlet:tourOpt '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	marriage:tourOpt(player, req.taskId, req.step)
end

function MarriageServlet:curTask(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSCurTask" , pbc_string)
	if not req then
		print('MarriageServlet:curTask '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	local ret, taskId = marriage:curTaskID()
	if not ret then
		return
	end
	local ret = {}
	if marriage:allTourTaskFini() then
		local config = g_marriageMgr:findTaskConfig(taskId)
		ret.status = 2
		if config then
			ret.taskType = config.q_type
			ret.taskStep = config.q_step
		end
	else
		local config = g_marriageMgr:findTaskConfig(taskId)
		if config then
			ret.taskType = config.q_type
			ret.taskStep = config.q_step
			if marriage:curTaskFini() then
				ret.status = 1
			else
				ret.status = 0
			end
		else
			ret.status = 0
			ret.taskType = 0
			ret.taskStep = 0
		end
	end
	fireProtoMessage(player:getID(), MARRIAGE_SC_TOUR_CUR_TASK, 'MarriageSCCurTask', ret)
end

function MarriageServlet:taskFinish(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageTourTaskFinish" , pbc_string)
	if not req then
		print('MarriageServlet:taskFinish '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	marriage:taskFinish()
end

function MarriageServlet:enterCeremony(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSEnterCeremony" , pbc_string)
	if not req then
		print('MarriageServlet:enterCeremony '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	marriage:answerEnterCeremony(player, req.res)
end

function MarriageServlet:enterCeremonyCancel(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSEnterCeremonyCancel" , pbc_string)
	if not req then
		print('MarriageServlet:enterCeremonyCancel '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	marriage:answerEnterCeremonyCancel(player)
end

function MarriageServlet:quitCeremonyBeforePoint(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSQuitCeremonyBeforePoint" , pbc_string)
	if not req then
		print('MarriageServlet:quitCeremonyBeforePoint '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	marriage:quitCeremonyBeforePoint(player)
end

function MarriageServlet:ceremonyFini(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSCeremonyFini" , pbc_string)
	if not req then
		print('MarriageServlet:ceremonyFini '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	marriage:ceremonyFini(player)
end

function MarriageServlet:reqStartWedding(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSReqStartWedding" , pbc_string)
	if not req then
		print('MarriageServlet:reqStartWedding '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		player:setMarriageID("")
		return
	end
	local res, errCode = marriage:reqStartWedding(player, req.type)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingInvitation(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingInvitation" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingInvitation '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = req.marriageID
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end
	local res, errCode = marriage:reqWeddingInvitation(player)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqEnterWeddingVenue(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSEnterWeddingVenue" , pbc_string)
	if not req then
		print('MarriageServlet:reqEnterWeddingVenue '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end
	marriage:reqEnterWeddingVenue(player)
end

function MarriageServlet:reqWeddingInvitationVenue(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingInvitationInfo" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingInvitationVenue '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local SID = req.roleID
	local marriageID = g_marriageMgr:getMarriageIDBySID(SID)
	if "" == marriageID or not marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end
	local ret = {}
	ret.roleID = SID
	ret.marriageID = marriageID
	ret.maleName = marriage:getMaleName()
	ret.femaleName = marriage:getFemaleName()
	fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_INVITATION_INFO, 'MarriageSCWeddingInvitationInfo', ret)
end

function MarriageServlet:reqWeddingGuestList(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingGuestList" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingGuestList '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingGuestList(player)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingSendBonus(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingSendBonus" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingSendBonus '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = req.marriageID
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingSendBonus(player, req.bonus)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingKickout(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingKickOut" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingKickout '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingKickout(player, req.roleSID)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingAmbience(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingAmbience" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingAmbience '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingAmbience(player, req.ambience)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingOnTheCar(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingOnTheCar" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingOnTheCar '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingOnTheCar(player)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingUnderTheCar(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingUnderTheCar" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingUnderTheCar '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingUnderTheCar(player)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingVenueInfo(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingVenueInfo" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingVenueInfo '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = req.marriageID
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end
	marriage:reqWeddingVenueInfo(player)
end

function MarriageServlet:reqWeddingPlay(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingPlay" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingPlay '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = player:getMarriageID()
	if "" == marriageID then
		return
	end
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingPlay(player, play)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingBonusInfo(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingBonusInfo" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingBonusInfo '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = req.marriageID
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingBonusInfo(player)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet:reqWeddingVenueTimeInfo(event)
	local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("MarriageCSWeddingVenueTimeInfo" , pbc_string)
	if not req then
		print('MarriageServlet:reqWeddingVenueTimeInfo '..tostring(err))
		return
	end
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local marriageID = req.marriageID
	local marriage = g_marriageMgr:getMarriageInfo(marriageID)
	if not marriage then
		return
	end

	local res, errCode = marriage:reqWeddingVenueTimeInfo(player)
	if not res then
		local ret = {}
		ret.res = errCode
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
	end
end

function MarriageServlet.getInstance()
	return MarriageServlet()
end

--全局对象定义
g_marriageServlet = MarriageServlet.getInstance()

g_eventMgr:addEventListener(MarriageServlet.getInstance())